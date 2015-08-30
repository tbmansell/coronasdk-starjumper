local utils           = require("core.utils")
local builder         = require("level-objects.builders.builder")
local enemyDef        = require("level-objects.enemy")
local enemyCollection = require("level-objects.collections.enemy-collection")
local spineStore      = require("level-objects.collections.spine-store")


-- @class special builder for enemies
local enemyBuilder = {
	-- Methods:
	-----------
	-- newEnemyCollection()
	-- newEnemy()
    -- newEnemyBrain()
    -- newEnemyHeart()
    -- newEnemyStomach()
    -- newEnemyGreyUfo()
    -- newEnemyGreyShooter()
    -- newEnemyGreyNapper()
    -- addJetpackMovement()
}


-- Creates a new enemyCollection
-- @param spineCollection    - ref to an existing spine collection, to add enemies to it
-- @param movementCollection - ref to an existing move  collection, to add enemies to it
-- @return new enemyCollection
----
function enemyBuilder:newEnemyCollection(spineCollection, movementCollection, particleEmitterCollection)
    local coll = builder:newMasterCollection("enemies", spineCollection, movementCollection, particleEmitterCollection)

    builder:deepCopy(enemyCollection, coll)
    
    return coll
end


-- Generic function for creating a new enemy without specifying the exact one
-- @param camera
-- @param spec
-- @param x
-- @param y
-- @param ledge - to base position from
-- @return new enemy object
----
function enemyBuilder:newEnemy(camera, spec, x, y, jumpObject)
    if     spec.type == "brain"       then return self:newEnemyBrain(camera, spec, x, y, jumpObject)
    elseif spec.type == "heart"       then return self:newEnemyHeart(camera, spec, x, y, jumpObject)
    elseif spec.type == "stomach"     then return self:newEnemyStomach(camera, spec, x, y, jumpObject)
    elseif spec.type == "greyufo"     then return self:newEnemyGreyUfo(camera, spec, x, y, jumpObject)
    elseif spec.type == "greyshooter" then return self:newEnemyGreyShooter(camera, spec, x, y, jumpObject)
    elseif spec.type == "greynapper"  then return self:newEnemyGreyNapper(camera, spec, x, y, jumpObject) end
end


-- Creates a new enemy brain @see newEnemy
-- @return new brain enemy
----
function enemyBuilder:newEnemyBrain(camera, spec, x, y, jumpObject)
	local json 		= spec.theme.."/enemy-"..spec.type
	local imagePath = "enemies/"..spec.theme
	local skin 		= spec.color or nil

	local enemy = builder:newSpineObject(spec, {jsonName=json, imagePath=imagePath, scale=spec.size, skin=skin, animation="Standard"})

	builder:deepCopy(enemyDef, enemy)

	enemy.skin        = skin
    enemy.deadly      = true
    enemy.awakenSound = {sound=sounds.enemyBrain1, duration=2200}
    enemy.missSound   = {sound=sounds.enemyBrain2, duration=2300}
    enemy.killSound   = {sound=sounds.enemyBrain3, duration=2500}

    function enemy:setPhysics(scale)
        local stats = {density=1, friction=0.3, bounce=0, filter={ groupIndex=-3 } }
        local s     = enemy.size * scale
        stats.shape = {-40*s,-170*s, 140*s,-100*s, 120*s,50*s, 0,100*s, -100*s,-100*s}

        if not globalIgnorePhysicsEngine then
            physics.addBody(enemy.image, "static", stats)
        end
    end

    self:setupCommonEnemy(camera, spec, x, y, jumpObject, enemy)

	return enemy
end


-- Creates a new heart enemy @see newEnemy
-- @return new heart enemy
----
function enemyBuilder:newEnemyHeart(camera, spec, x, y, jumpObject)
	local json 		= spec.theme.."/enemy-"..spec.type
	local imagePath = "enemies/"..spec.theme
	local skin 		= spec.color or "Red"

	local enemy = builder:newSpineObject(spec, {jsonName=json, imagePath=imagePath, scale=spec.size, skin=skin, animation="Standard"})

	builder:deepCopy(enemyDef, enemy)

	enemy.skin        = skin
	enemy.thief       = true
	enemy.stolen      = 0
    enemy.thefts      = enemy.behaviour.thefts or 10
    enemy.awakenSound = {sound=sounds.enemyHeart2, duration=3000,  fadeout=500}
    enemy.missSound   = {sound=sounds.enemyHeart2, duration=30000, realPlayer=1000, fadeout=500}
    enemy.stealSound  = {sound=sounds.enemyHeart1, duration=2000}
        
    function enemy:setPhysics(scale)
        local stats = {density=1, friction=0.3, bounce=0, filter={ groupIndex=-3 }, isSensor=true }
        local s     = enemy.size * scale
        local w, h  = 100*s, 290*s
        stats.shape = {-w,-h, w,-h, w,0, -w,0}

        if not globalIgnorePhysicsEngine then
            physics.addBody(enemy.image, "static", stats)
        end
    end

    self:setupCommonEnemy(camera, spec, x, y, jumpObject, enemy)

	return enemy
