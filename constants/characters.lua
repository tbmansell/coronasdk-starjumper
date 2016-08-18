-- core models
characterGygax      = 1
characterNewton     = 2
-- planet one:
characterSkyanna    = 3
characterBrainiak   = 4
characterKranio     = 5
-- planet two:
characterHammer     = 6
characterEarlGrey   = 7
characterReneGrey   = 8
-- planet three:
characterCykill     = 9
characterRobocop    = 10


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

playerNonLandModes      = {playerReady, playerWalk,      playerDrag, playerRun,       playerJumpStart}
playerNegPersistModes   = {playerRun,   playerJumpStart, playerJump, playerFallStart, playerFall, playerSwing, playerHang}
playerNegAnimBlockModes = {playerSwing, playerOnVehicle, playerHang, playerGrappling, playerClimb, playerKilled, playerThrowing}
playerAttackableModes   = {playerReady, playerWalk,      playerDrag, playerRun}

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


characterData = {
    [characterGygax] = {
        name          = "gygax",
        playable      = false,
        enemy         = false,
        title         = "navigator",
        bonus         = "",
        skin          = "",
        shipSkin      = "",
        hudImage      = "",
        color         = "aqua",
    },
    [characterNewton] = {
        name          = "newton",
        playable      = true,
        enemy         = false,
        title         = "rookie",
        skin          = "Green Space Man",
        shipSkin      = "green",
        color         = "green",
        nativeNegable = nil,
        soundIndex    = characterNewton,
        soundFolder   = "newton",
        bio = {
            grade     = "novice",
            home      = "nexus",
            age       = 15,
            likes     = "video games",
            hates     = "hard work",
            ability   = "none",
            throws    = "none",
        }
    },
    [characterSkyanna] = {
        name          = "skyanna",
        playable      = true,
        enemy         = false,
        title         = "jumper",
        skin          = "Female Alien",
        shipSkin      = "female",
        color         = "aqua",
        nativeNegable = negFreezeTarget,
        lockText      = "complete 21 zones in organia to unlock",
        planet        = 1,
        buyMode       = "no",
        soundIndex    = characterSkyanna,
        soundFolder   = "skyanna",
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
    [characterBrainiak] = {
        name          = "brainiak",
        playable      = false,
        enemy         = true,
        title         = "brain master",
        skin          = "Brain Enemy",
        shipSkin      = "brain",
        color         = "purple",
        nativeNegable = negElectrifier,
        planet        = 1,
        soundIndex    = characterBrainiak,
        soundFolder   = "brainiak",
    },
    [characterKranio] = {
        name          = "kranio",
        playable      = true,
        enemy         = false,
        title         = "son of brainiak",
        skin          = "Brain Enemy - Alt",
        shipSkin      = "brain",
        color         = "purple",
        nativeNegable = negElectrifier,
        lockText      = "buy organia planet pack to unlock",
        planet        = 1,
        buyMode       = "storeOnly",
        soundIndex    = characterBrainiak,
        soundFolder   = "brainiak",
        bio = {
            grade     = "jumper",
            home      = "organia",
            age       = 17,
            likes     = "vegetables",
            hates     = "brainiak",
            ability   = "mind matter",
            throws    = "electrifier",
        }
    },
    [characterHammer] = {
        name          = "hammer",
        playable      = true,
        enemy         = false,
        title         = "jumper",
        skin          = "Muscle Alien",
        shipSkin      = "muscle",
        color         = "yellow",
        nativeNegable = negImpactBomb,
        lockText      = "complete 21 zones in apocalypsoid to unlock",
        planet        = 2,
        buyMode       = "no",
        soundIndex    = characterHammer,
        soundFolder   = "hammer",
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
    [characterEarlGrey] = {
        name          = "earlgrey",
        playable      = false,
        enemy         = true,
        title         = "grey lord",
        skin          = "Grey Enemy",
        shipSkin      = "grey",
        color         = "grey",
        nativeNegable = negBackPorter,
        planet        = 2,
        soundIndex    = characterEarlGrey,
        soundFolder   = "earlgrey",
    },
    [characterReneGrey] = {
        name          = "renegrey",
        playable      = true,
        enemy         = false,
        title         = "renegade grey",
        skin          = "Grey - Alt",
        shipSkin      = "grey",
        color         = "grey",
        nativeNegable = negBackPorter,
        lockText      = "buy apaocalypsoid planet pack to unlock",
        planet        = 2,
        buyMode       = "storeOnly",
        soundIndex    = characterEarlGrey,
        soundFolder   = "earlgrey",
        bio = {
            grade     = "jumper",
            home      = "deep space",
            age       = 185,
            likes     = "earth movies",
            hates     = "cows",
            ability   = "teleporter",
            throws    = "back-porter",
        }
    },

    [characterCykill] = {
        name          = "cykill",
        playable      = false,
        enemy         = true,
        title         = "cyborg destroyer",
        skin          = "Urban Alien",
        shipSkin      = "orange",
        color         = "orange",
        nativeNegable = negBackPorter,
        planet        = 3,
        soundIndex    = characterEarlGrey,  -- todo
        soundFolder   = "earlgrey",         -- todo
    },
    [characterRobocop] = {
        name          = "robocop",
        playable      = false,
        enemy         = false,
        title         = "cyborg saviour",
        skin          = "Urban Alien",
        shipSkin      = "orange",
        color         = "orange",
        nativeNegable = negBackPorter,
        planet        = 3,
        soundIndex    = characterEarlGrey,  -- todo
        soundFolder   = "earlgrey",         -- todo
        bio = {}
    },

}
