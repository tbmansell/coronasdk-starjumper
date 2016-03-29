local physics     = require("physics")
local anim        = require("core.animations")
local particles   = require("core.particles")
local spineStore  = require("level-objects.collections.spine-store")


-- @class main player class
local player = {
	-- Methods:
	-----------
	-- collected()
	-- dragGearUsage()
	-- runupGearUsage()
	-- landGearUsage()
	-- jumpAction()
	-- shieldStarted()
	-- shieldExpired()
	-- freezeTimeStarted()
	-- freezeTimeExpired()
	-- reverseJumpStarted()
	-- parachuteStarted()
	-- jetpackStarted()
	-- showJetpack()
	-- gliderStarted()
	-- gliderExpired()
	-- climbLedgeStarted()
	-- negableTrajectoryStarted()
	-- negableDizzyStarted()
	-- negableBoosterStarted()
	-- negableRocketStarted()
	-- clearJumpAction()
	-- clearAnimationOverride()
	-- gearUsedUp()
}


-- Aliases:
local math_random = math.random


function player:collected(item)
    if item.collected then return end
    item.collected = true

    if item.isKey then
        self:addKey(item.color)
    end

    if item.isRing then
        self:sound("randomRing")
    else
        self:sound("collect"..item.key, item.collectedSound)
    end

    if self.main then
        hud:collect(item, self)
    elseif self.ai or self.scripted then
        if item.isGear then
            local gear = self.gear
            gear[gearSlots[item.name]] = item.name
            self:setGear(gear)
        elseif item.isNegable then
            local gear = self.gear
            gear[negableSlots[item.name]] = item.name
            self:setGear(gear)
        else
            item:collect(self:getCamera())
        end
    end
end


function player:dragGearUsage()
    if not self.main then return end

    -- check any gear activated that will be triggered by starting a jump
    local gear = self.gear[jump]

    if gear == gearTrajectory then
        self:sound("gearTrajectory")
        curve.showTrajectory = true
    elseif gear == gearFreezeTime then
        self:sound("gearFreezeTime", {duration=3000})
        self:freezeTimeStarted()
    end

    if gear == gearTrajectory or gear == gearFreezeTime then
        self:emit("usegear-green")
        self.slotInUse[jump] = true
        hud:markGearInUse(gear)
    end
end


function player:runupGearUsage(xVelocity, yVelocity)
    -- check any gear activated that will be triggered by starting a run
    -- return true if run loop should be run after, false if not
    local gear = self.gear[jump]
    
    if gear == gearSpringShoes or gear == gearFreezeTime or gear == gearShield then
        self:emit("usegear-green")

        self.slotInUse[jump] = true
        if self.main then hud:markGearInUse(gear) end

        if gear == gearFreezeTime then
            self:sound("gearAntigrav")

        elseif gear == gearShield then
            self:shieldStarted()

        elseif gear == gearSpringShoes then
            self:sound("gearSpringshoes")
            -- Spring shoes mean the player jumps from the spot
            self.mode = playerJumpStart
            self.jumpTypeHigh = true
            self:jump()
            return false
        end
    end
    return true
end


