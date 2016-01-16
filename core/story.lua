local anim    = require("core.animations")
local scripts = require("core.story-scripts")

-- @class main stories class
local stories = {}

-- Local for performance:
local story   = nil
local storyId = nil

-- Aliases:
local play = globalSoundPlayer


-- Checks if a story has been seen, should be showed and if so, shows it now or triggers handler to allow later viewing
function stories:start(storyName, scenePauseHandler, sceneResumeHandler, alertHandler)
	storyId = storyName
    story   = scripts[storyId]

    if story == nil or not state:showStory(storyId) then
    	return false
    end

    if story.cutscene or story.forced then
    	after(story.delay or 0, function()
		    self.pauseHandler  = scenePauseHandler
    		self.resumeHandler = sceneResumeHandler
    		self:init()
    		self:show()
    	end)
	else
		alertHandler(nil, storyName)
    end
end


-- Checks if a story has been seen and if not displays it straight away
function stories:startNow(storyName, scenePauseHandler, sceneResumeHandler)
	storyId = storyName
    story   = scripts[storyId]

    if story == nil or not state:showStory(storyId) then
    	return false
    end

    self.pauseHandler  = scenePauseHandler
	self.resumeHandler = sceneResumeHandler

	stories:init()
	stories:show()
end


function stories:init()
    -- if ingame then remove the players jump grid etc as this gets left
    if hud and hud.camera then
    	curve:clearUp(hud.camera)
    end

    -- lets show the story
    state.data.game = levelShowStory

    self.speakerNumber = 0
    self.canSkip       = false
    self.timerHandlers = {}

    self.pauseHandler()
    audio.pause()
end


function stories:show()
	local buttonX = centerX
	if story.close == "right" then buttonX = 700 end

	self.group  = display.newGroup()
	story.alpha = story.alpha or 0.5

	if story.custscene then story.alpha = 0.01 end

    newBlocker(self.group, story.alpha, 0,0,0, stories.acknowledgeStory, "block")

    self.labelInfo = newText(self.group, "(tap background to resume)", 490, 560, 0.5, "green", "CENTER")
    self.btnClose  = newButton(self.group, buttonX, 510, "close", stories.acknowledgeStory)
	self.btnClose.alpha = 0

	local seq = anim:oustSeq("pulse", self.btnClose)
	seq:add("pulse", {time=2000, scale=0.025})
	seq:start()

	after(1000, function() self.canSkip = true end)
	self:run()
end


function stories:acknowledgeStory()
	local self = stories

	if self.canSkip then
		state:saveStoryViewed(storyId)
		self:finish()
		self.resumeHandler()
	end
	return true
end


-- local version of global after() so timers can be killed when story is
function stories:storyAfter(delay, func)
	self.timerHandlers[#self.timerHandlers+1] = timer.performWithDelay(delay, func, 1)
end


-- Runs a single sequence event from a story sequence
function stories:runSequenceEvent(event)
	if event.type == "finish" then
		self:finish()
		self.resumeHandler()
		self.resumeHandler = nil

	elseif event.type == "gotit" then
		self.btnClose.alpha  = 1
		self.labelInfo.alpha = 0
	else
		self.speakerNumber = self.speakerNumber + 1

		local speaker = event.speaker or state.data.playerModel
		local name    = characterData[speaker].title..": "..characterData[speaker].name
		local ypos    = -120 + (self.speakerNumber * 120) + (event.y or 0)
		local balloon = newImage(self.group, "message-tabs/messagetab-"..characterData[speaker].name..(event.size or ""), 0, ypos)
		local title   = newText(self.group, name, 0, ypos+15, 0.35, "white", "LEFT")
		local message = display.newText(self.group, event.text, 0, ypos+30, 440, 95, "arial", 18)

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
end


-- Runs through the passed story and kicks of the sequence of events
function stories:run()
	local startSound = story.startSound or sounds.storyStart
	local bgrMusic   = story.bgrMusic   or sounds.tuneStory

	if state.data.gameSettings.music then
		musicChannel = audio.findFreeChannel()
		play(bgrMusic, {channel=musicChannel, loop=-1, fadein=1000})
	end
	
	play(startSound)

	local delay = 0
	for _,event in pairs(story.sequence) do
		delay = delay + (event.delay or 2000)
		self:storyAfter(delay, function() self:runSequenceEvent(event) end)
	end

	-- once all sequences are done, we show thr gotit buton
	self:storyAfter(delay+1000, function() self:runSequenceEvent({type="gotit"}) end)
end


function stories:finish()
	if self.timerHandlers then
		for _,handler in pairs(self.timerHandlers) do
			timer.cancel(handler)
		end
	end

	if musicChannel then 
		audio.fadeOut({channel=musicChannel, time=1000}) 
	end

    after(1000, function() 
    	audio.setVolume(1, {channel=musicChannel})
    	musicChannel = nil
	end)

    audio:resume()

	self.group:removeSelf()
	self.group         = nil
	self.btnPlay       = nil
	self.labelInfo     = nil
	self.timerHandlers = nil
end


return stories