end


-- Creates a new stomach enemy @see newEnemy
-- @return new stomach enemy
----
function enemyBuilder:newEnemyStomach(camera, spec, x, y, jumpObject)
	local json 		= spec.theme.."/enemy-"..spec.type
	local imagePath = "enemies/"..spec.theme

	local enemy = builder:newSpineObject(spec, {jsonName=json, imagePath=imagePath, scale=spec.size, animation="Standard"})

	builder:deepCopy(enemyDef, enemy)

	enemy.canShoot       = true
    enemy.constrainAxis  = true
    enemy.inPhysics 	 = false
    enemy.shootTimeMin   = enemy.shooting.minWait      or 4  -- seconds
    enemy.shootTimeMax   = enemy.shooting.maxWait      or 8  -- seconds
    enemy.itemsMax       = enemy.shooting.itemsMax     or 1
    enemy.ammo           = enemy.shooting.ammo         or {negDizzy}
    enemy.shotVelocity   = {x=enemy.shooting.velocity.x or 300, y=enemy.shooting.velocity.y or 600}
    enemy.shootAnimation = "Spit"
    enemy.awakenSound    = {sound=sounds.enemyStomach1, duration=4000}
    enemy.missSound      = enemy.awakenSound
    enemy.shootSound     = {sound=sounds.enemyStomach2, duration=1000}

    function enemy:generateShot()
        return hud.level:generateNegable(self:x(), self:y()-120, utils.randomFrom(self.ammo))
	end

    function enemy:contactCustom(object)
        after(1500, function()
            enemy.image.angularVelocity = 0
            enemy.image:setLinearVelocity(0,0)
            enemy.image.rotation = 0
            enemy.mode = stateResetting
        end)
    end

    self:setupCommonEnemy(camera, spec, x, y, jumpObject, enemy)

	return enemy
end


-- Creates a new grey ufo enemy @see newEnemy
-- @return new grey ufo enemy
----
function enemyBuilder:newEnemyGreyUfo(camera, spec, x, y, jumpObject)
	local json 		= spec.theme.."/enemy-"..spec.type
	local imagePath = "enemies/"..spec.theme.."/greyufo"

    local enemy = builder:newSpineObject(spec, {jsonName=json, imagePath=imagePath, scale=spec.size, animation="Standard"})

    builder:deepCopy(enemyDef, enemy)

    enemy.deadly = true
    enemy:flipX()  -- Ian created these facing the opposite way from planet1 enemies

    function enemy:setPhysics(scale)
        local stats = {density=1, friction=0.3, bounce=0, filter={ groupIndex=-3 }, isSensor=true }
        local s     = enemy.size * scale
        local w, h  = 85*s, 200*s
        stats.shape = {-w,-h, w,-h, w,0, -w,0}

        if not globalIgnorePhysicsEngine then
            physics.addBody(enemy.image, "static", stats)
        end
    end

    self:setupCommonEnemy(camera, spec, x, y, jumpObject, enemy)

	return enemy
end


-- Creates a new grey shooter enemy @see newEnemy
-- @return new grey shooter enemy
----
function enemyBuilder:newEnemyGreyShooter(camera, spec, x, y, jumpObject)
	local json 		= spec.theme.."/enemy-greyother"
	local imagePath = "enemies/"..spec.theme.."/greyother"
	local skin      = "shooter"

    local enemy = builder:newSpineObject(spec, {jsonName=json, imagePath=imagePath, scale=spec.size, skin=skin, animation="Standard"})

    builder:deepCopy(enemyDef, enemy)

    enemy.inPhysics 	 = false
    enemy.skin           = skin
    -- shooting:
    enemy.canShoot       = true
    enemy.shootTimeMin   = enemy.shooting.minWait  or 4  -- seconds
    enemy.shootTimeMax   = enemy.shooting.maxWait  or 8  -- seconds
    enemy.itemsMax       = enemy.shooting.itemsMax or 1
    enemy.ammo           = enemy.shooting.ammo     or {negDizzy}
    enemy.shotVelocity   = {x=enemy.shooting.velocity.x or 700, y=enemy.shooting.velocity.y or 200}
    enemy.shootAnimation = "Shooter-shoot"
    -- taunting:
    enemy.canTaunt       = true
    enemy.tauntTimeMin   = 5  -- seconds
    enemy.tauntTimeMax   = 10 -- seconds
    enemy.taunts         = {"Taunt-2", "Taunt-3"}
    
    enemy:flipX()
    self:addJetpackMovement(camera, enemy, {x=-20, y=-6, rotation=20, size=0.2})

    function enemy:generateShot()
        local x = self:x()-70
        if self.direction == right then x = self:x()+70 end

        return hud.level:generateNegable(x, self:y()-50, utils.randomFrom(self.ammo))
    end

    self:setupCommonEnemy(camera, spec, x, y, jumpObject, enemy)

	return enemy
