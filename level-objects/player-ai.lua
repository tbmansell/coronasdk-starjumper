local anim             = require("core.animations")
local utils            = require("core.utils")
local pathFinderLoader = require("level-objects.path-finder")


-- @class main player class
local player = {
	-- Methods:
	-----------
	-- wait()
	-- checkAIBehaviour()
	-- aiLanded()
	-- aiGrabbed()
	-- hasCompletedLevel()
	-- checkForKeyGear()
	-- preparedForJump()
	-- holdForNextJump()
	-- analyseNextJump()
	-- destroyPathFinder()
	-- analyseSwing()
	-- analyseHang()
	-- doNextJump()
	-- possibleNextJump()
	-- pathFinderFailed()
}


-- Aliases:
local math_abs    = math.abs
local math_random = math.random
local math_round  = math.round


-- Allows AI logic to be paused and resumed for script purposes
function player:pauseAi(pause)
	self.pauseAiLogic = pause
end


-- Used to tell the AI to wait X seconds before checking for a change of state again
function player:wait(seconds)
	-- currently where the game loop runs for times per second
	self.waitingTimer = seconds * 4
end


-- Main function which the AI uses to edtermine if it should performa and action
function player:checkAIBehaviour(level)
	if self.pauseAiLogic then return end

	local mainPlayer = self.mainPlayerRef

	-- Update any waiting timer
	if self.waitingTimer > 0 then self.waitingTimer = self.waitingTimer - 1 end

	-- Actions to perform only when the players waiting time has completed
	if self.waitingTimer <= 0 then
		local mode = self.mode

		if mode == playerReady then
			-- if AI ahead of main player by X ledges then it will stop and wait for them
			if not self:hasCompletedLevel(level) and
			   self:checkForKeyGear(level) and
			   self:preparedForJump(level) and
			   not self:waitForPlayer(level, mainPlayer)
			then
				self:holdForNextJump()
			end
		elseif mode == playerDrag then
			-- if player preparing for jump, run for jump
			self:analyseNextJump()
		elseif mode == playerSwing then
			self:analyseSwing()
		elseif mode == playerHang then
			self:analyseHang()
		end
	end
end


function player:aiLanded()
	-- only clear pathfinder data for jump just performed, if its not the same ledge we jumped from (e.g. bounced off)
	-- otherwise it will loop, performing all the same jumps
	if self.jumpedFrom and self.jumpedFrom.id ~= self.attachedLedge.id then
		self.pathFinderData = nil
	end

	if not self:onDeadlyLedge() then
		self:wait(self.personality.waitFromLand)
	end
end


function player:aiGrabbed()
	local jumpLogic = self.attachedObstacle.ai
	
	if jumpLogic and jumpLogic.letGoAfter then
        after(jumpLogic.letGoAfter, function()
            if player.mode == playerHang or player.mode == playerSwing then
                player:letGoAction()
            end
        end)
    end
end


function player:hasCompletedLevel(level)
	return self.attachedLedge and self.attachedLedge.id == level:lastLedgeId()
end


function player:onDeadlyLedge()
	local ledge   = self.attachedLedge
	if ledge then
		local surface = ledge.surface
		return ledge.deadly ~= nil or surface == collapsing or surface == lava
	end
	return false
end


-- check s if AI should wait for main player to catchup (how many ledges apart)
function player:waitForPlayer(level, mainPlayer)
	-- dont wait for player if not in personality or on a deadly ledge
	if not self.personality.waitForPlayer or self:onDeadlyLedge() then
		return false
	end

	if not mainPlayer.attachedLedge then
		-- player could be in the middle of dieing so wait
		self:wait(1)
		return true
	end

	local dist = self.attachedLedge.id - mainPlayer.attachedLedge.id

	if self.waitingToCatchup then
		if dist <= self.personality.waitCatchupTo then
			-- player has caught up, so stop waiting
			self.waitingToCatchup = false
			-- check if we're gonna throw a trap for them
			if self.personality.dropTrapOnCatchup then
				self:dropNegable()
				-- wait a second before running off
				self:wait(1)
			end

			return false
		else
			-- check if ai taunts player:
			if self.personality.tauntOnCatchup and not self.taunting then
				after((1+math_random(4))*1000, function()
					if self.mode == playerReady and not self.taunting then 
						self:taunt()
					end
				end)
			end

			-- wait a second to check again if they have caught up
			self:wait(1)
			return true
		end
	elseif dist >= self.personality.waitForPlayer then
		-- change direciton to wait for them
		if (mainPlayer:x() < self:x() and self.direction == right) or
		   (mainPlayer:x() > self:x() and self.direction == left) then
		   self:changeDirection()
		end

		-- if drops traps, then move to front of ledge so good chance it will land where player jumps
		if self.personality.dropTrapOnCatchup then
			local moveBy = self.attachedLedge:rightEdge() - self:x() - 30
			if moveBy > 0 then
				self:moveOnLedge(moveBy)
			end
		end

		-- wait a second to check again if they have caught up
		self:wait(1)
		self.waitingToCatchup = true
		return true
	end
