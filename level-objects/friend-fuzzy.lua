local anim    	  = require("core.animations")
local soundEngine = require("core.sound-engine")


-- @class Fuzzy friend class
local fuzzy = {

	isFuzzy       = true,
	class   	  = "friend",
	playingActive = false,

	-- Methods:
	-----------
	-- eventCollide()
	-- setPhysics()
	-- wave()
	-- randomSound()
	-- setDelayTillNextChange()
	-- collect()
}


-- Aliases:
local math_random = math.random


function fuzzy.eventCollide(self, event)
    local friend = self.object
    local other  = event.other.object

    if event.phase == "began" and other ~= nil and other.isPlayer then
        other:collected(friend)
    elseif event.phase == "ended" and friend.stealTimer ~= nil then
        timer.cancel(friend.stealTimer)
    end
end


function fuzzy:setPhysics(scale)
    local body    = "dynamic"
    local sensor  = false
    local frame   = "Standard"
    local bounce  = 0
    local s       = self.originalScale * scale
    --local l,t,r,b = -130*s, -200*s, 130*s, 0
    local l,t,r,b = -65*s, -110*s, 65*s, 0

    if self.kinetic == "bounce" then
        bounce = 1
    elseif self.kinetic == "hang" then
        body  = "static"
        sensor = true

        if self.direction == left then
            l,t,r,b = -60*s,  -200*s, 180*s, 120*s
        else
            l,t,r,b = -160*s, -200*s, 60*s, 120*s
        end
    elseif self.kinetic == "hangDouble" then
        body  = "static"
    end

    local stats = {density=0.3, friction=0.3, bounce=bounce, isSensor=sensor, shape={l,t, r,t, r,b, l,b}, filter={ groupIndex=-4 }}
    if not globalIgnorePhysicsEngine then
        physics.addBody(self.image, body, stats)
    end
end


function fuzzy:wave()
    if self.kinetic == nil then
        if math_random(2) == 1 then self:animate("Wave Single") else self:animate("Wave Double") end
        after(1500, function() self:loop("Standard") end)

    elseif self.kinetic == "bounce" then
        if math_random(2) == 1 then self:animate("Wave Single") else self:animate("Wave Double") end
        after(1500, function() self:loop("Jump") end)

    elseif self.kinetic == "hang" then
        self:animate("Hang Left Arm Wave")
        after(1500, function() self:loop("Hang Left Arm Standard") end)
    end

    soundEngine:playManagedAction(self, "random", {sound=self:randomSound(), duration=2000})
    self:setDelayTillNextChange()
end


function fuzzy:randomSound()
	return soundEngine:getRandomFuzzy()
end


function fuzzy:setDelayTillNextChange()
    self.cantChangeYet = true
    local time = 2000 + (math_random(10)*1000)
    after(time, function() self.cantChangeYet = false end)
end


function fuzzy:collect(camera)
    local scale = camera.scaleVelocity

    self:setGravity(0)
    self:intangible()
    self:applyForce(0, -200 * scale)

    self:emit("collect-fuzzy", {xpos=1, ypos=40, duration=2000}, true)

    local seq = anim:chainSeq("fuzzyCollected", self.image)
    seq:tran({time=2000, scale=2.5, alpha=0, playSound=sounds.friendCollected})
    seq.onComplete = function()
        self:destroy(camera)
    end
    seq:start()
end


return fuzzy