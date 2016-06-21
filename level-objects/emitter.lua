local utils   = require("core.utils")
local builder = require("level-objects.builders.builder")


-- @class main class
local emitter = {
	
	isEmitter = true,
	class     = "emitter",

	-- Methods:
	-----------
	-- *scale()
    -- setNextEmit()
	-- checkEmit()
	-- *emit()
	-- getItemToEmit()
	-- applyForce()
    -- checkEmittedOutOfPlay()
}


-- Aliases:
local math_random = math.random
local math_abs    = math.abs


function emitter:scale(camera)
    local move = camera.scalePosition
    self.image.x = self.image.x * move
    self.image.y = self.image.y * move
end


function emitter:setNextEmit()
    if type(self.timer) == "table" then
        self.emitWhen = math_random(self.timer[1], self.timer[2])
    else
        self.emitWhen = self.timer
    end

    after(self.emitWhen, function() self:checkEmit() end)
end


function emitter:checkEmit()
    -- check emitter not destroyed
    if self.inGame then
        self:setNextEmit()

        -- check if there are limits on number of items that can be bound
        if self.limit then
            local count, items = 0, self.boundItems
            for key,item in pairs(items) do
                if item ~= nil then count = count + 1 end
            end

            if count < self.limit then
                self:emit()
                return true
            end
        else
            self:emit()
            return true
        end
    end
    return false
end


function emitter:emit()
    local camera  = self:getCamera()
    local level   = hud.level
    local spec    = self:getItemToEmit(camera)
    local object  = spec.object
    --local scale   = camera.scaleImage
    --local move    = camera.scalePosition
    local x, y    = self:pos()
    local element = nil

    if     object == "scenery" then element = level:createScenery(spec, self)
    elseif object == "wall"    then element = level:createScenery(spec, self)
    elseif object == "spike"   then element = level:createScenery(spec, self)
    elseif object == "livebgr" then element = level:createLiveBackground(spec, self)
    elseif object == "negable" then element = level:createCollectable(spec, self)
    elseif object == "gear"    then element = level:createCollectable(spec, self)
    elseif object == "enemy"   then element = level:createEnemy(spec, self)
    elseif object == "friend"  then element = level:createFriend(spec, self)  end

    element:moveTo(x, y)

    --[[if scale ~= 1 then
        --element:scale(camera)
        element:moveBy(element:x()*move, element:y()*move)
    end]]

    self:bind(element)

    if self.force then
        self:applyForce(camera, element, object)
    end

    -- Emitted objects get destroyed if out of level bounds, so this allow them some time of exemption if the emitters are off level
    element.ignoreOutOfPlay = true
    after(2000, function() element.ignoreOutOfPlay = false end)

    if object == "livebgr" then
        element:appear()
    end
end


function emitter:getItemToEmit(camera)
    -- An emitter can pick a new item in two ways: either the emitter specifies a single item with self.item or there is a list with self.items to pick from
    local itemSpec = self.item

    if self.items then
        itemSpec = utils.percentFrom(self.items)
    end

    -- The item component should match the details for what you would normally use to create an item in a zone file
    -- But the x,y will be replaced with the emitters and velocity will be added afterward
    -- Create a copy of the item so we can modify it if the original specifies ranges rather than fixed values
    local item = builder:newClone(itemSpec)
    item.x = 0
    item.y = 0

    if itemSpec.object == "livebgr" then
        item.layer    = 4 + math_random(4)
        item.size     = itemSpec.size[item.layer-4] * camera.scaleImage
        item.movement = self:generateMovement(item.layer, itemSpec.movement)

    elseif type(itemSpec.size) == "table" then
        item.size = math_random(itemSpec.size[1], itemSpec.size[2]) / 10
    else
        item.size = itemSpec.size
    end
    
    return item
end


function emitter:generateMovement(layer, spec)
    local movement = {
        speed      = spec.speed[layer-4],
        moveStyle  = spec.moveStyle,
        steering   = spec.steering,
        oneWay     = spec.oneWay or false  -- loop movement by default
    }

    movement.pattern = {{
        utils.randomRange(spec.rangeX[1], spec.rangeX[2]),
        utils.randomRange(spec.rangeY[1], spec.rangeY[2])
    }}

    return movement
end


function emitter:applyForce(camera, element, objectName)
    if objectName == "scenery" then
        -- if object is scenery it doesnt get put in the physics engine and we need it to apply force:
        physics.addBody(element.image, "dynamic", {isSensor=true, density=0, friction=0, radius=5})
        element:setGravity(0)
    end

    local scale = camera.scaleVelocity
    local xforce, yforce, spin = self.force[1], self.force[2], self.force[3]

    -- check if force is random range
    if type(xforce) == "table" then xforce = utils.randomRange(xforce[1], xforce[2]) end
    if type(yforce) == "table" then yforce = utils.randomRange(yforce[1], yforce[2]) end
    if type(spin)   == "table" then spin   = utils.randomRange(spin[1],   spin[2])   end

    element:applyForce(xforce*scale, yforce*scale)

    if spin then
        element:applySpin(spin)
    end
end


function emitter:checkEmittedOutOfPlay(camera)
    local items = self.boundItems

    for key,object in pairs(items) do
        if object and object.image and not object.ignoreOutOfPlay and camera:outsideBounds(object.image) then
            object:destroy(camera)
        end
    end
end


return emitter