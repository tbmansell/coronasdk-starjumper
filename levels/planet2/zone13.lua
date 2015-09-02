local levelData = {
    name             = "sky high",
    timeBonusSeconds = 28,
    ceiling          = -2500,
    floor            = 1400,
    startLedge       = 13,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {9, 4},
        [bgrBack]  = {},
        [bgrSky]   = {1, 2}
    },

    elements = {
        {object="ledge", type="start"},

            {object="spike", x=700,  y=-2200, type="fg-wall-dividerx2-spiked", physics={shapeOffset={top=50, right=-20},  bounce=1}},
            {object="spike", x=2500,  y=-2000, type="fg-wall-dividerx2-spiked", physics={shapeOffset={top=50, right=-20}, bounce=1}}, 

            {object="emitter", x=100, y=-2500, timer={2000, 4000}, limit=nil, force={ {200, 500}, {100, 300}, {45, 180} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={7, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-3", size={7, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-5", size={4, 10}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-red", size={7, 8}} },
                }
            },
            {object="emitter", x=100, y=-1500, timer={2000, 4000}, limit=nil, force={ {0, 300}, {100, 300}, {45, 180} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-blue", size={8, 9}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={7, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-4", size={4, 10}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={7, 8}} },
                }
            },

-- Jet Pack Ledges

        {object="ledge", x=175, y=260, size="small3"},
            {object="gear", type=gearJetpack, x=25, y=-200, onLedge=true, regenerate=false},  
        
        {object="ledge", x=220, y=30, size="small2"},
            {object="gear", type=gearJetpack, x=0, y=-200, onLedge=true, regenerate=false},

        {object="ledge", x=250, y=30, size="small"},
            {object="gear", type=gearJetpack, x=0, y=-200, onLedge=true, regenerate=false},
        
-- Level Start

        {object="ledge", x=330, y=-50, surface="ramp", positionFromLedge=1}, 
             {object="rings", color=aqua, pattern={ {400,-400}, {100,-75}, {100,-75} }},

             {object="enemy", type="greyshooter", x=600, y=-550, size=0.5, 
                shooting={minWait=2, maxWait=5, velocity={x=700, y=200, varyX=200, varyY=300}, itemsMax=10, ammo={negDizzy, negTrajectory}},
                movement={pattern=moveTemplateCross, reverse=true, isTemplate=true, distance=250, speed=3, pause=500, moveStyle=moveStyleSwayBig, pauseStyle=moveStyleSwayBig}
            },

        {object="ledge", x=1000, y=-550, surface="ramp", flip="x"}, 
            {object="wall", x=-450, y=-500, type="fg-rock-1", size=0.8,  physics={shape="circle", friction=0.3, bounce=0.5}}, 

        {object="ledge", x=-900, y=-400, surface="ramp"}, 
            {object="rings", color=aqua, pattern={ {300, 0, color=pink}, {100, 50}, {100,50} }},
            {object="wall", x=450, y=-400, type="fg-rock-1", size=0.8,  physics={shape="circle", friction=0.3, bounce=0.5}},

        {object="ledge", x=900, y=-400, surface="ramp", flip="x"}, 
            {object="rings", color=aqua, pattern={ {-270, -270}, {100, 50}, {100,50, color=red} }},
            {object="wall", x=-500, y=-600, type="fg-rock-1", size=0.8,  physics={shape="circle", friction=0.3, bounce=0.5}},
              
        {object="ledge", x=-1000, y=-350, size="big2"}, 
            {object="rings", color=aqua, pattern={ {200, -170, color=blue}, {100, 50}, {100,50} }},
            {object="friend", type="fuzzy", x=-60, color="Red", onLedge=true},

-- Over the pit

        {object="ledge", x=350, y=-220, size="small"},

        {object="ledge", x=420, y=200, size="small"},

        {object="ledge", x=330, y=-175, size="small"},

-- Ledges Down

        {object="ledge", x=270, y=0, size="medsmall2", movement={pattern={{450,500}}, reverse=true, speed=3, pause=1000}},

        {object="ledge", x=200, y=0, size="medsmall2", positionFromLedge=8},
            {object="rings", color=aqua, pattern={ {275,-100} }},

         		{object="warpfield", x=750, y=75, size=0.70, radius=100, movement={steering=steeringMild, speed=4, pattern={{700, 0}, {-700, 0}}}},    

        {object="spike", x=50,  y=300, type="fg-spikes-float-5", size=1, physics={shape={-75,-100, 75,-100, -25,200}}},

        {object="ledge", x=350, y=205, size="small2"},

        {object="ledge", x=295, y=180, size="medsmall3", movement={pattern={{-450,500}}, reverse=true, speed=4, pause=1000}},
            {object="ledge", x=200, y=0, size="medsmall2"},

        {object="ledge", x=100, y=650, size="medsmall3", positionFromLedge=16},
            {object="rings", color=white, pattern={ {-275,-300} }},

            {object="emitter", x=100, y=800, timer={3000, 6000}, limit=nil, force={ {-10, -250}, {-100, -300}, {0, 180} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={3, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-4", size={4, 7}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-blue", size={6, 8}} },
                }
            },
            {object="spike", x=-75,  y=-700, type="fg-spikes-float-5", size=0.8, physics={shape={-75,-100, 75,-100, -25,200}}},
            {object="wall", x=300,  y=-820, type="fg-wall-divider-fs-completedown", rotation=-30, physics={shapeOffset={bottom=0, left=0},   bounce=1}},

        {object="ledge", x=550, y=350, type="finish"}
    },
}

return levelData