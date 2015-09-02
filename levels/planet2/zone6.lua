local levelData = {
    name             = "express elevator to hell...",
    timeBonusSeconds = 28,
    ceiling          = -1500,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {7},
        [bgrBack]  = {},
        [bgrSky]   = {1, 2}
    },

    elements = {
        {object="ledge", type="start"},

        {object="ledge", x=210, y=-300, size="medium3", movement={pattern={{0,200}}, reverse=true, speed=3, pause=1000}},
            {object="rings", color=pink, pattern={ {200,-150}}},

        {object="ledge", x=300, y=-170, size="medium3"},
            {object="rings", color=aqua, trajectory={x=30, y=-200, xforce=90, yforce=120, arc=65, num=3}},

            {object="emitter", x=200, y=699, timer={2000, 4000}, limit=nil, force={ {-500, 500}, {-100, -300}, {0, 360} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-ufo-left", size={6, 9}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={3, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-4", size={4, 8}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-right", size={6, 9}} },
                }
            },    

        {object="ledge", x=210, y=0, size="medium3", movement={pattern={{1600,0}}, reverse=true, speed=3, pause=1000}},

        --Fuzzy
        {object="ledge", x=200, y=280, size="medium3"},
            {object="friend", type="fuzzy", color="White", onLedge=true},

        {object="ledge", x=700, y=-250, size="small2", positionFromLedge=4},
            {object="enemy", type="greynapper", skin="ring-stealer", x=575, y=-100, size=0.5,
                movement={pattern=moveTemplateVertical, isTemplate=true, distance=1, reverse=true, speed=2.5, pause=3000, pauseStyle=moveStyleSwayBig, --[[steering=steeringMild]]}
            },
           
        {object="obstacle", x=150, y=200, timerOn=2000, timerOff=0, type="electricgate"},
           
            {object="emitter", x=0, y=-950, timer={2000, 6000}, limit=nil, force={ {-500, 500}, {100, 300}, {0, 360} }, 
                items={
                    {20, {object="scenery", layer=1, type="fg-debris-barrel-blue", size={6, 9}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={3, 9}} },
                    {70,  {object="scenery", layer=4, type="fg-bg-rock-2", size={3, 9}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={6, 8}} },
                }
            },

        {object="ledge", x=920, y=-145, size="medium2"},
            {object="wall", x=-475, y=-400, type="fg-rock-1", size=1.2, rotation=-45, physics={shape="circle", friction=0.3, bounce=0.4}},
            {object="rings", color=aqua, trajectory={x=30, y=-200, xforce=110, yforce=170, arc=65, num=3}},

        {object="ledge", x=210, y=0, size="medium3", movement={pattern={{1600,-200}}, reverse=true,  distance=800, speed=1.5, pause=1000}},

        {object="ledge", x=600, y=-350, size="small2"},
            {object="enemy", type="greynapper", skin="fuzzy-napper", x=650, y=-125, size=0.5,
                movement={pattern=moveTemplateVertical, isTemplate=true, distance=1, reverse=true, speed=2.5, pause=3000, pauseStyle=moveStyleSwayBig}, --steering=steeringMild}
            },
            {object="obstacle", x=150, y=200, timerOn=2000, timerOff=0, type="electricgate"},

            {object="emitter", x=0, y=-800, timer={2000, 6000}, limit=nil, force={ {-500, 500}, {100, 300}, {0, 360} }, 
                items={
                    {30, {object="scenery", layer=1, type="fg-debris-barrel-blue", size={6, 9}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={3, 9}} },
                    {70,  {object="scenery", layer=4, type="fg-bg-rock-2", size={3, 9}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={6, 8}} },
                }
            },

        {object="ledge", x=1000, y=-170, size="medsmall"},
            {object="wall", x=-600, y=-500, type="fg-rock-1", size=1.2, rotation=-45, physics={shape="circle", friction=0.3, bounce=0.4}},
            {object="rings", color=aqua, trajectory={x=30, y=-200, xforce=90, yforce=120, arc=65, num=3}},
        
        {object="ledge", x=300, y=-170, size="medsmall"},      

        	  {object="warpfield", x=220, y=-240, size=0.75, radius=100, movement={steering=steeringMild, speed=4, pattern={{0, 150}, {0, -150}}}},    
        
        {object="ledge", x=300, y=-200, type="finish"}
    },
}

return levelData