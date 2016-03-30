local levelData = {
    name             = "you cannot be serious",
    --tutorial         = "intro-planet1-zone1",
    timeBonusSeconds = 50,
   -- playerStart      = playerStartFall,
    ceiling          = -1000,
    floor            = 2000,   
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {2, 3, 4, 1},
        [bgrMid]   = {2, 9, 2, 9},
        [bgrBack]  = {3, 4, 1, 2},
        [bgrSky]   = {1, 2}
    },

    elements = {
        {object="ledge", type="start"},
            {object="scenery", x=250, type="fg-foilage-2-yellow", layer=2, onLedge=true},         
            fgflt-tree-1-yellow    
           

-- Down
        {object="ledge", size="small3", x=375, y=150},
            {object="scenery", x=20, type="fg-flowers-6-yellow", layer=2, onLedge=true}, 
            {object="spike",  x=150,  y=-750, type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=1}},
        
        {object="ledge", size="small3", x=-250, y=200},
            {object="rings", color=aqua, pattern={ {180,-80}, {100,50}, {100,50}}},


        {object="ledge", size="small3", x=350, y=220},
        {object="scenery", x=500, y=-300, type="fg-tree-4-yellow", size=1.5, flip="x"},
        {object="scenery", x=-10, type="fg-flowers-1-yellow", layer=2, onLedge=true}, 

          {object="enemy", type="stomach", x=150, y=-650, size=0.8, 
                shooting={minWait=1, maxWait=3, velocity={varyX=300, varyY=300}, itemsMax=10, ammo={negDizzy, negTrajectory,}},
                behaviour={ mode=stateSleeping, awaken=2, range=3},
                movement={pattern=movePatternHorizontal, distance=600, speed=2, pause=500, moveStyle=moveStyleSwayBig}
            },


    {object="emitter", x=0, y=-300, timer={1000, 2500}, limit=3, layer=4,
                item={
                    object="livebgr", type="stomach", direction=right, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.3, 0, 0.4},
                    movement={rangeX={-250, 250}, rangeY={-100, -1000}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },             

--Up
        
        {object="ledge", size="small3", x=345, y=-100},

        {object="ledge", size="small3", x=-125, y=-250},
            {object="rings", color=aqua, trajectory={x=75, y=-200, xforce=50, yforce=90, arc=40, num=3}},

        
        {object="ledge", size="small2", x=280, y=-220},
           
            {object="spike",  x=150,  y=0, type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=1}},
            {object="spike",  x=520,  y=-475, type="fg-wall-divider", rotation=90, physics={shapeOffset={bottom=-30}, bounce=1}},

        {object="obstacle", type="ropeswing", x=600, y=-300, direction=right, length=300, movement={speed=1, arcStart=220, arc=100}},    

        {object="ledge", size="small3", x=450, y=150},
             {object="rings", color=aqua, pattern={ {215,-185}, {115,-75, color=pink}, {95,75,color=red}}},
             {object="scenery", x=-23, type="fg-flowers-5-yellow", size=0.4, layer=2, onLedge=true}, 

        {object="ledge", size="small", x=525, y=230},
            {object="wall",    x=175,  y=-800, type="fg-wall-divider", physics={shapeOffset={bottom=-20}, bounce=1}},

         {object="obstacle", x=-250, y=-250, type="pole", length=400},
            {object="wall", x=-80, y=-300, type="fg-rock-1", physics={shape="circle", bounce=1}},

        {object="ledge", size="medium", x=0, y=160},  
            {object="randomizer", x=0, onLedge=true, items={{30,gearReverseJump}, {70,gearFreezeTime}, {100,yellow}}},

         {object="emitter", x=150, y=-350, timer={2000, 5000}, limit=5, layer=4,
                item={
                    object="livebgr", type="brain", color="Purple", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.4, 0, 0.3},
                    movement={rangeX={-1500, 1500}, rangeY={0, -150}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },
  


            
--  start cave

        {object="enemy", type="brain", x=-655, y=-90, size=1.6, color="Blue", physics={shapeOffset={left=-2000}},
            behaviour={mode=stateSleeping, awaken=0, range=6, atRange=stateResetting},
            movement={pattern=movePatternHorizontal, speed=2, distance=-3700, oneWay=true, moveStyle=moveStyleWave}
        },
            
     
        {object="ledge", x=420, y=50, size="small3"},
            {object="spike",    x=175,  y=-200, type="fg-wall-divider", physics={shapeOffset={bottom=-20}, bounce=1}},
            {object="spike",   x=125,  y=75,    type="fg-spikes-float-3", size=0.8, physics={shape={0,-110, 80,110, -80,110}} },
            {object="scenery", x=950, y=-300, type="fg-tree-2-yellow", size=1.2, flip="x"},
            {object="rings", color=aqua, pattern={ {x=230, y=-275} }},

         {object="ledge", x=270, y=0, size="small"},
            {object="spike",    x=30, y=-1100, type="fg-wall-divider", physics={shapeOffset={left=30, bottom=-20}, bounce=1}},
            {object="spike",   x=137, y=75, type="fg-spikes-float-4", size=0.8, physics={shape={0,-110, 80,110, -80,110}} },
          --  {object="rings", color=pink, pattern={ {200,-100} }},
            
          {object="ledge", x=475, y=-50, size="small2"},
            {object="spike",    x=275,  y=-200, type="fg-wall-divider", physics={shapeOffset={bottom=-20}, bounce=1}},  
            {object="spike",   x=150, y=75, type="fg-spikes-float-3", size=0.8, physics={shape={0,-110, 80,110, -80,110}} },    
            {object="rings", color=aqua, pattern={ {215,-185}, {115,-75, color=white}, {95,75}}},
            {object="scenery", x=-20, type="fg-flowers-4-yellow", layer=2, onLedge=true}, 
            --{object="ledge", x=800, y=100, size="small", positionFromLedge=12},

        --  {object="ledge", x=875, y=100, size="small"},  

         {object="ledge", x=510, y=100, size="small3"},
            {object="spike",    x=65, y=-1300, type="fg-wall-divider", physics={shapeOffset={bottom=-20}, bounce=1}},
            {object="scenery", x=800, y=-150, type="fg-tree-1-yellow", size=1.2},
           -- {object="scenery", x=950, y=-300, type="fg-tree-2-yellow", size=1.2, flip="x"},  
            --{object="wall",    x=-50, y=-1100, type="fg-wall-divider", physics={shapeOffset={bottom=-20}, bounce=1}},

           -- {object="ledge", x=305, y=75, size="small"},

         {object="obstacle", type="deathslide", x=290, y=-290, length={450,-600}, speed=5, animSpeed="FAST"},
            
            {object="emitter", x=-150, y=0, timer={1000, 2000}, limit=2, layer=4,
                item={
                    object="livebgr", type="heart", color="Red", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.4, 0, 0.2},
                    movement={rangeX={-1500, 1500}, rangeY={0, -300}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },  

         {object="spike",  x=1000,  y=-425, type="fg-spikes-3", size=0.7, physics={shapeOffset={left=20}, bounce=1}},        
         {object="spike",  x=1110,  y=-250, type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=1}},
         {object="spike",  x=720,  y=-660, type="fg-wall-divider", rotation=90, physics={shapeOffset={bottom=-30}, bounce=1}},  


        {object="ledge", x=0, y=320, size="small2"}, 
             {object="rings", color=blue, pattern={{0,-55}}},
             {object="scenery", x=-20, type="fg-flowers-5-yellow", layer=2, onLedge=true}, 


        {object="obstacle", x=800, y=-275, type="pole", length=700},
            {object="wall", x=-75, y=-425, type="fg-rock-2", physics={shape="circle", bounce=1}},

        {object="ledge", x=0, y=270, size="small2"},     
            {object="spike",  x=720,  y=-500, type="fg-wall-divider", rotation=90, physics={shapeOffset={bottom=-30}, bounce=1}}, 
            {object="spike",  x=1620,  y=-500, type="fg-wall-divider", rotation=90, flip="y", physics={shapeOffset={bottom=-30}, bounce=1}},   

              {object="emitter", x=0, y=-100, timer={2000, 5000}, limit=5, layer=4,
                item={
                    object="livebgr", type="brain", color="Purple", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.4, 0, 0.3},
                    movement={rangeX={-1500, 1500}, rangeY={0, -150}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },


         {object="ledge", x=210, y=-220, size="small3", positionFromLedge=16},  
             {object="rings", color=white, pattern={{0,-55}}},

         {object="ledge", x=400, y=-185, size="small2"},
            {object="rings", color=green, pattern={{0,-55}}},


         {object="ledge", x=-300, y=-200, size="small"},
            {object="rings", color=yellow, pattern={{0,-55}}},




         {object="ledge", x=155, y=220, size="small", positionFromLedge=16},    

         {object="ledge", x=400, y=185, size="small2"},
            {object="rings", color=aqua, trajectory={x=80, y=-110, xforce=85, yforce=150, arc=65, num=4}},
            {object="randomizer", x=0, onLedge=true, items={{20,gearGloves}, {70,gearShield}, {100,gearGlider}}},

        
        {object="ledge", x=500, y=0, type="finish"},
            {object="scenery", x=-200, type="fg-foilage-2-yellow", layer=2, onLedge=true},             
            {object="scenery", x=-250, type="fg-foilage-3-yellow", layer=2, onLedge=true}, 
            {object="scenery", x=-300, type="fg-foilage-2-yellow", layer=2, flip="x", onLedge=true},

            
    },
}

return levelData