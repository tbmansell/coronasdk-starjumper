local levelData = {
    name             = "eruption alert!",
    ceiling          = -display.contentHeight*5,
    timeBonusSeconds = 70,
    defaultLedgeSize = medium,
    playerStart      = playerStartWalk,
    lavaChase        = true,
    startAtNight     = true,

    backgroundOrder = {
        [bgrFront] = {2, 3, 4, 1},
        [bgrMid]   = {7, 5, 7, 5},
        [bgrBack]  = {4, 1, 2, 3},
        [bgrSky]   = {2, 1}
    },

    backgroundSounds = {
        {name="nature/lava1", quietTime=500,  minVolume=9, maxVolume=10},
        {name="nature/wind2", quietTime=3000, minVolume=2, maxVolume=3},
    },

    elements = {
        {object="ledge", type="start"},
            -- left wall
            {object="scenery", x=0,    y=-1500, type="fg-wall-divider"},
            {object="scenery", x=0,    y=-3300, type="fg-wall-divider"},
            -- right wall
            {object="scenery", x=2300, y=-1000, type="fg-wall-divider"},
            {object="scenery", x=2300, y=-2500, type="fg-wall-divider"},
            -- floor
            {object="scenery", x=-230, y=50,    type="fg-wall-middle", size=1, copy=10},
            {object="scenery", x=-230, y=100,   type="fg-wall-middle", size=1, copy=10},
        	{object="scenery", x=-380, y=150,   type="fg-wall-middle", size=1, copy=10},

        -- Path one higher than start ledge
        {object="ledge", x=200, y=-50, surface="lava", rotation=-5},

        {object="ledge", x=200, y=-50, surface="lava", rotation=-13},

        {object="ledge", x=300, y=-250},
            {object="gear", x=0, y=0, type=gearGloves},

        {object="ledge", x=-250, y=-200},
            {object="rings", color=aqua, trajectory={x=-50, y=-150, xforce=-70, yforce=180, arc=65, num=5}},
            {object="scenery", x=170, y=-600, type="fg-wall-double-l1"},

        {object="ledge", x=-250, y=-280, rotation=10},

           {object="emitter", x=-150, y=150, timer={1000, 3000}, limit=3, layer=4,
                item={
                    object="livebgr", type="heart", color="Red", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.4, 0, 0.1},
                    movement={rangeX={-0, 175}, rangeY={-600, 300}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },            


        {object="ledge", x=-250, y=-220, rotation=7},
            {object="rings", color=pink, trajectory={x=100, y=-150, xforce=90, yforce=160, arc=65, num=5}},


        -- #8
        {object="ledge", x=400, y=-250},
            {object="scenery", x=-250, y=-900, type="fg-wall-double-l1"},

        -- route 1
        {object="ledge", x=-350, y=-280, rotation=12},

        {object="ledge", x=-100, y=-150, size="small"},
            {object="scenery", x=-60,  y=-120, type="fg-flowers-5-yellow", layer=2, size=0.5, onLedge=true},
            {object="rings", color=red, trajectory={x=30, y=-200, xforce=40, yforce=90, arc=40, num=3}},

        {object="ledge", x=200, y=-200, rotation=-17},

        -- route 2
        {object="ledge", x=350, y=-280, positionFromLedge=8, rotation=-21},

        {object="ledge", x=100, y=-150, surface="collapsing"},

        {object="ledge", x=-200, y=-200},
            {object="scenery", x=-60,  y=-97, type="fg-foilage-3-yellow", layer=2, onLedge=true},

            {object="emitter", x=0, y=-250, timer={1000, 3000}, limit=4, layer=4,
                item={
                    object="livebgr", type="brain", color="Purple", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.2, 0, 0.4},
                    movement={rangeX={-400, 600}, rangeY={-150, 800}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },            

        -- merged again - #15
        {object="ledge", x=-250, y=-250, size="small3"},
            {object="gear", x=0, y=0, type=gearTrajectory},

        -- dead end, need pole to return to 15
        {object="ledge", x=-300, y=-270, surface="collapsing"},
            {object="friend", type="fuzzy", color="Yellow", onLedge=true},

        {object="obstacle", type="pole", x=330, y=-400, length=300},

        {object="ledge", x=300, y=-270, positionFromLedge=15, rotation=-5},
            {object="scenery", x=350, y=-550, type="fg-spikes-float-2"},

        {object="ledge", x=-140, y=-250, size="small2"},

        {object="ledge", x=-100, y=-250, size="small2"},

        -- optional
        {object="ledge", x=-400, y=0, size="medium2"},
            {object="scenery", x=35,   y=-135, type="fg-flowers-1-green", layer=4, size=0.5, onLedge=true},
            {object="scenery", x=1,    y=-160, type="fg-foilage-1-green", layer=2, size=0.6, onLedge=true},
            {object="scenery", x=-140, y=-150, type="fg-foilage-1-green", layer=2, size=0.5, onLedge=true},
            {object="scenery", x=-300, y=-500, type="fg-wall-l2", flip="y", layer=3},
            {object="friend",  x=250,  y=-300, type="fuzzy", color="Red", kinetic="hang"},

        {object="ledge", x=750, y=-40, surface="lava", rotation=5},
        
        {object="ledge", x=500, y=0, type="finish"}
    },
}

return levelData