local levelData = {
    name             = "fly my pretty",
    timeBonusSeconds = 28,
    ceiling          = -1000,
    floor            = 2000,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {18, 16},
        [bgrBack]  = {},
        [bgrSky]   = {1, 2}
    },

    elements = {
        {object="ledge", type="start"},

            {object="enemy", type="greyshooter", x=750, y=-500, size=0.5, 
                shooting={minWait=1, maxWait=3, velocity={x=700, y=200, varyX=100, varyY=100}, itemsMax=10, ammo={negTrajectory}},
                movement={pattern=moveTemplateVertical, isTemplate=true, reverse=true, distance=300, speed=2, pause=1500, moveStyle=moveStyleSwayBig, pauseStyle=moveStyleSwayBig}
            },

        {object="ledge", x=175, y=260, size="medsmall3"},
            {object="rings", color=pink, pattern={ {0,-80} }},

            {object="emitter", x=0, y=-1500, timer={2000, 6000}, limit=nil, force={ {100, 500}, {100, 300}, {0, 360} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-ufo-left", size={6, 9}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={3, 9}} },
                    {70,  {object="scenery", layer=4, type="fg-bg-rock-2", size={3, 9}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-right", size={6, 8}} },
                }
            },

        {object="ledge", x=250, y=220, size="medsmall2"},

        {object="ledge", x=300, y=260, size="small2"},
            {object="gear", type=gearGlider, x=30, y=-150, onLedge=true, regenerate=false},
            
        {object="ledge", x=310, y=27, size="small3"},
            {object="gear", type=gearGlider, x=30, y=-150, onLedge=true, regenerate=false},

            {object="emitter", x=0, y=350, timer={2000, 6000}, limit=nil, force={ {-500, 500}, {-100, -300}, {0, 360} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-ufo-left", size={6, 9}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={3, 9}} },
                    {70,  {object="scenery", layer=4, type="fg-bg-rock-2", size={3, 9}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-right", size={6, 8}} },
                }
            },

        {object="ledge", x=400, y=-130, size="big3", rotation=-22, positionFromLedge=1},
            {object="rings", color=aqua, pattern={ {550,-270}, {200, 80}, {200, 80} }},

            --last walls
            {object="spike", x=3860,  y=220, type="fg-wall-divider-spiked", rotation=-72, physics={shapeOffset={left=20},   bounce=1}},
            {object="spike", x=3860,  y=720, type="fg-wall-divider-spiked", rotation=-72, flip="x", physics={shapeOffset={right=-20,  left=0},   bounce=1}},

            -- middle walls
            {object="spike", x=3070,  y=-35, type="fg-wall-divider-spiked", rotation=-72, physics={shapeOffset={left=20},   bounce=1}},
            {object="spike", x=3070,  y=465, type="fg-wall-divider-spiked", rotation=-72, flip="x", physics={shapeOffset={right=-20,  left=0},   bounce=1}},
            
            --last walls
            {object="spike", x=2280,  y=-290, type="fg-wall-divider-spiked", rotation=-72, physics={shapeOffset={left=20},   bounce=1}},
            {object="spike", x=2280,  y=210, type="fg-wall-divider-spiked", rotation=-72, flip="x", physics={shapeOffset={right=-20,  left=0},   bounce=1}},

            -- middle walls
            {object="spike", x=1490,  y=-545, type="fg-wall-divider-spiked", rotation=-72,  physics={shapeOffset={left=20},   bounce=1}},
            {object="spike", x=1490,  y=-45, type="fg-wall-divider-spiked", rotation=-72, flip="x", physics={shapeOffset={right=-20,  left=0},   bounce=1}},
            --first walls
            {object="spike", x=700,  y=-800, type="fg-wall-divider-spiked", rotation=-72,  physics={shapeOffset={left=20},   bounce=1}},
            {object="spike", x=700,  y=-300, type="fg-wall-divider-spiked", rotation=-72, flip="x", physics={shapeOffset={right=-20, left=0},   bounce=1}},
            

        {object="obstacle", x=120, y=-130, size=1.3, timerOn=2000, timerOff=1000, type="electricgate"},   

        {object="ledge", x=900, y=370, size="medsmall2"},
            {object="rings", color=aqua, pattern={ {300,-130}, {40,-80,color=red}, {40,80} }},

        {object="ledge", x=390, y=155, size="small3"},

         {object="ledge", x=300, y=-85, surface="collapsing", movement={pattern={{0,250}}, reverse=true, speed=3, pause=2000}}, 
            {object="friend", type="fuzzy", x=230, y=30, color="Yellow", kinetic="hang", direction=right},

        {object="ledge", x=220, y=370, size="medsmall3", rotation=20}, 
            {object="rings", color=aqua, pattern={ {650,-50}, {200, 80}, {200, 80} }}, 

        {object="obstacle", x=450, y=120,  timerOn=2000, timerOff=1500, type="electricgate"},  

            {object="emitter", x=0, y=-1000, timer={2000, 6000}, limit=nil, force={ {-400, 400}, {100, 300}, {0, 360} }, 
                items={
                    {10,  {object="scenery", layer=1, type="fg-debris-barrel-blue", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 6}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={2, 8}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-right", size={4, 8}} },
                }
            },

        {object="ledge", x=700, y=334, size="medsmall3", rotation=20},

        {object="ledge", x=320, y=70, surface="collapsing"},
            --{object="rings", color=aqua, pattern={ {510,-150}, {40,-80}, {40,80} }},
            {object="wall", x=-50, y=-160, type="fg-rock-5", size=.8, rotation=90, physics={body="dynamic", shape="circle", friction=0.3, bounce=0.4}},

        {object="obstacle", x=390, y=-290, size=1.3, timerOn=2000, timerOff=2000, type="electricgate"},

        {object="ledge", x=800, y=440, type="finish"}
    },
}

return levelData