end


-- Creates a new grey kidnapper enemy @see newEnemy
-- @return new grey kidnapper enemy
----
function enemyBuilder:newEnemyGreyNapper(camera, spec, x, y, jumpObject)
	local json 		= spec.theme.."/enemy-greyother"
	local imagePath = "enemies/"..spec.theme.."/greyother"

    local enemy = builder:newSpineObject(spec, {jsonName=json, imagePath=imagePath, scale=spec.size, skin=spec.skin, animation="Standard"})

    builder:deepCopy(enemyDef, enemy)

    enemy.canTaunt     = true
    enemy.tauntTimeMin = 5  -- seconds
    enemy.tauntTimeMax = 10 -- seconds
    enemy.taunts       = {"Taunt-1", "Taunt-2", "Taunt-3"}
    
    enemy:flipX()
    self:addJetpackMovement(camera, enemy, {x=-20, y=-6, rotation=20, size=0.2})

    function enemy:setPhysics(scale)
        local stats = {density=1, friction=0.3, bounce=0, filter={ groupIndex=-3 }, isSensor=true }
        local s     = enemy.size * scale
        local w, h  = 50*s, 240*s
        stats.shape = {-w,-h/2, w,-h/2, w,h/2, -w,h/2}

        if not globalIgnorePhysicsEngine then
            physics.addBody(enemy.image, "static", stats)
        end
    end

    function enemy:contactCustom(object)
        if not self.timeOver then
            self.timeOver = true
            self.mode     = stateResetting

            self:stop()
            self.skeleton:setAttachment("Item-in-hand", nil)
            self:loop("Fly-off")
            self:showFlame()

            after(50, function()
                physics.removeBody(self.image)
                physics.addBody(self.image, "dynamic", {density=1, friction=0.3, bounce=0, filter={ groupIndex=-3 }, isSensor=true})
                
                local xvel = -200
                if self.direction == right then xvel = 200 end

                self:setGravity(0)
                self:applyForce(xvel,-200)

                if self.skin == "ring-stealer" then
                    hud.level:generateRing(object:x(), object:y(), pink)
                elseif self.skin == "fuzzy-napper" then
                    hud.level:generateFuzzy(object:x(), object:y(), "White")
                end

                after(3000, function()
                    if self.image then
                        spineStore:hideGearFlame(self:getCamera(), self)
                        self:destroy()
                    end
                end)
            end)
        end
    end

    self:setupCommonEnemy(camera, spec, x, y, jumpObject, enemy)

	return enemy
end


-- Sets up an already created enemy with common attributes
-- @param enemy - the new enemy
----
function enemyBuilder:setupCommonEnemy(camera, spec, x, y, jumpObject, enemy)
	enemy.startLedge  = jumpObject
	enemy.direction   = enemy.direction or left
    enemy.behaviour   = enemy.behaviour or {}
    enemy.shooting    = enemy.shooting  or {}

    if enemy.inPhysics then
		enemy:setPhysics(1)
	end

    if enemy.direction == right then
    	enemy:changeDirection(right)
    end

    if enemy.behaviour and enemy.behaviour.mode then
    	enemy.mode = enemy.behaviour.mode

		if enemy.mode == stateSleeping then
			enemy:loop("Sleep")
		end
	end

    if enemy.movement then
        enemy.movement.originalX = spec.x
        enemy.movement.originalY = spec.y
        
        if enemy.mode ~= stateSleeping and enemy.mode ~= stateWaiting then
            enemy:moveNow()
        end
    end

	enemy:moveTo(spec.x + x, spec.y + y)

    enemy.image.collision = enemy.eventCollide
    enemy.image:addEventListener("collision", enemy.image)

	camera:add(enemy.image, 2)
end


-- Hooks into the next movement start to fire a flame on a jetpack
-- @param enemy
----
function enemyBuilder:addJetpackMovement(camera, enemy, params)

    -- Creates a new flame and attaches to the enemy, so next time it can just be made visisble
    function enemy:showFlame()
        if self.jetPackFlame then
            if self.jetPackFlame.image then
                self.jetPackFlame:animate("Standard")
                self.jetPackFlame:visible()
            end
        else
            spineStore:showGearFlame(camera, self, params)
        end

        after(1000, function() 
            if self.jetPackFlame and self.jetPackFlame.image then
                self.jetPackFlame:hide()
            end
        end)
    end

    function enemy:reachedPatternPoint()
        self:showFlame()
    end

    function enemy:pauseMovementFinished()
        if self.pauseMovementHandle ~= nil then 
            self.pauseMovementHandle = nil
        end
        self:showFlame()
    end

end


return enemyBuilder