local levelData = {
    name             = "what goes up...",
    timeBonusSeconds = 80,
    ceiling          = -display.contentHeight*2,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {3, 4, 1, 2},
        [bgrMid]   = {8, 4, 8, 4},
        [bgrBack]  = {3, 4, 1, 2},
        [bgrSky]   = {1, 2}
    },

    backgroundSounds = {
        {name="animals/cats1", quietTime=5000, minVolume=1, maxVolume=2},
        {name="animals/cats3", quietTime=11000, minVolume=2, maxVolume=3},
    },

    elements = {
        {object="ledge", type="start"},
            {object="scenery", x=-50,  y=-950,  type="fg-tree-2-yellow",  layer=4, size=1.2},
            {object="spike",   x=280,  y=-770,  type="fg-spikes-float-1", size=0.5, physics={shape={-100,40, 3360,40, 3360,120, -100,120}} },
            {object="scenery", x=400,  y=-770,  type="fg-spikes-float-1", size=0.5, layer=2, copy=12, gap=-80},

            {object="wall",    x=700,  y=-1000, type="fg-wall-divider",   physics={shapeOffset={bottom=-30, left=50},   bounce=1}, rotation=90},
            {object="wall",    x=1600, y=-1000, type="fg-wall-divider",   physics={shapeOffset={bottom=-30, right=-50}, bounce=1}, rotation=-90},

            {object="wall",    x=2500, y=-300,  type="fg-wall-divider",   physics={shapeOffset={bottom=-30}, bounce=1}},
            {object="wall",    x=2500, y=-1200, type="fg-wall-divider",   physics={shapeOffset={bottom=-30}, bounce=1}, flip="y"},
            {object="spike",   x=890,  y=-1370, type="fg-spikes-float-1", size=0.5, physics={shape={-340,40, 3000,40, 3000,120, -340,120}} },
            {object="scenery", x=1090, y=-1370, type="fg-spikes-float-1", size=0.5, layer=2, copy=8, gap=-40 },
            {object="wall",    x=1190, y=-1600, type="fg-wall-divider",   physics={shapeOffset={bottom=-30, left=50}, bounce=1}, rotation=90},
            {object="wall",    x=2090, y=-1600, type="fg-wall-divider",   physics={shapeOffset={bottom=-30, right=-50}, bounce=1}, rotation=-90},

        {object="ledge", x=235, y=-150, size="medium2"},
          
        {object="ledge", x=0, y=250, surface="collapsing"},
            {object="rings", color=aqua, trajectory={x=30, y=-150, xforce=60, yforce=100, arc=50, num=3}},

        {object="ledge", x=220, y=-150, size="medium2", ai={loadGear=gearGloves}},

           {object="emitter", x=0, y=-150, timer={1000, 3000}, limit=5, layer=4,
                item={
                    object="livebgr", type="heart", color="Red", direction=right, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.4, 0, 0.3},
                    movement={rangeX={-600, 600}, rangeY={-250, 250}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },           
        
        {object="obstacle", type="ropeswing", x=450, y=-200, direction=right, length=200, movement={speed=1, arcStart=230, arc=90}, ai={ignore=true}},

        {object="ledge", x=350, y=200, size="small2"},
        
        {object="ledge", x=100, y=-200, size="small2"},

        {object="obstacle", type="deathslide", x=-105, y=-300, length={-500,-400}, speed=5, animSpeed="FAST"},
            {object="scenery", x=-605, y=-480, type="fg-rock-3", size=0.2, layer=2}, 

        {object="ledge", x=0, y=400, size="medium2"},
            {object="rings", color=pink, pattern={ {90,-75}}},

        {object="ledge", x=-90, y=10, surface="collapsing"},
            {object="friend", type="fuzzy", x=80, color="White", onLedge=true},
          
        {object="obstacle", type="ropeswing", x=-100, y=-250, direction=right, length=200, movement={speed=1, arcStart=220, arc=100}},
          
        {object="ledge", x=-250, y=175, surface="collapsing"}, 
            {object="rings", color=aqua, pattern={ {90,-225}, {-30,-30} }}, 

        {object="ledge", x=-125, y=-210, size="medium"},
        	 {object="randomizer", x=-65, onLedge=true, items={{30,gearGloves}, {70,negDizzy}, {100,yellow}}},

        {object="obstacle", type="deathslide", x=155, y=-350, length={1000,-300}, speed=3, animSpeed="FAST", ai={letGoAfter=5000}},
            {object="scenery", x=896, y=-390, type="fg-rock-3", size=0.2, layer=2},

        {object="ledge", x=-200, y=350, size="small3"},
            {object="gear", type=gearFreezeTime, y=-50, storyModeOnly=true},
            {object="rings", color=aqua, trajectory={x=30, y=-105, xforce=190, yforce=0, arc=40, num=3}},

            {object="enemy", type="heart", x=450, y=-200, size=0.5, color="Red",
                behaviour={mode=stateSleeping, awaken=0, range=4, atRange=stateResetting, thefts=5},
                movement={pattern=movePatternFollow, speed=1, pause=1000, moveStyle=moveStyleWave, pauseStyle=moveStyleWave}
            },

        {object="ledge", x=310, y=-50, surface="spiked", timerOff=3000, ai={jumpVelocity={200,700}}},

        {object="ledge", x=175, y=-75, size="small3"},
            {object="rings", color=aqua, pattern={ {-30,-50}, {30,-60,color=pink}, {30,60} }},
          
            {object="emitter", x=0, y=250, timer={1000, 3000}, limit=4, layer=4,
                item={
                    object="livebgr", type="brain", color="Purple", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.4, 0, 0.4},
                    movement={rangeX={-400, 800}, rangeY={-150, 800}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },               

        {object="ledge", x=175, y=75, surface="spiked", timerOff=3500, ai={ignore=true}},

        {object="ledge", x=175, y=175, size="big2"},
            {object="gear",  type=gearParachute, x=0, y=-150},
            {object="rings", color=aqua, trajectory={x=30, y=-150, xforce=180, yforce=175, arc=100, num=5}},
            {object="wall",    x=1200, y=-500, type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=1}},
            {object="scenery", x=-135, y=-185, type="fg-flowers-3-yellow", layer=4},
            {object="scenery", x=50,   y=-150, type="fg-flowers-4-yellow", layer=4, size=0.6, flip="x"},
            {object="scenery", x=300,  y=750,  type="fg-tree-2-yellow",    layer=4, size=1.2},
            {object="scenery", x=550,  y=850,  type="fg-tree-6-yellow",    layer=4, size=0.8},

        {object="ledge", x=750, y=1200, type="finish"}
    },
}

return levelData