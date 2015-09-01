    local levelData = {
    name             = "bad feeling about this drop",
    timeBonusSeconds = 28,
    ceiling          = -2300,
    floor            = 1000,
    startLedge       = 4,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {11},
        [bgrBack]  = {},
        [bgrSky]   = {1, 2}
    },

    elements = {
        {object="ledge", type="start"},
            {object="rings", color=aqua, trajectory={x=50, y=-50, xforce=90, yforce=0, arc=50, num=5}},

            {object="emitter", x=30, y=-2200, timer={2000, 4000}, limit=nil, force={ {200, 500}, {100, 300}, {45, 180} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={7, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-3", size={7, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-5", size={4, 10}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-red", size={7, 8}} },
                }
            },
            {object="emitter", x=30, y=-1200, timer={2000, 4000}, limit=nil, force={ {0, 300}, {100, 300}, {45, 180} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-blue", size={8, 9}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={7, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-4", size={4, 10}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={7, 8}} },
                }
            },

            {object="spike", x=900,  y=-1950, type="fg-wall-dividerx2-spiked", physics={shapeOffset={top=50, right=-20},   bounce=1}},

        {object="ledge", x=170, y=240, size="medium", movement={pattern={{700,-200}}, reverse=true, speed=3, pause=1500}},

        {object="ledge", x=1020, y=-385, size="medsmall2"},

        {object="ledge", x=210, y=-210, size="small3"},
            {object="rings", color=aqua, trajectory={x=- 30, y=-200, xforce=-110, yforce=120, arc=65, num=3}},

        {object="ledge", x=-375, y=-100, surface=pulley, distance=1500, speed=1},

        {object="ledge", x=-800, y=150, surface=pulley, distance=-1450, speed=2},

        {object="ledge", x=-265, y=-185, size="med-small", surface=oneshot, positionFromLedge=5, destroyAfter=300},

        {object="ledge", x=235, y=-165, size="medium", rotation=15, movement={pattern={{620,-250}}, reverse=true, speed=3, pause=1000}},
            {object="spike", x=555,  y=-500, type="fg-rock-5", size=0.7, rotation=-45, physics={shape="circle", friction=0.3, bounce=0.4}},

        {object="ledge", x=-195, y=-270, size="medium", surface=oneshot, destroyAfter=300},  
            {object="rings", color=aqua, pattern={ {300,-150}, {40,-80,color=green}, {40,80} }},

        {object="ledge", x=-130, y=-150, size="small3"},
            {object="gear", type=gearGlider, x=0, y=-150, onLedge=true, regenerate=false},
            {object="spike", x=2100,  y=-700, type="fg-wall-divider-spiked", rotation=-65, flip="x", physics={shapeOffset={top=50, right=-20},   bounce=1}},
        
        {object="ledge", x=370, y=-235, surface="electric"},    

        {object="ledge", x=-220, y=-190, size="medium2"},
            {object="key", x=0, y=-60, color="Blue", onLedge=true},
            {object="rings", color=white, pattern={ {-200,-350}}},
            {object="friend", type="fuzzy", x=50, y=60, size=0.2, color="Pink", kinetic="hang", direction=left},

        {object="ledge", x=220, y=-125, surface="ramp"},   
            {object="rings", color=aqua, pattern={ {650,100}, {100,35}, {100,35}}},
            {object="spike", x=910,  y=-250, type="fg-spikes-float-4", size=0.7, physics={shape={-75,-100, 75,-100, -25,200}}},
 
        {object="obstacle", x=820, y=-0, type="pole", length=1700},

        {object="ledge", x=0, y=150, size="big2", keylock="Blue", triggerObstacleIds={2}},

            {object="emitter", x=0, y=500, timer={3000, 6000}, limit=nil, force={ {-300, 300}, {-100, -300}, {45, 95} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={3, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-4", size={3, 8}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-blue", size={6, 8}} },
                }
             },
            {object="emitter", x=1500, y=500, timer={4000, 7000}, limit=nil, force={ {-10, -300}, {-100, -300}, {45, 95} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-4", size={4, 9}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-5", size={3, 6}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-blue", size={6, 8}} },
                }
             },    
 
        {object="ledge", x=265, y=-185, size="med-small", surface=oneshot, destroyAfter=300},
                
        {object="ledge", x=180, y=-200, size="med-small", surface=oneshot, destroyAfter=300},
                    
        {object="ledge", x=-300, y=-185, size="med-small", surface=oneshot, destroyAfter=300},
            {object="friend", type="fuzzy", x=-50, y=-50, size=0.2, color="Orange", onLedge=true},

        {object="ledge", x=700, y=-600, type="finish"}
    },
}

return levelData