-- Global label used for buld version
globalBuildVersion = "0.10.12"

-- Define global constants
require("constants.globals")

-- Define global objects
state  = require("core.state")
track  = require("core.track")
sounds = require("core.sounds")
curve  = require("core.curve")
hud    = require("core.hud")

-- Define global functions
require("core.draw")
require("core.movement")
-- Expand massive hud object
require("core.hud-gear")
require("core.hud-sequences")
require("core.hud-saving")
require("core.hud-debug")


-- Generate the random number seed
math.randomseed(os.time())

-- Create state data structures (empty)
state:initialiseData()

if state:checkForSavedGame() then
    state:loadSavedGame()
    state:validateSavedGame()
end

-- Load in key game sounds that always need to be in memory
sounds:loadStaticSounds()
sounds:loadRandomSounds()

-- Fire off the start scene
local storyboard = require("storyboard")
local mode       = "play"


-- game:   play the full game as normal from the title screen
-- cut     load the cutscene with cusotm params
-- play:   play a particular level
-- record  play a particular level and record it to file
-- gen     generate a new level from an algorithm


if mode == "play" or mode == "record" then
	if mode == "record" then globalRecordGame = true end

	sounds:loadPlayer(state.data.playerModel)
	state.data.planetSelected = 2
	state.data.zoneSelected   = 1
	state.data.gameSelected   = gameTypeStory
	storyboard:gotoScene("scenes.play-zone")

elseif mode == "cut" then
	state.data.planetSelected = 2
	state.cutsceneStory       = "cutscene-character-intro"
	state.cutsceneCharacter   = characterReneGrey
	storyboard:gotoScene("scenes.mothership")

elseif mode == "gen" then
	state.data.planetSelected = 1
	state.data.zoneSelected   = 18
	require("core.level-algorithms"):run("reverse")

elseif mode == "game" or mode == nil then
	storyboard:gotoScene("scenes.title")
end


-- Testing: add 100 holocubes
state.data.holocubes = 100

-- Testing: Show performance info
--timer.performWithDelay(1000, displayPerformance, 0)
