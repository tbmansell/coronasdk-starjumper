local json = require "json"

local particles       = {}
local emitterData     = {}
local createdEmitters = {}


function particles:preLoadEmitters()
    self:loadEmitter("landing-greengood")
    self:loadEmitter("landing-yellowgood")
    self:loadEmitter("landing-redgood")
    self:loadEmitter("landing-whitegood")
    --self:loadEmitter("landing-all")
    self:loadEmitter("run-trail")
    self:loadEmitter("jump-trail")
    self:loadEmitter("die")
    self:loadEmitter("deathflash")
    self:loadEmitter("collect-ring")
    self:loadEmitter("collect-item")
    self:loadEmitter("collect-fuzzy")
    self:loadEmitter("usegear-green")
    self:loadEmitter("usegear-blue")
    self:loadEmitter("usegear-red")
    self:loadEmitter("jetpack-trail")
    self:loadEmitter("ufo-trail")
    self:loadEmitter("collectable-sparks")
end


function particles:loadEmitter(name)
    local filePath = system.pathForFile("json/particle-effects/"..name..".json")
    local f        = io.open(filePath, "r")
    local fileData = f:read("*a")
    f:close()

    local emitterParams, _, errorMessage = json.decode(fileData)

    if errorMessage then
        print(errorMessage)
    end

    emitterData[name] = emitterParams
end


function particles:destroy()
    for _,data in pairs(createdEmitters) do
        if data and data.removeSelf then
            data:removeSelf()
        end
    end
    createdEmitters = {}
    emitterData     = {}
end


function particles:pause()
    for _,data in pairs(createdEmitters) do
        if data and data.pause then
            data:pause()
        end
    end
end


function particles:resume()
    for _,data in pairs(createdEmitters) do
        if data and data.start then
            data:start()
        end
    end
end


function particles:showEmitter(camera, name, x, y, duration, alpha, layer)
    -- Typically we preload them all, but if called without pre-loading then check if loaded before calling
    if emitterData[name] == nil then
        self:loadEmitter(name)
    end

    -- Create the emitter with the decoded parameters
    local emitter = display.newEmitter(emitterData[name])
    emitter.x     = x
    emitter.y     = y
    emitter.id    = #createdEmitters + 1
    emitter.alpha = alpha or 1

    createdEmitters[emitter.id] = emitter

    if camera then
        camera:add(emitter, layer or 2)
    end

    function emitter:destroy()
        if self and self.removeSelf then
            if createdEmitters[self.id] then
                createdEmitters[self.id] = nil
            end
            if camera then
                camera:remove(self)
            end
            self:removeSelf()
            self = nil
        end
    end

    if duration ~= "forever" then
        after(duration, function()
            if emitter and emitter.removeSelf then
                emitter:destroy()
            end
        end)
    end

    return emitter
end


function particles:scale(camera)
    for _,emitter in pairs(createdEmitters) do
        if emitter then
            local scale = camera.scalePosition

            emitter.x = emitter.x * scale
            emitter.y = emitter.y * scale

            -- Doesnt work for emitters:
            --emitter.xScale = scale
            --emitter.yScale = scale

            emitter.startParticleSize  = emitter.startParticleSize  * scale
            emitter.finishParticleSize = emitter.finishParticleSize * scale

            emitter.startParticleSizeVariance  = emitter.startParticleSizeVariance  * scale
            emitter.finishParticleSizeVariance = emitter.finishParticleSizeVariance * scale
        end
    end
end


return particles