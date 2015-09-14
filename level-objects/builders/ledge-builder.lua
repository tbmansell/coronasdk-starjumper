local builder 		  = require("level-objects.builders.builder")
local ledgeDef        = require("level-objects.ledge")
local ledgeCollection = require("level-objects.collections.ledge-collection")


-- @class special builder for ledges
local ledgeBuilder = {
	-- Methods:
	-----------
	-- newLedgeCollection()
	-- newLedge()
	-- newStartLedge()
	-- newFinishLedge()
	-- newPathLedge()
	-- makeImageLedge()
	-- makeSpineLedge()
	-- positionLedge()
	-- setupCommonLedge()
	-- setupPathLedge()
    -- setupMovementShortcuts()
    -- setupRotatedLedge()
	-- newLedgeKeylock()
}


-- Local vars:
local PI = math.pi/180

-- Aliases
local new_image  = display.newImage
local math_round = math.round
local math_floor = math.floor
local math_cos   = math.cos
local math_sin   = math.sin



-- Creates a new ledgeCollection
-- @param spineCollection    - ref to an existing spine collection, to add ledges to it
-- @param movementCollection - ref to an existing move  collection, to add ledges to it
-- @return new ledgeCollection
----
function ledgeBuilder:newLedgeCollection(spineCollection, movementCollection, particleEmitterCollection)
	local coll = builder:newMasterCollection("ledges", spineCollection, movementCollection, particleEmitterCollection)

	builder:deepCopy(ledgeCollection, coll)
    
	return coll
end


-- Fully Creates a new ledge - working out the type for you (instead of having to work out and call the specific type)
-- @param camera
-- @param spec
-- @param prev - previous jump object (for positioning)
-- @return new ledge
----
function ledgeBuilder:newLedge(camera, spec, prev)
	if spec.type == "start"  then 
		return self:newStartLedge(camera, spec)
	elseif spec.type == "finish" then
		return self:newFinishLedge(camera, spec, prev)
	else 
	    return self:newPathLedge(camera, spec, prev)
	end
end


-- Fully creates a start ledge
-- @param camera
-- @param spec
-- @return new ledge
----
function ledgeBuilder:newStartLedge(camera, spec)
    local moveX = -200
    local moveY = contentHeight - 250
    local style = spec.style or "start"

    if style == "start-middle" then
    	moveX = centerX
    end

    local image = display.newImage("levels/planet"..state.data.planetSelected.."/images/ledge-"..style..".png", moveX, moveY)
    local ledge = builder:newGameObject(spec, image)

    builder:deepCopy(ledgeDef, ledge)

    ledge.image.y = ledge.image.y + ledge.image.height/2
    ledge.moveX   = moveX
    ledge.moveY   = moveY
    ledge.points  = 0
    ledge.isStart = true

    if style == "start-middle" then
    	ledge.isMiddle = true
    end

    function ledge:setPhysics(s)
        local w,h   = (self.image.width*s)/2, (self.image.height*s)/2
        local shape = {-w,-h, w,-h, w,(35*s)-h, w-(170*s),-40*s, -w,-40*s}
        physics.addBody(self.image, "static", {density=1, friction=4, bounce=0, shape=shape})
    end

    ledge:setPhysics(1)
    self:setupCommonLedge(ledge)
    camera:add(ledge.image, 3)
    
    return ledge
end


-- Fully creates a finish ledge
-- @param camera
-- @param spec
-- @return new ledge
----
function ledgeBuilder:newFinishLedge(camera, spec, prev)
    local moveX = spec.x or 0
    local moveY = spec.y or 0
    local style = spec.style or "finish"
    local image = display.newImage("levels/planet"..state.data.planetSelected.."/images/ledge-"..style..".png", moveX, moveY)
    local ledge = builder:newGameObject(spec, image)

    builder:deepCopy(ledgeDef, ledge)

    ledge.moveX    = moveX
    ledge.moveY    = moveY
    ledge.points   = 0
    ledge.isFinish = true

	function ledge:setPhysics(s)
        local w,h   = (self.image.width*s)/2, (self.image.height*s)/2
        local shape = {-w,-h, w,-h, w,-40*s, (170*s)-w,-40*s, -w,(35*s)-h}
        physics.addBody(self.image, "static", {density=1, friction=4, bounce=0, shape=shape})
    end

    ledge:setPhysics(1)
    self:positionLedge(ledge, prev)
    self:setupCommonLedge(ledge)
    camera:add(ledge.image, 3)

    return ledge
end


