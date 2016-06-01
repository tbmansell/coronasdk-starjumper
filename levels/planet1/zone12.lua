local levelData = {
    name             = "is this love?",
    timeBonusSeconds = 70,
    ceiling          = -1400,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {3, 4, 1, 2},
        [bgrMid]   = {9, 2, 9, 2},
        [bgrBack]  = {2, 3, 4, 1},
        [bgrSky]   = {2, 1}
    },

    backgroundSounds = {
        {name="animals/cats2", quietTime=9000, minVolume=1, maxVolume=2},
        {name="animals/birds1", quietTime=12000, minVolume=2, maxVolume=3},
    },

    elements = {
        {object="ledge", type="start"},
            {object="scenery", x=70, y=-450, type="fg-tree-4-yellow"},

        {object="ledge", x=300, y=-50, size="medium4"},
            {object="enemy", type="heart", x=0, y=130, size=0.5, color="Red", behaviour={mode=stateSleeping}},
            {object="rings", color=aqua, pattern={ {0,-225}, {0,75}, {0,75}, {-75,-75}, {150,0} }},
            {object="scenery", x=50, y=-325, type="fg-tree-3-yellow"},

            {object="emitter", x=-150, y=150, timer={2000, 3000}, limit=3, layer=4,
                item={
                    object="livebgr", type="heart", color="Red", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.4, 0, 0.1},
                    movement={rangeX={0, 0}, rangeY={-400, -500}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },

        {object="ledge", x=400, y=50, size="medium3"},
            {object="enemy", type="heart", x=0, y=130, size=0.5, color="Red", behaviour={mode=stateSleeping}, spineDelay=900},
            {object="rings", color=aqua, pattern={ {0,-225}, {0,75,color=pink}, {0,75}, {-75,-75}, {150,0} }},
            {object="scenery", x=250, y=-325, type="fg-tree-2-yellow"},

        {object="ledge", x=350, y=-50, size="medium2"},
            {object="enemy", type="heart", x=0, y=130, size=0.5, color="Red",
                behaviour={mode=stateSleeping, awaken=0, range=5, atRange=stateResetting, thefts=20},
                movement={pattern=movePatternFollow, speed=1, pause=1000, moveStyle=moveStyleWave, pauseStyle=moveStyleWave}
            },

            {object="scenery", x=250,  y=-250, type="fg-tree-1-yellow"},
            {object="scenery", x=900,  y=-250, type="fg-tree-4-yellow"},
            {object="scenery", x=1300, y=-150, type="fg-tree-4-yellow"},

        {object="ledge", x=400, y=-600, size="big", movement={pattern=movePatternVertical, distance=600, speed=1}},

        {object="ledge", x=-100, y=0, size="medium2"},
            {object="wall", x=-400, y=-470, type="fg-rock-1", physics={shape="circle", bounce=1}},

        {object="ledge", x=-300, y=0, size="medium3"},
            {object="wall", x=-400, y=-500, type="fg-rock-3", physics={shape="circle", bounce=1}},

        {object="ledge", x=-400, y=0, size="medium4"},

            {object="emitter", x=-150, y=-350, timer={1000, 2000}, limit=2, layer=4,
                item={
                    object="livebgr", type="heart", color="Red", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.4, 0, 0.2},
                    movement={rangeX={-50, 50}, rangeY={500, -500}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },
            {object="emitter", x=-150, y=150, timer={1000, 2000}, limit=2, layer=4,
                item={
                    object="livebgr", type="heart", color="Red", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.4, 0, 0.1},
                    movement={rangeX={0, 0}, rangeY={-400, -500}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },            

        {object="ledge", x=-350, y=-600, size="big", movement={pattern=movePatternVertical, distance=600, speed=1}},
            {object="scenery", x=-500, y=-150, type="fg-tree-1-yellow"},
            {object="scenery", x=-400, y=475,  type="fg-rock-4"},

        {object="ledge", x=400, y=-50, size="medium3"},
            {object="rings", color=aqua, pattern={ {-0,-150}, {-50,-50}, {100,0}, {-100,100}, {100,0} }},
            {object="enemy", type="heart", x=0, y=130, size=0.5, color="Red", behaviour={mode=stateSleeping}},
            -- ceiling
            {object="scenery", x=-300, y=-750, type="fg-wall-left",   flip="y"},
            {object="scenery", x=-200, y=-750, type="fg-wall-middle", flip="y", copy=15},
            {object="scenery", x=-100, y=-650, type="fg-wall-left",   flip="y"},
            {object="scenery", x=-0,   y=-650, type="fg-wall-middle", flip="y", copy=15},

        {object="ledge", x=500, y=-50, size="medium2"},
            {object="rings", color=aqua, pattern={ {-0,-150,color=pink}, {-50,-50}, {100,0}, {-100,100}, {100,0} }},
            {object="enemy", type="heart", x=0, y=130, size=0.5, color="Red", spineDelay=400,
                behaviour={mode=stateSleeping, awaken=0, range=6, atRange=stateResetting, thefts=20},
                movement={pattern=movePatternFollow, speed=1, pause=1000, moveStyle=moveStyleWave, pauseStyle=moveStyleWave}
            },

        {object="ledge", x=350, y=50, size="medium4"},
            {object="friend", type="fuzzy", x=0, y=-250, size=0.5, color="Orange", kinetic="bounce", onLedge=true},
            {object="enemy",  type="heart", x=0, y=130,  size=0.5, color="Red", behaviour={mode=stateSleeping}},

        {object="ledge", x=500, y=-50, size="medium2"},

        {object="ledge", x=400, y=280, size="small2", ai={ignore=true}},
            {object="gear", type=gearGlider, x=0, y=-50},
            {object="scenery", x=400, y=-250, type="fg-tree-1-yellow"},
            {object="scenery", x=500, y=375, type="fg-rock-4"},

            {object="emitter", x=600, y=-125, timer={1000, 3000}, limit=3, layer=4,
                item={
                    object="livebgr", type="brain", color="Purple", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.3, 0, 0.3},
                    movement={rangeX={-800, 600}, rangeY={-50, 150}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },        

        {object="obstacle", type="deathslide", x=10, y=-400, length={1800,350}, speed=5, animSpeed="MEDIUM"},
        --{object="obstacle", type="deathslide", x=10, y=-400, length={500,350}, speed=2, animSpeed="MEDIUM"},
        
        {object="ledge", x=350, y=450, type="finish"}
    },
}

return levelData