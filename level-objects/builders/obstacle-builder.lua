local spineStore         = require("level-objects.collections.spine-store")
local builder 		     = require("level-objects.builders.builder")
local obstacleDef        = require("level-objects.obstacle")
local poleDef            = require("level-objects.obstacle-pole")
local deathslideDef      = require("level-objects.obstacle-deathslide")
local ropeSwingDef       = require("level-objects.obstacle-ropeswing")
local electricGateDef    = require("level-objects.obstacle-electricgate")
local spaceRocketDef     = require("level-objects.obstacle-spacerocket")


-- @class special builder for ledges
local obstacleBuilder = {
	-- Methods:
	-----------
	-- newObstacleCollection()
	-- newObstacle()
	-- newPole()
	-- newSlidingPole()
	-- newRopeSwing()
	-- newDeathSlide()
	-- newElectricGate()
	-- newSpaceRocket()
	-- setupObstacleCommon()
}


-- Aliases
local new_image  = display.newImage
local new_circle = display.newCircle
local math_abs   = math.abs
local play       = realPlayer


-- Creates a new obstacleCollection
-- @param spineCollection    - ref to an existing spine collection, to add obstacles to it
-- @param movementCollection - ref to an existing move  collection, to add obstacles to it
-- @return new obstacleCollection
----
function obstacleBuilder:newObstacleCollection(spineCollection, movementCollection, particleEmitterCollection)
	local coll = builder:newMasterCollection("obstacles", spineCollection, movementCollection, particleEmitterCollection)

	--builder:deepCopy(obstacleCollection, coll)
	function coll:reset(camera)
	   	local items = self.items
		local num   = #items

		for i=1,num do
			local obstacle = items[i]

			if obstacle and obstacle ~= -1 and obstacle.inGame then
				if obstacle.isDeathSlide or obstacle.isSpaceRocket then
					obstacle:reset(camera)
				end
			end
		end
	end
	
	return coll
end


-- Generic function to create an obstacle and let its type determine whats created
-- @param camera
-- @param spec
-- @param prev - ledge
-- @return obstacleObject
----
function obstacleBuilder:newObstacle(camera, spec, prev)
    if 	   spec.type == "pole"         then	return self:newPole(camera, spec, prev)
    elseif spec.type == "slidingpole"  then return self:newSlidingPole(camera, spec, prev)
    elseif spec.type == "ropeswing"    then return self:newRopeSwing(camera, spec, prev)
    elseif spec.type == "deathslide"   then return self:newDeathSlide(camera, spec, prev)
    elseif spec.type == "electricgate" then return self:newElectricGate(camera, spec, prev)
    elseif spec.type == "spacerocket"  then return self:newSpaceRocket(camera, spec, prev)
    end
end


-- Created a new sticky pole
-- @param camera
-- @param spec
-- @param prev - ledge
-- @return new pole
----
function obstacleBuilder:newPole(camera, spec, prev)
	local image = new_image("images/obstacles/pole-standard.png", 0,0)
	return self:newPoleCommon(camera, spec, prev, image, false)
end


-- Created a new sliding pole @see newPole()
----
function obstacleBuilder:newSlidingPole(camera, spec, prev)
	local image = new_image("images/obstacles/pole-ice.png", 0,0)
	return self:newPoleCommon(camera, spec, prev, image, true)
end


-- @see newPole(), newSlidingPole()
-- @param image  - image for pole
-- @param sticky - if pole is sticky
----
function obstacleBuilder:newPoleCommon(camera, spec, prev, image, sticky)
	image.height = image.height * (spec.length / 700)

	local pole = builder:newGameObject(spec, image)

	builder:deepCopy(obstacleDef, pole)
	builder:deepCopy(poleDef, pole)

	self:setupCommonObstacle(camera, spec, prev, pole)
	
	pole.sticky = sticky

    return pole
end


-- Created a new roepswing
-- @param camera
-- @param spec
-- @param prev - ledge
-- @return obstacleObject
----
function obstacleBuilder:newRopeSwing(camera, spec, prev)
	local image = new_image("images/obstacles/ropeswing-grip.png", 0,0)
	local swing = builder:newGameObject(spec, image)

	builder:deepCopy(obstacleDef,  swing)
	builder:deepCopy(ropeSwingDef, swing)

	self:setupCommonObstacle(camera, spec, prev, swing)

	-- build center point
    swing.movement.pattern = movePatternCircular
    swing.movement.center  = new_circle(swing:x() - swing.length, swing:y() - swing.length, 7)
    swing.movement.center:setFillColor(0.25,0.25,0.25)

    swing:moveNow()
    camera:add(swing.movement.center, 3)

    return swing