-- Fully creates a ledge between the start and finish ledges
-- @param camera
-- @param spec
-- @return new ledge
----
function ledgeBuilder:newPathLedge(camera, spec, prev)

	if spineSurfaces[spec.surface] then
		ledge = self:makeSpineLedge(camera, spec)
	else
		ledge = self:makeImageLedge(camera, spec)
	end

    ledge.type     = ledge.surface
    ledge.canShake = spec.canShake or true
    ledge.moveX    = spec.x or 0
    ledge.moveY    = spec.y or 0

    ledge:setPhysics(1)
	self:positionLedge(ledge, prev)
	self:setupCommonLedge(ledge)
	self:setupPathLedge(camera, ledge)
	camera:add(ledge.image, 3)

	return ledge
end


-- Creates the base for a static (non-spine) image
-- @param camera
-- @param spec
-- @return new base ledge object - not fully formed
----
function ledgeBuilder:makeImageLedge(camera, spec)
	local image = new_image("images/ledges/"..spec.theme.."/ledge-"..spec.surface.."-"..spec.size..".png", 0,0)
	local ledge = builder:newGameObject(spec, image)

	builder:deepCopy(ledgeDef, ledge)

    function ledge:setPhysics(s)
        local stats = self:getSurfacePhysics()
        local w, h  = ((self.image.width*s)/2), ((self.image.height*s)/2)
        
        stats.shape  = {-w,-h, w,-h, w,-h/1.5, -w,-h/1.5}
        stats.filter = { groupIndex=-5 }

        physics.addBody(self.image, "static", stats)
    end
	
	return ledge
end


-- Creates the base for a spine image
-- @param camera
-- @param spec
-- @return new base ledge object - not fully formed
----
function ledgeBuilder:makeSpineLedge(camera, spec)
	local jpath = spec.theme.."/ledge-"..spec.surface
    local ipath = "ledges/"..spec.theme
    local skin  = nil

    if spec.surface == oneshot then
        skin = spec.size or "medium"
    end

	local ledge = builder:newSpineObject(spec, {jsonName=jpath, imagePath=ipath, skin=skin, animation="Standard"})
	
	builder:deepCopy(ledgeDef, ledge)
	builder:setupCustomShape(ledge, ledge:getCustomSize(1))

	function ledge:setPhysics(s)
        physics.addBody(self.image, "static", self:getPhysics(s))
    end

    if ledge.surface == electric or ledge.surface == spiked then
        ledge.timerOff    = ledge.timerOff or 5000
        ledge.timerOn     = ledge.timerOn  or 1000
        ledge.deadly      = true  -- toggled off straight away
        ledge.deadlyTimer = true  -- used by AI so they know to time the jump
        ledge:toggleDeadlyState()

    elseif ledge.surface == ramp then
        if ledge.flip == "x" then
        	ledge.rotation = 10
        else 
        	ledge.rotation = -10
        end
    end
	
	return ledge
end


-- Sets the ledge position based on its X and Y spec from the previous jump object
-- @param ledge - to position
-- @param prev  - previous ledge or obstacle
----
function ledgeBuilder:positionLedge(ledge, prev)
    if prev == nil then
        ledge:x(ledge.moveX or 0)
        ledge:y(ledge.moveY or 0)

    elseif prev.isLedge then
        -- override allows you to position from center to center of prev ledge, rather than edge
        if ledge.positionFromCenter then
            ledge:x(prev:x() + ledge.moveX)

        elseif ledge.moveX >= 0 then
            -- position ledge from left or right edge depending on if position was negative or positive
            ledge:x(prev:rightEdge() + ledge.moveX + ledge:width()/2)
        else
            ledge:x(prev:leftEdge() + ledge.moveX - ledge:width()/2)
        end

        -- position ledge always from top of last
        ledge:y(prev:topEdge() + ledge.moveY + ledge:height()/2)

    elseif prev.isPole then
        ledge:x(prev:x() + ledge.moveX)
        ledge:y(prev:bottomEdge() + ledge.moveY + ledge:height())

    elseif prev.isDeathSlide then
        ledge:x(prev:x() + prev.length[1] + ledge.moveX)
        ledge:y(prev:y() + prev.length[2] + ledge.moveY)

    elseif prev.isRopeSwing then
        ledge:x(prev.movement.center.x + ledge.moveX)
        ledge:y(prev.movement.center.y + prev.length + ledge.moveY)

    elseif prev.isElectricGate or prev.isSpaceRocket then
        ledge:x(prev:x() + ledge.moveX)
        ledge:y(prev:y() + ledge.moveY)
    end
end


