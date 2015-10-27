local levelData = {
    name             = "close the gate",
    timeBonusSeconds = 28,
    ceiling          = -1000,
    floor            = 1000,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {3},
        [bgrBack]  = {},
        [bgrSky]   = {1, 2}
    },

    elements = {
        {object="ledge", type="start"},

            {object="emitter", x=100, y=-1400, timer={3000, 7000}, limit=nil, force={ {0, 200}, {100, 300}, {0, 360} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 7}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-blue", size={6, 8}} },
                }
            },
        
        {object="ledge", x=280, y=-150, size="medsmall"},
        
        {object="ledge", x=300, y=-160, size="medsmall2"},
            {object="rings", color=aqua, trajectory={x=50, y=-300, xforce=130, yforce=60, arc=40, num=3}},

        {object="ledge", x=-550, y=-190, size="small"},
            {object="gear", type=gearShield, x=30, y=-150, onLedge=true, regenerate=false},
            {object="spike",   x=-250,  y=-200, type="fg-spikes-float-1", size=0.5, rotation=15},

        {object="ledge", x=320, y=-170, size="medsmall", positionFromLedge=3},

        {object="obstacle", x=250, y=-100, timerOn=2000, timerOff=3000, type="electricgate"},

        {object="ledge", x=300, y=250, surface="collapsing"},

            {object="emitter", x=0, y=-799, timer={3000, 6000}, limit=nil, force={ {-400, 400}, {100, 300}, {0, 360} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={2, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-4", size={2, 8}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-left", size={6, 8}} },
                }
            },

            {object="emitter", x=0, y=490, timer={4000, 8000}, limit=nil, force={ {-500, 500}, {-100, -300}, {0, 360} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={2, 5}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-left", size={6, 8}} },
                }
            },

        {object="obstacle", x=250, y=-100, timerOn=2000, timerOff=4000, type="electricgate"},

        {object="ledge", x=300, y=250, surface="collapsing"},
            {object="rings", color=aqua, pattern={ {-100,-80}}},

        {object="obstacle", x=250, y=-200, timerOn=3000, timerOff=4000, type="electricgate"},

        {object="ledge", x=300, y=250, size="medium3"},
            {object="rings", color=aqua, trajectory={x=110, y=-150, xforce=70, yforce=50, arc=70, num=3}},

        {object="ledge", x=1, y=450, size="medsmall3"},
            {object="friend", type="fuzzy", color="Red", onLedge=true},

        {object="ledge", x=320, y=220, size="big3", rotation=-10, positionFromLedge=8}, 
            {object="wall", x=350,  y=-350, type="fg-wall-divider", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
           
        {object="ledge", x=400, y=0, size="medbig", rotation=15},
            {object="rings", color=aqua, trajectory={x=50, y=-100, xforce=130, yforce=15, arc=40, num=3}},

            {object="emitter", x=350, y=-955, timer={3000, 6000}, limit=nil, force={ {-200, 10}, {100, 300}, {0, 360} }, 
                  items={
                      {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={5, 8}} },
                      {90,  {object="scenery", layer=4, type="fg-bg-rock-5", size={4, 7}} },
                      {100, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                  }
            },
        
        {object="ledge", x=300, y=0, type="finish"}
    },
}

return levelData