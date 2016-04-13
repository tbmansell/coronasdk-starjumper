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
-- Global value indicaqting number of lives player has
globalPlayerLives          = 2


require("constants.game")
require("constants.characters")
require("constants.gear")
require("constants.ledges")
require("constants.collectables")
require("constants.movement")


-- shortcuts to centerX,Y
centerX 	  = display.contentCenterX
centerY 	  = display.contentCenterY
contentWidth  = display.contentWidth
contentHeight = display.contentHeight

-- positions
center = 1
left   = 2
right  = 3

-- message types
good    = 1
average = 2
bad     = 3

-- background image categories
bgrFront = 1
bgrMid   = 2
bgrBack  = 3
bgrSky   = 4

skyChangingNight = 1
skyChangingDay   = 2

backgroundNames = {
    [bgrFront] = "front",
    [bgrMid]   = "middle",
    [bgrBack]  = "back",
    [bgrSky]   = "sky"
}

-- Pathfinder constants for recording jump data instead of strings
jumpUnobstructed = 1
jumpObstructed   = 2
jumpMaxLow       = 10
jumpMaxHigh      = 11
jumpMiddle       = 12
