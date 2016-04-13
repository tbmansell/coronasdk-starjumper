local composer = require("composer")
--local analytics  = require("plugin.flurry-analytics")


-- @class global event tracker
local track = {
    -- simple array of all current scene timer handles that need cleaning up when the scene aborts
    timerHandles = {},
    -- simple array of all current scene transition handles that need cleaning up when the scene aborts
    transitionHandles = {},
    -- tracks the current timer key
    timerKey = 0
}


local function getState()
	return {
		player = state.data.playerModel,
        game   = state.data.gameSelected,
        planet = state.data.planet,
        zone   = state.data.zone,
        cuves  = state.data.holocubes,
	}
end


function track:pauseEventHandles()
	for key,handle in pairs(self.timerHandles) do
		if handle ~= nil then
			timer.pause(handle)
		end
	end

	for key,handle in pairs(self.transitionHandles) do
		if handle ~= nil then
			transition.pause(handle)
		end
	end
end


function track:resumeEventHandles()
	for key,handle in pairs(self.timerHandles) do
		if handle ~= nil then
			timer.resume(handle)
		end
	end

	for key,handle in pairs(self.transitionHandles) do
		if handle ~= nil then
			transition.resume(handle)
		end
	end
end


function track:cancelEventHandles()
	for key,handle in pairs(self.timerHandles) do
		if handle ~= nil then
			timer.cancel(handle)
			self.timerHandles[key] = nil
		end
	end

	for key,handle in pairs(self.transitionHandles) do
		if handle ~= nil then
			transition.cancel(handle)
			self.transitionHandles[key] = nil
		end
	end

	self.timerHandles = {}
	self.transitionHandles = {}
	-- WARNING: never reset the timerKey as relying on this does not work. Once a timer peice of code has run, even if it is paused or cancelled
	-- It can still complete and nil the key, which is reset could actually be the key for a new timer entry.
	-- Resetting this made certain deom plays never start as the last timer run cancelled the event for the firs trecorded action
	-- self.timerKey = 0
end


function track:timer(delay, func, loops)
	self.timerKey = self.timerKey + 1
	local key     = self.timerKey

	local event = function()
		if track.timerHandles[key] ~= nil then
			func()
			track.timerHandles[key] = nil
		end
	end

	self.timerHandles[key] = timer.performWithDelay(delay, event, loops)
end


------------------ GLOBAL FUNCTIONS -------------------


-- Improvement on using timer.performWithDelay() for single loops, when you just basically want a delayed action
function after(delay, func)
	if delay == nil or delay == 0 then
		func()
	else
		track:timer(delay, func, 1)
	end
end


-- Improvement on using timer.performWithDelay() for infinite loops
function loop(delay, func)
	track:timer(delay, func, 0)
end


function logAnalytics(event)
end


-- Generates an analytics event for us to track
function logAnalyticsStart()
	--print("[start] "..tostring(composer.getSceneName("current")))
	--analytics.startTimedEvent(composer.getSceneName(), getState())
end


function logAnalyticsEnd()
	--print("[end] "..tostring(composer.getSceneName("current")))
	--analytics.endTimedEvent(composer.getSceneName(), getState())
end


-- Init analytics:
--analytics.init({apikey="BWXBG2NT992ZJ8TP43FW", listener=logAnalytics, crashReportingEnabled=true})


return track