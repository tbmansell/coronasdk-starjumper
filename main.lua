-- Global label used for buld version
globalBuildVersion 		   = "0.10.9"
-- Global group used to do stuff during scene transitions
globalSceneTransitionGroup = display.newGroup()
-- Global timer for animating during loading scenes
globalTransitionTimer      = nil
-- Global FPS counter
globalFPS                  = 0
-- Global marker to say if physics functions should not be called when this is set
globalIgnorePhysicsEngine  = false
-- Global marker to allow infinite level generator to mark all generated items, for easy deletion
globalInfiniteStage        = nil
-- Global handler for tutorial object which controls the game
globalTutorialScript       = nil
-- Global flag to determine if played games should be recorded and saved to file
globalRecordGame           = false

-- shortcuts to centerX,Y
centerX 	  = display.contentCenterX
centerY 	  = display.contentCenterY
contentWidth  = display.contentWidth
contentHeight = display.contentHeight

require("constants.globals")
require("core.state")
require("core.track")
require("core.sounds")
require("core.draw")
require("core.movement")
require("core.curve")
require("core.hud")
require("networking.linkup")

-- Generate the random number seed
math.randomseed(os.time())

-- Create state data structures (empty)
state:initialiseData()

if state:checkForSavedGame() then
    state:loadSavedGame()
    state:validateSavedGame()
end

-- Load in all random sounds
sounds:loadRandom()

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
	state.data.planetSelected = 1
	state.data.zoneSelected   = 21
	state.data.gameSelected   = gameTypeStory
	storyboard:gotoScene("scenes.play-zone")

elseif mode == "cut" then
	state.cutsceneStory       = "cutscene-character-intro"
	state.data.planetSelected = 1
	state.cutsceneCharacter   = characterKranio
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
