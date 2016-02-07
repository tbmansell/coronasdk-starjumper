local spine            = require("core.spine")
local gameObject       = require("level-objects.game-object")
local spineObject      = require("level-objects.spine-object")
local collection   	   = require("level-objects.collections.collection")
local masterCollection = require("level-objects.collections.master-collection")


-- @class Core builder 
local builder = {
	-- Methods:
	-----------
	-- setCollectionBoundaries()
	-- deepCopy()
	-- newClone()
	-- newGameObject()
	-- newSpineObject()
	-- setupCustomShape()
	-- newCollection()
	-- newSpineCollection()
	-- newMovementCollection()
}

-- Local vars for performance
-- (x >= -300 and x <= 1200 and y >= -200 and y <= 800)
local constLeftNormal   = -300
local constRightNormal  = 1200
local constTopNormal    = -200
local constBottomNormal = 800

local constLeftScaled   = -300
local constRightScaled  = 1200
local constTopScaled    = -200
local constBottomScaled = 800

local leftBoundary      = constLeftNormal
local rightBoundary     = constRightNormal
local topBoundary       = constTopNormal
local bottomBoundary    = constBottomNormal

-- Used for spine animation
local lastTime          = 0


-- Aliases
local new_image 		= display.newImage
local move_item_pattern = moveItemPattern


-- Global function to scale the boundaries used for movement and animation
-- @param bool scale - nil or false to set normal boundaries, true to set scaled boundaries
----
function builder:setCollectionBoundaries(scale)
	if scale then
		leftBoundary   = constLeftScaled
		rightBoundary  = constRightScaled
		topBoundary    = constTopScaled
		bottomBoundary = constBottomScaled
	else
		leftBoundary   = constLeftNormal
		rightBoundary  = constRightNormal
		topBoundary    = constTopNormal
		bottomBoundary = constBottomNormal
	end
end



-- Performs a deep copy of the original into the target (used when target is an existing object)
-- @param orig   - source table to copy
-- @param target - object to copy properties from orig into
----
function builder:deepCopy(orig, copy)
    local orig_type = type(orig)
    
    if orig_type == 'table' then
        copy = copy or {}

        for orig_key, orig_value in next, orig, nil do
        	if globalDebugCopy then print("deepCopy: "..tostring(orig_key).."="..tostring(orig_value).." copy="..tostring(copy)) end
            copy[self:deepCopy(orig_key, copy)] = self:deepCopy(orig_value, copy)
        end
        --setmetatable(copy, self:deepCopy(getmetatable(orig, copy)))
    else  -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


-- Creates a replica of the original passed in, using a deep copy
-- @param orig - source table to clone
-- @return newly created table
----
function builder:newClone(orig)
    local orig_type = type(orig)
    local copy
    
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
        	--print("newClone: "..tostring(orig_key).."="..tostring(orig_value))
            copy[self:newClone(orig_key)] = self:newClone(orig_value)
        end
        --setmetatable(copy, self:newClone(getmetatable(orig)))
    else  -- number, string, boolean, etc
    	copy = orig
    end
    return copy
end


-- Creates a new gameObject which is the base for all elements in level:
-- @param spec  - original table used to create any element ingame (eg. {object="ledge", x=300, y=0} )
-- @param image - the object holding the image or image collection (for spine)
-- @return new gameObject
----
function builder:newGameObject(spec, image)
	-- an object is at its foundation a copy of the table spec passed in where we can override specifics
	local object = self:newClone(spec)

	-- we then apply the gameObject definition over it
	self:deepCopy(gameObject, object)

	if not object.type then object.type = "" end

	-- deepCopy on empty tables does not seem to work as it should, so reset them here
	object.boundItems  = {}
	object.collections = {}
	object.bindQueue   = {}

	-- simple assignment of an image passed in as a property of this object, and allow the image to have a ref to the object for event handlers
	object.image 		= image
	object.image.object = object
	-- for infinite level generation, mark the stage an element is in
	object.stage 		= globalInfiniteStage

	return object
end


-- Creates a new spine object (derived from gameObject) and loads in the spine data
-- @param spec
-- @param spineParams  - a table of paramteers to load the spine data
-- 			jsonName
--			imagePath
--			scale
--			skin
--			animation
-- @return new spineObject
----
function builder:newSpineObject(spec, spineParams)
	local imagePath = spineParams.imagePath
	local json 		= spine.SkeletonJson.new()

	if spineParams.scale ~= nil then
    	json.scale = spineParams.scale
	end

    local skeletonData = json:readSkeletonDataFile("json/spine/"..spineParams.jsonName..".json")
    local skeleton     = spine.Skeleton.new(skeletonData, nil)

    if spec.modifyImage then
    	-- Allow customisation of the spine images as they are created
    	local modify = spec.modifyImage

	    function skeleton:createImage(attachment)
	        local image = new_image("images/" .. imagePath .. "/" .. attachment.name .. ".png")
			image:setFillColor(modify[1], modify[2], modify[3])
			return image, true
	    end
	else
		-- Normal use: no modification to images
		function skeleton:createImage(attachment)
	        return new_image("images/" .. imagePath .. "/" .. attachment.name .. ".png"), false
	    end
	end

    if spineParams.skin ~= nil then
    	skeleton:setSkin(spineParams.skin)
    end
    
    skeleton:setToSetupPose()

    -- Now build the gameObject:
    local object = self:newGameObject(spec, skeleton.group)

    -- spineObject overrides the base destroy() to add spine cleanup - so keep ref to base destroy()
    object.isSpine     = true
	object.baseDestroy = object.destroy
	object.skeleton    = skeleton
	object.class       = "spineObject"

    -- we then apply the spineObject definition over it
	self:deepCopy(spineObject, object)

	-- setup initial animation to LOOP
    if spineParams.animation then
    	local loop = true
    	if spineParams.loop == false then loop = false end

    	object.stateData = spine.AnimationStateData.new(skeletonData)
    	object.state     = spine.AnimationState.new(object.stateData)
    	object.state:setAnimationByName(0, spineParams.animation, loop, 0)
	end

	return object
