local levelData = {
    name             = "so close",
    timeBonusSeconds = 90,
    ceiling          = -display.contentHeight*2,
    startAtNight     = true,
    turnDay          = true,

    backgroundOrder = {
        [bgrFront] = {2, 3, 4, 1},
        [bgrMid]   = {6, 5, 6, 6},
        [bgrBack]  = {1, 2, 3, 4},
        [bgrSky]   = {1, 2}
    },

    elements = {
        {object="ledge", type="start"},
            {object="scenery", x=200, y=-250, type="fg-flowers-5-yellow",layer=2, size=0.5, flip="x"},
            {object="scenery", x=125, y=-265, type="fg-flowers-5-yellow",layer=2, size=0.7},

         {object="emitter", x=1500, y=-550, timer={1000, 3000}, limit=3, layer=4,
                item={
                    object="livebgr", type="brain", color="Purple", direction=right, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.6, 0, 0.4},
                    movement={rangeX={-400, 800}, rangeY={-300, 1}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },                   


        {object="ledge", x=220, y=-250, size="medium", movement={pattern=movePatternVertical, distance=400, speed=1}},
            {object="scenery", x=550, y=-85, type="fg-tree-1-yellow",layer=2, size=1.1},
            {object="scenery", x=1000, y=-150, type="fg-tree-4-yellow",layer=2, size=1.1},

        {object="obstacle", type="deathslide", x=200, y=0, length={1400,-400}, speed=3, animSpeed="FAST"},
            {object="rings", color=aqua, pattern={ {500,-75}, {300,-80}, {300,-85} }},
            {object="wall",    x=-50, y=-900, type="fg-wall-divider", physics={shapeOffset={bottom=-50}, bounce=1}},
            {object="wall",    x=1348, y=-1300, type="fg-wall-divider", physics={shapeOffset={bottom=-50}, bounce=1}},
        
        ---secret Fuzzy Ledge
        {object="ledge", x=-300, y=600, size="small", invisible={invisibleFor=6000, visibleFor=500, alpha=0.3}},
           {object="friend", type="fuzzy", color="Orange", onLedge=true},    

        {object="ledge", x=150, y=-200, size="medium"}, 
        {object="scenery", x=50, y=-85, type="fg-foilage-3-yellow",layer=2, size=0.8},
        {object="scenery", x=-65, y=-150, type="fg-foilage-2-yellow",layer=2, size=0.8},
        {object="rings", color=aqua, pattern={ {200,-250}, {450,0}, {75,50}, {400,0} }},

        {object="obstacle", type="ropeswing", x=500, y=-220, direction=left, length=200, movement={speed=1, arcStart=320, arc=90}},
            {object="wall", x=-300, y=-300, type="fg-rock-3", size=.5},
            
            {object="enemy", type="stomach", x=450, y=300, size=0.8, 
                shooting={minWait=1, maxWait=3, velocity={varyX=300, varyY=300}, itemsMax=10, ammo={negDizzy, negTrajectory,}},
                behaviour={ mode=stateSleeping, awaken=3, range=3},
                movement={pattern=movePatternHorizontal, distance=600, speed=2, pause=500, moveStyle=moveStyleSwayBig}},
        
        {object="obstacle", type="ropeswing", x=450, y=25, direction=right, length=200, movement={speed=1, arcStart=230, arc=90}},
            {object="wall", x=-300, y=-300, type="fg-rock-4", size=.5},

        {object="ledge", x=350, y=-170, size="medium", movement={pattern=movePatternVertical, distance=400, speed=1}},

        {object="ledge", x=350, y=215, surface="collapsing"},
            {object="spike", x=250,  y=-300, type="fg-spikes-float-5", size=0.5, physics={shape={0,-100, 50, 100, -50,100}}, rotation=-90, flip="x"},
            {object="scenery", x=520, y=50, type="fg-tree-5-yellow", layer=1, size=1, flip="x"},
            {object="scenery", x=720, y=110, type="fg-tree-6-yellow", layer=1, size=0.9, flip="x"},
            {object="scenery", x=0, y=110, type="fg-tree-6-yellow", layer=1, size=1},

        {object="ledge", x=300, y=-290, size="small2"},
            {object="rings", color=aqua, trajectory={x=125, y=-100, xforce=150, yforce=-100, arc=40, num=3}},

         {object="emitter", x=450, y=0, timer={1000, 2500}, limit=5, layer=4,
                item={
                    object="livebgr", type="heart", color="Red", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.4, 0, 0.2},
                    movement={rangeX={-600, 1000}, rangeY={-450, 450}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },          

        {object="ledge", x=350, y=215, surface="collapsing"},
            {object="spike", x=25,  y=-830, type="fg-spikes-float-3", size=0.5, physics={shape={-30, -65, 30,-65, 30,75, -30,75}}, rotation=-90},
            {object="spike", x=25,  y=-630, type="fg-spikes-float-3", size=0.5, physics={shape={-30, -65, 30,-65, 30,75, -30,75}}, rotation=-90},
            {object="spike", x=25,  y=-450, type="fg-spikes-float-3", size=0.5, physics={shape={-30, -65, 30,-65, 30,75, -30,75}}, rotation=-90},
            {object="spike", x=25,  y=-250, type="fg-spikes-float-3", size=0.5, physics={shape={-30, -65, 30,-65, 30,75, -30,75}}, rotation=-90},
            {object="wall",  x=150,  y=-750, type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=1}},

            {object="enemy", type="heart", x=-500, y=-500, size=0.6, color="Red",
                behaviour={mode=stateSleeping, awaken=2, range=3, atRange=stateResetting, thefts=20},
                movement={pattern=movePatternFollow, speed=1, pause=1000, moveStyle=moveStyleWave, pauseStyle=moveStyleWave}},

        {object="ledge", x=-250, y=250, size="small2"},  

                  

        {object="ledge", x=350, y=235, surface="electric", timerOn=1000, timerOff=5000}, 
        		{object="randomizer", x=-75, onLedge=true, items={{30,negTrajectory}, {70,gearFreezeTime}, {100,yellow}}},

        {object="ledge", x=310, y=-190, size="medium2", rotation=17, ai={loadGear=gearShield}},   
            {object="rings", color=pink, pattern={{0,-85}}},

            {object="spike", x=45,  y=-830, type="fg-spikes-float-3", size=0.5, physics={shape={-30, -65, 30,-65, 30,75, -30,75}}, rotation=-90},
            {object="spike", x=45,  y=-630, type="fg-spikes-float-3", size=0.5, physics={shape={-30, -65, 30,-65, 30,75, -30,75}}, rotation=-90},
            {object="spike", x=45,  y=-450, type="fg-spikes-float-3", size=0.5, physics={shape={-30, -65, 30,-65, 30,75, -30,75}}, rotation=-90},
            {object="spike", x=55,  y=-250, type="fg-spikes-float-3", size=0.5, physics={shape={-30, -65, 30,-65, 30,75, -30,75}}, rotation=-90},
            {object="wall",  x=150,  y=-750, type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=1}},

        {object="ledge", x=-140, y=-270, surface="spiked", timerOn=1000, timerOff=5000},
            {object="rings", color=pink, pattern={{0,-85}}},

        {object="obstacle", type="deathslide", x=220, y=-350, length={-320,-300}, speed=3, animSpeed="FAST"},

        {object="ledge", x=0, y=350, size=medium, ai={loadGear=gearParachute, jumpVelocity={550,800}, useAirGearAfter={1000}}},
            {object="scenery", x=-90, y=-160, type="fg-flowers-6-yellow",layer=2, size=1},  
            {object="gear", type=gearParachute, x=0, y=-150, regenerate=true},
            {object="rings", color=aqua, trajectory={x=125, y=-200, xforce=150, yforce=100, arc=40, num=3}}, 
        
            ----Last Horizontal wall
            {object="spike", x=750,  y=-530, type="fg-spikes-float-3", size=0.5, physics={shape={-30, -65, 30,-65, 30,75, -30,75}}, rotation=-90},
            {object="spike", x=750,  y=-330, type="fg-spikes-float-3", size=0.5, physics={shape={-30, -65, 30,-65, 30,75, -30,75}}, rotation=-90},
            {object="spike", x=750,  y=-130, type="fg-spikes-float-3", size=0.5, physics={shape={-30, -65, 30,-65, 30,75, -30,75}}, rotation=-90},
            {object="spike", x=750,  y=130, type="fg-spikes-float-3", size=0.5, physics={shape={-30, -65, 30,-65, 30,75, -30,75}}, rotation=-90},
            {object="wall",  x=885,  y=-475, type="fg-wall-divider", physics={shapeOffset={bottom=-75}, bounce=1}},

            -----Roof Wall
            {object="spike", x=0,  y=-770, type="fg-spikes-float-3", size=0.5, physics={shape={-30, -65, 30,-65, 30,75, -30,75}} },
            {object="spike", x=200,  y=-770, type="fg-spikes-float-3", size=0.5, physics={shape={-30, -65, 30,-65, 30,75, -30,75}} },
            {object="spike", x=400,  y=-770, type="fg-spikes-float-3", size=0.5, physics={shape={-30, -65, 30,-65, 30,75, -30,75}} },
            {object="spike", x=600, y=-770, type="fg-spikes-float-3", size=0.5, physics={shape={-30, -65, 30,-65, 30,75, -30,75}} },
            {object="wall",  x=335,  y=-1000, type="fg-wall-divider", physics={shapeOffset={bottom=-75}, bounce=1}, rotation=90},
            {object="wall",  x=-215,  y=-600, type="fg-rock-4", physics={bounce=1}},
            {object="wall",  x=782,  y=-595, type="fg-rock-3", physics={bounce=1}, rotation=20, size=1.1},

        {object="ledge", x=525, y=825, size="big2", ai={loadGear=gearJetpack, jumpVelocity={300,900}, useAirGearAfter={500,1000}}},
            {object="rings", color=aqua, pattern={ {700,-750}, {30,-50, color=white}, {30,50}}},
            {object="gear", type=gearJetpack, x=0, y=-500, regenerate=true},

            {object="scenery", x=50, y=-115, type="fg-foilage-3-yellow",layer=2, size=0.8},
            {object="scenery", x=-130, y=-170, type="fg-foilage-2-yellow",layer=2, size=0.8, flip="x"},
            {object="wall",  x=400,  y=-450, type="fg-wall-divider", physics={shapeOffset={bottom=-75}, bounce=1}},
            {object="scenery", x=700, y=-510, type="fg-tree-2-yellow", layer=2, size=1.1},

        {object="ledge", x=650, y=0, type="finish"}
    },
}

return levelData