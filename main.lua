-- Global label used for buld version
globalBuildVersion 		   = "0.10.3"
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
globalRecordGame           = true

-- shortcuts to centerX,Y
centerX 	  = display.contentCenterX
centerY 	  = display.contentCenterY
contentWidth  = display.contentWidth
contentHeight = display.contentHeight

require("core.constants")
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
storyboard:gotoScene("scenes.title")


state.data.holocubes = 100
--state.cutsceneStory   = "cutscene-planet-intro"
--state.cutsceneStory     = "cutscene-character-intro"
--state.cutsceneCharacter = characterSkyanna


--[[
-- used for testing only
	sounds:loadPlayer(state.data.playerModel)
	state.data.planetSelected = 1
	state.data.zoneSelected   = 2
	state.data.gameSelected   = gameTypeStory
	--state.data.gameSelected = gameTypeSurvival
	--state.data.gameSelected = gameTypeTimeAttack
	--state.data.gameSelected = gameTypeClimbChase
	--state.data.gameSelected = gameTypeTimeRunner
	--state.data.gameSelected = gameTypeArcadeRacer
	storyboard:gotoScene("scenes.play-zone")
	--storyboard:gotoScene("scenes.mothership")
	--storyboard:gotoScene("scenes.select-zone")
]]
-- Show debug info
	timer.performWithDelay(1000, displayPerformance, 0)
