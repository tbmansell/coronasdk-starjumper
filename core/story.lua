local anim    = require("core.animations")
local scripts = require("core.story-scripts")

-- @class main storyTeller class
local storyTeller = {}

-- Aliases:
local play = globalSoundPlayer


-- Checks if a story has been seen, should be showed and if so, shows it now or triggers handler to allow later viewing
-- @param storyName          - string which matches one of the story-scripts
-- @param scenePauseHndler   - callback to pause current scene when story starts
-- @param sceneResumeHandler - callback to resume current scene when story finished
-- @param alertHandler       - callback to use for certain storyTeller that dont interrupt thr unning of the game
-- @param scene              - a reference to the scene itself so scripts can call function on it
----
function storyTeller:start(storyName, scenePauseHandler, sceneResumeHandler, alertHandler, scene)
	local story = scripts[storyName]

    if story == nil or (not story.alwaysShow and not state:showStory(storyName)) then
    	return false
    end

    if story.cutscene or story.forced then
    	after(story.delay or 0, function()
    		self:startNow(storyName, scenePauseHandler, sceneResumeHandler, scene)
    	end)
	else
		alertHandler(nil, storyName)
    end
end


-- Checks if a story has been seen and if not displays it straight away
-- @param storyName          - string which matches one of the story-scripts
-- @param scenePauseHndler   - callback to pause current scene when story starts
-- @param sceneResumeHandler - callback to resume current scene when story finished
-- @param scene              - a reference to the scene itself so scripts can call function on it
----
function storyTeller:startNow(storyName, scenePauseHandler, sceneResumeHandler, scene)
	self.storyId = storyName
    self.story   = scripts[storyName]

    if self.story == nil or (not self.story.alwaysShow and not state:showStory(storyName)) then
    	return false
    end

    self.pauseHandler  = scenePauseHandler
	self.resumeHandler = sceneResumeHandler
	self.scene         = scene
	self.sequence 	   = 0
	self.canSkip       = false

	self:setup()

	if self.story.cutscene then
		self:showInCutscene()
	else
		self:showInGame()
	end
end


function storyTeller:setup()
    -- if ingame then remove the players jump grid etc as this gets left
    if hud and hud.camera then
    	curve:clearUp(hud.camera)
    end

    -- lets show the story
    self.prevGameState = state.data.game
    state.data.game    = levelShowStory

    self.pauseHandler()
    audio.pause()
end


function storyTeller:showInCutscene()
	self.speakerNumber = 1
	self.group         = display.newGroup()
	self.story.alpha   = self.story.alpha or 0.01

	newBlocker(self.group, self.story.alpha, 0,0,0, storyTeller.skipEvent, "block")

	after(1000, function() self.canSkip = true end)
	self:run()
end


function storyTeller:showInGame()
	local buttonX = centerX
	if self.story.close == "right" then buttonX = 700 end

	self.speakerNumber = 0
	self.group         = display.newGroup()
	self.story.alpha   = self.story.alpha or 0.5

	newBlocker(self.group, self.story.alpha, 0,0,0, storyTeller.skipEvent, "block")

	self.labelInfo = newText(self.group, "(tap background to resume)", 490, 560, 0.5, "green", "CENTER")
	self.btnClose  = newButton(self.group, buttonX, 510, "close", storyTeller.finish)
	self.btnClose.alpha = 0

	local seq = anim:oustSeq("pulse", self.btnClose)
	seq:add("pulse", {time=2000, scale=0.025})
	seq:start()

	after(1000, function() self.canSkip = true end)
	self:run()
end


-- Runs through the passed story and kicks of the sequence of events
function storyTeller:run()
	local startSound = self.story.startSound or sounds.storyStart
	local bgrMusic   = self.story.bgrMusic   or sounds.tuneStory

	if state.data.gameSettings.music then
		musicChannel = audio.findFreeChannel()
		play(bgrMusic, {channel=musicChannel, loop=-1, fadein=1000})
	end
	
	play(startSound)
	self:runNextEvent()
end


function storyTeller:runNextEvent(ignoreDelay)
	self.sequence = self.sequence + 1

	local sequences = self.story.sequence

	if self.sequence > #sequences then
		local delay = self.story.delayEnd

		if ignoreDelay or delay == nil then
			self:runFinalEvent()
		else
			self.timerHandler = timer.performWithDelay(delay, function() self:runFinalEvent() end)
		end
	else
		local event = sequences[self.sequence]

		if ignoreDelay then
			self:runSequenceEvent(event)
		else
			self.timerHandler = timer.performWithDelay((event.delay or 2000), function() self:runSequenceEvent(event) end, 1)
		end
	end
end


-- Runs a single sequence event from a story sequence
function storyTeller:runSequenceEvent(event)
	self.speakerNumber = self.speakerNumber + 1
	self.timerHandler  = nil

	self:showSpeechBalloon(event)

	if event.action then
		event.action(self.scene)
	end

	self:runNextEvent()
end


function storyTeller:runFinalEvent()
	self.canSkip = false
	self.timerHandler = nil

	-- Cutscenes close out automatically, ingame scripts show close button and keep text on-screen
	if self.story.cutscene then
		self:finish()
	else
		self.btnClose.alpha  = 1
		self.labelInfo.alpha = 0
	end
end


function storyTeller:skipEvent()
	local self = storyTeller

	if self.canSkip then
		if self.timerHandler then
			timer.cancel(self.timerHandler)
			self.timerHandler = nil
		end

		self.sequence = self.sequence - 1
		self:runNextEvent(true)
	end
	-- return true to stop event bubbling
	return true
end


function storyTeller:showSpeechBalloon(event)
	local ypos  = 10
	local group = self.group

	if self.story.cutscene then
		-- cutscene scripts replace the previous balloon
		if self.eventGroup then
			self.eventGroup:removeSelf()
			self.eventGroup = nil
		end
		self.eventGroup = display.newGroup()
		group = self.eventGroup
	else
		-- in game scripts show the balloon one after the other?
		ypos = -120 + (self.speakerNumber * 120) + (event.y or 0)
	end

	local speaker = event.speaker or state.data.playerModel
	local name    = characterData[speaker].title..": "..characterData[speaker].name
	local balloon = newImage(group, "message-tabs/messagetab-"..characterData[speaker].name..(event.size or ""), 0, ypos)
	local title   = newText(group, name, 0, ypos+15, 0.35, "white", "LEFT")
	local message = display.newText(group, event.text, 0, ypos+30, 440, 95, "arial", 18)

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
end


function storyTeller:finish()
	local self = storyTeller

	-- Gaurd for skipping
	if self.finished then return end
	self.finished = true

	state:saveStoryViewed(self.storyId)
	self:cleanup()
	self.resumeHandler(self.prevGameState)

	self.resumeHandler = nil
	self.pauseHandler  = nil
	self.alertHandler  = nil
end


function storyTeller:cleanup()
	if self.timerHandler then
		timer.cancel(self.timerHandler)
		self.timerHandler = nil
	end

	if musicChannel then 
		audio.fadeOut({channel=musicChannel, time=1000}) 
	end

    after(1000, function() 
    	audio.setVolume(1, {channel=musicChannel})
    	musicChannel = nil
	end)

    audio:resume()

    if self.eventGroup then
		self.eventGroup:removeSelf()
		self.eventGroup = nil
	end

	self.group:removeSelf()
	self.group         = nil
	self.btnPlay       = nil
	self.labelInfo     = nil
	self.storyId       = nil
	self.story         = nil
	self.scene         = nil
end


return storyTeller