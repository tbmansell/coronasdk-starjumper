local engine           = {}
local soundQueue       = {}
local timerHandlers    = {}

local debugGroup       = nil
local updateInterval   = 250  -- time between checks of the loop
local loopCounter      = 0
local shouldTidy	   = false -- true if an item has been removed at some point
local reservedChannels = 0
local enabled          = true


-- lists regions of different sound volumes
-- 1=left, 2=right, 3=top, 4=bottom, 5=volume
local soundRanges = {
	
	[1]  = {-1200, 2100,  -1200, 1800,	0},
	[2]  = {-800,  1700,  -800,  1400,	0.1},
	[3]  = {-700,  1600,  -700,  1300,	0.2},
	[4]  = {-600,  1500,  -600,  1200,	0.3},
	[5]  = {-500,  1400,  -500,  1100,	0.4},
	[6]  = {-400,  1300,  -400,  1000,	0.5},
	[7]  = {-300,  1200,  -300,  900,	0.6},
	[8]  = {-200,  1100,  -200,  800,	0.7},
	[9]  = {-100,  1000,  -100,  700,	0.8},
	[10] = {0,     900,   0,     600,	0.9},
	[11] = {100,   800,   100,   500, 	1},
	
	--[[
	[1]  = {-400, 1300, -400, 1100,	0},
	[2]  = {-350, 1250, -350, 1050,	0.1},
	[3]  = {-300, 1200, -300, 1000,	0.2},
	[4]  = {-250, 1150, -250, 950,	0.3},
	[5]  = {-200, 1100, -200, 800,	0.4},
	[6]  = {-150, 1050, -150, 750,	0.5},
	[7]  = {-100, 1000, -100, 700,	0.6},
	[8]  = {-50,  950,  -50,  650,	0.7},
	[9]  = { 0,   900,   0,   600,	0.8},
	[10] = { 50,  850,   50,  550,	0.9},
	[11] = { 100, 800,   100, 500, 	1},
	]]
}

local soundList 	 = sounds
local math_random 	 = math.random
local play 			 = globalSoundPlayer
local stop 			 = audio.stop
local seek 			 = audio.seek
local fadeout    	 = audio.fadeOut
local setVolume 	 = audio.setVolume
local getVolume		 = audio.getVolume
local setMaxVolume 	 = audio.setMaxVolume
local freeChannel 	 = audio.findFreeChannel
local channelPlaying = audio.isChannelPlaying


------------- LOCAL FUNCTIONS -----------------

