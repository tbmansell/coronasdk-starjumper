local levelData = {
    name             = "things are heating up",
    floor            = display.contentHeight+500,
    timeBonusSeconds = 55,
    turnNight        = true,

    backgroundOrder = {
        [bgrFront] = {1, 2, 3, 4},
        [bgrMid]   = {6, 4, 6, 4},
        [bgrBack]  = {1, 2, 3, 4},
        [bgrSky]   = {2, 1}
    },

    elements = {
        -- for AI 50% chance they will go high route or low route
        {object="ledge", type="start", ai={nextJump={[50]=11}}},
        	{object="scenery", x=100, y=-288, type="fg-rock-1", size=0.7, layer=2, rotation=-10},
        	{object="scenery", x=20,  y=-268, type="fg-rock-1", size=0.4, layer=2, rotation=-80},
        	{object="scenery", x=180, y=-258, type="fg-rock-1", size=0.3, layer=2, rotation=-50},

        -- Path one higher than start ledge
        {object="ledge", x=200, y=-250, surface="lava"},
        	{object="rings", color=aqua, trajectory={x=25, y=-100, xforce=100, yforce=50, arc=35, num=3}},
            {object="spike", x=200, y=-600, type="fg-spikes-float-1", size=1, flip="y", physics={shape={-90,-130, 90,-130, 0,120}}},

        {object="ledge", x=300, y=-50, surface="lava"},

        {object="ledge", x=400, y=-100, size="big3"},
        	{object="rings", color=aqua, trajectory={x=25, y=-100, xforce=160, yforce=20, arc=35, num=3}},

        	{object="enemy", type="heart", x=50, y=120, size=0.5, color="Red",
                behaviour={mode=stateSleeping, awaken=0, range=5, atRange=stateResetting, thefts=5},
                movement={pattern=movePatternFollow, speed=1, pause=1000, moveStyle=moveStyleWave, pauseStyle=moveStyleWave}
            },

        {object="obstacle", type="pole", x=200, y=-50, length=300, ai={ignore=75}},

        {object="ledge", x=300, y=-300, size="medium"},
        	{object="scenery", x=-70, y=-145, type="fg-foilage-1-yellow", size=1, layer=4, size=0.8, onLedge=true},
        	{object="scenery", x=-10, y=-115, type="fg-flowers-6-yellow", size=1, layer=2, size=0.3, onLedge=true},
        	{object="scenery", x=40,  y=-140, type="fg-flowers-6-yellow", size=1, layer=2, size=0.7, onLedge=true},
        	{object="scenery", x=-10, y=-145, type="fg-foilage-1-yellow", size=1, layer=2, size=0.8, onLedge=true},

        {object="ledge", x=450, y=50, rotation=15, size="medium"},
        	{object="friend", x=0, y=0, type="fuzzy", size=0.2, color="Orange"},

		{object="ledge", x=500, y=-150, surface="lava"},
			{object="rings", color=pink, trajectory={x=100, y=-150, xforce=160, yforce=120, arc=70, num=5}},

		{object="ledge", x=600, y=0, size="medium2"},
            {object="scenery", x=500, y=-150, type="fg-tree-1-yellow", size=0.8},
            {object="scenery", x=600, y=405, type="fg-rock-4", size=0.8},

		{object="ledge", x=300, y=-300, size="medium2", ai={nextJump={[100]=20}}, movement={pattern={{1000,500}}, reverse=true, speed=4}},


        -- Path two lower than start ledge
        {object="ledge", x=200, y=150, positionFromLedge=1, surface="lava"},
        	{object="rings", color=aqua, trajectory={x=50, y=-200, xforce=120, yforce=0, arc=35, num=3}},

        {object="ledge", x=300, y=50, surface="lava"},
        	{object="scenery", x=200, y=-50, type="fg-spikes-float-5", size=0.7, layer=2},

        {object="ledge", x=250, y=50, size="medium"},
            {object="gear", type=gearShield},
        	{object="rings", color=aqua, trajectory={x=100, y=-200, xforce=120, yforce=0, arc=35, num=3}},

        {object="ledge", x=300, y=-70, size="big"},

        	{object="enemy", type="brain", x=0, y=50, size=0.3, color="Purple",
                behaviour={mode=stateSleeping, awaken=0},
                movement={pattern={{0,-300}}, reverse=true , distance=400, speed=0.3, pause=1000, moveStyle=moveStyleSway, pauseStyle=moveStyleSwaySmall}
            },

        {object="ledge", x=450, y=50, rotation=-15, size="medium"},
        	{object="scenery", x=300, y=-50, type="fg-spikes-float-2", layer=2},

        {object="obstacle", type="deathslide", x=200, y=-300, length={650,-900}, speed=5, animSpeed="FAST", ai={ignore=50}},


        -- Paths joining
        {object="ledge", x=450, y=50, positionFromLedge=14, surface="lava"},
        	{object="rings", color=pink, trajectory={x=100, y=-150, xforce=90, yforce=60, arc=77, num=5}},

        {object="ledge", x=450, y=300, size="medium3"},
        	{object="friend", x=0, y=0, type="fuzzy", size=0.2, color="Orange"},

        {object="ledge", x=250, y=-200, size="medium3", movement={pattern={{1500,-450}}, reverse=true, speed=4}},

        {object="ledge", x=1800, y=-550, size="medium4"},
        	{object="rings", color=aqua, pattern={ {500,-200,color=red}, {0,-50}, {50,50}, {-50,50}, {-50,-50} }},
            {object="scenery", x=-100, y=-166,  type="fg-flowers-3-yellow",layer=2, size=0.7, onLedge=true},
            {object="scenery", x=400,  y=300,   type="fg-tree-5-yellow", size=1.4},
            {object="scenery", x=-200, y=300,   type="fg-tree-2-yellow", size=1.4},
            {object="spike",   x=-400, y=-1000, type="fg-spikes-float-1", size=1, flip="y", physics={shape={-90,-130, 90,-130, 0,110}}},
            {object="scenery", x=875,  y=-175,  type="fg-rock-1", size=0.7, layer=2, rotation=-10},
            {object="scenery", x=965,  y=-160,  type="fg-rock-1", size=0.4, layer=2, rotation=-80},

        {object="ledge", x=500, y=0, type="finish"}
    },
}

return levelData