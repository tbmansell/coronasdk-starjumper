local levelData = {
    name             = "model behaviour",
    timeBonusSeconds = 28,
    ceiling          = -2000,
    floor            = 1000,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {0, 17},
        [bgrBack]  = {},
        [bgrSky]   = {1, 2}
    },

    elements = {
        {object="ledge", type="start"},

            {object="emitter", x=-100, y=500, timer={3000, 6000}, limit=nil, force={ {0, 500}, {-100, -300}, {45, 180} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 9}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 9}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-right", size={6, 11}} },
                }
            },
            {object="emitter", x=1900, y=500, timer={3000, 6000}, limit=nil, force={ {-10, -500}, {-100, -300}, {45, 180} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-blue", size={6, 11}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-5", size={4, 9}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-left", size={6, 11}} },
                }
            },

--Cross Beam
            {object="spike", x=910,  y=-1500, type="fg-wall-divider-spiked", rotation=90, physics={shapeOffset={top=50, right=-20},   bounce=1}},   
--Start
            {object="spike", x=50,  y=-900, type="fg-wall-divider-spiked", rotation=90, physics={shapeOffset={top=50, right=-20},   bounce=1}},
--Middle
            {object="spike", x=925,  y=-1750, type="fg-wall-dividerx2-spiked", physics={shapeOffset={top=50, right=-20},   bounce=1}},
--End
            {object="spike", x=1965,  y=-900, type="fg-wall-divider-spiked", rotation=90, physics={shapeOffset={top=50, right=-20},   bounce=1}},         

--Side one

        {object="ledge", x=235, y=75, surface=pulley, distance=-900, speed=3, reverse="true", regenerate="true"},

        {object="ledge", x=-335, y=-550, surface=pulley, distance=-1000, speed=3, reverse="true", regenerate="true"},
            {object="spike", x=-80,  y=-1300, type="fg-rock-1", size=1.4, rotation=-45, physics={shape="circle", friction=0.3, bounce=0.4}},
            {object="spike", x=-320,  y=-1150, type="fg-rock-5", size=0.7, rotation=-45, physics={shape="circle", friction=0.3, bounce=0.4}},
            {object="spike", x=120,  y=-1150, type="fg-rock-5", size=0.7, rotation=-45, physics={shape="circle", friction=0.3, bounce=0.4}},
       
        {object="ledge", x=205, y=-600, size="small3"},
            {object="rings", color=aqua, trajectory={x=20, y=-150, xforce=40, yforce=125, arc=40, num=3}},

        {object="ledge", x=134, y=-260, size="small3"},    

        {object="ledge", x=-253, y=-285, size="small3"},     

        {object="ledge", x=500, y=100, surface="exploding"},
            {object="rings", color=pink, pattern={ {-70,-60} }},

        {object="ledge", x=315, y=270, size="medium"},
            {object="rings", color=aqua, trajectory={x=-110, y=-150, xforce=-80, yforce=0, arc=55, num=3}},

            {object="emitter", x=500, y=-800, timer={3000, 6000}, limit=nil, force={ {-1, -600}, {100, 300}, {45, 90} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={6, 8}} },    
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-4", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-1", size={4, 7}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                }
            },
            {object="spike", x=400,  y=-500, type="fg-rock-2", size=1.2, rotation=-45, physics={shape="circle", friction=0.3, bounce=0.4}},
            {object="spike", x=400,  y=-200, type="fg-rock-2", size=1.0, rotation=-45, physics={shape="circle", friction=0.3, bounce=0.4}},
            {object="spike", x=400,  y=75, type="fg-rock-2", size=0.8, rotation=-45, physics={shape="circle", friction=0.3, bounce=0.4}},

        {object="ledge", x=-400, y=205, size="medsmall2", rotation=17},

        {object="ledge", x=335, y=95, surface=pulley, distance=650, speed=3, reverse="true", regenerate="true"},

        {object="ledge", x=-275, y=475, surface=pulley, distance=1500, speed=5, reverse="true", regenerate="true"},
            {object="rings", color=aqua, pattern={ {200,-150}, {40,-120,color=white}, {40,120} }},
            {object="rings", color=aqua, trajectory={x=30, y=650, xforce=40, yforce=125, arc=40, num=3}},
            {object="friend", type="fuzzy", x=-50, color="White", onLedge=true},

        {object="ledge", x=275, y=500, type="finish", fromLedgePosition=1}
    },
}

return levelData