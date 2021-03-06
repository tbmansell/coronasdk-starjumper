local particles   = require("core.particles")
local soundEngine = require("core.sound-engine")


-- @class foundation gameObject
local gameObject = {

    key           = nil,
	--  the id is used to differantiate instances of the same class and type for collections
	id            = 0,
	-- the class is used to determine the top most (most derived) class of the object is
	class         = "gameObject",
	-- the image property holds the actual image:
	image         = nil,
	-- true if object has a physics shape, false if not
	inPhysics     = true,
    -- set to true when destroy() is called
    isDestroyed   = false,
    -- the reverse of isDestroyed: starts true and set t`o false when destroy() is called
    inGame        = true,

    -- reference to a ledge object which this object is bound to (moves with)
    attachedLedge = nil,
    -- reference to another (non ledge) object which this object is bound to (eg. shots from an enemy)
    attachedOther = nil,
    -- list of other objects which are bound to this object
    boundItems    = {},
    -- list of other objects this object is to be bound to, once it's full key has been created - by the first key() call from adding to a master collection
    bindQueue     = {},
    -- list of references to collections this object is in: stored as {[name] = {id, ref}, }
    collections   = {},
    -- each type of object has a collection dedicated to it so we have a direct ref for shared info (eg. ledgeCollection for ledge)
    master        = nil,
    
	-- used to mark that scaling has been using to flip the object, so when in-game scaling it wont get lost
    flipYAxis     = false,
    flipXAxis     = false,
    
    -- used for when an object is scaled to beign with, when scaling further this needs to be taken into account
	-- NOTE: this only matters for non-spine items using xScale or scale as in-game scaling will overwrite it
    originalScale = 1,
    scaled        = 1,

    -- Methods:
    -----------
    -- setPhysics()
    -- generateKey()
    -- destroy()
    -- bind()
    -- queueBind()
    -- release()
    -- numBoundItems()
    -- detachFromLedge()
    -- detachFromOther()
    -- scaleNumber()
    -- x()
    -- y()
    -- pos()
    -- moveBy()
    -- moveTo()
    -- width()
    -- height()
    -- leftEdge()
    -- rightEdge()
    -- topEdge()
    -- bottomEdge()
    -- flipX()
    -- flipY()
    -- solid()
    -- intangible()
    -- setGravity
    -- body()
    -- visible()
    -- hide()
    -- rotate()
    -- applyForce()
    -- applySpin()
    -- getForce()
    -- getCamera()
    -- scale()
    -- distanceFrom()
    -- jumpLeft()
    -- jumpRight()
    -- jumpTop()
    -- setMovement()
    -- setBobbingMovement()
    -- move()
    -- stop()
    -- pauseMovement()
    -- pauseMovementFinished()
    -- movementCompleted()
    -- scaleMovement()
    -- scaleCircularMovement()
    -- removeCircularPath()
    -- scalePatternMovement()
    -- scalePatternPath()
    -- removePatternPath()
    -- emit()
    -- bindEmitter()
    -- sound()
    -- constantSoundHandler()
}


-- Aliases:
local math_round = math.round
local draw_point = drawMovingPathPoint
local new_circle = display.newCircle


-- @hook: override this if the object has a physics shape
function gameObject:setPhysics(scale) end


-- Generates the full unique identifier for this object, which is made up from:
-- 1. class: main class of the object (eg. ledge, enemy, collectable, scenery)
-- 2. type:  specific type of the object (eg. brain, ufoshooter, electric-ledge, spiked scenery)
-- 3. id:    numeric sequence provided to this object by adding it to a master collection
--
-- NOTE:  Once this function is called it also binds to all other objects it was queued to
-- NOTE2: If this function is called more than once it will NOT generate the key again
--
-- @param  id     - the new id to set
-- @return string - object key
----
function gameObject:generateKey(id)
	if not self.key then
        self.id  = id
    	self.key = self.class.."_"..self.type.."_"..self.id

        -- Once a key has been generated: bind this object to any other objects currently queued
        local num = #self.bindQueue
        for i=1,num do
            self.bindQueue[i]:bind(self)
        end
        self.bindQueue = {}
    else
        print("Warning: generateKey() already called on: "..self.key.." new id sent is "..id)
    end
    return self.key
end


-- Destroys this object and removes itslef from all collections
-- @param camera            - optional - if passed will remove itself from the camera
-- @param destroyBoundItems - true if any bound items to this one should be destroyed
----
function gameObject:destroy(camera, destroyBoundItems)
    self:destroyEmitter()
    self:detachFromLedge()
    self:detachFromOther()
    self:detachFromObstacle()

	-- Releases all this object's bound objects
    if self.boundItems then
        for key,object in pairs(self.boundItems) do
            if object.image then
                self:release(object)

                if destroyBoundItems and not object.isPlayer then
                    object:destroy()
                end
            end
        end
    end

    if self.timerRotatingHandle then
        timer.cancel(self.timerRotatingHandle)
        self.timerRotatingHandle = nil
    end

    if self.timerAnimationHandle then
        timer.cancel(self.timerAnimationHandle)
        self.timerAnimationHandle = nil
    end

    if camera then
        camera:remove(self.image)
    end

    if self.movement and self.movement.center then
        if camera then camera:remove(self.movement.center) end
        self.movement.center:removeSelf()
        self.movement.center = nil
    end

    if self.image and self.image.removeSelf then
        self.image:removeSelf()
    end

    self.image 	     = nil
    self.boundItems  = nil
    self.isDestroyed = true
    self.inGame      = false

    -- remove itself from all collections its currently in (collection does the work, the object just triggers the action)
    if self.collections then
        for _,collection in pairs(self.collections) do
        	if collection.ref then
        		collection.ref:remove(self)   -- this ref to collection removed by collection
        	end
        end
    end

    -- remove itself from its master collection
    if self.master then
    	self.master:remove(self)   -- this ref to collection removed by collection
    end

    self.collections = nil
end


-- Binds another object to this one
-- @param object to bind
----
function gameObject:bind(object)
    --print("**bind** "..tostring(object.key).." to "..tostring(self.key))
    self.boundItems[object.key] = object

    if self.isLedge then
        object.attachedLedge = self
    elseif self.isObstacle then
        object.attachedObstacle = self
    else
        object.attachedOther = self
    end
end


-- Sticks an object in the queue to bind to, when generateKey() is called
-- @param object - that this object will be bound to
----
function gameObject:queueBind(object)
    self.bindQueue[#self.bindQueue+1] = object
end


-- Frees another object from being bound to this one
-- @param object to release
----
function gameObject:release(object)
    if self.boundItems then
        self.boundItems[object.key] = nil
    end

    if self.isLedge then
        object.attachedLedge = nil

    elseif self.isObstacle then
        object.attachedObstacle = nil
        
        if object.isPlayer then
            self.player = nil
        end
    else
        object.attachedOther = nil
    end
end


-- Gets number of bound items
-- @return int
----
function gameObject:numBoundItems()
    local num=0

    for key,object in pairs(self.boundItems) do
        if object then 
            num = num + 1 
        end
    end
    return num
end


-- Free this object from its bound ledge
function gameObject:detachFromLedge()
    if self.attachedLedge then
        self.attachedLedge:release(self)   	-- release will nil this objects reference
    end
end


-- Free this object from its bound other object
function gameObject:detachFromOther()
    if self.attachedOther then
        self.attachedOther:release(self)	-- release will nil this objects reference
    end
end


-- Free this object from its bound other object
function gameObject:detachFromObstacle()
    if self.attachedObstacle then
        self.attachedObstacle:release(self)    -- release will nil this objects reference
    end
end


-- Determines if the object passed is bound to this object
-- @return true if bound
----
function gameObject:isBound(object)
    return (self.boundItems[object.key] ~= nil)
end


function gameObject:scaleNumber(number)
    if number then 
        return number * self.scaled 
    else 
        return 0 
    end
end


function gameObject:x(x)
    if self.image then
        if x then 
        	self.image.x = x
        else
        	return self.image.x
        end
    end
end


function gameObject:y(y)
    if self.image then
        if y then 
        	self.image.y = y
        else
        	return self.image.y
        end
    end
end


function gameObject:pos()
    if self.image then
        return self.image.x, self.image.y
    else
        return 0, 0
    end
end


function gameObject:moveBy(x, y)
    if self.image then
        if x then self.image.x = self.image.x + x end
        if y then self.image.y = self.image.y + y end
    end
end


function gameObject:moveTo(x, y)
    if self.image then
        if x then self.image.x = x end
        if y then self.image.y = y end
    end
end


function gameObject:width()
    if self.image then
        return self.image.width * (self.originalScale or 1) * self.scaled
    else
        return 0
    end
end


function gameObject:height()
    if self.image then
        return self.image.height * (self.originalScale or 1) * self.scaled
    else
        return 0
    end
end


function gameObject:leftEdge(fromEdge)
    if self.image then
        return self.image.x - (self:width()/2) + self:scaleNumber(fromEdge)
    else
        return 0
    end
end


function gameObject:rightEdge(fromEdge)
    if self.image then
        return self.image.x + (self:width()/2) - self:scaleNumber(fromEdge)
    else
        return 0
    end
end


function gameObject:topEdge(fromEdge)
    if self.image then
        return self.image.y - (self:height()/2) + self:scaleNumber(fromEdge)
    else
        return 0
    end
end


function gameObject:bottomEdge(fromEdge)
    if self.image then
        return self.image.y + (self:height()/2) - self:scaleNumber(fromEdge)
    else
        return 0
    end
end


function gameObject:flipX()
    if self.image then
        self.flipXAxis = true
        self.image:scale(-1,1)
    end
end


function gameObject:flipY()
    if self.image then
        self.flipYAxis = true
        self.image:scale(1,-1)
    end
end


function gameObject:solid()
    if self.image then
        self.image.isSensor = false
    end
end


function gameObject:intangible()
    if self.image then
        self.image.isSensor = true
    end
end


function gameObject:setGravity(gravityScale)
    if self.image then
        self.image.gravityScale = gravityScale or 1
    end
end


function gameObject:body(type)
    if self.image then
        self.image.bodyType = type
    end
end


function gameObject:visible(alpha)
    if self.image then
	   self.image.alpha = alpha or 1
    end
end


function gameObject:hide()
    if self.image then
	   self.image.alpha = 0
    end
end


function gameObject:rotate(rotation)
    if self.image then
        self.image.rotation = rotation
    end
end


function gameObject:isRotated()
    return (self.image.rotation ~= nil and self.image.rotation ~= 0)
end


function gameObject:applyForce(velx, vely)
    if self.image then
        self.image:setLinearVelocity(velx, vely)
    end
end


function gameObject:applySpin(spin)
    if self.image then
        self.image.angularVelocity = spin
    end
end


function gameObject:getForce()
    return self.image:getLinearVelocity()
end


function gameObject:pose()
    self.skeleton:setToSetupPose()
end


-- Function intended to encapulate objects from getting access to the viewport camera (for adding items or scaling)
-- In one place: rather than litter the code with different methods.
-- NOTE: this relies on the scene creating a global object called: cameraHolder and putting a camera reference to it
-- @return camera
----
function gameObject:getCamera()
    if cameraHolder == nil or cameraHolder.camera == nil then
        print("ERROR: no cameraHolder created with a camera reference")
    end
    return cameraHolder.camera
end


function gameObject:scale(camera)
    local scale = camera.scaleImage
    local move  = camera.scalePosition

    if self.image then
        self.scaled = scale

        --[[if self.isPlayer then 
            print("player pre-scale:  "..self:x().." ledge: "..self.attachedLedge:x())
        end]]


        local xvel, yvel = 0, 0
        local scaleImage = scale * (self.originalScale or 1)

        if self.inPhysics then
            xvel, yvel = self.image:getLinearVelocity()
            physics.removeBody(self.image)
        end

        if self.customWidth then
            self.preScaleWidth  = self.customWidth
            self.preScaleHeight = self.customHeight
        else
            self.preScaleWidth  = self.image.width
            self.preScaleHeight = self.image.height
        end

        self.image.xScale = scaleImage
        self.image.yScale = scaleImage

        if self.flipXAxis then self:flipX() end
        if self.flipYAxis then self:flipY() end

        self.image.x = self.image.x * move
        self.image.y = self.image.y * move

        if self.inPhysics then self:setPhysics(scale) end

        -- check if we need to scale movement:
        if self.movement and (self.movement.draw or self.isMoving) then
            self:scaleMovement(camera)
        end

        -- add velocity back in before recreation
        if xvel ~= 0 or yvel ~= 0 then
            self.image:setLinearVelocity(xvel, yvel)
        end

        --[[if self.isPlayer then 
            print("player post-scale: "..self:x().." ledge: "..self.attachedLedge:x())
        end]]
    end
end


-- used for pathFinder jump distances
function gameObject:distanceFrom(to)
    local xdist, ydist = 0, math_round(to:jumpTop() - self:jumpTop())

    if self:x() < to:x() then
        xdist = math_round(to:jumpLeft()  - self:jumpRight())
    else
        xdist = math_round(to:jumpRight() - self:jumpLeft())
    end

    return xdist, ydist
end


-- used for pathFinder jump distances: objects need to override these
function gameObject:jumpTop()   return self:topEdge()   end
function gameObject:jumpLeft()  return self:leftEdge()  end
function gameObject:jumpRight() return self:rightEdge() end


-- Sets up this objects movement pattern, but does not make it move now: @see move() for that
-- @param camera   - optional
-- @param movement - optional movement spec - if not supplied, uses item.movment property
-- @param drawPath - optional true to draw the movement path
----
function gameObject:setMovement(camera, movement, drawPath)
    camera        = camera   or self:getCamera()
    self.movement = movement or self.movement

    -- for circular movement:
    if self.movement.pattern == movePatternCircular and self.movement.center == nil then
        local length = self.length or self.movement.distance
        local center = new_circle(self:x() - length, self:y() - length, 5)
        center.alpha = 0
        camera:add(center, 3)

        self.movement.center = center
    end
   
    setupMovingItem(self)

    -- disable draw here for any object that has specified dontDraw
    if self.movement.dontDraw then
        self.movement.draw = false
    end
    
    self:scaleMovement(camera)
end


-- Sets up movements based on shortcut names, to save lots of repeated stuff in the levels
-- @param ledge
----
function gameObject:setBobbingMovement()
    local m = self.movement

    -- Short cuts for bobbing ledges:
    if m.bobbingPattern then
        -- NOTE: bobbing patterns should loop so they dont require reverse=true to keep things simple
        self.punyMover = true
        self.movement  = {
            pattern=m.bobbingPattern, isTemplate=true, pause=0, dontDraw=true, distance=m.distance, speed=m.speed, steering=(m.steering or steeringSmall)
        }
    end
end


-- Puts the object in its masters movement collection - to start it moving if setMovement() has been called
----
function gameObject:move()
    if self.movement then
        self.isMoving = true
        
        if self.master then
            self.master:addToMovementCollection(self)
        end
    end
end


-- Traditionally: you called setMovement() then move() to do the full move, now this combines them
-- @param movement
-- @param movePath
----
function gameObject:moveNow(movement, drawPath)
    self:setMovement(nil, movement, drawPath)
    self:move()
end


-- Removes the ledge from its masters movement collection - which stops it moving
----
function gameObject:stop()
    if self.master then
        self.master.movementCollection:remove(self)
    end
    self.isMoving = false
end


function gameObject:toString(orig)
    local orig_type = type(orig)
    local copy

    if orig_type == 'table' then
        local first = true
        copy = "{"

        for orig_key, orig_value in next, orig, nil do
            if first then first = false else copy=copy..", " end
            local v = self:toString(orig_value)
            copy = copy..orig_key.."="..tostring(v)
            print(orig_key)
        end
        copy = copy.."}"
    else  -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


function gameObject:pauseMovement(duration)
    local time = duration or self.movement.pause

    -- only allow pause if time specified and not already paused
    if time > 0 and self.pauseMovementHandle == nil then
        self.pauseMovementHandle = transition.to(self, {dummy=1, time=time, onComplete=function() self:pauseMovementFinished() end})
    end
end


function gameObject:pauseMovementFinished()
    if self.pauseMovementHandle ~= nil then 
    	self.pauseMovementHandle = nil
    end
end


function gameObject:movementCompleted()
    self:stop()
end


-- the main scaling function to rescale a moving object
function gameObject:scaleMovement(camera)
    if self.movement.pattern == movePatternCircular then
        self:removeCircularPath(camera)
        self:scaleCircularMovement(camera)
    else
        self:removePatternPath(camera)
        self:scalePatternMovement(camera)
    end
end


function gameObject:scaleCircularMovement(camera)
    local move     = camera.scalePosition
    local movement = self.movement
    local drawPath = movement.draw
    local center   = movement.center
    local length   = self.length or movement.distance
    local centerX, centerY = center.x, center.y

    camera:remove(center)
    center:removeSelf()

    center = new_circle(centerX*move, centerY*move, 5)
    center.alpha = 0
    camera:add(center, 3)

    movement.center = center
    self.length     = length * move

    if drawPath then
        local path = new_circle(centerX*move, centerY*move, self.length)
        path.alpha = 0.5
        path.strokeWidth = 5
        path:setStrokeColor(0.2, 0.4, 0.6)
        path:setFillColor(0, 0, 0, 0)
        camera:add(path, 3)
        path:toBack()

        self.movementCircularPathway = path
    end
end


function gameObject:removeCircularPath(camera)
    -- Exclude attached items to a circular ledge which will have a movementPath but for a pattern
    local path = self.movementCircularPathway

    if path  then
        camera:remove(path)
        path:removeSelf()
        path = nil
    end
end


function gameObject:scalePatternMovement(camera)
    local moveScale    = camera.scalePosition
    local movement     = self.movement

    -- dont scale if: the pattern has not been scaled yet (new since level start) AND scalPosition > 1 (zoomed in then out)
    -- cos this means new movements produced in-game will get expanded when they shouldnt - such as shake patterns
    if movement.scaled == nil and moveScale > 1 then
        moveScale = 1
    end

    local pattern      = movement.pattern
    local patternPos   = movement.patternPos
    local drawPath     = movement.draw
    local fromX, fromY = self.image.x, self.image.y
    local pathway      = {}

    if drawPath then
        if movement.inReverse then
            fromX = fromX - ((pattern[patternPos][1] + movement.currentX) * moveScale)
            fromY = fromY - ((pattern[patternPos][2] + movement.currentY) * moveScale)
        else
            fromX = fromX - (movement.currentX * moveScale)
            fromY = fromY - (movement.currentY * moveScale)
        end
    end

    -- Draw from current path ppoint to end
    for i=patternPos, #pattern do
        fromX, fromY = self:scalePatternPath(camera, pattern, pathway, moveScale, drawPath, i, fromX, fromY)
    end

    -- Draw from start up to before current path point
    for i=1, patternPos-1 do
        fromX, fromY = self:scalePatternPath(camera, pattern, pathway, moveScale, drawPath, i, fromX, fromY)
    end

    movement.pathway  = pathway
    movement.nextX    = movement.nextX    * moveScale
    movement.nextY    = movement.nextY    * moveScale
    movement.currentX = movement.currentX * moveScale
    movement.currentY = movement.currentY * moveScale
    movement.speed    = movement.speed    * moveScale
    movement.scaled   = moveScale
end


function gameObject:scalePatternPath(camera, pattern, path, moveScale, drawPath, index, fromX, fromY)
    pattern[index][1] = pattern[index][1] * moveScale
    pattern[index][2] = pattern[index][2] * moveScale

    if drawPath then
        local fromX, fromY, line, circle, fromCircle = draw_point(fromX, fromY, pattern, index, camera)

        path[#path+1] = line
        path[#path+1] = circle
        
        if fromCircle then
            path[#path+1] = fromCircle
        end

        return fromX, fromY
    else
        return 0, 0
    end
end


function gameObject:removePatternPath(camera)
    local drawPath = self.movement.draw
    local path     = self.movement.pathway

    if drawPath and path then
        local num = #path
        
        for i=1, num do
            camera:remove(path[i])
            path[i]:removeSelf()
        end
    end
end


-- Creates an emitter and ties it to this object for its duration
-- @param effectName - must match a particle name
-- @param duration   - either int mseconds, nil for default 1500 or "forever" to not turn off
-- @param attach     - true to add the emitter to the objects image group, so it moves with it
-- return new display.emitter object
----
function gameObject:emit(effectName, params, attach)
    local params  = params or {}

    local emitter = particles:showEmitter(
        self:getCamera(),
        effectName, 
        params.xpos     or self:x(), 
        params.ypos     or self:y(), 
        params.duration or 1500,
        params.alpha    or 1
    )

    if self.direction == left then
        emitter:scale(-1,1)
    end

    if attach then
        self.image:insert(emitter)
    end

    return emitter
end


-- Shortcut to emit() for binding an emitter to an object with a standard name and status tracking var
-- Repeat call to this will remove the previous bound emitter - so only one can be bound with this method
-- @param effectName
-- @param params
----
function gameObject:bindEmitter(effectName, params)
    params.duration = "forever"

    self:destroyEmitter()
    self.boundEmitterOn = true
    self.boundEmitter   = self:emit(effectName, params, self.isSpine)

    if self.master then
        -- TODO: check if already in collection
        self.master.particleEmitterCollection:add(self)
    end
end


-- Removes an emitter added with bindEmitter()
----
function gameObject:destroyEmitter()
    if self.boundEmitter then
        if self.master and self.master.particleEmitterCollection then
            self.master.particleEmitterCollection:remove(self)
        end

        self.boundEmitter:destroy()
        self.boundEmitter   = nil
        self.boundEmitterOn = false
    end
end


-- Plays a sound by binding it to this object into the sound engine
-- @param string action               - name of the sound (under global sounds) which also double as the action name for a managed sound
-- @param function|table|string param - specify the sound either as a function to call on soundEngine(), a table of properties or a string name matching a global sound
----
function gameObject:sound(action, params)
    local soundData = nil

    if type(params) == "function" then
        soundData = params(soundEngine)
    else
        soundData = params or {}
    end

    soundData.sound = soundData.sound or sounds[action]

    if soundData.duration == "forever" then
        soundData.loops    = -1
    end

    if soundData.sound then
        soundEngine:playManagedAction(self, action, soundData)
    end
end


function gameObject:stopSound(action)
    soundEngine:stopSound(self.key, action)
end


-- Called when an objects constant sound has stopped, this adds it again to the sound engine after a delay
-- @param bool force - optional bool that skips conditional check (used for level start to avoid repeating same if statements)
----
function gameObject:constantSoundHandler(force, delay)
    if force or (self.constantSound and self.inGame) then
        after(delay or 250, function()
            if self.inGame then
                self:sound("constant", self.constantSound)
            end
        end)
    end
end


return gameObject