-- Sets attributes and event handlers that ALL ledges require
-- @param ledge
----
function ledgeBuilder:setupCommonLedge(ledge)
	ledge.immuneWarpFields = true

    if ledge.rotation then
        ledge.image.rotation = ledge.rotation
    end

    if ledge.flip == "x" then
        self.flipXAxis = true
        -- give spine ledges a chance to load
        if spineSurfaces[ledge.surface] then
            after(1000, function() ledge.image:scale(-1,1) end)
        end
    end

    -- bind tap event to global sceneTapLedge
    ledge.image.tap = globalTapLedge
    ledge.image:addEventListener("tap", ledge.image)

    -- bind collision event to ledge collision
    ledge.image.collision = ledge.eventCollide
    ledge.image:addEventListener("collision", ledge.image)
end


-- Sets up the common part of a path ledge
-- @param camera
-- @param ledge
----
function ledgeBuilder:setupPathLedge(camera, ledge)
    if ledge.movement then
        self:setupMovementShortcuts(ledge)

        ledge.movement.draw = true
        ledge:moveNow()
    end

    if ledge.rotating then
        ledge:setRotating(ledge.rotating)
    end

    if ledge.invisible then
        ledge:setInvisible()
    end

    if ledge.keylock then
        ledge.keylockColor = ledge.keylock
    	ledge.keylock      = self:newLedgeKeylock(camera, ledge)
        ledge.isLocked     = true

        -- override destroy() to ensure keylock us destroyed, but call prev destroy after
        ledge.parentDestroy = ledge.destroy

    	function ledge:destroy(camera)
    		if self.keylock then
    			self.keylock:destroy()
    			self.keylock = nil
    		end
    		self:parentDestroy(camera)
    	end
    end

    if ledge.rotation or ledge.rotating then
        self:setupRotatedLedge(ledge)
    end
end


-- Sets up movements based on shortcut names, to save lots of repeated stuff in the levels
-- @param ledge
----
function ledgeBuilder:setupMovementShortcuts(ledge)
    local m = ledge.movement

    -- Short cuts for bobbing ledges:
    if m.bobbingPattern then
        -- NOTE: bobbing patterns should loop so they dont require reverse=true to keep things simple
        ledge.punyMover = true
        ledge.movement  = {
            pattern=m.bobbingPattern, isTemplate=true, pause=0, dontDraw=true, distance=m.distance, speed=m.speed, steering=(m.steering or steeringSmall)
        }
    end
end


-- Adds overrides to topEdge(), ledtEdge() and rightEdge() to handle rotation calculations
-- @param ledge
----
function ledgeBuilder:setupRotatedLedge(ledge)
    -- Override for top
    function ledge:topEdge(fromEdge, x)
        if self.image == nil then return 0 end
        
        if fromEdge == nil then fromEdge = 0 end

        local top = self.image.y + fromEdge

        if self.customHeight then
            top = top - (self.customHeight/2)
        else
            top = top - (self.image.height/2)
        end

        -- Currently deal with the lower ends (so dont fall through) but leave upper ends
        -- This means you can hit upper ends anywhere and it counts as a hit, but better than falling through
        if x then
            local middle   = self:x()
            local rotation = self.image.rotation

            if rotation > 0 then
                top = top + math_sin(rotation*PI) * (x-middle)
            else
                top = top - math_sin(rotation*PI) * (middle-x)
            end
        end
        
        return top
    end

    -- Override for rotated ledges
    function ledge:leftEdge(fromEdge)
        if fromEdge == nil then fromEdge = 0 end
        local left = self.image.x + fromEdge
        local dist = 0

        if self.customWidth then 
            dist = (self.customWidth/2) 
        else 
            dist = (self.image.width/2) 
        end

        left = left - math_cos(self.image.rotation*PI) * dist
        return left
    end

    -- Override for rotated ledges
    function ledge:rightEdge(fromEdge)
        if fromEdge == nil then fromEdge = 0 end
        local right = self.image.x - fromEdge
        local dist  = 0

        if self.customWidth then 
            dist = (self.customWidth/2) 
        else 
            dist = (self.image.width/2) 
        end

        right = right + math_cos(self.image.rotation*PI) * dist
        return right
    end
end


-- Creates a new keylock for a ledge
-- @param camera
-- @param ledge  - to position
-- @return new keylock spineObject
----
function ledgeBuilder:newLedgeKeylock(camera, ledge)
	local skin    = ledge.keylock.." Card"
	local keylock = builder:newSpineObject({type="keylock"}, {jsonName="ledge-keylock", imagePath="ledges", scale=0.4, skin=skin, animation="Standard"})

    keylock.inPhysics = false

    keylock:moveTo(ledge:x(), ledge:topEdge())
    camera:add(keylock.image, 4)
    
    return keylock
end


return ledgeBuilder