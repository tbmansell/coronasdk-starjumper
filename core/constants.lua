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
levelSelectingGear = 5  -- when hud overlay is shown to alow player to select their gear
levelShowStory     = 6  -- when story is shown
levelOverFailed    = 7  -- when player has run out of lives and gets level over screen
levelOverComplete  = 8  -- when player has landed on the finish ledge
levelTutorial      = 9  -- when tutorial mode is actived locking down what the player can do

-- player models
characterNewton    = 1
characterSkyanna   = 2
characterHammer    = 3
characterBrainiak  = 4
characterGrey      = 5
characterCyborg    = 6
characterGygax     = 7

-- Player behaviour modes
playerReady         = 0
playerWalk          = 1
playerDrag          = 2
playerRun           = 3
playerJumpStart     = 4
playerJump          = 5
playerFallStart     = 6
playerFall          = 7
playerSwing         = 8
playerHang          = 9
playerClimb         = 10
playerKilled        = 11
playerMissedDeath   = 12
playerCompletedZone = 13
playerAnalysingJump = 14
playerThrowing      = 15
playerTeleporting   = 16
playerOnVehicle     = 17
playerGrappling     = 18

playerNonLandModes    = {playerReady, playerWalk, playerDrag, playerRun, playerJumpStart}
playerNegPersistModes = {playerRun,   playerJumpStart, playerJump, playerFallStart, playerFall, playerSwing, playerHang}
playerAttackableModes = {playerReady, playerWalk, playerDrag, playerRun}

-- AI behaviour modes
stateActive    = 0
stateWaiting   = 1
stateSleeping  = 2
stateLeaving   = 3
stateResetting = 4
stateHiding    = 5
-- AI action modes
actionNothing  = 0
actionShooting = 1
actionTaunting = 2

-- different options for starting a player on a zone:
playerStartWalk  = 1
playerStartStand = 2
playerStartFall  = 3

-- characters
characterData = {
    [characterNewton] = {
        name          = "newton",
        title         = "rookie",
        skin          = "Green Space Man",
        shipSkin      = "green",
        color         = "green",
        playable      = true,
        enemy         = false,
        nativeNegable = nil,
        bio = {
            grade     = "novice",
            home      = "nexus",
            age       = 17,
            likes     = "video games",
            hates     = "hard work",
            ability   = "none",
            throws    = "none",
        }
    },
    [characterSkyanna] = {
        name          = "skyanna",
        title         = "jumper",
        skin          = "Female Alien",
        shipSkin      = "female",
        color         = "aqua",
        playable      = true,
        enemy         = false,
        nativeNegable = negFreezeTarget,
        lockText      = "complete 21 zones in organia to unlock",
        planet        = 1,
        buyMode       = "no",
        bio = {
            grade     = "jumper",
            home      = "nexus",
            age       = 27,
            likes     = "exercise",
            hates     = "warm planets",
            ability   = "fast run",
            throws    = "freeze enemy",
        }
    },
    [characterHammer] = {
        name          = "hammer",
        title         = "jumper",
        skin          = "Muscle Alien",
        shipSkin      = "muscle",
        color         = "yellow",
        playable      = true,
        enemy         = false,
        nativeNegable = negImpactBomb,
        lockText      = "complete 21 zones in apocalypsoid to unlock",
        planet        = 2,
        buyMode       = "no",
        bio = {
            grade     = "jumper",
            home      = "nexus",
            age       = 24,
            likes     = "explosives",
            hates     = "taunts",
            ability   = "iron skin",
            throws    = "impact bomb",
        }
    },
    [characterBrainiak] = {
        name          = "brainiak",
        title         = "enemy",
        skin          = "Brain Enemy",
        shipSkin      = "green",
        color         = "purple",
        playable      = true,
        enemy         = true,
        nativeNegable = negElectrifier,
        lockText      = "buy organia planet pack to unlock",
        planet        = 1,
        buyMode       = "storeOnly",
        bio = {
            grade     = "brain master",
            home      = "organia",
            age       = 20,
            likes     = "fresh brains",
            hates     = "fuzzies",
            ability   = "ledge changer",
            throws    = "electrifier",
        }
    },
    [characterGrey] = {
        name          = "grey",
        title         = "enemy",
        skin          = "Grey Enemy",
        shipSkin      = "green",
        color         = "grey",
        playable      = true,
        enemy         = true,
        nativeNegable = negBackPorter,
        lockText      = "buy apaocalypsoid planet pack to unlock",
        planet        = 2,
        buyMode       = "storeOnly",
        bio = {
            grade     = "great grey",
            home      = "deep space",
            age       = 185,
            likes     = "earth movies",
            hates     = "cows",
            ability   = "teleporter",
            throws    = "back-porter",
        }
    },
    [characterCyborg] = {
        name          = "cyion",
        title         = "enemy",
        skin          = "Brain Enemy",
        shipSkin      = "green",
        color         = "red",
        playable      = false,
        enemy         = true,
        nativeNegable = nil,
    },
    [characterGygax] = {
        name          = "gygax",
        title         = "navigator",
        bonus         = "",
        skin          = "",
        shipSkin      = "",
        hudImage      = "",
        color         = "aqua",
        playable      = false,
        enemy         = false,
    },
}


