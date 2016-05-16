local analytics = require("plugin.flurry.analytics")
local composer  = require("composer")

-- Local vars:
local isSimulator  = (system.getInfo("environment") == "simulator")
local anaylticsKey = nil


if system.getInfo("platformName") == "iPhone OS" then
	anaylticsKey = "JD92HH8QYHDBZ5H7RX7S"
else
	anaylticsKey = "QX43FJYZM6RSRQR9T2B5"
end


local function getState()
	return {
		player = tostring(state.data.playerModel),
        game   = tostring(state.data.gameSelected),
        planet = tostring(state.data.planet),
        zone   = tostring(state.data.zone),
        cubes  = tostring(state.data.holocubes),
	}
end


local function flurryListener(event)
end


function logAnalyticsEvent(eventName, params)
	for key,value in pairs(getState()) do
    	params[key] = value
    end

    if isSimulator then
    	local data = ""
		for key,value in pairs(params) do
			data = data..key.."="..value..", "
		end
		--print("[logEvent] "..eventName.." "..data)
	else
		analytics.logEvent(eventName, params)
	end
end


-- Generates an analytics event for us to track
function logAnalyticsStart()
	if isSimulator then
		--print("[start] "..tostring(composer.getSceneName("current")))
	else
		analytics.startTimedEvent(composer.getSceneName("current"), getState())
	end
end


function logAnalyticsEnd()
	if isSimulator then
		--print("[end] "..tostring(composer.getSceneName("current")))
	else
		analytics.endTimedEvent(composer.getSceneName("current"), getState())
	end
end


-- Init analytics:
if not isSimulator then
	analytics.init(flurryListener, {apiKey=anaylticsKey, logLevel="default", crashReportingEnabled=true})
end
