-- star colors
orange = 1
aqua   = 2
pink   = 3
red    = 4
blue   = 5
white  = 6
yellow = 7
green  = 8

colorNames = {
    [orange] = "Orange",
    [aqua]   = "Aqua",
    [pink]   = "Pink",
    [red]    = "Red",
    [blue]   = "Blue",
    [white]  = "White",
    [yellow] = "Yellow",
    [green]  = "Green",
}

colorCodes = {
    ["Orange"] = orange,
    ["Aqua"]   = aqua,
    ["Pink"]   = pink,
    ["White"]  = white,
    ["Red"]    = red,
    ["Blue"]   = blue,
    ["Yellow"] = yellow,
    ["Green"]  = green,
}

ringValues = {
    [orange] = {points=2,  cubes=0.25},
    [aqua]   = {points=10, cubes=1},
    [pink]   = {points=20, cubes=2},
    [red]    = {points=30, cubes=3},
    [blue]   = {points=40, cubes=4},
    [white]  = {points=50, cubes=5},
    [yellow] = {points=60, cubes=6},
    [green]  = {points=70, cubes=7},
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