-- gear categories
jump     = 1
air      = 2
land     = 3
negGood  = 4
negEnemy = 5

gearNames = {
    [jump]     = "jump",
    [air]      = "air",
    [land]     = "land",
    [negGood]  = "good",
    [negEnemy] = "enemy",
}

-- gear names otherwise if images renamed, then we have to rename all over the code
gearSpringShoes = "springshoes"
gearShield      = "shield"
gearFreezeTime  = "freezetime"
gearTrajectory  = "trajectory"

gearGlider      = "glider"
gearParachute   = "parachute"
gearJetpack     = "jetpack"
gearReverseJump = "reversejump"

gearMagnet      = "magnet"
gearDestroyer   = "destroyer"
gearGrappleHook = "grapplehook"
gearGloves      = "gloves"

-- negable names
negDizzy        = "dizzy"
negBooster      = "fixedbooster"

negTrajectory   = "antitrajectory"
negRocket       = "fixedrocket"
negFreezeTarget = "freezetarget"
negImpactBomb   = "impactbomb"

negGravField    = "gravfield"
negTimeBomb     = "timebomb"
negElectrifier  = "electrifier"
negBackPorter   = "backporter"


gearSlots = {
    [gearShield]        = jump,
    [gearFreezeTime]    = jump,
    [gearSpringShoes]   = jump,
    [gearTrajectory]    = jump,
    [gearGlider]        = air,
    [gearParachute]     = air,
    [gearJetpack]       = air,
    [gearReverseJump]   = air,
    [gearMagnet]        = land,
    [gearDestroyer]     = land,
    [gearGrappleHook]   = land,
    [gearGloves]        = land,
    -- negables used as gear for race throwing
    [negTrajectory]     = negGood,
    [negRocket]         = negGood,
    [negFreezeTarget]   = negGood,
    [negImpactBomb]     = negGood,
    [negGravField]      = negEnemy,
    [negTimeBomb]       = negEnemy,
    [negElectrifier]    = negEnemy,
    [negBackPorter]     = negEnemy,
}

-- when certain negables hijack a player gear, this lists which category they take over
negableSlots = {
    [negTrajectory] = jump,
    [negDizzy]      = jump,
    [negBooster]    = air,
    [negRocket]     = air
}

gearUnlocks = {
    [gearTrajectory]    = {unlockAfter=1,  buyMode="both"},
    [gearShield]        = {unlockAfter=2,  buyMode="both"},
    [gearFreezeTime]    = {unlockAfter=3,  buyMode="both"},
    [gearSpringShoes]   = {unlockAfter=4,  buyMode="both"},
    [gearGlider]        = {unlockAfter=5,  buyMode="both"},
    [gearParachute]     = {unlockAfter=6,  buyMode="both"},
    [gearJetpack]       = {unlockAfter=7,  buyMode="both"},
    [gearReverseJump]   = {unlockAfter=8,  buyMode="both"},
    [gearMagnet]        = {unlockAfter=9,  buyMode="both"},
    [gearDestroyer]     = {unlockAfter=10, buyMode="both"},
    [gearGrappleHook]   = {unlockAfter=11, buyMode="both"},
    [gearGloves]        = {unlockAfter=12, buyMode="both"},
}

-- sizes
big      = "big"
medbig   = "medbig"
medium   = "medium"
medsmall = "medsmall"
small    = "small"

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