end


-- check current ledge to see if any required gear is selected and go walk to it
function player:checkForKeyGear(level)
	if self.checkedForgear then return true end
	
	local from = self.attachedLedge
	if from then
		for _,object in pairs(from.boundItems) do
			if object.image and object.regenerate then
				local pos = object:x() - self:x()
				self:moveOnLedge(pos)
				self:wait(1)
				self.checkedForgear = true
				return false
			end
		end
	end
	return true
end


-- once landed, detects where the next ledge is, if it needs to reposition by walking,
-- if any gear needs to be used and how long to wait when entering ready drag mode
function player:preparedForJump(level)
	-- Dont recheck all this if already done
	if self.jumpPrepared then return true end

	local from = self.attachedLedge or self.attachedObstacle
	if not from then return false end

	local target   = level:nextAiJumpObject(from.zoneRouteIndex)
	if not target or not target.image then return false end

	local myx, tox = target:x(), target:x()

	self.jumpFrom   = from
	self.jumpTarget = target

	-- if too far forward then walk backward a little bit for the next jump
	if target.isLedge and not self:onDeadlyLedge() then
		local repos = self.personality.reposition
		if repos then
			if (tox > myx and target:rightEdge() - self:x() < repos) then
				self:moveOnLedge(-repos)
				self:wait(1)
				return false
			elseif (tox < myx and target:leftEdge() - self:x() > repos) then
				self:moveOnLedge(repos)
				self:wait(1)
				return false
			end
		end
	end

	self.jumpPrepared = true
	return true
end


-- determines how long player should wait until they do the jump
function player:holdForNextJump()
	-- Recheck direction as could have changed to wait for player
	local from, to = self.jumpFrom, self.jumpTarget

	if from.image == nil or to.image == nil then
		print("AI ledge missing: waiting ")
		self:wait(1)
	end

	local myx, tox = from:x(), to:x()

	if (tox > myx and self.direction == left) or
	   (tox < myx and self.direction == right) then
		self:changeDirection()
	end

	-- Check if next ledge is a moving ledge, that it is within a comfortable reach
	if to.isLedge and (from.isMoving or to.isMoving) then
		local xdist, ydist = from:distanceFrom(to)
		local ax, ay = math_abs(xdist), math_abs(ydist)

		if ax > 500 or ay > 250 then
			--print("waiting for moving ledge distance: ax="..ax.." ay="..ay)
			self:wait(1)
		else
			-- if in range go for it straight away as any delay could miss
			self:readyJump()
		end
	elseif to.deadlyTimer then
		-- logic to say: if arrive at deadly timer ledge and its currently deadly, then wait for it to go non deadly and jump,
		-- but if arrive at ledge and is not deadly, wait for it to go deadly and off again before jumping
		if not to.deadly and self.waitedForDeadlyTimer == 2 then
			self:readyJump()
			self.waitedForDeadlyTimer = 0
		else
			if self.waitedForDeadlyTimer == nil or self.waitedForDeadlyTimer == 0 then
				if to.deadly then self.waitedForDeadlyTimer = 2 else self.waitedForDeadlyTimer = 1 end
			elseif self.waitedForDeadlyTimer == 1 and to.deadly then
				self.waitedForDeadlyTimer = 2
			end
		end
	elseif to.deadly then
		self:wait(1)
	elseif self:onDeadlyLedge() or (to.deadly ~= nil and to.deadly == false) then
		-- if ON or NEXT is a deadly ledge then dont wait go for it
		self:readyJump()
	else
		-- normal ledge so take yer time
		self:wait(self.personality.waitForJump)
		self:readyJump()
	end
end


