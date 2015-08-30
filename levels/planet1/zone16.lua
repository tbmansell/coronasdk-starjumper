local levelData = {
    name             = "swing if you're winning",
    timeBonusSeconds = 40,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {4, 1, 2, 3},
        [bgrMid]   = {11, 2, 11, 2},
        [bgrBack]  = {1, 2, 3, 4},
        [bgrSky]   = {1, 2}
    },

    elements = {
        {object="ledge", type="start"},
            {object="scenery", x=50,  y=-238, type="fg-foilage-4-yellow", layer=2, size=0.5},
            {object="scenery", x=200, y=-238, type="fg-foilage-4-yellow", layer=2, size=0.5, flip="x"},

       {object="ledge", x=230, y=-175, surface="collapsing"},
            {object="rings", color=aqua, trajectory={x=30, y=-150, xforce=60, yforce=100, arc=30, num=3}},
        
        {object="ledge", x=150, y=-150, surface="electric", timerOn=1000, timerOff=8000},
           {object="rings", color=aqua, trajectory={x=30, y=-150, xforce=70, yforce=150, arc=50, num=3}},   
           
        {object="ledge", x=280, y=-175, surface="collapsing"},            

        {object="ledge", x=280},
            {object="scenery", x=0,  y=-165, type="fg-flowers-2-yellow",layer=2, onLedge=true},
            {object="scenery", x=50, y=-155, type="fg-flowers-2-yellow",layer=2, size=0.8, flip="x", onLedge=true},

        {object="obstacle", type="ropeswing", x=450, y=-200, direction=right, length=200, movement={speed=1, arcStart=230, arc=90}, ai={ignore=true}},
            {object="scenery", x=-300, y=-300, type="fg-rock-3", size=0.5, layer=2}, 
            {object="wall",    x=-500, y=300,  type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=1}},
            {object="wall",    x=0,    y=300,  type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=1}},

            {object="enemy", type="brain", x=-200, y=400, size=1.1, color="Blue",
                movement={pattern=movePatternHorizontal, distance=60, speed=0.3, pause=1000, moveStyle=moveStyleSwaySmall, pauseStyle=moveStyleSwayBig}
            },

        {object="ledge", x=400, y=200},
            {object="rings", color=aqua, trajectory={x=30, y=-150, xforce=150, yforce=175, arc=50, num=5}},

        {object="ledge", x=150, y=-150, surface="electric", timerOn=1000, timerOff=0, rotation=-25, ai={ignore=true}},
        
        {object="obstacle", x=250, y=-400, type="pole", length=500},
            {object="wall", x=-80, y=-300, type="fg-rock-1", physics={shape="circle", bounce=1}},
            {object="friend", type="fuzzy", x=-50, y=-100, size=0.2, color="Pink", kinetic="hang", direction=left},

        {object="ledge", x=0, y=250, surface="collapsing", ai={ignore=true}},

        {object="ledge", x=190, y=-180, size="medium2"},
            {object="rings", color=aqua, trajectory={x=30, y=-150, xforce=25, yforce=150, arc=50, num=3}}, 

        {object="ledge", x=150, y=-200, size="small2", ai={loadGear=gearParachute, jumpVelocity={450,800}, useAirGearAfter={1300}}},
            {object="scenery", x=-50, y=-133, type="fg-flowers-3-yellow",layer=2, size=0.5, flip="x", onLedge=true},

        {object="ledge", x=150, y=-50, surface="electric", timerOn=5000, timerOff=0, ai={ignore=true}},
            {object="rings", color=aqua, pattern={ {270,-140}, {0,100}, {0,100}, {0,100}}},
            {object="wall",    x=350, y=-800, type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=1}},
        
        {object="ledge", x=200, y=200, positionFromLedge=10, type="finish"}
    },
}

return levelData