--ledge surfaces
stone      = "stone"
girder     = "girder"
ice        = "ice"
grass      = "grass"
lava       = "lava"
exploding  = "exploding"
collapsing = "collapsing"
electric   = "electric"
spiked     = "spiked"
spring     = "spring"
pulley     = "pulley"
ramp       = "ramp"
oneshot    = "oneshot"

spineSurfaces = {
    [lava]       = true,
    [exploding]  = true,
    [collapsing] = true,
    [electric]   = true,
    [spiked]     = true,
    [spring]     = true,
    [pulley]     = true,
    [ramp]       = true,
    [oneshot]    = true,
}

deadlyTimedSurfaces = {
    [electric] = true,
    [spiked]   = true,
}

-- ledge score categories
scoreCategoryFirst  = 1
scoreCategorySecond = 2
scoreCategoryThird  = 3

-- star colors
aqua   = 1
pink   = 2
red    = 3
blue   = 4
white  = 5
yellow = 6
green  = 7
orange = 8  -- not used by rings yet

colorNames = {
    [aqua]   = "Aqua",
    [pink]   = "Pink",
    [red]    = "Red",
    [blue]   = "Blue",
    [white]  = "White",
    [yellow] = "Yellow",
    [green]  = "Green",
    [orange] = "Orange",
}

colorCodes = {
    ["Aqua"]   = aqua,
    ["Pink"]   = pink,
    ["White"]  = white,
    ["Red"]    = red,
    ["Blue"]   = blue,
    ["Yellow"] = yellow,
    ["Green"]  = green,
    ["Orange"] = orange,
}

ringValues = {
    [aqua]   = {points=10, cubes=1},
    [pink]   = {points=20, cubes=2},
    [red]    = {points=30, cubes=3},
    [blue]   = {points=40, cubes=4},
    [white]  = {points=50, cubes=5},
    [yellow] = {points=60, cubes=6},
    [green]  = {points=70, cubes=7},
    [orange] = {points=80, cubes=8},
}

collectableObject = {
    ["rings"]      = true,
    ["gear"]       = true,
    ["negable"]    = true,
    ["key"]        = true,
    ["timebonus"]  = true,
    ["warpfield"]  = true,
    ["randomizer"] = true,
}

sceneryObject = {
    ["scenery"] = true,
    ["wall"]    = true,
    ["spike"]   = true,
}

-- award names
awardGoldDigger   = 1
awardSurvivor     = 2
awardJumpPro      = 3
awardSpeedPro     = 4
awardGearMonster  = 5
awardLedgeMaster  = 6

awardDefinitions = {
    [awardSpeedPro] = {
        id   = awardSpeedPro,
        name = "speed pro",
        icon = "speedpro",
        desc = "Awarded for completing a zone within the time limit",
    },
    [awardGoldDigger] = {
        id   = awardGoldDigger,
        name = "gold digger",
        icon = "collector",
        desc = "Awarded for collecting everything in a zone",
    },
    [awardSurvivor] = {
        id   = awardSurvivor,
        name = "survivor",
        icon = "survivor",
        desc = "Awarded for not losing a life in a zone",
    },
    [awardJumpPro] = {
        id   = awardJumpPro,
        name = "jump pro",
        icon = "jumppro",
        desc = "Awarded for 3 great jumps in a row",
    },
    [awardGearMonster] = {
        id   = awardGearMonster,
        name = "gear monster",
        icon = "gearmonster",
        desc = "Awarded for using gear from each category successfulyl in a zone",
    },
    [awardLedgeMaster] = {
        id   = awardLedgeMaster,
        name = "ledge master",
        icon = "ledgemaster",
        desc = "Awarded for turning every scoring ledge green in a zone",
    }
}

racePositions = {"1st", "2nd", "3rd", "4th", "5th"}

-- Pathfinder constants for recording jump data instead of strings
jumpUnobstructed = 1
jumpObstructed   = 2
jumpMaxLow       = 10
jumpMaxHigh      = 11
jumpMiddle       = 12


-- Builtin movement patterns
movePatternHorizontal = 1
movePatternVertical   = 2
movePatternCircular   = 3
movePatternFollow     = 4

-- Builtin movement style modifications
moveStyleRandom    = 1
moveStyleSway      = 2
moveStyleSwaySmall = 3
moveStyleSwayBig   = 4
moveStyleWave      = 5
moveStyleWaveTiny  = 6
moveStyleWaveSmall = 7
moveStyleWaveBig   = 8

