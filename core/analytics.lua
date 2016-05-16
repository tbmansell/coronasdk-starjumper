local analytics = require("plugin.flurry.analytics")
local composer  = require("composer")

-- Local vars:
--[[local]] isSimulator  = (system.getInfo("environment") == "simulator")
--[[local]] anaylticsKey = nil


if system.getInfo("platformName") == "iPhone OS" then
	anaylticsKey = "JD92HH8QYHDBZ5H7RX7S"
else
	anaylticsKey = "QX43FJYZM6RSRQR9T2B5"
end


local function debugStatus(text, reset)
	--[[if reset then
    	if statusGroup then
        	statusGroup:removeSelf()
        	debugText:removeSelf()
        	bgr:removeSelf()
        end

        statusGroup = display.newGroup()
        bgr = display.newRoundedRect(centerX, 150, 880, 400, 15)
	    bgr:setFillColor(0.3,    0.3,  0.3,  0.85)
	    bgr:setStrokeColor(0.75, 0.75, 0.75, 0.75)
	    bgr.strokeWidth = 2
	    bgr.alpha = 0.6

	    debugText = display.newText({text=text, x=centerX, y=330, width=900, height=400, fontSize=22, align="center"})
	else
		debugText.text = debugText.text.."\n"..text
    end]]
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
	debugStatus("listener: "..tostring(event.phase).." err="..tostring(event.isError).." name="..tostring(event.name).." event="..tostring(event.data.event))

	--[[if event.phase == "init" then
		if event.isError then
			-- log an error
			analytics.logEvent(event.name, {event=event.data.event, errorCode=event.data.errorCode, reason=event.data.reason})
		else
			-- log a game event
			analytics.logEvent(event.data.event, event.data.params)
		end
	end]]
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
		print("[logEvent] "..eventName.." "..data)
	else
		debugStatus("logEvent", true)
		analytics.logEvent(eventName, params)
		debugStatus("loggedEvent")
	end
end


-- Generates an analytics event for us to track
function logAnalyticsStart()
	if isSimulator then
		print("[start] "..tostring(composer.getSceneName("current")))
	else
		debugStatus("startTimedEvent", true)
		analytics.startTimedEvent(composer.getSceneName("current"), getState())
		debugStatus("startedTimedEvent")
	end
end


function logAnalyticsEnd()
	if isSimulator then
		print("[end] "..tostring(composer.getSceneName("current")))
	else
		debugStatus("endTimedEvent", true)
		analytics.endTimedEvent(composer.getSceneName("current"), getState())
		debugStatus("endedTimedEvent")
	end
end


-- Init analytics:
if not isSimulator then
	debugStatus("init", true)
	analytics.init(flurryListener, {apiKey=anaylticsKey, logLevel="default", crashReportingEnabled=true})
	debugStatus("inited")
end