end


-- Created a new deathslide
-- @param camera
-- @param spec
-- @param prev - ledge
-- @return obstacleObject
----
function obstacleBuilder:newDeathSlide(camera, spec, prev)
	local animation = spec.startAnimation or "Standard"

	local slide = builder:newSpineObject(spec, {jsonName="obstacle-deathslide", imagePath="obstacles/deathslide", scale=(spec.size or 0.4), animation=animation})

	builder:deepCopy(obstacleDef,   slide)
	builder:deepCopy(deathslideDef, slide)

    self:setupCommonObstacle(camera, spec, prev, slide)

    slide.movement  = {pattern={{slide.length[1], slide.length[2]}}, speed=slide.speed, draw=true, oneWay=true, movedX=0, movedY=0}
    slide.animSpeed = slide.animSpeed or "SLOW"
    slide.delay     = slide.delay or 1000
    slide.originX   = slide:x()
    slide.originY   = slide:y()

    -- set movement here, so its path is drawn, but then turn of isMoving so its not added to the movement collection
    slide:setMovement(camera, slide.movement)

    return slide
end


-- Created a new electric gate
-- @param camera
-- @param spec
-- @param prev - ledge
-- @return obstacleObject
----
function obstacleBuilder:newElectricGate(camera, spec, prev)
	local skin = "Blue"
    if spec.antishield then skin = "Red" end

	local gate = builder:newSpineObject(spec, {jsonName="obstacle-electric-gate", imagePath="obstacles/electric-gate", scale=(spec.size or 1), skin=skin, animation="Standard"})

	builder:deepCopy(obstacleDef,     gate)
	builder:deepCopy(electricGateDef, gate)

    self:setupCommonObstacle(camera, spec, prev, gate)

    gate.timerOff    = gate.timerOff or 2000
    gate.timerOn     = gate.timerOn  or 2000
    gate.deadly      = true     -- toggled off straight away
    gate.deadlyTimer = true     -- used by AI so they know to time the jump
    
    gate:toggleDeadlyState()

    return gate
end


-- Created a new sticky pole
-- @param camera
-- @param spec
-- @param prev - ledge
-- @return obstacleObject
----
function obstacleBuilder:newSpaceRocket(camera, spec, prev)
	local rocket = builder:newSpineObject(spec, {jsonName="obstacle-space-rocket-base", imagePath="obstacles/space-rocket", animation="Standard"})

	rocket.baseScale = rocket.scale

	builder:deepCopy(obstacleDef,    rocket)
	builder:deepCopy(spaceRocketDef, rocket)

	rocket.inPhysics = false
	rocket.moveX     = spec.x
	rocket.moveY     = spec.y
	rocket:position(prev)

	if     spec.takeoff == "fast"   then rocket.delay = 3000
	elseif spec.takeoff == "medium" then rocket.delay = 4000
	elseif spec.takeoff == "slow"   then rocket.delay = 5000 end

	-- create the cradle
	rocket.cradle = new_image("images/obstacles/space-rocket/rocket-cradle.png", rocket:x(), rocket:y()-70)
	rocket.cradle:scale(0.6, 0.6)
	rocket.cradle.rotation = spec.angle

	-- create the rocket
	rocket.ship = new_image("images/obstacles/space-rocket/rocket.png", rocket:x() - (math_abs(spec.angle)/2), (rocket:y() -150))
	rocket.ship.rotation = spec.angle

	-- modify for pointing left
	if spec.angle > 0 then  -- left
		rocket.cradle:scale(-1,1)
		rocket.ship:scale(-1,1)
		rocket.ship.x = rocket.ship.x + math_abs(spec.angle)
	end

	rocket:setPhysics(1)
	rocket.ship.object    = rocket
    rocket.ship.collision = rocket.eventCollide
    rocket.ship:addEventListener("collision", rocket.ship)

	camera:add(rocket.cradle, 2)
	camera:add(rocket.image,  2)
	camera:add(rocket.ship,   2)

	return rocket
end


-- Performs setup on a new obstacle common to all obstacles
-- @param camera
-- @param spec
-- @param prev
-- @param obstacle - just built
----
function obstacleBuilder:setupCommonObstacle(camera, spec, prev, obstacle)
	obstacle.moveX = spec.x
	obstacle.moveY = spec.y
    
    obstacle:setPhysics(camera.scaleImage)
    obstacle:position(prev)

    obstacle.image.collision = obstacle.eventCollide
    obstacle.image:addEventListener("collision", obstacle.image)

    camera:add(obstacle.image, spec.layer or 4)
end


return obstacleBuilder