-- local version of global after() so timers can be killed when story is
local function bgrAfter(delay, func)
	timerHandlers[#timerHandlers+1] = timer.performWithDelay(delay, func, 1)
end


-- stops any timer events so sounds dont drag on - also used to stop background sounds
local function cancelTimerHandles()
	for key,handle in pairs(timerHandlers) do
		if handle ~= nil then
			timer.cancel(handle)
			timerHandlers[key] = nil
		end
	end
	timerHandlers = {}
end


-- if the sound if a constant sound then trigger a callback if the element still exists
local function resetConstantSound(params)
	if params.action == "constant" and params.source then
		params.source:constantSoundHandler(false, 250)
	end
end


-- Checks if an object is within the furthesr range we play a sound from
local function inSoundRange(sourceObject, range)
	local x, y = sourceObject.image.x, sourceObject.image.y
	local distance = soundRanges[range]

	return x >= distance[1] and x <= distance[2] and y >= distance[3] and y <= distance[4]
end


-- Checks which sound range an object is in, returns -1 if out of range
local function getSoundRange(sourceObject)
	-- Play safe as item could have been deleted since it was palced in the sound engine
	if sourceObject.image then
		local x, y = sourceObject.image.x, sourceObject.image.y

		if x and y then
			for i=#soundRanges, 1, -1 do
				local distance = soundRanges[i]
				if x >= distance[1] and x <= distance[2] and y >= distance[3] and y <= distance[4] then
					return distance[5]
				end
			end
		end
	end
	return -1
end


local function tidySoundQueue()
	local num = #soundQueue
	for i=num, 1, -1 do
		if soundQueue[i] == nil then
			table.remove(soundQueue, i)
		end
	end
end


-- Hunts through the queue and stops a sound if a key matches, optionally fading out if passed
local function soundInQueue(key)
	local num = #soundQueue
	for i=1, num do
		local params = soundQueue[i]
		if params and params.key == key then
			return true
		end
	end
	return false
end



-- Plays a random sound from a set passed
local function playRandom(set)
    play(set[math_random(#set)])
end


local function playCustom(params)
	local sound     = params.sound
	local seekStart = params.seek
	local volume    = params.volume
	local channel   = params.channel
	local passed    = params.durationPassed or 0
	local source    = params.source

	-- Check if specifically set seek point or duration has passed and need to set seek point
	if seekStart then
		seek(seekStart, {channel=channel})
	elseif passed > 0 then
		seek(passed, {channel=channel})
	end

	play(sound, params)

	-- Check if specifically requesting a volume or is a managed sound so determine the volume
	if volume and channel then
		setVolume(volume, {channel=channel})
	elseif source then
		local volume = getSoundRange(source)
		setVolume(volume, {channel=channel})
	end
end


-- Play a level ambient background sound
local function playBackground(params)
	local delay = math_random(params.quietTime)
	bgrAfter(delay, function()
		local channel   = params.channel
		local seekStart = math_random(params.length/2)
		local duration  = math_random(params.length/2)
		local volume    = math_random(params.minVolume + params.maxVolume)/10

		seek(seekStart,      {channel=channel})
		setMaxVolume(volume, {channel=channel})
		play(params.sound, params)

		bgrAfter(duration, function()
			fadeout({channel=params.channel, time=2000})
			
			bgrAfter(2000, function()
				setVolume(volume, {channel=channel})
				playBackground(params)
			end)
		end)
	end)
end


-- Plays a sound if its in range and there is a free channel
-- returns: -1     if source object out of range to add to queue,
--           false if should add to queue but didnt actually play the sound (no free channel / in quiet zone)
-- 			 true  if played and should add to queue
local function checkShouldPlay(params)
	local source = params.source

	-- Is it outside the range where we would add it to the queue?
	if not inSoundRange(source, 1) then
		return -1
	end

	-- Is it in the quiet range where we dont play it, but we keep it in the queue in-case it moves into the playable range?
	local volume = getSoundRange(source)

	if volume == 0 and params.action ~= "constant" then
		-- Allow sounds within a certain range that re not played yet but ont the boundary
		return true
	else
		local channel = freeChannel()

		if channel == 0 then
			return false
		else
			params.channel = channel
			params.volume  = volume
			params.started = true
			playCustom(params)
			return true
		end
	end
end


-- Removes an item from the soundQueue
local function removeManagedSound(index, params)
	-- gaurd for onComplete
	if soundQueue == nil then return end

	local channel = params.channel
	local fade    = params.fadeout

	if fade then
		fadeout({channel=channel, time=fade})
		after(fade, function()
			soundQueue[index] = nil
			shouldTidy = true
		end)
	elseif params.channel then
		stop(params.channel)
		soundQueue[index] = nil
		shouldTidy = true
	end

	resetConstantSound(params)
end


-----------  PUBLIC FUNCTIONS ------------


-- These sounds also need managing for their volume over time, same as playManaged. The difference is the params are passed in as a table for flexibility 
-- and the sound is uniquely identified by the sourceObject key plus the action name - as some source objects can produce multiple sounds at once
-- Note: this also checks if the same action is running and aborts if so
function engine:playManagedAction(sourceObject, actionName, params)
	-- safety check so we can safely pass in nils without always having to check in the source object (more compact calling code)
	if sourceObject and actionName and params and enabled then
		local key     = sourceObject.key..":"..actionName
		local queueId = #soundQueue + 1

		if soundInQueue(key) then
			-- signal that sound is already in the queue
			return 0
		end

		self:stopSound(key)

		params.started 		  = false
		params.durationPassed = 0
		params.key            = key
		params.source 		  = sourceObject
		params.action         = actionName
		params.onComplete 	  = function() removeManagedSound(queueId, params) end

		if checkShouldPlay(params) == true then
			soundQueue[queueId] = params
			-- signal that the sound has just been added
			return 1
		else
			resetConstantSound(params)
		end
	end

	-- signal that the sound could not be added
	return -1
end


-- function to call within a loop to update eahc sound and see what needs removing
function engine:updateSounds()
	local num = #soundQueue
	for i=1, num do
		local params = soundQueue[i]
		if params then
			local channel  = params.channel or ""
			local started  = params.started
			local duration = params.duration
			
			-- Update its durationPassed if its not a looping sound
			if duration ~= "forever" then
				params.durationPassed = (params.durationPassed or 0) + updateInterval
			end

			-- check if it needs removing due to time passing
			if duration ~= "forever" and params.durationPassed >= (duration or 0) then
				removeManagedSound(i, params)

			elseif started then
				-- if a sound is loaded with a set volume we dont vary it by distance
				local suggestedVolume = getSoundRange(params.source)
				local actualVolume    = tonumber(string.format("%.1f", getVolume({channel=channel})))

				-- if now out of range then remove Sound
				if suggestedVolume == -1 then
					removeManagedSound(i, params)

				elseif suggestedVolume ~= actualVolume and suggestedVolume ~= params.volume then
					setVolume(suggestedVolume, {channel=channel})
				end
			elseif checkShouldPlay(params) == -1 then
				removeManagedSound(i, params)
			end
		end
	end

	-- soundQueue cleanup now and then
	loopCounter = loopCounter + 1
	if shouldTidy and loopCounter > 10 then
		tidySoundQueue()
		loopCounter = 0
		shouldTidy = false
	end
end


-- Hunts through the queue and stops a sound if a key matches, optionally fading out if passed
function engine:stopSound(key, actionName)
	local num = #soundQueue

	if actionName then
		key = key..":"..actionName
	end

	for i=1, num do
		local params = soundQueue[i]
		if params and params.key == key then
			removeManagedSound(i, params)
			return true
		end
	end
	
	return false
end


-- GET a random sound from a set (for sequences)


function engine:getRandom(set)
    return set[math_random(#set)]
end


function engine:getRandomImpact()
    return self:getRandom(soundList.impacts)
end


function engine:getRandomRing()
	return self:getRandom(soundList.rings)
end


function engine:getRandomFuzzy()
	return self:getRandom(soundList.fuzzies)
end


function engine:getRandomGreyTalking()
	return self:getRandom(soundList.greysTalking)
end


function engine:getRandomPlayerFall()
	return self:getRandom(soundList.playerFalls)
end


function engine:getPlayerJump(type)
    return self:getRandom(soundList.playerJump[type])
end


function engine:getPlayerImpact(type)
    return self:getRandom(soundList.playerLand[type])
end


function engine:getPlayerWorry(type)
    return self:getRandom(soundList.playerLandEdge[type])
end


function engine:getPlayerCelebrate(type)
    return self:getRandom(soundList.playerCelebrate[type])
end


function engine:getPlayerTaunt(type)
    return self:getRandom(soundList.playerTaunt[type])
end



-- Loads in the ambiant sounds for a zone and keep them playing
function engine:loadBackgroundSounds(spec)
	reservedChannels = #spec
	audio.reserveChannels(reservedChannels)

	for i=1, reservedChannels do
		local params = spec[i]

		params.channel = i
		params.length  = audio.getDuration(params.sound)/2
		params.fadein  = 2000
		playBackground(params)
	end
end


function engine:stopBackgroundSounds()
	cancelTimerHandles()
	
	for i=1, reservedChannels do
		stop(i)
	end

	audio.reserveChannels(0)
	setMaxVolume(1, 0)
	reservedChannels = 0
end


function engine:setup()
	soundQueue       = {}
	timerHandler     = {}
	loopCounter      = 0
	reservedChannels = 0
	enabled          = true
end


function engine:disable()
	enabled = false
end


function engine:destroy()
	print("engine:destroy()")
	engine:stopBackgroundSounds()

	soundQueue     = nil
	channelsActive = nil
	stop()
end


return engine