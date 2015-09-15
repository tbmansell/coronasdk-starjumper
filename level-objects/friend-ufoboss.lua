local anim    	  = require("core.animations")
local soundEngine = require("core.sound-engine")
local utils       = require("core.utils")


-- @class Fuzzy friend class
local ufoBoss = {

	isBossShip    = true,
	class         = "friend",
	model         = characterGygax,
    inPhysics     = false,
    playingActive = false,

	-- Methods:
	-----------
	-- fadeTrail()
	-- movementCompleted()
	-- reachedPatternPoint()
	-- nextPositionStarted()
}


-- Aliases:
local math_random = math.random


-- Fades the trail
-- @param alpha - to fade to
-- @param destroyAfter - true to destroy after faded
----
function ufoBoss:fadeTrail(alpha, destroyAfter)
	if self.boundTrail then
		local seq = anim:oustSeq("fadeTrail"..self.key, self.boundTrail)
		seq:tran({alpha=alpha, time=500})

		if destroyAfter then
			seq.onComplete = function() self:destroyEmitter() end
		end

		seq:start()
	end
end


-- Remove itself from the movement collection to stop moving
----
function ufoBoss:movementCompleted()
    self:stop()
    self:loop("Stationary")
    self:fadeTrail(0, true)

    if self.racer then
        hud:racerCompletedZone(self)
    end
end


-- Action triggered when ufo reaches next movement point
----
function ufoBoss:reachedPatternPoint()
    if not self.waitingForNextDrop then
        self.waitingForNextDrop = true

        local dropper = self.gearDropper
        local gear    = utils.percentFrom(dropper.gear)
        local amount  = state:gear(gearSlots[gear], gear)

        if amount < (dropper.limit or 1) and hud.level then
            hud.level:generateGear(self:x(), self:y(), gear)
        end

        after((dropper.wait or 3000), function()
            self.waitingForNextDrop=false
        end)
    end
end


-- Hook for when moving to next point to generate trail and move it to the correct angle
----
function ufoBoss:nextPositionStarted()
    local xvel = self.movement.nextX
    local yvel = self.movement.nextY

    if xvel ~= 0 or yvel < 0 then
    	if self.boundEmitter == nil then
            self:bindEmitter("ufo-trail", {xpos=1, ypos=-10})
    		self.boundEmitter:scale(0.35, 0.35)

    	elseif not self.boundEmitterOn then
    		--self:fadeTrail(1)
    		--self.trailHidden = false
            self.boundEmitter:start()
            self.boundEmitterOn = true
    	end
    	
    	-- these angles dont relate to normal as their default is 90
    	if xvel > 0 then
    		self.boundEmitter.angle = 180
    	elseif xvel < 0 then
    		self.boundEmitter.angle = 0
    	else
    		self.boundEmitter.angle = 90
    	end
    else
    	if self.boundEmitter then
            self.boundEmitter:stop()
            self.boundEmitterOn = false
    		--self:fadeTrail(0)
    		--self.trailHidden = true
    	end
    end
end


return ufoBoss