-- Preset movement patterns:
movePatternLeftArc    = { {-300,-300}, {300,300}, {-300,300}, {300,-300},  }
movePatternCross      = { {-200,-200}, {200,200,2}, {-200,200}, {200,-200,2}, {200,200}, {-200,-200,2}, {200,-200}, {-200,200,2}, }
movePatternWhooshOval = { {-1500,0,speed=15}, {0,300}, {1500,0,speed=15}, {0,-300} }
movePatternShooter1   = { {-100,0}, {100,-200,speed=5}, {0,200}, {100,0}, {-100,-200,speed=5}, {0,200} }

-- Preset steering configs:
steeringBig   = { cap=0.5, mass=60, radius=60 }
steeringMild  = { cap=0.5, mass=30, radius=30 }
steeringSmall = { cap=0.5, mass=20, radius=20 }
steeringTiny  = { cap=0.5, mass=10, radius=10 }

-- Template movement patterns which require running through *parseMovementPattern() to get the final pattern:
moveTemplateVertical     = { {0,1} }
moveTemplateHorizontal   = { {1, 0} }
moveTemplateDiagonalUp   = { {1,1} }
moveTemplateSlantedUp    = { {0.5,1} }
moveTemplateLeanedUp     = { {1,0.5} }

moveTemplateTriangleDown = { {0.5,0.5}, {0.5,-0.5}, {-1,0} }
moveTemplateTriangleUp   = { {0.5,-0.5}, {0.5,0.5}, {-1,0} }

-- bobbing patterns that loop on themselves (no need to set reverse)
moveTemplateBobUp1       = { {0.5,-1},  {0.5,1},   {-0.5,-1},  {-0.5,1} }
moveTemplateBobUp2       = { {0.75,-1}, {0.75,1},  {-0.75,-1}, {-0.75,1} }
moveTemplateBobUp3       = { {1,-1},    {1,1},     {-1,-1},    {-1,1} }
moveTemplateBobDown1     = { {0.5,1},   {0.5,-1},  {-0.5,1},   {-0.5,-1} }
moveTemplateBobDown2     = { {0.75,1},  {0.75,-1}, {-0.75,1},  {-0.75,-1} }
moveTemplateBobDown3     = { {1,1},     {1,-1},    {-1,1},     {-1,-1} }
moveTemplateBobDiamond1  = { {1,1},     {1,-1},    {-1,-1},    {-1,1} }
moveTemplateBobDiamond2  = { {0.5,1},   {0.5,-1},  {-0.5,-1},  {-0.5,1} }
moveTemplateBobDiamond3  = { {1,0.5},   {1,-0.5},  {-1,-0.5},  {-1,0.5} }

moveTemplateSquare       = { {0,0.5}, {0.5,0}, {0,-0.5}, {-0.5,0} }
moveTemplateDiamond      = { {0.5,0.5}, {0.5,-0.5}, {-0.5,-0.5}, {-0.5,0.5} }
moveTemplateLeftArc      = { {-1,-1}, {1,1}, {-1,1}, {1,-1} }
moveTemplateRightArc     = { {1,-1}, {-1,1}, {1,1}, {-1,-1} }
moveTemplateCross        = { {1,1}, {-1,-1}, {1,-1}, {-1,1}, {-1,-1}, {1,1}, {-1,1}, {1,-1} }
moveTemplateWhooshOval   = { {4,0,speed=10}, {0,-0.5}, {-4,0,speed=10}, {0,0.5} }
moveTemplateShooter1     = { {-0.5,0}, {0.5,-1,speed=5}, {0,1}, {0.5,0}, {-0.5,-1,speed=5}, {0,1} }

moveTemplateJerky        = { {-0.25,0},{0.25,0},  {-0.5,0,speed=1.5},{0.5,0,speed=1.5},  {-0.75,0,speed=1.75},{0.75,0,speed=1.75},  {-1,0,speed=2},{1,0,speed=2} }
moveTemplateJerkyReverse = { {0.25,0}, {-0.25,0}, {0.5,0,speed=1.5}, {-0.5,0,speed=1.5}, {0.75,0,speed=1.75}, {-0.75,0,speed=1.75}, {1,0,speed=2}, {-1,0,speed=2} }

moveTemplateHighRec      = { {0,1}, {0.5,0}, {0,-1}, {-0.5,0} }
moveTemplateSlantedSlight  = { {1,0.3} }
