local lfs   = require("lfs")
local utils = require("core.utils")


local recorder = {

    -- Constants for file paths
    baseSaveDir = system.DocumentsDirectory,
    baseLoadDir = system.ResourceDirectory,
    demoDir     = "demos",
    numberDemos = 8,
	
	-- The number of milliseconds since game started
	time      = nil,
	startTime = nil,
	pauseTime = 0,
	lapseTime = 0,
	-- The game details
	planet    = nil,
	zone      = nil,
	game      = nil,
	player    = nil,

 	-- Array of actions a player takes:
	actions   = {},

	-- A place to stash global state before overwriting it with demo data
	stashed   = {},
}


-- Aliases
local osTime = system.getTimer

-- Local vars
local mainPlayer
local actions
local numActions
local currentAction
local lapse


--[[
	Problems Found with replaying a saved game
	==========================================
	1. Time lapse does add up for each action until it will become a big difference (miss ledge, swing etc): Swings mis-timing looks like this needs to be spot on: player misses swing and then it crashes when trying to swing off
	2. Randomizers - the item collected could be essential to how the level plays out and we would need to record what was selected and force the randomizer to generate it when the demo was played
	3. Cant scan a directory for demos in sysem.ResourceDirectory on android
	4. Trajectory doesnt show
	5. Need to determine if these tiny quick changeDirections can be stripped out but timings kept
]]


-- Sets the time to 0 ready for recording and collects the zone data for saving
function recorder:init()
	self.time      = osTime()
	self.startTime = self.time
	self.lapseTime = 0     
	self.pauseTime = 0
	self.planet    = state.data.planetSelected
	self.zone      = state.data.zoneSelected
	self.game      = state.data.gameSelected
	self.player    = state.data.playerModel
	self.actions   = {}

	if state.demoActions then
		-- We are playing a recorded game
		mainPlayer    = hud.player
		actions       = state.demoActions
		numActions    = #actions
		currentAction = 0
		lapse         = 0

		self:runNextDemoAction()
	end
end


-- Record an action from the player
function recorder:recordAction(eventName, eventTarget, eventParams)
	if globalRecordGame then
		print("recording action")
		local newTime  = osTime() - self.pauseTime
		local timeDiff = newTime  - self.time
		local timeRun  = newTime  - self.startTime

		self.actions[#self.actions+1] = {
			timeDiff = timeDiff,
			timeRun  = timeRun,
			event    = eventName,
			target   = eventTarget,
			params   = eventParams,
		}

		print("Event recorded: runTime="..timeRun.." timeDiff="..timeDiff..", event="..eventName..", target="..tostring(eventTarget))

		self.time = newTime
	end
end


-- Need to handle game pauses so they dont count towards the clock
function recorder:pause()
	self.timeAtPause = osTime()
end

-- Need to handle game pauses so they dont count towards the clock
function recorder:resume()
	self.pauseTime = self.pauseTime + (osTime() - self.timeAtPause)
end


-- Save a recording to file
function recorder:saveGame()
	if not globalRecordGame then return end

	local game       = gameTypeData[self.game]
	local planetName = planetData[self.planet].name
	local charName   = characterData[self.player].name

	local date     = os.date("%Y%m%d_%H%M")
	local filename = game.name .. "_" .. planetName .. "_zone" .. self.zone .. "_" .. charName .. "_" .. date .. ".lua"
	local path     = system.pathForFile(self.demoDir.."/"..filename, self.baseSaveDir)

	local file, errorString = io.open(path, "w")

	if not file then
		print("Error saving recorder data to file: "..filename.." "..errorString)
	else
        file:write("local data = {\n")

		file:write("    game      = "..game.id..",\n")
        file:write("    planet    = "..self.planet..",\n")
        file:write("    zone      = "..self.zone..",\n")
        file:write("    player    = "..self.player..",\n")
        file:write("    actions   = {\n")

        for _,event in pairs(self.actions) do
        	file:write("        {timeRun="..event.timeRun..",\ttimeDiff="..event.timeDiff..",\tevent=\""..event.event.."\"")

        	if event.target then
        		file:write(", target=\""..event.target.."\"")
        	end

        	if event.params then
        		for key,value in pairs(event.params) do
        			if type(value) == "string" then
        				file:write(", "..key.."=\""..value.."\"")
        			else
        				file:write(", "..key.."="..value)
        			end
        		end
        	end

        	file:write("},\n")
        end

		file:write("    }\n")
        file:write("}\n\n")
        file:write("return data")

		io.close(file)
		print("Game Recording saved to: "..path)
	end

	self.actions = nil
end


