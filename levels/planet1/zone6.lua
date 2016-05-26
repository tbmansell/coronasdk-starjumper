local levelData = {
    name             = "move your body",
    floor            = display.contentHeight+300,
    ceiling          = -display.contentHeight-350,
    timeBonusSeconds = 60,
    startAtNight     = true,
    turnDay          = true,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {2, 3, 4, 1},
        [bgrMid]   = {4, 3, 4, 3},
        [bgrBack]  = {3, 4, 1, 2},
        [bgrSky]   = {1, 2}
    },

    elements = {
        {object="ledge", type="start"},
            {object="scenery", x=100, y=-298, size=1.2, layer=2, type="fg-flowers-1-yellow"},
        
        {object="ledge", x=280, y=-100, rotation=-25},
            {object="enemy", type="brain", x=280, y=-250, size=0.5, color="Purple",
                behaviour={mode=stateSleeping, awaken=0},
                movement={pattern=movePatternVertical, distance=200, speed=0.6, pause=0, moveStyle="sway", pauseStyle="sway-small"}
            },

            {object="scenery", x=450, y=-450, type="fg-tree-5-yellow", size=1.0},
            {object="scenery", x=300, y=200, type="fg-wall-double-l1"}, 
            {object="rings", color=aqua, trajectory={x=0, y=-150, xforce=110, yforce=100, arc=60, num=3}},

        {object="ledge", x=280, y=0, rotation=25},

        {object="ledge", x=150, y=-275, size="small", ai={ignore=true}},
            {object="gear", type=gearReverseJump, x=0, y=-100},
            {object="scenery", x=400, y=-500, layer=2, type="fg-rock-4", size=1.2},
            {object="scenery", x=400, y=-330, layer=2, type="fg-flowers-5-yellow", layer=2, size=0.7, rotation=15, flip="y"},

            {object="emitter", x=0, y=100, timer={2000, 5000}, limit=4, layer=4,
                item={
                    object="livebgr", type="brain", color="Purple", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.3, 0, 0.3},
                    movement={rangeX={-750, 750}, rangeY={-100, 100}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },    


        {object="ledge", x=0, y=330, size="medium3", movement={pattern={{500,-150}}, reverse=true, distance=200, speed=1.5, pause=2000}},  
        
        {object="ledge", x=700, y=-200, size="small"},
            {object="wall",    x=-50,  y=-1150, type="fg-wall-divider", physics={shapeOffset={bottom=-20}, bounce=1}},
            {object="spike",   x=125,  y=75,    type="fg-spikes-float-3", size=0.8, physics={shape={0,-110, 80,110, -80,110}} },
            {object="scenery", x=-300, y=150,   type="fg-tree-5-yellow", size=1.2, flip="x"},
            {object="scenery", x=-50,  y=300,   type="fg-tree-5-yellow", size=1.2},
            {object="rings", color=aqua, pattern={ {x=175, y=-100} }},

         {object="ledge", x=250, y=0, size="small"},
            {object="wall",    x=-50, y=-1100, type="fg-wall-divider", physics={shapeOffset={bottom=-20}, bounce=1}},
            {object="spike",   x=137, y=75, type="fg-spikes-float-4", size=0.8, physics={shape={0,-110, 80,110, -80,110}} },
            {object="rings", color=pink, pattern={ {200,-100} }},
            
         {object="ledge", x=275, y=0, size="small"},
            {object="wall",    x=-50, y=-1150, type="fg-wall-divider", physics={shapeOffset={bottom=-20}, bounce=1}},   
            {object="spike",   x=150, y=75, type="fg-spikes-float-3", size=0.8, physics={shape={0,-110, 80,110, -80,110}} },    
            {object="rings", color=aqua, pattern={ {210,-100} }},

         {object="ledge", x=300, y=0, size="small"},
            {object="scenery", x=800, y=150, type="fg-tree-5-yellow", size=1.2},
            {object="scenery", x=950, y=300, type="fg-tree-5-yellow", size=1.2, flip="x"},  
            {object="wall",    x=-50, y=-1100, type="fg-wall-divider", physics={shapeOffset={bottom=-20}, bounce=1}},

        {object="ledge", x=210, y=0, size="medium3", movement={pattern={{500,150}}, reverse=true,  distance=200, speed=2, pause=900}},
        		  {object="randomizer", x=-60, onLedge=true, items={{30,negDizzy}, {70,gearSpringShoes}, {100,red}}},    

        {object="ledge", x=400, y=-100, size="medium"},
            {object="rings", color=aqua, pattern={ {-135,175}, {0,-75}, {75,0}, {0,75} }},
            {object="scenery", x=-100, y=-600, layer=2, type="fg-rock-4", size=1.2},
            {object="scenery", x=-100, y=-430, layer=2, type="fg-flowers-6-yellow", layer=2, size=0.7, rotation=15, flip="y"},
            {object="scenery", x=0, y=-500, layer=2, type="fg-flowers-6-yellow", layer=2, size=0.7, rotation=-15, flip="y"},

             {object="emitter", x=0, y=-350, timer={1000, 5000}, limit=5, layer=4,
                item={
                    object="livebgr", type="brain", color="Purple", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.3, 0, 0.3},
                    movement={rangeX={-750, 750}, rangeY={-50, 250}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },    

        {object="ledge", x=350, y=-225, size="medium"},
            {object="friend", type="fuzzy", x=-70, color="Orange", onLedge=true},
            
            {object="enemy", type="brain", x=200, y=-150, size=0.5, color="Purple",
                behaviour={mode=stateSleeping, awaken=0},
                movement={pattern={{0,220}, {-400,0}, {0,-220}, {400,0}}, speed=4, pause=0, moveStyle="sway", pauseStyle="sway-small"}
            },

            {object="friend", x=550, y=-450, type="ufoboss", size=0.7, direction=right,
                movement={speed=1, pause=2000, distance=100, pauseStyle=moveStyleWaveBig, pattern=movePatternVertical}
            },

        {object="ledge", x=250, y=-200, type="finish"},
            {object="scenery", x=-150, y=-311, layer=2, size=1.2, type="fg-flowers-3-yellow"}
    },
}

return levelData