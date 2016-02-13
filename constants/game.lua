-- game types
gameTypeStory       = 1
gameTypeTimeAttack  = 2
gameTypeSurvival    = 3
gameTypeRace        = 4
--gameTypeArcadeTrial = 5
gameTypeTimeRunner  = 5
gameTypeClimbChase  = 6
gameTypeArcadeRacer = 7


gameTypeData = {
    [gameTypeStory]       = {id="gameTypeStory",       name="story",        icon="story",       color="green",  buyOnly=false},
    [gameTypeTimeAttack]  = {id="gameTypeTimeAttack",  name="time attack",  icon="timeattack",  color="aqua",   buyOnly=false},
    [gameTypeSurvival]    = {id="gameTypeSurvival",    name="survival",     icon="survival",    color="red",    buyOnly=false},
    [gameTypeRace]        = {id="gameTypeRace",        name="space race",   icon="spacerace",   color="purple", buyOnly=false, comingSoon=true},
    --[gameTypeArcadeTrial] = {id="gameTypeArcadeTrial", name="arcade trial", icon="arcadetrial", color="green"},
    [gameTypeTimeRunner]  = {id="gameTypeTimeRunner",  name="time runner",  icon="timerunner",  color="red",    buyOnly=false},
    [gameTypeClimbChase]  = {id="gameTypeClimbChase",  name="climb chase",  icon="climbchase",  color="pink",   buyOnly=false},
    [gameTypeArcadeRacer] = {id="gameTypeArcadeRacer", name="arcade racer", icon="spacerace",   color="yellow", buyOnly=false, comingSoon=true},
}

challengeGameType = {
    [gameTypeRace]       = true,
    [gameTypeSurvival]   = true,
    [gameTypeTimeAttack] = true
}

infiniteGameType = {
    --[gameTypeArcadeTrial] = true,
    [gameTypeTimeRunner]  = true,
    [gameTypeClimbChase]  = true,
    [gameTypeArcadeRacer] = true,
}

raceGameType = {
    [gameTypeRace]        = true,
    [gameTypeArcadeRacer] = true,
}


-- basic planet info
planetData = {
    [1] = {name="organia",      color="purple", normalZones=21, secretZones=0, fuzzies=22},
    [2] = {name="apocalypsoid", color="blue",   normalZones=21, secretZones=0, fuzzies=0, buyMode="both"},
    [3] = {name="broken earth", color="green",  normalZones=0,  secretZones=0, fuzzies=0, buyMode="both", comingSoon=true},
}


-- in-game states:
levelStartShowCase = 1  -- when level loads and takes player backwards through level
levelStarted       = 2  -- when player first runs onto ledge, but user cant control them
levelPlaying       = 3  -- normal status when user can control player through the level
levelPaused        = 4  -- when pause hit and all elements in level pause
levelRunScript     = 5  -- when ingame script is running and we stop player interacting 
levelShowStory     = 6  -- when story is shown
levelOverFailed    = 7  -- when player has run out of lives and gets level over screen
levelOverComplete  = 8  -- when player has landed on the finish ledge
levelTutorial      = 9  -- when tutorial mode is actived locking down what the player can do


racePositions = {"1st", "2nd", "3rd", "4th", "5th"}
