local levelData = {
    name             = "explosive sprint",
    timeBonusSeconds = 28,
    ceiling          = -1000,
    floor            = 1800,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {8,17},
        [bgrBack]  = {},
        [bgrSky]   = {1, 2}
    },

    elements = {
        {object="ledge", type="start"},

            {object="emitter", x=-100, y=500, timer={3000, 6000}, limit=nil, force={ {0, 400}, {-100, -300}, {45, 180} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-ufo-left", size={6, 9}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={4, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 7}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-right", size={6, 11}} },
                }
            },

            {object="spike", x=1280,  y=-1000, type="fg-wall-dividerx2-spiked", physics={shapeOffset={top=50, right=-20},   bounce=1}},
            {object="spike", x=2300,  y=-1500, type="fg-wall-divider-spiked", physics={shapeOffset={top=50, right=-20},   bounce=1}},
            {object="spike", x=2300,  y=-100, type="fg-wall-divider-spiked", physics={shapeOffset={top=50, right=-20},   bounce=1}},
                  
        {object="obstacle", x=1870, y=-140, timerOn=1000, timerOff=0, type="electricgate"},

--First ledges Up

        {object="ledge", x=205, y=-150, size="medium", positionFromLedge=1},
            {object="rings", color=aqua, trajectory={x=30, y=-150, xforce=40, yforce=125, arc=40, num=3}},

        {object="ledge", x=210, y=-200, size="medsmall"},
                
        {object="ledge", x=-190, y=-290, size="small"},
            {object="key", x=0, y=-60, color="Yellow", onLedge=true},
                
        {object="ledge", x=290, y=-320, size="medsmall"},
            {object="rings", color=aqua, trajectory={x=50, y=-50, xforce=250, yforce=10, arc=35, num=5}},

              {object="warpfield", x=500, y=-75, size=1, radius=100, movement={steering=steeringMild, speed=3, pattern={{500, 0}, {-500, 0}}}},

--Second 

        {object="ledge", x=550, y=240, surface="exploding"},
            {object="enemy", type="greynapper", skin="fuzzy-napper", x=-35, y=-225, size=0.5,
                movement={pattern=moveTemplateHorizontal, isTemplate=true, distance=75, reverse=true, speed=2.5, pause=3000, pauseStyle=moveStyleSwayBig, --[[steering=steeringMild]]}
            },
            
        {object="ledge", x=-240, y=240, surface="exploding"},
            {object="rings", color=red, pattern={ {-50,-60} }},

        {object="ledge", x=340, y=275, surface="exploding"},
            {object="rings", color=blue, pattern={ {70,-60} }},

        {object="ledge", x=-320, y=275, surface="exploding"},
            {object="rings", color=white, pattern={ {-90,-60} }},

        {object="ledge", x=290, y=200, size="small"},
            
        {object="ledge", x=20, y=400, size="small"},
            {object="friend", type="fuzzy", x=30, color="Pink", onLedge=true},
            
        {object="ledge", x=-325, y=230, size="medsmall", keylock="Yellow", triggerObstacleIds={1}, positionFromLedge=10},

            {object="emitter", x=1700, y=-1700, timer={3000, 6000}, limit=nil, force={ {-1, -600}, {100, 300}, {45, 90} }, 
                  items={
                      {10, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={6, 8}} },    
                      {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 5}} },
                      {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 7}} },
                      {100, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                  }
            },

        {object="ledge", x=950, y=-325, type="finish"}
    },
}

return levelData