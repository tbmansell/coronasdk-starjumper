-- star colors
aqua   = 1
pink   = 2
red    = 3
blue   = 4
white  = 5
yellow = 6
green  = 7
orange = 8


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

ringValuesClimbChase = {
    [aqua]   = {points=10, cubes=0.125},  -- 1.25 cubes for 10 rings
    [pink]   = {points=20, cubes=0.25},   -- 2.5  cubes for 10 rings
    [red]    = {points=30, cubes=0.5},    -- 5    cubes for 10 rings
    [blue]   = {points=40, cubes=1},      -- 10   cubes for 10 rings
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