-- calculates velocity for next jump
function player:analyseNextJump()
	-- clear gear (not negables)
	local gear = self.gear
	if gearSlots[gear[jump]] ~= nega then gear[jump] = nil end
	if gearSlots[gear[air]]  ~= nega then gear[air]  = nil end
	if gearSlots[gear[land]] ~= nega then gear[land] = nil end
	self:setGear(gear)

	-- if level has ai={} override rules, use them here
	local from = self.attachedLedge or self.attachedObstacle
	local jumpLogic = from.ai
	
	if jumpLogic then
		if jumpLogic.loadGear then
			self:setIndividualGear(jumpLogic.loadGear)
		end

		if jumpLogic.useAirGearAfter then
			self.triggerJumpAction = jumpLogic.useAirGearAfter
		end

		if jumpLogic.jumpVelocity then
			local vel = jumpLogic.jumpVelocity
			self:doNextJump(vel[1], -vel[2])
			return
		end
	end

	self.pathFinder = pathFinderLoader:new(self, self:getCamera(), self.jumpFrom, self.direction, self.jumpTarget)
	self.pathFinder:start(player.doNextJump, player.possibleNextJump, player.pathFinderFailed)

	self.mode = playerAnalysingJump
    self:wait(1)
end


function player:destroyPathFinder()
	if self.pathFinder then 
		self.pathFinder:destroy()
		self.pathFinder = nil
	end
end


-- determines when AI jumps of a swing (random at moment)
function player:analyseSwing()
	local swing = self.attachedObstacle

	if swing then
		-- only jump off if swinging same direction as facing
		if self.direction == swing.direction then
			local m = swing.movement
			local lastQuarter = m.arcStart - ((m.arcStart - m.arcEnd) / 4)
			-- allow to jump if swing is in the last quarter in the direction required, as thats most likely the best position
			if m.degree >= lastQuarter then
				self:swingOffAction()
		    end
		end
		-- dont apply a wait as need to respond to swing action very quickly
	end
end


-- determines when AI jumps of a stick pole (random at moment)
function player:analyseHang()
	local from = self.attachedObstacle

	if from and from.isPole and from.sticky then
		local delay = math_random(3)
		after(delay*1000, function() player:letGoAction() end)
		self:wait(delay+1)
	end
end


-- callback from pathFinder for succssful find: run and do the next jump
function player:doNextJump(velx, vely)
	--print("doing jump with vel: "..velx..", "..vely)
	--self:runup(velx*vscale, vely*vscale)
	self:destroyPathFinder()
	self:runup(velx, vely)
	self.jumpPrepared   = false
	self.checkedForgear = false
end


-- callback from pathFinder if shot hits side - AI can choose to do jump if they have gloves
function player:possibleNextJump(velx, vely, hitType)
	if self.jumpTarget.movement then
		--print("AI not doing half jump on moving ledge")

	elseif hitType == "corner" then
		--print("AI not doing corner jump with vel: "..velx..", "..vely)

	elseif hitType == "side" then
		--print("AI doing jump with gloves with vel: "..velx..", "..vely)
		self:setGear({[jump]=nil, [air]=nil, [land]=gearGloves})
		self:doNextJump(velx, vely)
	end
end


function player:pathFinderFailed()
	--print("AI pathFinder couldnt find route, waiting 1 second")

	-- determine what to change on the next jump, and also check if its already been done
	local from   = self.jumpFrom
	local target = self.jumpTarget
	local decide = self.pathFinderData
	local done   = false

	if decide then
		if from and from:topEdge() < target:topEdge() then
			-- logic for lower ledges
			if decide.ignoreLowerJumpModifier == nil then
				decide.ignoreLowerJumpModifier = true
				--print("setting next jump to ignore lower jump modifer")
				-- dont add any more rules to the next jump
				--done = true
			elseif decide.ignoreLowerJumpModifier == true then
				decide.ignoreLowerJumpModifier = "done"
			end
		end

		if not done then
			if decide.changeJumpDistance == nil then
				--print("setting next jump to use distance before")
				decide.changeJumpDistance = -1
				done = true
			elseif decide.changeJumpDistance == -1 then
				--print("setting next jump to use distance after")
				decide.changeJumpDistance = 1
				done = true
			elseif decide.changeJumpDistance == 1 then
				decide.changeJumpDistance = "done"
			end
		end
	end

	self:destroyPathFinder()

	-- dont delay on moving ledge as have to check fast
	if from and not from.isMoving and not target.isMoving and not self:onDeadlyLedge() then
		self:wait(1)
	end
	
	self.mode = playerReady
end


return player