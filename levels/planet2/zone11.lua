local levelData = {
    name             = "up and down",
    timeBonusSeconds = 68,
    ceiling          = -3000,
    floor            = 1800,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {16, 8},
        [bgrBack]  = {},
        [bgrSky]   = {1, 2}
    },

    backgroundSounds = {
        {name="nature/wind5", quietTime=3000, minVolume=1, maxVolume=2},
        {name="nature/wind1", quietTime=6000, minVolume=2, maxVolume=3},
    },

    elements = {
        {object="ledge", type="start"},

            {object="emitter", x=100, y=-1500, timer={2000, 4000}, limit=nil, force={ {0, 400}, {100, 300}, {45, 180} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={7, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 10}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                }
            },
            {object="emitter", x=100, y=800, timer={2000, 4000}, limit=nil, force={ {0, 400}, {-100, -300}, {45, 180} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={7, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 10}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                }
            },
            {object="wall", x=580,  y=-1300, type="fg-wall-divider", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            
        {object="ledge", x=300, surface=pulley, distance=-1000, speed=1, reverse="true"},
            {object="wall", x=190,  y=-1700, type="fg-wall-divider", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="spike", x=-50,  y=-1200, type="fg-spikes-float-2", size=1.4, physics={shape={-20,-100, 65,150, 0,40, -50,150}}, flip="y"},

        {object="ledge", x=300, y=-400, surface=pulley, distance=-1000, speed=2},
            {object="rings", color=aqua, pattern={ {200,-450} }},
            {object="wall", x=190,  y=-1800, type="fg-wall-divider", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="spike", x=-80,  y=-1200, type="fg-spikes-float-5", size=1.4, physics={shape={-20,-90, 70,120, -80,20}}, flip="y"},

        {object="ledge", x=300, y=-500, surface=pulley, distance=-1000, speed=3},
            {object="rings", color=pink, pattern={ {200,-550} }},
            {object="wall", x=190,  y=-1900, type="fg-wall-divider", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="spike", x=-50,  y=-1200, type="fg-spikes-float-2", size=1.4, physics={shape={-20,-100, 65,150, 0,40, -50,150}}, flip="y"},
        
        {object="ledge", x=300, y=-600, surface=pulley, distance=-1000, speed=4},
            {object="spike", x=-80,  y=-1200, type="fg-spikes-float-5", size=1.4, physics={shape={-20,-90, 70,120, -80,20}}, flip="y"},

        {object="ledge", x=280, y=-600, size="big3", movement={pattern={{50,-60},{-50,30},{-50,-40},{50,70}}, speed=1, pause=0, dontDraw=true, steering=steeringSmall}},

            {object="emitter", x=0, y=1500, timer={3000, 6000}, limit=nil, force={ {-400, 400}, {-100, -300}, {45, 95} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-5", size={4, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 8}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-right", size={6, 8}} },
                }
            },

        -------------------------Rocket

 		{object="obstacle", type="spacerocket", x=300, y=0, angle=-20, takeoff="slow", force={1000,-700}, rotation={time=100, degrees=1}},
			{object="scenery", x=800, y=-500, type="fgflt-pole-2"},


        {object="ledge", x=1400, y=0, size="big3", movement={pattern={{-50,-30},{50,-50},{50,30},{-50,50}}, speed=1, pause=0, dontDraw=true,  steering=steeringSmall}},
            {object="spike", x=200,  y=-1250, type="fg-wall-divider-spiked", physics={shapeOffset={bottom=0, left=0}, bounce=1}},
            
        {object="ledge", x=300, surface=pulley, distance=1000, speed=3, reverse="true"},
            {object="spike", x=190,  y=-800, type="fg-wall-divider-spiked", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="spike", x=-50,  y=800, type="fg-spikes-float-2", size=1.4, physics={shape={-75,-100, 75,-100, -25,200}}},

        {object="ledge", x=300, y=400, surface=pulley, distance=1000, speed=4},
            {object="rings", color=aqua, pattern={ {200,450} }},
            {object="spike", x=190,  y=-700, type="fg-wall-divider-spiked", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="spike", x=-80,  y=800, type="fg-spikes-float-5", size=1.4, physics={shape={-75,-40, 75,-40, -25,200}}},

        {object="ledge", x=300, y=500, surface=pulley, distance=1000, speed=5},
            {object="rings", color=pink, pattern={ {200,550} }},
        
            {object="emitter", x=100, y=-875, timer={2000, 4000}, limit=nil, force={ {-10, -350}, {100, 300}, {45, 90} }, 
                items={
                      {10, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={6, 8}} },    
                      {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 5}} },
                      {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 7}} },
                      {100, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                }
            },

            {object="spike", x=190,  y=-600, type="fg-wall-divider-spiked", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="spike", x=-50,  y=800, type="fg-spikes-float-2", size=1.4, physics={shape={-75,-100, 75,-100, -25,200}}},
        
        {object="ledge", x=300, y=600, surface=pulley, distance=1000, speed=4},
            {object="spike", x=-80,  y=800, type="fg-spikes-float-5", size=1.4, physics={shape={-75,-100, 75,-100, -25,200}}},
        
        {object="ledge", x=500, y=100, type="finish"}
    },
}

return levelData