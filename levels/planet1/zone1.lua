local levelData = {
    name             = "one small step for alien kind",
    tutorial         = "intro-planet1-zone1",
    timeBonusSeconds = 50,
    playerStart      = playerStartFall,
    ceiling          = -1000,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {1,  2, 3,  4},
        [bgrMid]   = {12, 2, 12, 2},
        [bgrBack]  = {1,  2, 3,  4},
        [bgrSky]   = {1,  2}
    },

    backgroundSounds = {
        {name="nature/wind1", quietTime=10000, minVolume=1, maxVolume=3},
    },

    elements = {
        {object="ledge", type="start"},
            {object="scenery", x=100, y=-260, type="fg-foilage-2-yellow", layer=2, size=0.5},
            {object="scenery", x=230, y=-220, type="fg-foilage-3-yellow", layer=2, size=0.8},
            {object="scenery", x=370, y=-260, type="fg-foilage-2-yellow", layer=2, size=0.5, flip="x"},

            -- tutorial helper:
            {object="friend", x=-500, y=-950, type="ufoboss", size=0.7, animation="Standard", storyModeOnly=true, 
                gearDropper={gear={ {100,gearTrajectory} }, wait=2000, limit=1},
                movement={pattern=movePatternFollow, 
                    delay=2000,
                    speed=10,
                    offsetY=-150, 
                    --moveStyle=moveStyleWave,
                    pause=1000, 
                    --pauseStyle=moveStyleWave,
                    --steering=steeringMild,
                }
            },
        
        {object="ledge", x=280},
            {object="scenery", x=90, y=-300, type="fg-tree-4-yellow"},
            {object="gear", type=gearTrajectory, x=-100, y=-45, onLedge=true},
            
        {object="ledge", x=280, y=-200},
            {object="scenery", x=0, y=-145, type="fg-flowers-3-yellow", layer=2, size=0.7, onLedge=true},
            {object="rings", color=aqua, trajectory={x=50, y=-50, xforce=100, yforce=50, arc=40, num=3}},

        {object="ledge", x=250, y=150, size="big2"},

        {object="ledge", x=200, y=-200},
            {object="rings", color=aqua, trajectory={x=50, y=-100, xforce=130, yforce=15, arc=40, num=3}},
            --pinacle of scenery
            {object="scenery", x=360, y=-190, type="fg-tree-4-yellow"},
            {object="scenery", x=200, y=220,  type="fg-wall-left"},
            {object="scenery", x=300, y=220,  type="fg-wall-right"},
            -- top row of blocks
            {object="scenery", x=0,   y=320, type="fg-wall-left"},
            {object="scenery", x=100, y=320, type="fg-wall-middle"},
            {object="scenery", x=480, y=320, type="fg-wall-right"},
            -- bottom row of blocks
            {object="scenery", x=-150, y=420, type="fg-wall-left"},
            {object="scenery", x=-50,  y=420, type="fg-wall-middle", copy=2},
            {object="scenery", x=710,  y=420, type="fg-wall-right"},

        {object="ledge", x=300, y=-30, size="medium2"},
            {object="scenery", x=0, y=-175, type="fg-flowers-1-yellow", layer=2, onLedge=true},

            {object="rings", color=aqua, pattern={ {350,-225}, {100,70} }},

        {object="ledge", x=300, y=200},
        
        {object="ledge", x=300, y=0, type="finish"}
    },
}

return levelData