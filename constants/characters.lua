-- player models
characterGygax     = 1
characterNewton    = 2
-- planet one:
characterSkyanna   = 3
characterBrainiak  = 4
characterKranio    = 5
-- planet two:
characterHammer    = 6
characterGrey      = 7
characterGreyson   = 8


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


characterData = {
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
    [characterNewton] = {
        name          = "newton",
        title         = "rookie",
        skin          = "Green Space Man",
        shipSkin      = "green",
        color         = "green",
        playable      = true,
        enemy         = false,
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
        title         = "enemy",
        skin          = "Brain Enemy",
        shipSkin      = "green",
        color         = "purple",
        playable      = false,
        enemy         = true,
        nativeNegable = negElectrifier,
        lockText      = "buy organia planet pack to unlock",
        planet        = 1,
        buyMode       = "storeOnly",
        soundIndex    = characterBrainiak,
        soundFolder   = "brainiak",
        --[[bio = {
            grade     = "brain master",
            home      = "organia",
            age       = 20,
            likes     = "fresh brains",
            hates     = "fuzzies",
            ability   = "mind matter",
            throws    = "electrifier",
        }]]
    },
    [characterKranio] = {
        name          = "kranio",
        title         = "jumper",
        skin          = "Brain Enemy - Alt",
        shipSkin      = "green",
        color         = "purple",
        playable      = true,
        enemy         = false,
        nativeNegable = negElectrifier,
        lockText      = "buy organia planet pack to unlock",
        planet        = 1,
        buyMode       = "storeOnly",
        soundIndex    = characterBrainiak,
        soundFolder   = "brainiak",
        --specialAbility= true,
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
    [characterGrey] = {
        name          = "grey",
        title         = "enemy",
        skin          = "Grey Enemy",
        shipSkin      = "green",
        color         = "grey",
        playable      = false,
        enemy         = true,
        nativeNegable = negBackPorter,
        lockText      = "buy apaocalypsoid planet pack to unlock",
        planet        = 2,
        buyMode       = "storeOnly",
        soundIndex    = characterGrey,
        soundFolder   = "grey",
        --[[bio = {
            grade     = "great grey",
            home      = "deep space",
            age       = 185,
            likes     = "earth movies",
            hates     = "cows",
            ability   = "teleporter",
            throws    = "back-porter",
        }]]
    },
    [characterGreyson] = {
        name          = "greyson",
        title         = "jumper",
        skin          = "Grey - Alt",
        shipSkin      = "green",
        color         = "grey",
        playable      = true,
        enemy         = false,
        nativeNegable = negBackPorter,
        lockText      = "buy apaocalypsoid planet pack to unlock",
        planet        = 2,
        buyMode       = "storeOnly",
        soundIndex    = characterGrey,
        soundFolder   = "greyson",
        --specialAbility= true,
        bio = {
            grade     = "renegade grey",
            home      = "deep space",
            age       = 185,
            likes     = "earth movies",
            hates     = "cows",
            ability   = "teleporter",
            throws    = "back-porter",
        }
    },

}