function player:landGearUsage(ledge)
    -- make sure the ledge jumped to is not the same one (we're not that mean)
    if self.jumpedFrom and ledge.id == self.jumpedFrom.id then
        -- if ledge is the same one - we still check for reversejump usage otherwise they can keep using it
        self:gearUsedUp(air, {gearReverseJump})
        return
    end

    spineStore:hideGearFlame(self:getCamera(), self)

    if self.slotInUse[jump] then self.gearUsed[jump] = true end
    if self.slotInUse[air]  then self.gearUsed[air]  = true end
    if self.slotInUse[land] then self.gearUsed[land] = true end

    -- Check for any jump gear that was in use for the jump or previous ledge that must expire on the next ledge:
    self:gearUsedUp(jump, {gearSpringShoes, gearFreezeTime,  gearTrajectory})
    self:gearUsedUp(air,  {gearJetpack,     gearGlider,      gearParachute})
    self:gearUsedUp(land, {gearGloves,      gearGrappleHook, gearDestroyer, gearMagnet})
end


-- triggered when player taps during a jump
function player:jumpAction()
    local gear = self.gear[air]

    self:destroyEmitter()

    -- Jetpack can be used multiple times per jump
    if gear == gearJetpack and self.jetpackUses > 0 then
        if self.jetpackUses == 3 then
    		self.slotInUse[air] = true
        	if self.main then hud:markGearInUse(gear) end
--            self:emit("usegear-blue", {xpos=20, ypos=-60}, true)
    	end

    	self.jetpackUses = self.jetpackUses - 1
    	self:jetpackStarted()
        self:showJetpack()

    -- Glider can be tapped while in use to stop using it
    elseif gear == gearGlider and self.gliding then
        self:gliderExpired()

    -- Parachute can be tapped while in use to stop using it
    elseif self.parachuting then
        self:parachuteExpired()

    -- Other jump gear can only be used once
    elseif gear ~= nil and self.slotInUse[air] ~= true then
    	self.slotInUse[air] = true
        if self.main then hud:markGearInUse(gear) end

        self:emit("usegear-blue", {xpos=20, ypos=-60}, true)

		if     gear == gearReverseJump then self:reverseJumpStarted()
        elseif gear == gearParachute   then self:parachuteStarted()
        elseif gear == gearGlider      then self:gliderStarted() end
    end
end


function player:shieldStarted()
    if self.shielded ~= true then
        self.shielded = true
        spineStore:showGearShield(self:getCamera(), self, {x=0, y=-60})
        self:setPhysicsFilter("addShield")
    end
end


function player:shieldExpired()
    if self.shielded then
        self.shielded = false
        self.loadedShield = false

        after(50, function()
            spineStore:hideGearShield(self:getCamera(), self)
            self:gearUsedUp(jump, {gearShield})
            self:setPhysicsFilter("removeShield")
        end)
    end
end


function player:freezeTimeStarted()
    if self.timeFrozen ~= true then
        if self.cancelGear then
            self.cancelGear.alpha = 1
        else
            -- Create an icon that allows the player to cancel freezeTime as they can do it wrong and screw things up
            local cancel = display.newImage("images/collectables/gear-jump-freezetime-cancel.png", 0, 35)
            cancel:scale(0.35,0.35)
            cancel:addEventListener("tap", cancel)
            cancel.tap = function()
                self:gearUsedUp(jump, {gearFreezeTime})
                self:freezeTimeExpired()
            end

            self.image:insert(cancel)
            self.cancelGear = cancel
        end

        globalSetLevelFreeze(true)
        self.timeFrozen = true
    end
end


function player:freezeTimeExpired()
    if self.timeFrozen == true then
        globalSetLevelFreeze(false)
        self.timeFrozen = false
        self:gearUsedUp(jump, {gearFreezeTime})
        self.cancelGear.alpha = 0
    end
end    


function player:reverseJumpStarted()
    --if self.mode == playerJump or self.mode == playerFall or self.mode == playerMissedDeath then
    local xvel, yvel = self.image:getLinearVelocity()
    local gravity    = self.image.gravityScale

    self.image:setLinearVelocity(0,0)
    self:setGravity(0)
    self:sound("gearReverseJump")

    after(1000, function()
        self:sound("gearReverseJump")
        -- add a bit more to xvel so less likely to fall off ledge
        -- ONLY if we are not also using spring shoes (as they give us an exact restart)
        -- NOTE: reverse time also doesnt use up other gear (such as spring shoes) - pretty sweet
        if self.gear[jump] ~= gearSpringShoes then
            if xvel < 0 then xvel=xvel-50 else xvel=xvel+50 end
        end

        xvel, yvel = -xvel, -yvel
        self.image:setLinearVelocity(xvel,yvel)
        self:setGravity(gravity)
    end)
    --end
end


function player:jetpackStarted()
    self:sound("gearJetpack")
    self:animate("Powerup ROCKET")

    if self.main then
        hud:useJetpackFuel() 
    end

    local scale   = self:getCamera().scaleVelocity
    local xvel, _ = self.image:getLinearVelocity()
    local yvel    = -600 * scale

    -- If player is currently moving the opposite direction to what hes facing (bounce) - switch the xvelocity
    if (xvel < 0 and self.direction == right) or (xvel > 0 and self.direction == left) then
        xvel = -xvel
    end

    self.image:setLinearVelocity(xvel, yvel)
end


function player:showJetpack()
    local flame  = self.jetPackFlame
    local trailX = 0

    if flame then
        if flame.image then
            flame:animate("Standard")
            flame:visible()
        end
    else
        local x = -16
        if self.direction == left then x = 16 end

        spineStore:showGearFlame(camera, self, {x=x, y=-53, size=0.3})
        flame = self.jetPackFlame
    end

    if flame.flipped then
        flame.image:scale(-1,1)
        flame.flipped = false
        trailX = -54
    end

    if self.direction == left then
        flame.image:scale(-1,1)
        flame.flipped = true
        trailX = 18
    end

--    self:bindEmitter("run-trail", {xpos=trailX, ypos=-55, alpha=0.75})
end


function player:parachuteStarted()
	self:sound("gearAir")
    self.skeleton:setAttachment("Back - POWER UP ATTACHMENT", "attachment-parachute-parachute")
    self:animate("Powerup PARACHUTE")
    self:setGravity(0.1)
    self.parachuting = true

    local xvel, yvel = 0, 0
    self.image:setLinearVelocity(xvel, yvel)
end


function player:parachuteExpired()
    self.parachuting = false
    self:setGravity(1)
    self.skeleton:setAttachment("Back Attachment", nil)
    self:animate("Death JUMP HIGH")
end


function player:gliderStarted()
    self:sound("gearAir")
    self.skeleton:setAttachment("Back - POWER UP ATTACHMENT", "attachment-glider-glider")
    self:animate("Powerup GLIDER")
    self:setGravity(0.1)
    self.gliding = true

    local xpos, ypos = -60, -65
    if self.direction == left then xpos, ypos = 60, -65 end

    local scale = self:getCamera().scaleVelocity
    local xvel, yvel = 400*scale, 0
    if self.direction == left then xvel = -xvel end

    self:bindEmitter("jump-trail", {xpos=xpos, ypos=ypos, alpha=0.75})
    self.image:setLinearVelocity(xvel, yvel)
end


function player:gliderExpired()
    self.gliding = false
    self:setGravity(1)
    self.skeleton:setAttachment("Back Attachment", nil)
    self:animate("Death JUMP HIGH")
end


function player:climbLedgeStarted(ledge, edge)
    if self.mode ~= playerKilled then
        self.mode = playerClimb
        self.slotInUse[land] = true

        self:emit("usegear-red")

        if self.main then self:getCamera():cancel() end
        
        self:soundLand()

        after(50, function()
            local ydiff  = ledge:topEdge(0, self:x()) - self:topEdge()
            
            if ydiff < 1 then
                -- dont allow grab
                return
            elseif ydiff > self.intHeight-30 then  -- if ydiff > 80
                self:climbLedgeLand()
                self:climbLedgeMove(ledge)
            else
                local fallDelay = 0

                if ydiff > 25 and ydiff < 50 then
                    fallDelay = 150
                elseif ydiff >= 50 then
                    fallDelay = 250
                end

                after(fallDelay, function()
                    self:climbLedgeAdjust(ledge)
                    self:climbLedgeMove(ledge)
                end)
            end
        end)
    end
end


function player:climbLedgeLand()
    self.image:setLinearVelocity(0,0)
    self:setGravity(0)
    self:animate("Start Flat Front")
end


function player:climbLedgeAdjust(ledge)
    self.image:setLinearVelocity(0,0)
    self:setGravity(0)

    local tox    = self:x()
    local ledgeX = ledge:x()
    local movex  = 60

    if tox > ledgeX then movex = -30 end

    -- if player hits ledge edge facing away from it (e.g. they bounce off something), turn them to face it
    if tox > ledgeX and self.direction == right then
        self:changeDirection()
    elseif tox < ledgeX and self.direction == left then
        self:changeDirection()
    end

    self:moveBy(movex, movey)
    self:animate("Powerup LEDGE GLOVES")
end


function player:climbLedgeMove(ledge)
    local tox = self:x()
    local toy = self:y() + (ledge:topEdge(0, tox) - self:y())

    -- Move to center of rotated edges until can calc height of edges better
    if tox < ledge:x() then
        tox = tox + (ledge:leftEdge() - tox)
    else
        tox = tox - (ledge:rightEdge() - tox)
    end

    transition.to(self.image, {time=500, x=tox, y=toy, onComplete=function()
        self:land(ledge)
        ledge:land(self)

        if self.main then self:getCamera():track() end
    end})
end


function player:negableTrajectoryStarted()
    if self.main then
        self:sound("negable")
        curve.showGrid       = false
        self.slotInUse[jump] = true
        curve:hideJumpGrid(self:getCamera())
    end
end


function player:negableDizzyStarted()
    if not self.main then return end

    local seq = anim:oustSeq("negableDizzy", self.image)
    seq:add("callbackLoop", {delay=100, loops=50, callback=function()
        hud.level:colorBackgroundsRandom()
    end})
    seq.onComplete=function()
        hud.level:colorBackgroundsRestore()
        hud:clearSlot(jump)
    end
    seq:start()

    self:sound("randomWorry")
end


function player:negableBoosterStarted()
    self:sound("gearJetpack")
    self:loop("Powerup BOOSTER")
    self.slotInUse[air]    = true
    self.negableBoosterOn  = true
end


function player:negableRocketStarted()
    self:sound("gearJetpack")
    self:loop("Powerup ROCKET")
    self.slotInUse[air]    = true
    self.negableRocketOn   = true
end


function player:clearJumpAction(leaveGravity)
    if leaveGravity == nil then self:setGravity(1) end

    self.gliding     = false
    self.parachuting = false
    self.jetpackUses = 3
    self.repeatWallCollision = nil
    
    if self.main then
        curve.showTrajectory = false
    end

    self.skeleton:setAttachment("Back - POWER UP ATTACHMENT", nil)
    self:clearAnimationOverride()
    self:freezeTimeExpired()
end


function player:clearAnimationOverride()
    self.negableRocketOn  = false
    self.negableBoosterOn = false

    if self.animationOverride ~= nil then
        self.animationOverride = nil
        self:stand()
    end
end


function player:gearUsedUp(category, gearList)
    if self.slotInUse[category] == true then
        local gear = self.gear[category]

        if self.gearDuration[category] > 0 then
            -- We can mark gear as having a duration over 1 jump, if so we reduce the duration and keep the gear active
            self.gearDuration[category] = self.gearDuration[category] - 1
            return
        end

        if negableSlots[gear] then
            self:clearAnimationOverride()
            self.slotInUse[category] = false

            if self.main then
                if gear == negTrajectory then curve.showGrid = true end
                hud:clearSlot(category)
            elseif self.ai then
                self.gear[category] = nil
                self:setGear(self.gear)
            end
        else
            for i=1,#gearList do
                if gear == gearList[i] then
                    self.slotInUse[category] = false

                    if self.main then
                        hud:useUpGear(gear) 
                    elseif self.ai then
                        self.gear[category] = nil
                        self:setGear(self.gear)
                    end
                end
            end
        end
    end
end


function player:useGrappleHook(ledge, side)
    local camera = self:getCamera()
    local hookX, offsetX, offsetY = 0, 0, -(ledge:height()/2)

    if side == right then 
        offsetX, hookX = ledge:width()/2, ledge:rightEdge()
    else
        offsetX, hookX = -(ledge:width()/2), ledge:leftEdge()
    end

    self:sound("whoosh")

    self.mode          = playerGrappling
    self.grappleJoint  = physics.newJoint("rope", ledge.image, self.image, offsetX, offsetY)
    self.grappleTarget = ledge
    self.grappleSide   = side

    self.skeleton:setAttachment("attachment-handfront-grapplegun",  nil)
    self:changeDirection()
    self:animate("Powerup GRAPPLEHOOK QUICK")

    self.grappleHook = display.newImage("images/player/grapple-hook.png", hookX, ledge:topEdge())
    self.grappleHook:scale(0.2, 0.2)

    if side == right then self.grappleHook:scale(-1,1) end
    camera:add(self.grappleHook, 2)

    local seq = anim:oustSeq("grappleHook", self.grappleJoint)
    seq:tran({maxLength=0, time=1000})
    seq.onComplete = function() self:grappleHookComplete(camera) end
    seq:start()
    
    self:destroyEmitter()
    hud:useUpGear(gearGrappleHook)
end


function player:grappleHookComplete(camera)
    if self.mode == playerGrappling then
        self.grappleJoint:removeSelf()
        self.grappleJoint = nil

        camera:remove(self.grappleHook)
        self.grappleHook:removeSelf()
        self.grappleHook = nil

        self:moveBy(0, -20)
        self.mode = playerJump

        if self.grappleLine then
            self.grappleLine:removeSelf()
            self.grappleLine = nil
        end

        self.grappleTarget = nil
    end
end


return player