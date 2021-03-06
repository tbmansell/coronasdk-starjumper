local levelData = {
    name             = "shock factor",
    floor            = display.contentHeight+300,
    ceiling          = -display.contentHeight*2,
    timeBonusSeconds = 85,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {2, 3, 4, 1},
        [bgrMid]   = {5, 8, 5, 8},
        [bgrBack]  = {1, 2, 3, 4},
        [bgrSky]   = {2, 1}
    },

    backgroundSounds = {
        {name="nature/wind5", quietTime=8000, minVolume=2, maxVolume=4},
    },

    elements = {
        {object="ledge", type="start"},
        
        {object="ledge", x=300, y=75, surface="electric", timerOn=1000, timerOff=5000},
            {object="rings", color=aqua, trajectory={x=75, y=-150, xforce=80, yforce=70, arc=50, num=3}},

        {object="ledge", x=300, y=-150, rotation=-20},
        
        {object="ledge", x=350, y=0, rotation=20, ai={ignore=true}},
            {object="friend", type="fuzzy", color="Pink", onLedge=true},

        {object="ledge", x=-125, y=-350, size="small"},

           {object="emitter", x=0, y=50, timer={1000, 2000}, limit=3, layer=4,
                item={
                    object="livebgr", type="brain", color="Purple", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.2, 0, 0.4},
                    movement={rangeX={-800, 800}, rangeY={-400, 200}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },    
     

        {object="ledge", x=-130, y=-300, rotation=20, ai={ignore=true}},
             {object="rings", color=aqua, trajectory={x=75, y=-200, xforce=120, yforce=70, arc=50, num=3}},
     
        {object="ledge", x=360, y=0, rotation=-20, ai={jumpVelocity={300,800}}},

        {object="ledge", x=-700, y=350, surface="electric", timerOn=1000, timerOff=5000, ai={ignore=true}},
            {object="gear", type=gearShield, x=30, y=-150},
            {object="rings", color=white, pattern={ {1350,-550}, }},
            {object="wall",    x=1300, y=-500, type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=1}},
            {object="wall",    x=2200, y=-600, type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=1}},
            {object="wall",    x=2200, y=-1500, type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=1}, flip="y"},

        {object="ledge", x=1400, y=-350, size="small"},    

        {object="ledge", x=300, y=250,  size="small2"},
            {object="spike",   x=75, y=0, type="fg-spikes-float-4", size=0.8, physics={shape={0,-110, 40,110, -40,110}} },
            {object="spike",   x=-110, y=-120, type="fg-spikes-float-4", size=0.4, rotation=-90, flip="x", physics={shape={0,-70, 40,70, -40,70}} },
            {object="spike",   x=-585, y=0, type="fg-spikes-float-4", size=0.8, physics={shape={0,-110, 60,110, -60,110}} },
            {object="rings", color=aqua, pattern={ {0,-100},  {0,-90}, {0,-130,color=pink} }},

            {object="emitter", x=150, y=0, timer={1000, 2000}, limit=3, layer=4,
                item={
                    object="livebgr", type="brain", color="Purple", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.3, 0, 0.2},
                    movement={rangeX={-800, 800}, rangeY={0, 400}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },    

        {object="obstacle", x=-340, y=-230, type="pole", length=500, sticky=true},

        {object="ledge", x=0, y=120, surface="electric", timerOn=1000, timerOff=8000},

        {object="ledge", x=290, y=250, size="medium3"},
            {object="rings", color=aqua, pattern={ {200,-80},  {50,0}  }},

        {object="ledge", x=150, y=95, size="medium3", movement={pattern={{700,-400}}, reverse=true,  distance=300, speed=1.5, pause=1000}},

        {object="ledge", x=175, y=-600, size="medium", ai={loadGear=gearShield}},
            {object="enemy", type="brain", x=250, y=-350, size=0.5, color="Purple", 
                movement={pattern=movePatternVertical, distance=175, speed=.7, pause=1000, moveStyle=moveStyleSwaySmall, pauseStyle=moveStyleSwaySmall}
            },

        {object="ledge", x=235, y=-100, type="finish"}
    },
}

return levelData