-- Loads a random recording from the demo folder:
-- NOTE: an mobile devices we cant file scan dirs in the resource location (where app code is) so we cant just pick a random file as we can on desktop
-- Therefore we have to name them nunbered and pick one that way
function recorder:loadRandomDemo()
	if self.numberDemos == nil or self.numberDemos < 1 then
		return false
	end

	local file = "demo" .. math.random(self.numberDemos)

	return self:loadGame(file)
end


-- Loads a specific demo recording into memory as lua code
function recorder:loadGame(filename)
	-- make sure we dont re-record a playing demo
	globalRecordGame = false

	local path = self.demoDir.."."..filename:gsub(".lua", "")
	local data = require(path)

	-- Take a copy of global state
	self.stashed.game   = state.data.gameSelected
	self.stashed.planet = state.data.planetSelected
	self.stashed.zone   = state.data.zoneSelected
	self.stashed.player = state.data.playerModel

	-- Load game data in global state and kick off level
	state.data.gameSelected   = data.game
	state.data.planetSelected = data.planet
	state.data.zoneSelected   = data.zone
	state.data.playerModel    = data.player
	state.demoActions         = data.actions
	
	sounds:loadPlayer(state.data.playerModel)
	return true
end


-- Restores the global state after a demo has been played
function recorder:restoreFromDemo()
	mainPlayer = nil
	actions    = nil

	state.data.gameSelected   = self.stashed.game
	state.data.planetSelected = self.stashed.planet
	state.data.zoneSelected   = self.stashed.zone
	state.data.playerModel    = self.stashed.player

	-- allow time for demo game scene to close before turning off this (or player casn interact with game and crash game)
	after(1500, function() 
		state.demoActions = nil
		sounds:unloadPlayer(state.data.playerModel)
	end)
end


-- Recursises through the loaded demo actions until it reaches the end
function recorder:runNextDemoAction()
	-- Guard for player aborting demo
	if mainPlayer == nil then return end

	currentAction = currentAction + 1

	if currentAction <= numActions and actions ~= nil then
		local action = actions[currentAction]

		--after(action.timeDiff - self.lapseTime, function()
		after(action.timeDiff, function()
			self:runAction(action)
			self:runNextDemoAction()
		end)
	else
		-- debug:
		local newTime = osTime() - recorder.pauseTime
		local timeRun = newTime  - recorder.startTime
		-- end debug
	end
end


-- Runs a specific action
function recorder:runAction(action)
	-- Guard for player aborting demo
	if mainPlayer == nil then return end

	local event  = action.event
	local target = action.target

	-- debug:
	local newTime   = osTime() - self.pauseTime
	local timeDiff  = newTime  - self.time
	local timeRun   = newTime  - self.startTime
	local lapseDiff = timeDiff - action.timeDiff
	local lapseRun  = timeRun  - action.timeRun

	print("Event: "..(string.format("%15s", event)).."\t timeDiff=[real="..timeDiff.." saved="..action.timeDiff.." lapse="..lapseDiff.."], timeRun=[real="..timeRun.." saved="..action.timeRun.." lapse="..lapseRun.."], target="..tostring(target))
	-- end debug
	self.time      = newTime
	self.lapseTime = lapseDiff

	-- Check if there is a problem with running the current event: likely due to a timing error.
	-- If so, the game would crash if we run the event, so instead we close the demo
	if (event == "prepare-jump" or event == "run-up" or event == "tap-ledge") and mainPlayer.attachedLedge == nil then
		return hud:exitZone()
	elseif (event == "jump-off-swing" or event == "drop-obstacle" or event == "escape-vehicle") and mainPlayer.attachedObstacle == nil then
		return hud:exitZone()
	end
	
	-- Safe to run event
	if     event == "select-gear"      then	mainPlayer:setIndividualGear(target)
	elseif event == "prepare-jump"     then	mainPlayer:readyJump()
	elseif event == "change-direction" then	mainPlayer:changeDirection()
	elseif event == "tap-ledge"        then self:runActionTapLedge(action)
	elseif event == "run-up"           then	mainPlayer:runup(action.xvelocity, action.yvelocity)
	elseif event == "use-air-gear"     then	mainPlayer:jumpAction()
	elseif event == "jump-off-swing"   then	mainPlayer:swingOffAction()
	elseif event == "drop-obstacle"    then	mainPlayer:letGoAction()
	elseif event == "escape-vehicle"   then	mainPlayer:escapeVehicleAction()
	end
end


-- Handles tapping a ledge the player is on to walk on OR tapping another ledge for a special ability
function recorder:runActionTapLedge(action)
	local keyStart, _ = string.find(action.target, "_", 7)

	if keyStart then
		local key = action.target:sub(keyStart+1)

		if key then
			local ledge = hud.level:getLedge(tonumber(key))

			if ledge then
				-- Add player X to event X as its recorded with this subtracted
				globalTapLedge({object=mainPlayer.attachedLedge}, {x=action.to + mainPlayer:x()})
			end
		end
	end
end


return recorder