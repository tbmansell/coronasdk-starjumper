local levelData = {
    name             = "reach for the stars",
    timeBonusSeconds = 28,
    ceiling          = -1500,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {14, 4},
        [bgrBack]  = {},
        [bgrSky]   = {1, 2}
    },

    backgroundSounds = {
        {name="space/space7", quietTime=2000, minVolume=4, maxVolume=6},
        {name="nature/wind4", quietTime=6000, minVolume=2, maxVolume=3},
    },
    
    elements = {
        {object="ledge", type="start"},

            {object="emitter", x=100, y=-900, timer={2000, 8000}, limit=nil, force={ {0, 600}, {100, 300}, {0, 360} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={4, 6}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 7}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-blue", size={6, 8}} },
                }
            },

        {object="ledge", x=300, y=-170, size="medbig", rotation=-20},
            {object="rings", color=aqua, trajectory={x=75, y=-200, xforce=100, yforce=100, arc=40, num=3}},
            {object="enemy", type="greyufo", x=-500, y=-100, size=0.7, 
                movement={pattern=moveTemplateHorizontal, isTemplate=true, distance=500, speed=2, pause=1500, reverse=true, moveStyle=moveStyleSwayBig, pauseStyle=moveStyleSwayBig}
            },
    
        {object="ledge", x=320, y=-250, size="medbig2", rotation=-20},
            
        {object="ledge", x=350, y=-300, size="medbig3", rotation=-20},

        {object="ledge", x=200, y=-75, surface="ramp"},
            {object="gear", type=gearJetpack, x=-30, y=-150, onLedge=true, regenerate=false},
            {object="rings", color=aqua, pattern={ {800,-400}, {575,150}, {350,200}}},

            {object="wall", x=237,  y=314, type="fg-wall-divider", copy=2, gap=1095, physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="spike", x=250,  y=105, type="fg-wall-divider-fs-completedown1", physics={shapeOffset={top=50, right=-20},   bounce=1}},
            {object="spike", x=890,  y=105, type="fg-wall-divider-fs-completedown2", physics={shapeOffset={top=50, right=-20},   bounce=1}},
            {object="spike", x=547,  y=81, type="fg-spikes-row-big", copy=2, gap=100},
            
            {object="emitter", x=600, y=-950, timer={3000, 6000}, limit=nil, force={ {-500, 500}, {100, 300}, {0, 360} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-blue", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-5", size={2, 8}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={6, 8}} },
                }
            },       

            {object="enemy", type="greyufo", x=1000, y=-300, size=0.7, 
                movement={pattern=moveTemplateLeftArc, isTemplate=true, distance=300, speed=2, pause=1500, reverse=true, moveStyle=moveStyleSwayBig, pauseStyle=moveStyleSwayBig}
            },

        {object="obstacle", x=1600, y=-600, type="pole", length=800},
            {object="wall", x=-50,  y=-720, type="fg-wall-divider-halfsize", physics={shapeOffset={bottom=0, left=0},   bounce=1}},       

        {object="ledge", x=0, y=250, size="big3"},

        {object="ledge", x=265, y=-75, surface="ramp"},
            {object="rings", color=aqua, pattern={ {800,-450}, {40,-80,color=pink}, {40,80} }},
            {object="gear", type=gearJetpack, x=-30, y=-150, onLedge=true, regenerate=false},
            {object="wall", x=237,  y=314, type="fg-wall-divider", copy=2, gap=1095, physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="spike", x=250,  y=105, type="fg-wall-divider-fs-completedown", physics={shapeOffset={top=50, right=-20},   bounce=1}},
            {object="spike", x=547,  y=81, type="fg-spikes-row-big", copy=2, gap=100},

            {object="emitter", x=0, y=550, timer={2000, 6000}, limit=nil, force={ {-500, 500}, {-100, -300}, {0, 360} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={4, 7}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 7}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-left", size={6, 8}} },
                }
            },

        {object="ledge", x=1600, y=-150, size="big3"}, 
           
        {object="ledge", x=150, y=-200, size="medbig2", positionFromLedge=8},
            {object="rings", color=aqua, trajectory={x=50, y=-100, xforce=110, yforce=120, arc=30, num=3}},

            {object="emitter", x=100, y=-875, timer={2000, 9000}, limit=nil, force={ {-300, 10}, {100, 300}, {0, 360} }, 
                items={
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-4", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 7}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                }
            },

        {object="ledge", x=-135, y=-278, size="medsmall"}, 

        {object="ledge", x=-235, y=-90, size="small"}, 
            {object="friend", type="fuzzy", color="Aqua", onLedge=true},

        {object="ledge", x=975, y=165, type="finish", postionFromLedge=9}
    },
}

return levelData