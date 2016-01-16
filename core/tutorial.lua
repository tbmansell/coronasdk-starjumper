local scripts  = require("core.tutorial-scripts")
local recorder = require("core.recorder")

-- @class main class
local tutorials = {}

-- Local for performance:
local tutorialScript = nil
local tutorialId 	 = nil
local tutorialStep   = nil
local group          = nil
local speechGroup    = nil
-- list of event names that can be controlled
local eventNames     = {"tap-ledge", "prepare-jump", "use-air-gear", "jump-off-swing", "drop-obstacle", "select-gear", "deselect-gear"}

-- Aliases:
local play = globalSoundPlayer


-- global function used to restrict player actions in the game if a tutorial has been set
function allowPlayerAction(eventName, eventTarget, eventParams)
	if state.data.game == levelTutorial and globalTutorialScript then
		return globalTutorialScript:filterEvent(eventName, eventTarget, eventParams)
	else
		-- Hook for game recorder
		if globalRecordGame then
			recorder:recordAction(eventName, eventTarget, eventParams)
		end

		return true
	end
end


-- Checks if a story has been seen, should be showed and if so, shows it now or triggers handler to allow later viewing
function tutorials:start(tutorialName)
	tutorialId     = tutorialName
    tutorialScript = scripts[tutorialName]

    if tutorialScript and state:showTutorial(tutorialId) then
    	after(tutorialScript.delay or 0, function()
    		self:init()
    		self:show()
    	end)
    	return true
    end
end


function tutorials:init()
	state.data.game      = levelTutorial
	self.step            = 0
	globalTutorialScript = self

	hud:levelStartedSequence()
	self:nextSequence()
end


-- runs through the current sequence-step's allowed actions
function tutorials:filterEvent(eventName, eventTarget, eventParams)
	local actions = tutorialStep.actions

	for i=1, #actions do
		local action = actions[i]

		-- special case: allow any action to proceed (for last action in tutorial)
		if action.name == "any" then
			self:nextSequence()
			return true
		end

		-- special case: if our current action is "jump" also allow "prepare-jump" through, but dont jump to next sequence, to allow repeat jumps
		if action.name == "jump" and eventName == "prepare-jump" then
			return true
		end

		if action.name == eventName then
			if action.target == nil or action.target == eventTarget then
				if action.params == nil or self:paramsValid(action.params, eventParams) then
					print("action allowed: "..eventName..": "..tostring(eventTarget))
					self:nextSequence()
					return true
				end
			end
		end
	end
	print("action disallowed: "..eventName..": "..tostring(eventTarget))
	return false
end


function tutorials:paramsValid(actionParams, eventParams)
	if eventParams then
		if actionParams.to then
			local ato = actionParams.to
			local acc = actionParams.accuracy or 0
			local eto = eventParams.to
			return (ato > (eto - acc) and ato < (eto + acc))

		elseif actionParams.pullx then
			return curve:playerAtLockPoint(eventParams.player, eventParams.event)
		end
	end
	return false
end


function tutorials:nextSequence()
	if self.group then
		hud.camera:remove(self.group)
		self.group:removeSelf()
		self.group = nil
	end

	if self.speechGroup then
		self.speechGroup:removeSelf()
		self.speechGroup = nil
	end

	self.step    = self.step + 1
	tutorialStep = tutorialScript.sequence[self.step]

	if tutorialStep == nil then
		self:completed()
	else
		self.group 		 = display.newGroup()
		self.speechGroup = display.newGroup()

		if tutorialStep.showNote then
			self:showNote(tutorialStep.showNote)
		end

		if tutorialStep.showSpeech then
			self:showSpeech(tutorialStep.showSpeech)
		end

		if tutorialStep.customCode then
			tutorialStep.customCode()
		end
	end
end


function tutorials:showNote(note)
	after(note.delay or 0, function()
		newImage(self.group, "message-tabs/tutorial-"..note.image, note.x, note.y, note.size)
		newText(self.group,  note.text, note.x, note.y + note.textY, 0.35, (note.color or "white"), "CENTER", 500)

		if note.inCamera then
			hud.camera:add(self.group, 2)
		end
	end)
end


function tutorials:showSpeech(event)
	after(event.delay or 0, function()
		local speaker = event.speaker
		local name    = characterData[speaker].title..": "..characterData[speaker].name
		local balloon = newImage(self.speechGroup, "message-tabs/messagetab-"..characterData[speaker].name.."-big", 0, event.y)
		local title   = newText(self.speechGroup, name, 0, event.y+15, 0.35, "white", "LEFT")
		local message = display.newText(self.speechGroup, event.text, 0, event.y+30, 440, 95, "arial", 18)

		balloon.anchorY = 0
		balloon:scale(1, 0.7)
		
		message:setFillColor(0,0,0)
		message.anchorX, message.anchorY = 0, 0
		
		if event.dir == left then
			balloon.x = 290
			title.x   = 130
			message.x = 130
		else
			balloon.x = 670
			title.x   = 510
			message.x = 510
		end
	end)
end


function tutorials:show()
	print("tutorial started: "..tutorialId)
end


function tutorials:completed()
	print("tutorial completed")

	curve:freeJump(hud.camera)
	globalTutorialScript = nil

	state.data.game = levelPlaying
	--TODO: save this tutorial in state?
	hud.magnifyIcon.alpha = 1
end



return tutorials