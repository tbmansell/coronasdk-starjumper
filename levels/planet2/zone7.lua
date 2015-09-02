local levelData = {
    name             = "bad electric",
    timeBonusSeconds = 28,
    ceiling          = -4000,
    floor            = 1000,
    startLedge       = 1,
    warpChase        = true,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {2},
        [bgrBack]  = {},
        [bgrSky]   = {1, 2}
    },

    elements = {
        {object="ledge", type="start"},
            {object="rings", color=red, pattern={ {745,-450}}},

            --Set Up Level

            -- Left Side
            {object="spike", x=690,  y=-2200, type="fg-wall-dividerx2-spiked", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="spike", x=705,  y=-2390, type="fg-wall-divider-cornertop", physics={shapeOffset={bottom=-125, left=0},   bounce=1}},
            {object="spike", x=1297,  y=-2802, type="fg-wall-divider-spiked", rotation=90, physics={shapeOffset={bottom=0, right=-25},   bounce=1}},
            {object="spike", x=1790,  y=-2516, type="fg-wall-divider-cornerbottom", flip="x", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="spike", x=1899,  y=-4235, type="fg-wall-dividerx2-spiked", physics={shapeOffset={bottom=0, left=0},   bounce=1}},

            -- Right Side A - 1000 D - 500
            {object="spike", x=1890,  y=-1700, type="fg-wall-dividerx2-spiked", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="spike", x=1905,  y=-1890, type="fg-wall-divider-cornertop", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="spike", x=2497,  y=-2302, type="fg-wall-divider-spiked", rotation=90, physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="spike", x=2990,  y=-2016, type="fg-wall-divider-cornerbottom", flip="x", physics={shapeOffset={bottom=0, left=75},   bounce=1}},
            {object="spike", x=3099,  y=-3735, type="fg-wall-dividerx2-spiked", physics={shapeOffset={bottom=0, left=0},   bounce=1}},

            -- Phase 1 - First Climb

            {object="emitter", x=5, y=-900, timer={2000, 8000}, limit=nil, force={ {0, 600}, {100, 300}, {0, 360} }, 
                items={
                    {10, {object="scenery", layer=4, type="fg-debris-barrel-grey", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={4, 6}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 7}} },
                    {100, {object="scenery", layer=4, type="fg-debris-barrel-blue", size={6, 8}} },
                }
            },

            {object="emitter", x=5, y=-1500, timer={2000, 5000}, limit=nil, force={ {0, 600}, {100, 300}, {0, 360} }, 
                items={
                    {10, {object="scenery", layer=4, type="fg-debris-ufo-left", size={6, 10}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={4, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 8}} },
                    {100, {object="scenery", layer=4, type="fg-debris-barrel-blue", size={6, 8}} },
                }
            },

        {object="ledge", x=300, y=30, size="medium3"},

        {object="ledge", x=320, y=-130, size="medium2"},
            {object="rings", color=aqua, trajectory={x=30, y=-150, xforce=110, yforce=90, arc=35, num=3}},

        {object="ledge", x=250, y=-175, size="small2"},

        {object="ledge", x=-270, y=-200, surface="electric"},
   
        {object="ledge", x=-210, y=-220, size="medsmall"},
            {object="spike", x=220,  y=-350, type="fg-spikes-float-5", size=0.6, physics={shape={-50, 150, 100,150, 50,-80}}},
            {object="rings", color=blue, pattern={ {380,-460}}},

        {object="obstacle", x=350, y=-500, type="pole", length=250},
            {object="wall", x=-85,  y=-220, type="fg-rock-2", size=0.5, rotation=-45, physics={shape="circle", friction=0.3, bounce=1}},

        {object="ledge", x=0, y=150, size="medsmall2", canShake=false, movement={pattern={{490,0}}, reverse=true, speed=2, pause=0}},

        {object="ledge", x=1, y=-250, size="medsmall2"},
            {object="rings", color=aqua, trajectory={x=30, y=-150, xforce=110, yforce=90, arc=35, num=3}},

        {object="ledge", x=200, y=-220, size="small2"},

        {object="ledge", x=-290, y=-150, surface="electric"},

        {object="ledge", x=-165, y=-200, surface=pulley, distance=-475, speed=1, reverse="true"},
            {object="rings", color=white, pattern={ {180,-500}}},

            {object="emitter", x=300, y=-950, timer={2000, 5000}, limit=nil, force={ {-50, 500}, {100, 300}, {0, 360} }, 
                items={
                    {10, {object="scenery", layer=4, type="fg-debris-helmet", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={2, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={2, 8}} },
                    {100, {object="scenery", layer=4, type="fg-debris-barrel-grey", size={6, 8}} },
                }
            },

            {object="emitter", x=300, y=-1950, timer={2000, 5000}, limit=nil, force={ {-50, 500}, {100, 300}, {0, 360} }, 
                items={
                    {10, {object="scenery", layer=4, type="fg-debris-ufo-right", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={2, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={2, 8}} },
                    {100, {object="scenery", layer=4, type="fg-debris-barrel-grey", size={6, 8}} },
                }
            },       

        {object="ledge", x=200, y=-200, surface="exploding"},

        {object="ledge", x=300, y=-50, surface="exploding"},
            {object="friend", type="fuzzy", x=-100, color="Orange", onLedge=true},

        {object="ledge", x=250, y=-150, surface="exploding"},
            {object="rings", color=aqua, trajectory={x=75, y=-240, xforce=130, yforce=15, arc=20, num=3}},

        {object="ledge", x=300, y=50, surface=pulley, distance=-300, speed=1, reverse="true"},
        
        {object="ledge", x=-200, y=-400, size="small2"},

        {object="ledge", x=-275, y=-175, surface=pulley, distance=-200, speed=1, reverse="true"},
            {object="rings", color=green, pattern={ {350,-655}}},

        {object="obstacle", x=250, y=-450, timerOn=1000, timerOff=1200, type="electricgate"},

        {object="ledge", x=100, y=150, size="medsmall2", canShake=false, movement={pattern={{490,-150}}, reverse=true, speed=2, pause=0}},
     
        {object="ledge", x=350, y=-760, size="medsmall", positionFromLedge=17},

        {object="ledge", x=-290, y=-150, size="medbig2"},

        {object="ledge", x=245, y=-280, surface="exploding"},
            {object="rings", color=aqua, trajectory={x=30, y=-150, xforce=40, yforce=125, arc=40, num=3}},

        {object="ledge", x=300, y=25, surface="exploding"},

        {object="ledge", x=250, y=-200, surface="exploding"},
            {object="scenery", x=150, y=-750, type="fgflt-pole-6"},
            {object="rings", color=aqua, trajectory={x=30, y=-150, xforce=70, yforce=120, arc=80, num=5}},

        {object="ledge", x=300, y=120, type="finish"}
    },
}

return levelData