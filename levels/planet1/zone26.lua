local levelData = {
    name             = "yeah, its possible",
    floor            = display.contentHeight+750,
    ceiling          = -display.contentHeight*2,
    timeBonusSeconds = 150,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {3, 4, 1, 2},
        [bgrMid]   = {7, 9, 7, 9},
        [bgrBack]  = {1, 2, 3, 4},
        [bgrSky]   = {2, 1}
    },

    backgroundSounds = {
        {name="animals/birds3", quietTime=6000, minVolume=1, maxVolume=2},
        {name="animals/birds1", quietTime=8000, minVolume=1, maxVolume=2},
    },

    elements = {
        {object="ledge", type="start"},
            {object="scenery", x=180,  y=-700,  type="fg-tree-5-yellow", size=0.6, layer=4},
            {object="scenery", x=75,  y=-750, type="fg-tree-5-yellow", size=0.8, layer=4},
        
        {object="ledge", x=180, y=-150, size="small", movement={pattern=movePatternHorizontal, distance=125, speed=1}},
             {object="rings", color=aqua, pattern={ {150,-300}}},

        {object="ledge", x=195, y=-180, size="small", movement={pattern=movePatternVertical, distance=125, speed=1}},
             {object="rings", color=aqua, pattern={ {120,-320}}},
        {object="ledge", x=205, y=-200, size="small", movement={pattern=movePatternHorizontal, distance=125, speed=1}},
             {object="rings", color=aqua, pattern={ {180,-220}}},            
        {object="ledge", x=215, y=-215, size="small", movement={pattern=movePatternVertical, distance=125, speed=1}},
             {object="wall", x=100, y=-200, type="fg-rock-3", physics={shape="circle", bounce=1, radius=160}},


        {object="ledge", x=-220, y=-150, surface="electric", timerOn=1500, timerOff=3250, rotation=7},
                {object="rings", color=aqua, trajectory={x=30, y=-200, xforce=120, yforce=60, arc=20, num=3}},

        {object="ledge", x=200, y=-220, size="small"},
        
        {object="ledge", x=300, y=0, size="medium2", movement={pattern=movePatternVertical, distance=600, speed=1}},
            --{object="friend", type="fuzzy", x=300, y=143, color="Orange", kinetic="hangDouble"},
             {object="wall", x=225,  y=-750, type="fg-wall-divider", size=0.8, physics={shapeOffset={bottom=-30}, bounce=1}},
            {object="spike", x=175, y=-75, type="fg-rock-3", physics={shape="circle", bounce=1, radius=160}},
            {object="spike", x=175, y=400, type="fg-rock-4", size=1.3, physics={shape="circle", bounce=1, radius=160}},
            {object="spike", x=850, y=550, type="fg-rock-3", physics={shape="circle", bounce=1, radius=160}},
            {object="spike", x=650, y=50, type="fg-rock-4", size=1.3, physics={shape="circle", bounce=1, radius=160}},
            {object="rings", color=aqua, trajectory={x=30, y=350, xforce=90, yforce=50, arc=50, num=2}},


     {object="emitter", x=0, y=150, timer={1000, 3000}, limit=3, layer=4,
                item={
                    object="livebgr", type="brain", color="Purple", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.3, 0, 0.3},
                    movement={rangeX={-200, -1000}, rangeY={-50, 150}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },

        {object="ledge", x=1000, y=650, size="big2"},    

        {object="obstacle", type="deathslide", x=210, y=-250, length={800,300}, speed=4, animSpeed="SLOW"},
            {object="spike",   x=695, y=500, type="fg-spikes-float-1", size=0.6, physics={shape={0,-110, 80,110, -80,110}} },
            {object="rings", color=blue, pattern={ {0,-75}}},

        {object="obstacle", type="deathslide", x=500, y=375, length={-900,200}, speed=5, animSpeed="FAST"},
            {object="spike",   x=-975, y=500, type="fg-spikes-float-2", size=0.8, physics={shape={0,-110, 60,110, -60,110}} },
             {object="rings", color=aqua, pattern={ {-500,150}, {100,-20}, {100,-20} }},

        {object="obstacle", type="deathslide", x=-600, y=350, length={800,300}, speed=6, animSpeed="FAST"},
             {object="spike",   x=715, y=500, type="fg-spikes-float-3", size=0.8, physics={shape={0,-110, 80,110, -80,110}} },

        {object="ledge", x=-150, y=300, size="small"},
              {object="spike",   x=-200, y=-750, type="fg-spikes-float-1", size=0.8, physics={shape={0,-110, 80,110, -80,110}} },
            {object="spike", x=350,  y=-2050, type="fg-wall-divider", flip="y", physics={shapeOffset={bottom=-30}, bounce=1}},
            {object="spike", x=350,  y=-1150, type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=1}},
            {object="rings", color=aqua, trajectory={x=50, y=-150, xforce=75, yforce=50, arc=45, num=3}},


        {object="ledge", x=-200, y=100, size="small"}, 
             {object="randomizer", x=-20, onLedge=true, items={{30,gearParachute}, {70,gearFreezeTime}, {100,white}}}, 
              {object="wall", x=-125, y=-350, type="fg-rock-3", size=0.5, physics={shape="circle", bounce=1, radius=80}}, 

        {object="ledge", x=300, y=0, size="small", positionFromLedge=10}, 

           

        {object="ledge", x=250, y=-150, size="small", movement={pattern=movePatternHorizontal, distance=150, speed=2}},
             {object="rings", color=aqua, pattern={ {120,-320}}},

        {object="ledge", x=205, y=-180, size="small", movement={pattern=movePatternVertical, distance=150, speed=2}},
           
             {object="rings", color=aqua, pattern={ {120,-320}}},

        {object="ledge", x=210, y=-200, size="small", movement={pattern=movePatternHorizontal, distance=150, speed=2}},
             {object="rings", color=white, pattern={ {150,-320}}},

        {object="ledge", x=-300, y=-215, size="small", movement={pattern=movePatternVertical, distance=150, speed=2}},
            {object="spike", x=500,  y=0, type="fg-wall-divider", physics={shapeOffset={left=20}, bounce=1}},
            {object="spike", x=750,  y=-850, type="fg-wall-divider", physics={shapeOffset={left=20}, bounce=1}},
              {object="spike", x=750,  y=-1750, type="fg-wall-divider", flip="y", physics={shapeOffset={bottom=-30}, bounce=1}},
            {object="enemy", type="brain", x=800, y=125, size=0.4, color="Purple",
                behaviour={mode=stateSleeping, awaken=0},
                --behaviour={mode=stateAwake},
                movement={pattern=movePatternHorizontal, distance=-1400, speed=6, pause=500, moveStyle=moveStyleSway, pauseStyle=moveStyleSwaySmall}
            },    

        {object="ledge", x=-235, y=-260, size="medium2"},
              {object="rings", color=aqua, pattern={ {-75,-80}, {30,-50, color=blue}, {30,50}}},


          {object="ledge", x=270, y=-275, size="small"}, 
           {object="randomizer", x=20, onLedge=true, items={{30,gearParachute}, {70,gearGreen}, {100,Yellow}}}, 

         {object="ledge", x=554, y=400, size="medium3", positionFromLedge=16},   



         {object="ledge", x=300, y=-195, size="small"}, 
            {object="spike", x=-50, y=-550, type="fg-rock-1", physics={shape="circle", bounce=1, radius=160}},
             {object="rings", color=pink, pattern={ {0,-80}}},


         {object="ledge", x=250, y=-220, size="small"}, 

         {object="ledge", x=300, y=220, size="small"}, 
            {object="spike", x=-50, y=-575, type="fg-rock-1", size=1.3, physics={shape="circle", bounce=1, radius=160}},
             {object="rings", color=red, pattern={ {0,-80}}},

         {object="ledge", x=275, y=-240, size="small"}, 
             {object="rings", color=aqua, trajectory={x=30, y=-200, xforce=120, yforce=60, arc=20, num=3}},

        {object="ledge", x=250, y=-200, type="finish"}
    },
}

return levelData