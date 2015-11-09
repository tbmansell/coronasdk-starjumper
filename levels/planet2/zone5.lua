local levelData = {
    name             = "think backwards",
    timeBonusSeconds = 28,
    ceiling          = -1000,
    startLedge       = 7,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {8, 8},
        [bgrBack]  = {},
        [bgrSky]   = {1, 2}
    },

    elements = {
        {object="ledge", type="start"},

        {object="ledge", x=300, y=-170, size="medsmall"},
            {object="rings", color=aqua, trajectory={x=30, y=-150, xforce=40, yforce=125, arc=40, num=3}},
        
        {object="ledge", x=310, y=-180, size="small2"},
            {object="enemy", type="greyufo", x=-175, y=-175, size=0.7, 
                movement={pattern=moveTemplateSquare , isTemplate=true, distance=800, speed=2.5, pause=500, reverse=true, moveStyle=moveStyleSwayBig, pauseStyle=moveStyleSwayBig}
            },
       
        {object="ledge", x=300, y=-170, size="medbig"},

            {object="emitter", x=0, y=-699, timer={2000, 5000}, limit=nil, force={ {-400, 400}, {100, 300}, {0, 360} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-5", size={4, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-1", size={3, 8}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-left", size={6, 8}} },
                }
            },          
            {object="wall", x=475,  y=-1100, type="fg-wall-divider", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="wall", x=475,  y=200, type="fg-wall-divider", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="spike", x=340,  y=-430, type="fg-spikes-row-big", rotation=-90, physics={shapeOffset={top=20, left=-30}}},

        {object="ledge", x=-310, y=-220, size="small2"},
            {object="friend", type="fuzzy", color="Pink", onLedge=true},

        {object="ledge", x=300, y=150, surface="collapsing", positionFromLedge=4},
            {object="rings", color=pink, pattern={ {80,-80} }},
            {object="spike", x=100,  y=-400, size=0.6, type="fg-spikes-float-3", rotation=240, physics={shape={-60,-130, 70,140, -80,140}}},	
            
        {object="ledge", x=-250, y=250, size="medsmall2"},

        {object="ledge", x=420, y=0, size="big3"},

        {object="ledge", x=320, y=-150, surface="ramp"},
            {object="rings", color=aqua, pattern={ {450,-300}, {40,-80}, {40,80} }},  
            {object="wall", x=237,  y=314, type="fg-wall-divider", copy=2, gap=1095, physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="spike", x=250,  y=105, type="fg-wall-divider-fs-completedown", physics={shapeOffset={top=50, right=-20},   bounce=1}},
            {object="spike", x=547,  y=81, type="fg-spikes-row-big", copy=2, gap=100},

            {object="emitter", x=0, y=490, timer={2000, 5000}, limit=nil, force={ {-500, 500}, {-100, -300}, {0, 360} }, 
                items={
                    {10,  {object="scenery", layer=1, type="fg-debris-barrel-blue", size={6, 9}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={3, 9}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-2", size={3, 9}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                }
            },
    
        {object="ledge", x=-250, y=-280, size="small2"},
            {object="rings", color=aqua, pattern={ {0,-80} }},

		{object="ledge", x=300, y=-150, size="small2"},
			{object="wall", x=475,  y=-1100, type="fg-wall-divider", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
		
		{object="ledge", x=-400, y=-150, size="small2"},
            {object="gear", type=gearJetpack, x=0, y=-150, onLedge=true, regenerate=false},

        {object="obstacle", x=1200, y=200, size=1.3, timerOn=2000, timerOff=3000, type="electricgate", positionFromLedge=7},
   
        {object="ledge", x=825, y=200, size="big2"},        
            {object="rings", color=aqua, trajectory={x=35, y=-100, xforce=60, yforce=120, arc=30, num=3}},     

        {object="ledge", x=150, y=-200, size="medium3"},
        
        {object="ledge", x=300, y=-200, type="finish"}
    },
}

return levelData