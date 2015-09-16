local utils       = require("core.utils")
local anim    	  = require("core.animations")
local soundEngine = require("core.sound-engine")
local spineStore  = require("level-objects.collections.spine-store")


-- @class Base enemy class
local enemy = {

	isEnemy = true,
	class   = "enemy",
	mode    = stateActive,
	action  = actionNothing,
	-- Methods:
	-----------
	-- eventCollide()
	-- contact()
	-- lostContact()
	-- shouldAwaken()
	-- reachedRange()
	-- passedPlayer()
	-- hasReset()
	-- steal()
	-- shoot()
	-- taunt()
    -- checkDirection()
	-- checkShouldShoot()
    -- checkFiredItemsOutOfPlay()
	-- checkShouldTaunt()
}


-- Aliases:
local math_random       = math.random
local randomFrom        = utils.randomFrom
local move_item_pattern = moveItemPattern


function enemy.eventCollide(self, event)
    local enemy  = self.object
    local object = event.other.object

    if event.phase == "began" and object ~= nil and object.isPlayer then
        enemy:contact(object)
    elseif (event.phase == "ended" or event.phase == "cancelled") then
        enemy:lostContact(object)
    end
end


function enemy:contact(object)
	if self.deadly and not self.image.isSensor and object.mode ~= playerKilled then
        soundEngine:playManagedAction(self, "kill", self.killSound)

        self:intangible()
    	self:animate("Activate")
        after(1000, function() self:loop("Standard") end)

        if object.ironSkin and object.ironSkin > 0 then
            object:ironSkinCollision()
        else
            object:explode(self)
            if object.main then hud:displayMessageDied("enemy-"..self.type) end
        end

    elseif self.thief and self.stealTimer == nil and self.state ~= stateResetting and self.state ~= stateSleeping then
        self.stealTimer = timer.performWithDelay(1000, function()
            self:steal(object)
        end, 0)
    end

    if self.contactCustom then
        self:contactCustom(object)
    end
end


function enemy:lostContact(object)
    if self.stealTimer ~= nil then
        timer.cancel(self.stealTimer)
        self.stealTimer = nil
    end
end


function enemy:shouldAwaken(ledgeId, player)
    local awaken = self.behaviour.awaken

    -- If awaken is not specified then they dont wake up
    if awaken == nil then return false end

	local leftLimit  = self.startLedge.id - (awaken or 0)
	local rightLimit = self.startLedge.id + (awaken or 0)

    if ledgeId >= leftLimit and ledgeId <= rightLimit then
		if self.mode == stateSleeping or self.mode == stateWaiting then
            soundEngine:playManagedAction(self, "awaken", self.awakenSound)
			self:loop("Standard")
		end
        self.player = player
		self.mode   = stateActive
        
		if self.movement then
			self:moveNow()
		end
        return true
	end
    return false
end


function enemy:reachedRange(ledgeId)
	local leftLimit  = self.startLedge.id - self.behaviour.range
	local rightLimit = self.startLedge.id + self.behaviour.range

	if ledgeId < leftLimit or ledgeId > rightLimit then
		self.mode = self.behaviour.atRange or stateWaiting
	end
end


function enemy:passedPlayer()
    if self.image then
        soundEngine:playManagedAction(self, "miss", self.missSound)
        self:flipX()
    end
end


function enemy:hasReset()
	self.mode = self.behaviour.mode or stateWaiting
	self.isResetting = nil

	if self.stolen ~= nil and self.stolen > 0 then self.stolen = 0 end

	if self.mode == stateSleeping then
        self:pose()
		self:loop("Sleep")
	end
end


function enemy:steal(target)
    if self.isStealing == nil then
        local color = hud:selectCollectedRing()

        if color then
            self:pose()
            self:animate("Activate")
            self.isStealing = true

            after(500, function()
                soundEngine:playManagedAction(self, "kill", self.stealSound)

                local item = hud.level:generateRing(target:x(), target:y(), color)
                item.isStolen = true
                item:intangible()
                item:body("dynamic")

                -- Global HUD var used to get scale
                local scale = self:getCamera().scaleVelocity
                local xvel, yvel, dir = 100 + math_random(200), 100 + math_random(200), math_random(100)

                if dir > 50 then xvel = -xvel  end
                item:applyForce(xvel * scale, -yvel * scale)
                
                hud:lost(item)

                self.stolen = self.stolen + 1
                if self.stolen >= self.thefts then
                    self.mode = stateResetting
                end

                after(1500, function()
                    item:destroy()
                    self:loop("Standard")
                    self.isStealing = nil
                end)
            end)
        end
    end
end


function enemy:shoot()
    soundEngine:playManagedAction(self, "kill", self.shootSound)
    self:animate(self.shootAnimation)

    -- generate & fire negable after shooting animation finished
    after(600, function()
        local scale  = self:getCamera().scaleVelocity
    	local shot   = self:generateShot()
        local varies = self.shooting.velocity
    	local x, y   = self.shotVelocity.x * scale, self.shotVelocity.y * scale
    	local vx, vy = varies.varyX * scale, varies.varyY * scale

    	-- check for shooting variance
    	if vx then
    		vx = math_random(vx)
    		if math_random(100) > 50 then vx = -vx end
		end

		if vy then
    		vy = math_random(vy)
    		if math_random(100) > 50 then vy = -vy end
		end

    	if self.direction == left then x = -x end

        -- NOTE: the shot has been generated by the level, which has already added it to its master collection and generated its key
        self:bind(shot)
        -- Fire it off
    	shot.image:setLinearVelocity(x + vx, -y + vy)
	end)

    -- resume normal animation after a few seconds
    after(2000, function()
        self:pos()
        self:loop("Standard")
        self.action = actionNothing
    end)

    -- allow shooting again after a variable time
    local min = self.shootTimeMin * 1000
    local max = self.shootTimeMax - self.shootTimeMin

    after(min+(math_random(max)*1000), function() 
        self.canShoot = true
    end)
end


function enemy:taunt()
    local animation = randomFrom(self.taunts)
    self:animate(animation)

    after(4000, function()
        if self.image then
            self:pose()
            self:loop("Standard")
            self.action = actionNothing
        end
    end)

    -- allow taunting again after a variable time
    local min = self.tauntTimeMin * 1000
    local max = self.tauntTimeMax - self.tauntTimeMin

    after(min+(math_random(max)*1000), function() 
        self.canTaunt = true
    end)
end


function enemy:checkDirection(playerX)
    if self.mode ~= stateSleeping then
        if self:x() < playerX and self.direction == left then
            self.direction = right
            after(750, function() self:passedPlayer() end)

        elseif self:x() > playerX and self.direction == right then
            self.direction = left
            after(750, function() self:passedPlayer() end)
        end
    end
end


function enemy:checkShouldShoot()
    if self.canShoot and self.mode == stateActive and self.action == actionNothing and self:numBoundItems() < self.itemsMax then
        self.canShoot = false
        self.action   = actionShooting
        self:shoot()
    end
end


function enemy:checkFiredItemsOutOfPlay(floor)
    if self.canShoot then
        -- loop through all shooters bound items (shots) and check them
        local items = self.boundItems
        
        for _,item in pairs(items) do
            if item and item.image.y > floor then
                item:destroy()
            end
        end
    end
end


function enemy:checkShouldTaunt()
    if self.canTaunt and self.action == actionNothing then
        self.canTaunt = false
        self.action   = actionTaunting
        self:taunt()
    end
end


return enemy