end


-- Modifies an object by supplying a custom shape that does not fit its image and overrides methods to determine its size and edges
-- @param object - gameObject to modify
-- @param width  - new width
-- @param height - new height
----
function builder:setupCustomShape(object, width, height)
	object.customWidth  = width
	object.customHeight = height

	-- These functions replace the base ones for performance reasons (rather than have if/else inside): 

    function object:width()
        return self.customWidth * self.scaled
    end
    
    function object:height()
        return self.customHeight * self.scaled
    end

    function object:leftEdge(fromEdge)
        if fromEdge == nil then fromEdge = 0 end
        return self.image.x - ((self.customWidth/2) * self.scaled) + fromEdge
    end

    function object:rightEdge(fromEdge)
        if fromEdge == nil then fromEdge = 0 end
        return self.image.x + ((self.customWidth/2) * self.scaled) - fromEdge
    end

    function object:topEdge(fromEdge)
        if fromEdge == nil then fromEdge = 0 end
        return self.image.y - ((self.customHeight/2) * self.scaled) + fromEdge
    end

    function object:bottomEdge(fromEdge)
        if fromEdge == nil then fromEdge = 0 end
        return self.image.y + ((self.customHeight/2) * self.scaled) + fromEdge
    end
end


-- Creates a new collection with a given name
-- @param name - for the collection (shoud be unique for an object)
----
function builder:newCollection(name)
	local coll = self:newClone(collection)
	coll.name  = name
	coll.items = {}
	return coll
end


-- Creates a collection specific to animating spine objects
----
function builder:newSpineCollection()
	local coll = self:newCollection("spineSet")

	lastTime = 0

	-- Loops through each item and updates its spine animation state
	-- @param event
	-- @param visibleOnly - if true will only animate items in the viewport, if false will animate all items
	----
	function coll:animateEach(event, visibleOnly)
	    -- Calc delta
	    local time  = event.time / 1000
	    local delta = time - lastTime
	    lastTime    = time
		local items = self.items
	    local num   = #items

	    for i=1,num do
	        local object = items[i]

	        if object and object ~= -1 and object.inGame then
	        	-- Check if image on-screen (or close to on-screen for fast movement)
	        	local image = object.image
	            local x, y  = image.x, image.y

	            if not visibleOnly or object.alwaysAnimate or (x >= leftBoundary and x <= rightBoundary and y >= topBoundary and y <= bottomBoundary) then
		            object.state:update(delta)
		            object.state:apply(object.skeleton)
		            object.skeleton:updateWorldTransform()
	            end
	        end
	    end
	end

	return coll
end


-- Creates a new collection specific to moving game objects: note this is tempoaray as its calling a ref to a global to do all the work
-- TODO: move all the required code from movement.lua into its own collection
----
function builder:newMovementCollection()
	local coll = self:newCollection("movementSet")

	-- Essentially just calls the global moveItemPattern() on each object
	function coll:moveEach(delta, camera)
	    local items = self.items
	    local num   = #items

	    for i=1,num do
	        local object = items[i]

	        if object and object ~= -1 then
	        	-- objects marked punyMover=true only move if visible on-screen for performance
	        	if object.punyMover then
	        		local x, y = object.image.x, object.image.y

	        		if (x >= leftBoundary and x <= rightBoundary and y >= topBoundary and y <= bottomBoundary) then
	        			move_item_pattern(camera, object, delta)
	        		end
	        	else
	        		-- All other objects always move regardless of where they are on level
	        		move_item_pattern(camera, object, delta)
	        	end
	        end
	    end
	end

	return coll
end


-- Creates a new collection specific to game objects that have a bound aprticle emitter - so that we can control it only emitting when on-screen
----
function builder:newParticleEmitterCollection()
	local coll = self:newCollection("particleEmitterSet")

	-- Called to check that collectables with bound emitters turn them off wehn they are off screen and on when on screen
	function coll:checkEach()
	    local items = self.items
	    local num   = #items

	    for i=1,num do
	        local object = items[i]

	        if object and object ~= -1 and object.inGame and object.boundEmitter then
                local x, y = object.image.x, object.image.y
                
                if (x >= leftBoundary and x <= rightBoundary and y >= topBoundary and y <= bottomBoundary) then
                    if not object.boundEmitterOn then
                        object.boundEmitterOn = true
                        object.boundEmitter:start()
                    end
                else
                    if object.boundEmitterOn then
                        object.boundEmitterOn = false
                        object.boundEmitter:stop()
                    end
                end
	        end
	    end
	end

	return coll
end


-- Creates a new master collection, which extends collection to allow manage a particular class of objects
-- @param name of the collection
-- @param spineCollection    - ref to an existing spine collection, to add enemies to it
-- @param movementCollection - ref to an existing move  collection, to add enemies to it
-- @return new master collection
----
function builder:newMasterCollection(name, spineCollection, movementCollection, particleEmitterCollection)
	local coll = self:newCollection(name)

    -- override base clear(), destroy() but provide base references to them
    coll.baseClear   = coll.clear
    coll.baseDestroy = coll.destroy

	builder:deepCopy(masterCollection, coll)

	coll.spineCollection   	       = spineCollection
	coll.movementCollection 	   = movementCollection
	coll.particleEmitterCollection = particleEmitterCollection

	return coll
end


return builder