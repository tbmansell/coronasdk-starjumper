local levelData = {
    name             = "conspiracy 23",
    timeBonusSeconds = 50,
    ceiling          = -1000,
    floor            = 2000,   
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {1, 2, 3, 4},
        [bgrMid]   = {4, 7, 4, 7},
        [bgrBack]  = {2, 3, 4, 1},
        [bgrSky]   = {2, 1}
    },

    elements = {
        {object="ledge", type="start"},

        {object="scenery", x=550, y=-150, type="fgflt-tree-1-yellow", layer=3},

        {object="ledge", x=150, y=-200, size="medium"}, 
              {object="scenery", x=35, type="fg-flowers-1-yellow", size=0.7, layer=2, onLedge=true},
             {object="rings", color=pink, pattern={ {396,-75}}}, 
             {object="enemy", type="stomach", x=400, y=-120, size=0.6, 
                shooting={minWait=1, maxWait=3, velocity={varyX=300, varyY=300}, itemsMax=6, ammo={negDizzy, negTrajectory}},
                behaviour={ mode=stateSleeping, awaken=0, range=3},
                movement={pattern=movePatternHorizontal, distance=600, speed=2, pause=500, moveStyle=moveStyleSwayBig}
            },

        -- Pit Set Up

        {object="spike",  x=720,  y=400, type="fg-wall-divider", rotation=90, physics={shapeOffset={bottom=-30}, bounce=1}}, 
        {object="spike",  x=1620,  y=400, type="fg-wall-divider", rotation=90, flip="y", physics={shapeOffset={bottom=-30}, bounce=1}},  
        {object="spike",  x=340,  y=0, type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=1}},
        {object="spike",  x=2000,  y=0, type="fg-wall-divider", physics={shapeOffset={bottom=-30, left=20}, bounce=1}},

        -- The Pit

        {object="ledge", x=360, y=150, size="medium", invisible={invisibleFor=3000, visibleFor=100, alpha=0.2}},
            {object="rings", color=aqua, pattern={ {250,-140}, {60,-60, color=blue}, {60,-60}}},
            {object="spike",  x=625,  y=-800, type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=1}},

           {object="emitter", x=-150, y=-200, timer={1000, 2000}, limit=5, layer=3,
                item={
                    object="livebgr", type="heart", color="Red", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.4, 0, 0.2},
                    movement={rangeX={-1500, 2000}, rangeY={500, -500}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },    

        {object="obstacle", type="deathslide", x=385, y=-290, length={-650,750}, speed=2, animSpeed="FAST"},

        {object="ledge", x=170, y=150, size="medium", invisible={invisibleFor=3000, visibleFor=100, alpha=0.2}},

        {object="ledge", x=225, y=-90, size="small", movement={pattern=movePatternHorizontal, distance=105, speed=1, dontDraw=true}, invisible={invisibleFor=3000, visibleFor=100, alpha=0.2}},

        {object="ledge", x=250, y=120, size="small", movement={pattern=movePatternHorizontal, distance=135, speed=1, dontDraw=true}, invisible={invisibleFor=3000, visibleFor=100, alpha=0.2}},

        {object="ledge", x=275, y=-150, size="small", movement={pattern=movePatternHorizontal, distance=165, speed=1, dontDraw=true}, invisible={invisibleFor=3000, visibleFor=100, alpha=0.2}},
             {object="scenery", x=170, y=-100, type="fgflt-tree-2-yellow", layer=1},


        {object="ledge", x=185, y=-202, size="small", invisible={invisibleFor=3000, visibleFor=100, alpha=0.2}},

        {object="ledge", x=-270, y=-330, size="small", movement={pattern=movePatternVertical, distance=175, speed=1, dontDraw=true}, invisible={invisibleFor=3000, visibleFor=100, alpha=0.2}}, 
            {object="enemy", type="heart", x=475, y=-100, size=0.5, color="White",
                behaviour={mode=stateSleeping, awaken=0, range=4, atRange=stateResetting, thefts=5},
                movement={pattern=movePatternFollow, speed=1, pause=1000, moveStyle=moveStyleWave, pauseStyle=moveStyleWave}
            },

         {object="emitter", x=500, y=-125, timer={1000, 3000}, limit=5, layer=4,
                item={
                    object="livebgr", type="brain", color="Purple", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.3, 0, 0.3},
                    movement={rangeX={-1000, 2000}, rangeY={-200, 450}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },            

        {object="ledge", x=-145, y=-202, size="small", invisible={invisibleFor=3000, visibleFor=100, alpha=0.2}},


        {object="ledge", x=425, y=-90, size="big"},
            {object="scenery", x=105, type="fg-flowers-2-yellow", size=0.7, layer=2, onLedge=true},
            {object="scenery", x=-40, type="fg-flowers-3-yellow", size=0.8, layer=2, onLedge=true},
            {object="spike", x=160, y=-225, size=0.5, type="fg-spikes-float-1", physics={shape={0,-110, 80,110, -80,110}}},
             {object="rings", color=aqua, trajectory={x=50, y=-150, xforce=250, yforce=20, arc=40, num=5}},
             {object="randomizer", x=-100, onLedge=true, items={{40,gearSpringShoes}, {80,gearGlider}, {100,yellow}}},


        {object="ledge", x=435, y=125, surface="electric", timerOn=1000, timerOff=5000}, 
            {object="spike", x=-275, y=-260, size=0.3, rotation=90, type="fg-spikes-float-1", physics={shape={0,-110, 80,110, -80,110}}},
           


        -- Secret Ledge
         {object="ledge", x=0, y=300, size="medium", positionFromLedge=11},
            {object="rings", color=aqua, pattern={ {-75,-100}, {75,0, color=pink}, {75,0, color=red}, {-150,50}, {75,0, color=pink}, {75,0, color=red}}},


        -- Ledge before Glider Bit 

        {object="ledge", x=275, y=150, size="medium", positionFromLedge=12},
            {object="rings", color=aqua, pattern={ {-150,-200}, {75,60, color=blue}, {75,60}}},
            {object="rings", color=yellow, pattern={ {675,100}}}, 
            {object="spike",  x=965,  y=-450, type="fg-wall-divider", rotation=110, flip="y", physics={shapeOffset={bottom=-30}, bounce=1}},  
            {object="spike",  x=600,  y=-975, type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=1}},
            {object="spike",  x=250,  y=-250, type="fg-wall-divider", rotation=90, physics={shapeOffset={top=30, left=20}, bounce=1}},

             {object="emitter", x=300, y=0, timer={1000, 3000}, limit=4, layer=3,
                item={
                    object="livebgr", type="stomach", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.2, 0, 0.6},
                    movement={rangeX={-1600, 1600}, rangeY={-350, 350}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },            


        {object="obstacle", x=1300, y=130, type="pole", length=700},

        {object="ledge", x=0, y=400, size="medium"},
            {object="spike",  x=600,  y=-1375, type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=1}},
            {object="rings", color=aqua, pattern={ {0,-400, color=blue}, {0,80, color=white}, {0,80, color=green}}},




         {object="obstacle", type="ropeswing", x=828, y=-185, direction=right, length=300, movement={speed=1.5, arcStart=220, arc=100}},
              
              {object="emitter", x=-150, y=-200, timer={1000, 2000}, limit=5, layer=3,
                item={
                    object="livebgr", type="heart", color="Red", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.4, 0, 0.2},
                    movement={rangeX={-800, 800}, rangeY={500, -1000}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },    

            
            {object="scenery", x=-350, y=-350, type="fgflt-tree-5-yellow", layer=3},

         {object="ledge", x=470, y=150, size="medium"},
            {object="scenery", x=30, type="fg-flowers-5-yellow", size=0.6, layer=2, onLedge=true},
            {object="rings", color=aqua, trajectory={x=30, y=-200, xforce=100, yforce=160, arc=65, num=5}},



          {object="ledge", x=300, y=-300, size="medium"},
            {object="rings", color=aqua, trajectory={x=30, y=-200, xforce=110, yforce=150, arc=65, num=5}},
             {object="scenery", x=-250, y=-450, type="fgflt-tree-3-yellow", layer=3},



          
        {object="ledge", x=400, y=-175, type="finish"},
            {object="scenery", x=-200, type="fg-foilage-2-yellow", layer=2, onLedge=true},             
            {object="scenery", x=-250, type="fg-foilage-3-yellow", layer=2, onLedge=true}, 
            {object="scenery", x=-300, type="fg-foilage-2-yellow", layer=2, flip="x", onLedge=true},

            
    },
}

return levelData