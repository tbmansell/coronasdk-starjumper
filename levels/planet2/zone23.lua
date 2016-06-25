local levelData = {
    name             = "you know the drill",
    timeBonusSeconds = 28,
    ceiling          = -4000,
    floor            = 2000,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {9, 6},
        [bgrBack]  = {},
        [bgrSky]   = {1, 2}
    },

    backgroundSounds = {
        {name="space/space5", quietTime=4000, minVolume=4, maxVolume=5},
        {name="space/space7", quietTime=4000, minVolume=5, maxVolume=6},
    },

    elements = {
        {object="ledge", type="start"},
        
        {object="ledge", x=275, y=250, size="medium3"},
            {object="wall", x=475,  y=-1100, type="fg-wall-divider", physics={shapeOffset={bottom=0, left=0}, bounce=1}},    

        {object="ledge", x=425, y=200, size="big2"},        
            {object="rings", color=aqua, trajectory={x=35, y=-100, xforce=60, yforce=120, arc=30, num=3}},
            
        {object="ledge", x=330, y=-150, size="small2"},
            {object="gear", type=gearJetpack, x=0, y=-150, onLedge=true, regenerate=false},
            {object="emitter", x=0, y=-1200, timer={3000, 6000}, limit=nil, force={ {-100, 300}, {100, 300}, {45, 90} }, 
                items={
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={2, 5}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-right", size={6, 8}} },
                }
            },

        {object="ledge", x=320, y=-150, size="small2"},

        {object="ledge", x=-265, y=-280, size="small2"},
            {object="rings", color=aqua, pattern={ {0,-80} }},
        
        {object="ledge", x=320, y=-150, surface="ramp"},
            {object="rings", color=aqua, pattern={ {450,-200}, {40,-50}, {40,50} }},  
            {object="wall", x=237,  y=314, type="fg-wall-divider", copy=2, gap=1095, physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="spike", x=250,  y=105, type="fg-wall-divider-fs-completedown1", physics={shapeOffset={top=50, right=-20},   bounce=1}},
            {object="spike", x=890,  y=105, type="fg-wall-divider-fs-completedown2", physics={shapeOffset={top=50, right=-20},   bounce=1}},
            {object="spike", x=547,  y=81, type="fg-spikes-row-big", copy=2, gap=100},
            {object="scenery", x=900, y=-900, rotation=200, type="fgflt-pole-2"},    

            {object="emitter", x=300, y=-699, timer={2000, 4000}, limit=nil, force={ {-400, 400}, {100, 300}, {0, 45} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={3, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-4", size={5, 8}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-right", size={6, 8}} },
                }
            },        

        {object="ledge", x=-380, y=-260, size="small2"},

        {object="ledge", x=480, y=-220, size="small2"},
            {object="rings", color=white, pattern={ {0,-75} }},

        {object="ledge", x=-380, y=-240, size="small2"},
            {object="randomizer", x=0, onLedge=true, items={{30,gearSpringShoes}, {70,green}, {100,white}}},

        {object="obstacle", x=1775, y=525, size=1.3, timerOn=2000, timerOff=3000, type="electricgate"},
    
        {object="ledge", x=520, y=400, size="medsmall3"},
            {object="rings", color=aqua, pattern={ {300,-75}, {45,40,color=pink}, {45,40, color=red} }},

        {object="ledge", x=250, y=250, size="medsmall2"},
            {object="spike", x=320,  y=-1100, type="fg-wall-divider", rotation=40, physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="spike", x=1240,  y=-325, type="fg-wall-divider", rotation=40, physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="spike", x=480,  y=-380, type="fg-wall-divider", rotation=40, physics={shapeOffset={bottom=0, right=-20},   bounce=1}},
            {object="spike", x=621,  y=-995, type="fg-wall-divider-fs-completedown1", rotation=40, physics={shapeOffset={bottom=-140, right=-20},   bounce=1}},
            {object="spike", x=1109,  y=-590, type="fg-wall-divider-fs-completedown2", rotation=40, physics={shapeOffset={bottom=-140, right=-20},   bounce=1}},
            {object="spike", x=75,  y=125, size=0.6, type="fg-spikes-float-2", physics={shape={-60,-130, 70,140, -80,140}}}, 
            {object="spike", x=-125,  y=125, size=0.6, type="fg-spikes-float-2", physics={shape={-60,-130, 70,140, -80,140}}}, 

        {object="ledge", x=320, y=-100, size="small"},

        {object="ledge", x=225, y=-240, size="small3"},
            {object="spike", x=-50,  y=-500, size=0.6, type="fg-spikes-float-3", physics={shape={-60,-130, 70,140, -80,140}}},
            {object="rings", color=red, pattern={ {0,-600} }},

        {object="ledge", x=-130, y=-150, size="small2"},

        {object="ledge", x=280, y=20, rotation=22, size="medsmall"},
            {object="rings", color=aqua, pattern={ {300,-120}, {45,40,color=white}, {45,40} }},

        {object="ledge", x=320, y=250, size="small3"},
            {object="randomizer", x=-10, onLedge=true, items={{30,gearParachute}, {70,yellow}, {100,green}}},

        {object="ledge", x=-170, y=220, size="small2"},

        {object="ledge", x=-295, y=250, surface=pulley, distance=1500, speed=3},
            {object="gear", type=gearJetpack, onLedge=true, x=75},
            {object="rings", color=green, pattern={ {0, 650} }},

        {object="ledge", x=-120, y=450, surface="ramp"},

        {object="obstacle", type="spacerocket", x=1350, y=100, angle=-30, takeoff="medium", force={1500, -1200}, rotation={time=100, degrees=1}},
            {object="scenery", x=1200, y=-500, rotation=-25, type="fgflt-pole-3"},
            {object="spike", x=4000,  y=-1400, size=3, rotation=240, type="fg-spikes-float-4", physics={shape={0,-130, 70,140, -70,140}}},
            {object="rings", color=red, pattern={ {-200,-270}, {75,40,color=blue}, {75,40} }},
            {object="scenery", x=2200, y=-850, rotation=-30, type="fgflt-pole-5"},

            {object="emitter", x=1000, y=500, timer={1000, 2000}, limit=nil, force={ {-500, 500}, {-100, -300}, {0, 360} }, 
                items={
                    {10,  {object="scenery", layer=1, type="fg-debris-barrel-blue", size={6, 9}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={3, 9}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-2", size={3, 9}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                }
            },

        {object="ledge", x=3300, y=0, size="big2"},   
            {object="rings", color=aqua, pattern={ {0,-550}, {0,-100}, {0,-100} , {0,-100}}}, 

            {object="emitter", x=0, y=-1400, timer={1000, 3000}, limit=nil, force={ {-500, 500}, {50, 150}, {0, 360} }, 
                items={
                    {10,  {object="scenery", layer=1, type="fg-debris-barrel-blue", size={6, 9}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={3, 9}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-2", size={3, 9}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                }
            },
             
        {object="ledge", x=300, y=-150, size="medium", movement={bobbingPattern=moveTemplateBobUp2, speed=1, distance=85}},
            {object="enemy", type="greyshooter", x=-10, y=-700, size=0.5,
                shooting={minWait=2, maxWait=4, velocity={x=700, y=200, varyX=200, varyY=300}, itemsMax=10, ammo={negDizzy, negTrajectory}},
                behaviour={mode=stateSleeping, awaken=1, range=5},
                movement={pattern=movePatternFollow, speed=2.5, pause=250, moveStyle=moveStyleWave, pauseStyle=moveStyleWave}
            },

        {object="ledge", x=350, y=-200, size="medium2", movement={bobbingPattern=moveTemplateBobUp1, speed=1.5, distance=65}},
            {object="scenery", x=400, y=-200, rotation=20, type="fgflt-pole-1"},
            {object="rings", color=aqua, pattern={ {300,-300}, {40,-80}, {40,80} }},  
        
        {object="ledge", x=400, y=-250, size="medium3", movement={bobbingPattern=moveTemplateBobUp2, speed=2, distance=65}}, 

        {object="ledge", x=450, y=-200, type="finish"}
    },
}

return levelData