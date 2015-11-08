local utils                 = require("core.utils")
local anim                  = require("core.animations")
local builder               = require("level-objects.builders.builder")
local collectableDef        = require("level-objects.collectable")
local collectableCollection = require("level-objects.collections.collectable-collection")


-- @class special builder for enemies
local collectableBuilder = {
	-- Methods:
	-----------
	-- newCollectableCollection()
	-- newRings()
	-- newRing()
	-- newGear()
	-- newNegable()
	-- newKey()
	-- newTimeBonus()
	-- newWarpField()
	-- newRandomizer()
    -- setupCommon()
}


-- Aliases:
local math_random = math.random
local new_image   = display.newImage


-- Creates a new enemyCollection
-- @param spineCollection    - ref to an existing spine collection, to add enemies to it
-- @param movementCollection - ref to an existing move  collection, to add enemies to it
-- @return new enemyCollection
----
function collectableBuilder:newCollectableCollection(spineCollection, movementCollection, particleEmitterCollection)
    local coll = builder:newMasterCollection("collectables", spineCollection, movementCollection, particleEmitterCollection)

    builder:deepCopy(collectableCollection, coll)

    coll.ringsAvailable = {}
    
    return coll
end


-- Creates a set of new rings
-- @param camera
-- @param spec
-- @param x - starting x offset for first ring
-- @param y - starting y offset for first ring
-- @param jumpObject
-- @return list of ring objects
----
function collectableBuilder:newRings(camera, spec, x, y, jumpObject)
	-- There are various ways to create a set of rings:
	local rings = {}

    -- 1. in a pattern where each ring is specified by an x,y:
    if spec.pattern then
        for i,item in pairs(spec.pattern) do
            local px, py       = (item.x or item[1]), (item.y or item[2])
            local movement     = builder:newClone(spec.movement)
            local patternStart = nil

            x, y = x + px, y + py

            if spec.movement and movement.stagger then
                movement.patternStart = i
            end

            local ringSpec  = {object="ring", position=i, color=spec.color, isTemp=false, movement=movement}
            rings[#rings+1] = self:newRing(camera, ringSpec, x, y)
        end
    -- 2. in a trajectory mimicking a players jump between ledges
    elseif spec.trajectory ~= nil then
        local t = spec.trajectory
        y = jumpObject:topEdge() + t.y

        if t.xforce > 0 then
            x = jumpObject:rightEdge() + t.x
        else
            x = jumpObject:leftEdge() + t.x
        end

        curve:drawItemTrajectory(x, y, t.xforce, -t.yforce, t.arc, t.num,
            function(pos, x, y)
            	local ringSpec  = {object="ring", position=pos, color=spec.color, isTemp=false, movement=spec.movement}
                rings[#rings+1] = collectableBuilder:newRing(camera, ringSpec, x, y)
            end
        )
    end

    return rings
end


-- Creates a new ring
-- @param camera
-- @param spec
-- @param x
-- @param y
-- @return new ring object
----
function collectableBuilder:newRing(camera, spec, x, y)
    local color    = spec.color or aqua
    local ring     = builder:newSpineObject(spec, {jsonName="rings", imagePath="collectables", skin=colorNames[color], animation="Pulse"})
    ring.isRing    = true
    ring.class     = "collectable"
    ring.type      = spec.color
    ring.collected = false

    function ring:setPhysics(s)
        physics.addBody(self.image, "static", {radius=25*s, density=0, friction=0, bounce=0, isSensor=true})
    end

    function ring:collect(camera)
        local seq = anim:chainSeq("ringCollected", self.image)
        seq:tran({time=500, x=0, y=0})
        seq:callback(function() ring:destroy(camera) end)
        seq:start()
    end

    ring:moveTo(x, y)
    self:setupCommon(camera, ring, spec, collectableDef.eventCollideRing)

    return ring
end


-- Creates a new gear 
-- @param camera
-- @param spec
-- @param x
-- @param y
-- @param ledge
-- @return new gear object
----
function collectableBuilder:newGear(camera, spec, x, y, ledge)
    local slot  = gearSlots[spec.type]
	local image = new_image("images/collectables/gear-"..gearNames[slot].."-"..spec.type..".png", 0,0)
	local gear  = builder:newGameObject(spec, image)

    gear.isGear         = true
    gear.class          = "collectable"
    gear.name           = gear.type
    gear.slot           = slot
    gear.collected      = false
    gear.regenerate     = gear.regenerate or false
    gear.collectedSound = {sound=sounds.collectGear, duration=1000}
    gear.originalScale  = 0.3
    
    function gear:setPhysics(scale)
        local s = 70 * self.originalScale * scale
        physics.addBody(self.image, "dynamic", {density=0.2, friction=0.5, bounce=0.3, shape={-s,-s, s,-s, s,s, -s,s}})
    end

    self:setupCommon(camera, gear, spec, collectableDef.eventCollideGear, x, y, ledge)

    -- Generate a constant emitter
    after(1500, function()
        if gear.inGame and not gear.isTemp then
            gear:bindEmitter("collectable-sparks", {xpos=gear:x(), ypos=gear:y(), alpha=0.5})
        end
    end)

    return gear
end


-- Creates a new negable 
-- @param camera
-- @param spec
-- @param x
-- @param y
-- @param ledge
-- @return new gear object
----
function collectableBuilder:newNegable(camera, spec, x, y, ledge)
    local slot    = negableSlots[spec.type]
	local image   = new_image("images/collectables/negable-"..gearNames[slot].."-"..spec.type..".png", 0,0)
	local negable = builder:newGameObject(spec, image)

    negable.isNegable      = true
    negable.class          = "collectable"
    negable.name           = negable.type
    negable.slot           = slot
    negable.collected      = false
    negable.regenerate     = negable.regenerate or false
    negable.collectedSound = {sound=sounds.collectNegable, duration=1000}
    negable.originalScale  = 0.3
    
    function negable:setPhysics(scale)
        local s = 70 * self.originalScale * scale
        physics.addBody(self.image, "dynamic", {density=0.2, friction=0.5, bounce=0.3, shape={-s,-s, s,-s, s,s, -s,s}})
    end

    self:setupCommon(camera, negable, spec, collectableDef.eventCollideGear, x, y, ledge)

    return negable
end


-- Creates a new key used to unlock locked ledges
-- @param camera
-- @param spec
-- @param x
-- @param y
-- @param ledge
-- @return new key object
----
function collectableBuilder:newKey(camera, spec, x, y, ledge)
	local image = new_image("images/collectables/"..spec.color.."-key.png", 0,0)
	local key   = builder:newGameObject(spec, image)

    key.isKey          = true
    key.class          = "collectable"
    key.type           = "key"
    key.collected      = false
    key.collectedSound = {sound=sounds.collectKey, duration=1000}
    key.originalScale  = 0.3

    function key:setPhysics(scale)
        local s = 70 * self.originalScale * scale
        physics.addBody(self.image, "dynamic", {density=0.2, friction=0.5, bounce=0.3, shape={-s,-s, s,-s, s,s, -s,s}})
    end

    self:setupCommon(camera, key, spec, collectableDef.eventCollideKey, x, y, ledge)

    return key
end


-- Creates a new timebonus used for infinte time runner
-- @param camera
-- @param spec
-- @param x
-- @param y
-- @param jumpObject
-- @return new timebonus object
----
function collectableBuilder:newTimeBonus(camera, spec, x, y, jumpObject)
    local bonus = builder:newSpineObject(spec, {jsonName="time-bonus", imagePath="collectables/infinite", scale=0.25, animation="Standard"})

    bonus.isTimeBonus    = true
    bonus.class          = "collectable"
    bonus.type           = "timebonus"
    bonus.collected      = false
    bonus.bonus          = bonus.bonus or 15
    bonus.collectedSound = {sound=sounds.collectTimeBonus, duration=1000}

    function bonus:setPhysics(scale)
        local r = 22 * scale
        physics.addBody(self.image, "static", {isSensor=true, radius=r})
    end

    self:setupCommon(camera, bonus, spec, collectableDef.eventCollideTimeBonus, x, y, jumpObject)

    return bonus
end


-- Creates a new warpfield
-- @param camera
-- @param spec
-- @param x
-- @param y
-- @param jumpObject
-- @return new warpfield object
----
function collectableBuilder:newWarpField(camera, spec, x, y, jumpObject)
    local size = spec.size or 0.75
	local warp = builder:newSpineObject(spec, {jsonName="warp-field", imagePath="effects", scale=size, animation="Standard"})

    warp.isWarpField   = true
    warp.class         = "collectable"
    warp.type          = "warpfield"
    warp.originalScale = size
    warp.constantSound = {sound=sounds.warpActive, duration="forever"}
    warp.hitSound      = {sound=sounds.warpHit,    duration=1000}

    function warp:setPhysics(scale)
        local r = self.radius * scale
        physics.addBody(self.image, "static", {isSensor=true, radius=r})
    end

    self:setupCommon(camera, warp, spec, collectableDef.eventCollideWarpField, x, y, jumpObject)

    return warp
end


-- Creates a new randomizer
-- @param camera
-- @param spec
-- @param x
-- @param y
-- @param ledge
-- @return new randomizer object
----
function collectableBuilder:newRandomizer(camera, spec, x, y, ledge)
	local randomizer = builder:newSpineObject(spec, {jsonName="item-randomizer", imagePath="collectables", scale=0.5, animation="Standard"})

    randomizer.isRandomizer = true
    randomizer.class        = "collectable"
    randomizer.type         = "randomizer"
    randomizer.collected    = false

    function randomizer:setPhysics(s)
        physics.addBody(self.image, "static", {density=1, friction=0, bounce=0, isSensor=true, shape={-26*s,-52*s, 26*s,-52*s, 26*s,0, -26*s,0}})
    end

    -- Triggers the randomizer
    function randomizer:activate()
        self.collected = true
        self:sound("checkpoint", {duration=1000})

        local name = utils.percentFrom(self.items)
        if name then
            local x, y, object = self:x(), self:y()-50, nil

            if     colorNames[name]   then object = hud.level:generateRing(x, y, name)
            elseif negableSlots[name] then object = hud.level:generateNegable(x, y, name)
            elseif gearSlots[name]    then object = hud.level:generateGear(x, y, name) end

            if object then
                -- initially mark as uncollectable until it can fly in the air for a second
                object.isStolen = true
                object:intangible()
                object:body("dynamic")
                object.image:setLinearVelocity(0, -800 * self:getCamera().scaleVelocity)

                after(500, function()
                    object.isStolen = false
                    object:solid()
                end)
            end
        else
            -- Put this here incase there is a typo in the level generation
            print("Warning: randomizer didnt generate anything")
        end

        -- After activation, the randomizer destroys itself
        local seq = anim:chainSeq("randomizer", self.image)
        seq:tran({time=100, alpha=0, delay=1000})
        seq.onComplete = function()
            randomizer:destroy()
        end
        seq:start()
    end

    self:setupCommon(camera, randomizer, spec, collectableDef.eventCollideRandomizer, x, y, ledge)

    return randomizer
end


-- Sets up common properties for a collectable
-- @param camera
-- @param collectable
-- @param spec
-- @param collisionHandler
-- @param x
-- @param y
----
function collectableBuilder:setupCommon(camera, collectable, spec, collisionHandler, x, y, ledge)
    local scale = (collectable.originalScale or 1) * camera.scaleImage
    if scale ~= 1 then
        collectable.image:scale(scale, scale)
    end
        
    collectable:setPhysics(camera.scaleImage)

    if spec.onLedge and ledge then
        collectable:moveTo((spec.x or 0) + x,  ledge:topEdge() - (collectable:height()/2))
    elseif x and y then
        collectable:moveTo((spec.x or 0) + x, (spec.y or 0) + y)
    end

    if collectable.movement then
        collectable.movement.originalX = spec.x
        collectable.movement.originalY = spec.y
        collectable:moveNow()
    end

    collectable.image.collision = collisionHandler
    collectable.image:addEventListener("collision", collectable.image)

    camera:add(collectable.image, 3)
end


return collectableBuilder