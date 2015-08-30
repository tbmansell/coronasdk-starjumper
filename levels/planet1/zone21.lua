local levelData = {
    name             = "catch me if you can",
    timeBonusSeconds = 70,
    defaultLedgeSize = "medium",
    aiRace           = true,
    playerStart      = playerStartWalk,

    backgroundOrder = {
        [bgrFront] = {1,  2, 3,  4},
        [bgrMid]   = {11, 2, 11, 2},
        [bgrBack]  = {4,  1, 2,  3},
        [bgrSky]   = {2,  1}
    },

    elements = {
        {object="ledge", type="start"},
            {object="scenery", x=100, y=-400, type="fg-tree-4-yellow", copy=12, gap=400, layer=4, darken=100},
            {object="scenery", x=360, y=-300, type="fg-tree-4-yellow", copy=2,  gap=300, flip="x"},
            
        -- AI start
        {object="ledge", x=300, y=-50},

        {object="ledge", x=300, y=-150, size="medium2"},
            --pinacle of scenery
            {object="scenery", x=0,   y=-170, type="fg-tree-4-yellow", rgb={200,100,255}},
            {object="scenery", x=200, y=200,  type="fg-wall-left"},
            {object="scenery", x=300, y=200,  type="fg-wall-right"},
            -- top row of blocks
            {object="scenery", x=0,   y=300, type="fg-wall-left"},
            {object="scenery", x=100, y=300, type="fg-wall-middle"},
            {object="scenery", x=480, y=300, type="fg-wall-right"},
            -- bottom row of blocks
            {object="scenery", x=-150, y=400, type="fg-wall-left"},
            {object="scenery", x=-50,  y=400, type="fg-wall-middle", copy=2},
            {object="scenery", x=710,  y=400, type="fg-wall-right"},
            {object="scenery", x=650,  y=50,  type="fg-tree-4-yellow", rgb={200,100,255}},

        {object="ledge", x=175, y=-200, size="medium2", flip="x"},
            {object="rings", color=aqua, trajectory={x=50, y=-150, xforce=10, yforce=100, arc=70, num=3}},
            {object="scenery", x=650,  y=50,  type="fg-tree-4-yellow", rgb={200,0,255}, copy=4, gap=300},
            {object="scenery", x=1000, y=250, type="fg-tree-4-yellow", rgb={200,150,255}, copy=5, gap=300},

        {object="ledge", x=150, y=280},

        {object="ledge", x=150, y=200, size="medium3"},

        {object="ledge", x=250, y=-100, surface="spiked", timerOff=4000},

        {object="ledge", x=250, y=100},
            {object="rings", color=aqua, trajectory={x=150, y=-150, xforce=100, yforce=100, arc=40, num=3}},

        {object="ledge", x=350, y=-400, size="medium2", movement={pattern=movePatternVertical, distance=500, speed=1}},
            {object="rings", color=aqua, trajectory={x=50, y=100, xforce=50, yforce=0, arc=40, num=3}},

        {object="ledge", x=300, y=200, size="small2"},

        {object="ledge", x=250, y=0, surface="electric", timerOn=5000, timerOff=5000},

        {object="ledge", x=300, y=100, size="big2"},

        {object="ledge", x=250, y=0, surface="spiked", timerOff=4000},

        {object="ledge", x=300, y=-100},

        {object="ledge", x=900, movement={pattern=movePatternHorizontal, distance=600, speed=2}},
            {object="scenery", x=1500, y=150, type="fg-wall-left"},
            {object="scenery", x=1600, y=150, type="fg-wall-middle", copy=4},
            {object="scenery", x=3100, y=150, type="fg-wall-right"},
            -- top row of blocks
            {object="scenery", x=500,  y=250, type="fg-wall-left"},
            {object="scenery", x=600,  y=250, type="fg-wall-middle", copy=7},
            {object="scenery", x=3250, y=250, type="fg-wall-right"},
            -- bottom row of blocks
            {object="scenery", x=-150, y=350, type="fg-wall-left"},
            {object="scenery", x=-50,  y=350, type="fg-wall-middle", copy=9},
            {object="scenery", x=3370, y=350, type="fg-wall-right"},

        {object="ledge", x=350, y=0},

        {object="ledge", x=275, y=0, movement={pattern={{500,-150}}, reverse=true,  distance=100, speed=1, pause=1000}},

        {object="ledge", x=800, y=0, size="medium3"},
        
        {object="ledge", x=500, y=0, type="finish"}
    },

    ai = {
        [1] = {
            skin          = "Female  Alien",
            model         = characterSkyanna,
            direction     = left,
            startSequence = "taunt",
            startTaunt    = 1,
            startLedge    = 2,
            lives         = 10,
            waitingTimer  = 3.5,
            personality   = {
                waitForPlayer     = 3,    -- waits for player if they are this many ledges in front
                waitCatchupTo     = 1,    -- once waited, waits until the player is 1 ledge in front, before continuing
                waitFromLand      = 1,    -- seconds to wait from landing, before performing next action (jump)
                waitForJump       = 1,    -- seconds to wait in drag mode before they jump (simulating working out jump)
                reposition        = 30,   -- distance they will reposition themselves on a ledge by
                dropTrapOnCatchup = true, -- will throw a trap on current ledge when it wait for player to cathup, just before it runs off again
                tauntOnCatchup    = true, -- will perform taunt animation while waiting for player
                traps = {                 -- traps AI has to throw (currently infinite)
                    {50,negTrajectory}, {100,negDizzy}
                },
            }
        },
    },
}

return levelData