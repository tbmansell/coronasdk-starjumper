local anim       = require("core.animations")
local builder    = require("level-objects.builders.builder")
local emitterDef = require("level-objects.emitter")
local sceneryDef = require("level-objects.scenery")


local sceneryBuilder = {
	-- Methods:
	-----------
	-- newSceneryCollection()
	-- newSceneryGroup()
	-- newScenery()
	-- setupBlockingScenery()
	-- setupDeadlyScenery()
    -- newEmitterCollection()
	-- newEmitter()
    -- newLiveBackground()
    -- newCloudCollection()
	-- newCloud()
}


-- Aliases:
local new_image   = display.newImage
local math_random = math.random


-- Creates a new masterCollection for scenery
-- @param spineCollection    - ref to an existing spine collection, to add ledges to it
-- @param movementCollection - ref to an existing move  collection, to add ledges to it
-- @return new masterCollection
----
function sceneryBuilder:newSceneryCollection(spineCollection, movementCollection, particleEmitterCollection)
	return builder:newMasterCollection("scenery", spineCollection, movementCollection, particleEmitterCollection)
end


-- Creates a new block of scenery to be copied multiple times (defines by the copy attribute)
-- @param camera
-- @param spec
-- @param x
-- @param y
-- @return list of new scenery objects all matching the spec but spaced apart
----
function sceneryBuilder:newSceneryGroup(camera, spec, x, y)
	local items = {}
	local copy  = spec.copy

	for i=1,copy do
        local scenery   = self:newScenery(camera, spec, x, y)
		items[#items+1] = scenery
		
        -- use original image width (ignoring sizing) as levels were written before sizing was added to gameObject:width()
        x = x + scenery.image.width + (spec.gap or 0)
	end

	return items
end


-- Creates a new scenery object
-- @param camera
-- @param spec
-- @param x
-- @param y
-- @return new scenery object
----
function sceneryBuilder:newScenery(camera, spec, x, y)
    local size    = spec.size or 1
    local image   = new_image("images/foreground/"..spec.theme.."/"..spec.type..".png", 0,0)
    local scenery = builder:newGameObject(spec, image)

    builder:deepCopy(sceneryDef, scenery)

    scenery.isScenery     = true
    scenery.alpha         = spec.alpha or 1
    scenery.originalScale = size
    scenery.inPhysics     = false

    if scenery.object == "wall" then
    	self:setupBlockingScenery(camera, scenery)

    elseif scenery.object == "spike" then
    	self:setupDeadlyScenery(camera, scenery)
    else
        scenery.layer = scenery.layer or 1
    end

    self:setupSceneryCommon(camera, scenery, spec, image)
    
    -- Add width, height to center
    local xpos = (spec.x or 0) + (x or 0) + image.width/2
    local ypos = (spec.y or 0) + (y or 0) + image.height/2
    scenery:moveTo(xpos, ypos)

    if scenery.movement then
        scenery.movement.originalX = spec.x
        scenery.movement.originalY = spec.y
        scenery:setBobbingMovement()
        scenery:moveNow()
    end

    camera:add(scenery.image, scenery.layer, false, (scenery.fixFloor or false), (scenery.fixSky or false))

    return scenery
end


function sceneryBuilder:setupSceneryCommon(camera, scenery, spec, image)
    local scale = (scenery.originalScale or 1) * camera.scaleImage

    if scale ~= 1 then
        scenery.image:scale(scale, scale)
    end

    if scenery.flip == "x" then scenery:flipX() end
    if scenery.flip == "y" then scenery:flipY() end

    if scenery.darken then
        scenery.image:setFillColor(scenery.darken)

    elseif scenery.rgb then
        scenery.image:setFillColor(scenery.rgb[1], scenery.rgb[2], scenery.rgb[3])
    end

    if scenery.rotation then
        scenery:rotate(scenery.rotation)
    end
end


-- Sets up a scenery object as a blocking object where player bounces off
-- @param scenery to configure
----
function sceneryBuilder:setupBlockingScenery(camera, scenery)

    function scenery:setPhysics(s)
        local stats = self:createPhysicsShape(s)
        local body  = "static"
        local p     = self.physics

        if p and p.body then
            body = p.body
        end

        physics.addBody(self.image, body, stats)
    end

    scenery:setPhysics(camera.scaleImage)

    scenery.isWall    = true
    scenery.inPhysics = true
    scenery.layer     = scenery.layer or 2

    scenery.image.collision = sceneryDef.eventCollideWall
    scenery.image:addEventListener("collision", scenery.image)
end


-- Sets up a scenery object as a deadly object where player dies if they touch it
-- @param scenery to setup
----
function sceneryBuilder:setupDeadlyScenery(camera, scenery)

    function scenery:setPhysics(s)
        local stats = self:createPhysicsShape(s)
        local body  = "static"
        local p     = self.physics

        if p then
            if p.body then body = p.body end
            if p.stopMomentum then object.stopMomentum = p.stopMomentum end
        end
        
        physics.addBody(self.image, body, stats)
    end

    scenery:setPhysics(camera.scaleImage)

    scenery.isSpike   = true
    scenery.inPhysics = true
    scenery.layer     = scenery.layer or 2

    scenery.image:setFillColor(1, 0.4, 0.4)

	scenery.image.collision = sceneryDef.eventCollideSpike
	scenery.image:addEventListener("collision", scenery.image)
end


-- Creates a new masterCollection for clouds
-- @param movementCollection - ref to an existing move  collection, to add ledges to it
-- @return new masterCollection
----
function sceneryBuilder:newEmitterCollection(movementCollection)
    local coll =  builder:newMasterCollection("emitters", nil, movementCollection)

    -- Loops through all objects fired by emitters and destroys any that have fallen out of play
    -- @param camera
    ----
    function coll:checkEmittedOutOfPlay(camera)
        local items = self.items
        local num   = #items

        for i=1,num do
            local emitter = items[i]

            if emitter and emitter ~= -1 and emitter.image then
                emitter:checkEmittedOutOfPlay(camera)
            end
        end
    end

    return coll
end


-- Creates a new game emitter (emitts game objects)
-- @param camera
-- @param spec
-- @param x
-- @param y
-- @return new emitterObject
----
function sceneryBuilder:newEmitter(camera, spec, x, y)
    --local image   = display.newCircle(0, 0, 10)
    local image   = display.newRect(0, 0, 2, 2)
    local emitter = builder:newGameObject(spec, image)

    builder:deepCopy(emitterDef, emitter)

    -- For debugging: show where the emitter is
    --emitter.image:setFillColor(1,0,0)
    emitter.image.alpha = 0

    emitter:moveTo(spec.x + x, spec.y + y)
    emitter:setNextEmit()
    camera:add(emitter.image, emitter.layer or 3)

    return emitter
end


-- Creates a live background element from an emitter - which is a moving spine object that doesnt interact with other elements
-- @param camera
-- @param spec
-- @return new live background game element
----
function sceneryBuilder:newLiveBackground(camera, spec)
    local json      = spec.theme.."/enemy-"..spec.type
    local imagePath = spec.imagePath or ("background/"..spec.theme)
    local skin      = spec.color or spec.skin
    local livebgr   = builder:newSpineObject(spec, {jsonName=json, imagePath=imagePath, scale=spec.size, skin=skin, animation="Standard"})

    function livebgr:appear()
        self.scalingIn = true

        local seq = anim:oustSeq("appear"..self.key, self.image)
        seq:tran({alpha=0.9, xScale=1, yScale=1, time=2000})
        seq.onComplete = function() self.scalingOut = false end
        seq:start()
    end

    function livebgr:movementCompleted()
        self:stop()

        if self.startFade == nil then
            self.startFade = true

            local seq = anim:oustSeq("moveComplete"..self.key, self.image)
            seq:tran({xScale=0.1, yScale=0.1, time=2500})
            seq.onComplete = function()
                self:destroy()
            end
            seq:start()
        end
    end

    -- We override the base scale() in order to hook in and stop any scaloing in function: so that if scaled out, we dont generate an object way bigger than it should appear scaled out
    livebgr.baseScale = livebgr.scale

    function livebgr:scale(camera)
        self:baseScale(camera)

        if self.scalingIn then
            anim:destroyQueue("appear"..self.key)
            self.image:scale(camera.scaleImage, camera.scaleImage)
            self:visible(0.9)
        end
    end


    livebgr.inPhysics   = false
    livebgr.image.alpha = 0  -- must be faded in
    livebgr:moveNow()

    livebgr.image.xScale = 0.1
    livebgr.image.yScale = 0.1

    -- Ian created these facing the opposite way from planet1 enemies
    if spec.type == "greyufo" or spec.type == "greyother" then
        if livebgr.movement.pattern[1][1] < 0 then
            livebgr:changeDirection(right)
        end
    else
        if livebgr.movement.pattern[1][1] > 0 then
            livebgr:changeDirection(right)
        end
    end

    camera:add(livebgr.image, spec.layer)

    return livebgr
end


--[[
    Clouds no longer used in the game: decided they looked rubbish

-- Creates a new masterCollection for clouds
-- @param movementCollection - ref to an existing move  collection, to add ledges to it
-- @return new masterCollection
function sceneryBuilder:newCloudCollection(movementCollection)
    return builder:newMasterCollection("clouds", nil, movementCollection)
end


function sceneryBuilder:newCloud(camera, x, levelStart, levelEnd, windRight, windSpeed, colourer)
    if colourer then
        cloudColourer = colourer
    end

    local cloudNum    = math_random(8)
    local cloudHeight = math_random(300)
    local layer       = 5 + math_random(3)
    local scale       = 0.5 + math_random()
    local r,g,b       = 100+math_random(155), 100+math_random(155), 100+math_random(155)

    local cloud = display.newImage("images/background/cloud-"..cloudNum..".png", x, -cloudHeight)
    cloud.x = cloud.x + cloud.width/2
    cloud.y = cloud.y + cloud.height/2

    cloud:scale(scale, scale)
    cloud.alpha       = 0.7
    cloud.moveCounter = 0
    cloudColourer(cloud)

    if x == -1000 then
        if windRight then
            cloud.x = levelStart - cloud.width/2
        else
            cloud.x = levelEnd + cloud.width/2
        end
    end
    
    if windSpeed < 5 then
        cloud.speed     = 1
        cloud.moveDelay = math_random(5-windSpeed) --WS 4 = speed 1, delay 1
    else
        cloud.speed     = math_random(windSpeed-3) --WS 5 = speed 2, delay 1
        cloud.moveDelay = 1
    end

    camera:add(cloud,layer,false)
end
]]

return sceneryBuilder