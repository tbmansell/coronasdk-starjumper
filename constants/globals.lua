require("constants.game")
require("constants.characters")
require("constants.gear")
require("constants.ledges")
require("constants.collectables")
require("constants.movement")

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
