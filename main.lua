-- Global label used for buld version
globalBuildVersion = "0.12.6"
globalDebugGame    = true

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
require("core.analytics")
-- Expand massive hud object
require("core.hud-gear")
require("core.hud-sequences")
require("core.hud-saving")
require("core.hud-debug")


-- Generate the random number seed
math.randomseed(os.time())

-- turn off phone display status
display.setStatusBar(display.HiddenStatusBar)

-- Create state data structures (empty)
state:initialiseData()

if state:checkForSavedGame() then
    state:loadSavedGame()
    state:validateSavedGame()
end

-- Load in key game sounds that always need to be in memory
sounds:loadStaticSounds()
sounds:loadRandomSounds()


-- Global debug game logic
if globalDebugGame then
    -- Testing: provide 20 lives instead of 2
    globalPlayerLives = 20
    -- Testing: add 100 holocubes
    state.data.holocubes = 100
    -- Testing: Show performance info
    --timer.performWithDelay(1000, displayPerformance, 0)
end


-- Fire off the start scene
local composer = require("composer")
local mode     = "testads"

-- game    play the full game as normal from the title screen
-- cut     load the cutscene with custom params
-- zone    play a particular level
-- record  play a particular level and record it to file
-- gen     generate a new level from an algorithm

if mode == "zone" or mode == "record" then
	if mode == "record" then globalRecordGame = true end

	sounds:loadPlayer(state.data.playerModel)
	state.data.planetSelected = 1
	state.data.zoneSelected   = 25
	state.data.gameSelected   = gameTypeStory
	composer.gotoScene("scenes.play-zone")

elseif mode == "cut" then
	state.data.planetSelected = 2
	state.cutsceneStory       = "cutscene-character-intro"
	state.cutsceneCharacter   = characterReneGrey
	composer.gotoScene("scenes.mothership")

elseif mode == "gen" then
	state.data.planetSelected = 1
	state.data.zoneSelected   = 18
	require("core.level-algorithms"):run("reverse")

elseif mode == "testads" then
	composer.gotoScene("scenes.test-ads")
	
elseif mode == "game" or mode == nil then
	composer.gotoScene("scenes.title")

end
