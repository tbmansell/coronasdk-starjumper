local levelData = {
    name             = "creepy cavern",
    timeBonusSeconds = 200,
    playerStart      = playerStartWalk,
    ceiling          = -1000,
    floor            = 3000,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {2, 3, 4, 1},
        [bgrMid]   = {1, 4, 3},
    },

    backgroundSounds = {
        {name="animals/cats1", quietTime=8000, minVolume=2, maxVolume=3},
        {name="nature/wind2", quietTime=4000, minVolume=2, maxVolume=4},
    },

    elements = {
        {object="ledge", type="start"},
            {object="scenery", x=0,   type="fg-rock-3", size=0.5, onLedge=true, layer=2},
            {object="scenery", x=130, type="fg-rock-3", size=0.5, onLedge=true, flip="x", layer=2},
            {object="scenery", x=-140, y=-900, type="fgflt-tree-3-yellow", layer=4},

    -- Level 1
        --#2
        {object="ledge", x=440, y=100, size="medium2"},

            -- entrance walls
            {object="wall",    x=-580, y=-1550, type="fg-wall-divider", rotation=-35},
            {object="scenery", x=-650, y=-150,  type="fg-wall-divider", rotation=65, layer=2},

            -- first level ceiling & floor
            {object="spike",  x=150,  y=-1200, type="fg-wall-divider", rotation=90},
            {object="spike",  x=1050, y=-1200, type="fg-wall-divider", rotation=90, flip="y"},
            {object="spike",  x=1950, y=-1200, type="fg-wall-divider", rotation=90},
            {object="spike",  x=2850, y=-1200, type="fg-wall-divider", rotation=90, flip="y"},
            {object="spike",  x=3750, y=-1200, type="fg-wall-divider", rotation=90},
            {object="spike",  x=4650, y=-1200, type="fg-wall-divider", rotation=90, flip="y"},

            -- second floor ceiling & floor
            {object="spike",  x=150,  y=-350, type="fg-wall-divider", rotation=90},
            {object="spike",  x=1050, y=-350, type="fg-wall-divider", rotation=90, flip="y"},
            {object="spike",  x=1950, y=-350, type="fg-wall-divider", rotation=90},
            {object="spike",  x=2850, y=-350, type="fg-wall-divider", rotation=90, flip="y"},
            {object="spike",  x=3750, y=-350, type="fg-wall-divider", rotation=90},

            -- third level ceiling & floor
            {object="spike",  x=300,  y=540, type="fg-wall-divider", rotation=90},
            {object="spike",  x=1200, y=540, type="fg-wall-divider", rotation=90, flip="y"},
            {object="spike",  x=2100, y=540, type="fg-wall-divider", rotation=90},
            {object="spike",  x=3000, y=540, type="fg-wall-divider", rotation=90, flip="y"},
            {object="spike",  x=3900, y=540, type="fg-wall-divider", rotation=90},
            {object="spike",  x=4800, y=540, type="fg-wall-divider", rotation=90, flip="y"},

            {object="spike",  x=200,  y=1400, type="fg-wall-divider", rotation=90},
            {object="spike",  x=1100, y=1400, type="fg-wall-divider", rotation=90, flip="y"},
            {object="spike",  x=2000, y=1400, type="fg-wall-divider", rotation=90},
            {object="spike",  x=2900, y=1400, type="fg-wall-divider", rotation=90, flip="y"},
            {object="spike",  x=3800, y=1400, type="fg-wall-divider", rotation=90},
            {object="spike",  x=4700, y=1400, type="fg-wall-divider", rotation=90, flip="y"},

            --Second row of spikes
            {object="spike",  x=450,  y=670, type="fg-wall-divider", rotation=90},
            {object="spike",  x=1350, y=670, type="fg-wall-divider", rotation=90, flip="y"},
            {object="spike",  x=2250, y=670, type="fg-wall-divider", rotation=90},
            {object="spike",  x=3150, y=670, type="fg-wall-divider", rotation=90, flip="y"},
            {object="spike",  x=4050, y=670, type="fg-wall-divider", rotation=90},
            {object="spike",  x=4950, y=670, type="fg-wall-divider", rotation=90, flip="y"},

            {object="scenery", x=-200, y=-720, type="fg-foilage-1-yellow", size=1, layer=2, flip="y"},
            {object="scenery", x=-50,  y=-720, type="fg-foilage-3-yellow", size=1, layer=2, flip="y"},
            {object="scenery", x=250,  y=-720, type="fg-foilage-3-yellow", size=1, layer=2, flip="y"},
            {object="scenery", x=-250, y=-80,  type="fg-foilage-1-green",  size=1, layer=2},
            {object="scenery", x=100,  y=-20,  type="fg-foilage-3-green",  size=1, layer=2},

        {object="ledge", x=-300, y=100, size="medium"},
            {object="randomizer", onLedge=true, items={ {25,gearSpringShoes}, {50,gearShield}, {75,gearFreezeTime}, {100,gearTrajectory} }},

        {object="ledge", x=700, y=-100, size="big2", positionFromLedge=2},
            {object="rings", color=aqua, pattern={{-130,-85}, {250,0}}},
            {object="enemy", type="brain", x=300,  y=85, size=0.5, color="Purple", spineDelay=0,   behaviour={mode=stateSleeping}},
            {object="enemy", type="brain", x=650,  y=85, size=0.4, color="Purple", spineDelay=333, behaviour={mode=stateSleeping}, direction=right},
            {object="enemy", type="brain", x=1000, y=85, size=0.6, color="Blue", spineDelay=666, behaviour={mode=stateSleeping}},

            {object="scenery", x=300,  y=-110, type="fg-spikes-5", size=0.8, layer=4},
            {object="scenery", x=750,  y=-100, type="fg-spikes-4", size=1,   layer=4},
            {object="scenery", x=1150, y=-130, type="fg-spikes-2", size=1,   layer=4},

        {object="ledge", x=200, y=-300, size="small"},
            {object="rings", color=aqua, pattern={{0,-100}}},

        {object="ledge", x=200, y=50, size="small"},
            {object="rings", color=aqua, pattern={{0,-100}}},

        {object="ledge", x=200, y=50, size="small"},
            {object="rings", color=aqua, pattern={{0,-100}}},

        --#8
        {object="ledge", x=300, y=50, size="medium4"},

        {object="ledge", x=200, y=-150, size="medium4"},
            {object="rings", color=aqua, pattern={{-100,-90}, {100,0,color=pink}, {100,0}}},

        {object="ledge", x=150, y=200,  size="medium4", positionFromLedge=8},
            {object="rings", color=aqua, pattern={{-80,-90}, {80,0,color=pink}, {80,0}}},

        --#11
        {object="ledge", x=350, y=-200, size="medium4"},
            {object="enemy", type="brain", x=300,  y=200, size=0.3, color="Purple", spineDelay=0, behaviour={mode=stateSleeping, awaken=0},
                movement={pattern={{0,-400}, {400,0}, {0,400}, {-400,0}}, speed=2, moveStyle=moveStyleSway, steering=steeringMild}
            },
            {object="scenery", x=-150, y=50, type="fg-spikes-2", size=1, layer=4},
            {object="scenery", x=100,  y=50, type="fg-spikes-2", size=1, layer=4},

        {object="ledge", x=300, y=-150, size="small3"},
            {object="rings", color=red, pattern={{0,-100}}},

        {object="ledge", x=300, y=50,   size="small3"},
            {object="rings", color=blue, pattern={{0,-100}}},

        {object="ledge", x=250, y=200, size="small3", positionFromLedge=11},
            {object="rings", color=white, pattern={{0,-100}}},

        {object="ledge", x=300, y=-50, size="small3"},
            {object="randomizer", onLedge=true, items={ {25,gearGlider}, {50,gearParachute}, {75,gearJetpack}, {100,gearReverseJump} }},
            {object="enemy", type="brain", x=400,  y=-180, size=0.5, color="Purple", spineDelay=0, behaviour={mode=stateSleeping, awaken=2},
                movement={pattern={{150,100}, {-150,100}, {150,100}, {-150,100}}, reverse=true, speed=2, moveStyle=moveStyleSway, steering=steeringMild}
            },
            {object="scenery", x=770, y=-610, type="fg-flowers-5-green", size=1, layer=4, flip="y"},

        {object="obstacle", x=550, y=-400, type="pole", length=1000},
            -- rear wall
            {object="wall", x=550, y=150,  type="fg-wall-divider", layer=4},
            {object="wall", x=550, y=-750, type="fg-wall-divider", layer=4},

            {object="emitter", x=0, y=-300, timer={5000, 15000}, limit=5, layer=4,
                item={
                    object="livebgr", type="brain", color="Purple", direction=right, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.3, 0, 0.3},
                    movement={rangeX={-10000, -20000}, rangeY={-200, 450}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },

    -- Level 2:
        --#16
        {object="ledge", x=-50, y=300, size="medium3"},
            {object="rings", color=aqua, trajectory={x=-100, y=-170, xforce=-120, yforce=160, arc=75, num=5}},
            {object="scenery", x=-250, y=-20, type="fg-flowers-4-green", size=1, layer=4},

        {object="ledge", x=350,  y=-200, size="small2"},
        {object="ledge", x=-250, y=-200, size="small2"},
        {object="ledge", x=250,  y=-200, size="small3"},
            {object="randomizer", onLedge=true, items={ {50,gearGrappleHook}, {100,gearGloves} }},

        {object="ledge", x=-500, y=-150, size="medium", positionFromLedge=16},
            {object="enemy", type="brain", x=-300, y=20, size=0.5, color="Purple", spineDelay=0, behaviour={mode=stateSleeping, awaken=4},
                movement={pattern=movePatternCircular, distance=150, arcStart=360, arc=0, dontDraw=true, fullCircle=true, speed=1}
            },
            {object="scenery", x=0,    y=60, type="fg-spikes-1", size=0.8, layer=4},
            {object="scenery", x=-200, y=50, type="fg-spikes-2", size=0.8, layer=4},
            {object="scenery", x=-400, y=50, type="fg-spikes-3", size=0.8, layer=4},
            {object="scenery", x=-2000, y=60, type="fg-spikes-1", size=0.8, layer=4},
            {object="scenery", x=-2200, y=50, type="fg-spikes-2", size=0.8, layer=4},
            {object="scenery", x=-2400, y=50, type="fg-spikes-3", size=0.8, layer=4},

        {object="ledge", x=-650, y=150, size="medium"},

        {object="ledge", x=-650, y=-150, size="medium2", movement={pattern=movePatternHorizontal, speed=2, distance=600}},
            {object="rings", color=pink, pattern={{-600,-100}, {600,0}}},
            {object="enemy", type="brain", x=400, y=150, size=1, color="Blue", spineDelay=333, behaviour={mode=stateSleeping, awaken=0},
                movement={pattern=movePatternHorizontal, distance=3000, speed=0.5, moveStyle=moveStyleSway,}
            },

        {object="ledge", x=-1300, y=-150, size="small2", movement={pattern=movePatternHorizontal, speed=2, distance=-600}},
            {object="rings", color=pink, pattern={{0,-100}, {600,0}}},

        {object="ledge", x=-200, y=250, size="medium"},
          
            -- moving spikes
            {object="spike", x=-550, y=-575, type="fg-spikes-float-1", size=0.8, flip="y", physics={shape={-90,-130, 90,-130, 0,125}},
                movement={pattern=movePatternVertical, distance=275, speed=1}
            },
            {object="spike", x=-550, y=-85,  type="fg-spikes-float-1", size=0.8, physics={shape={0,-125, 90,130, -90,130}}, 
                movement={pattern={{0,-275},{0,275}}, speed=1}
            },


        {object="ledge", x=-500, y=100, surface="spiked", timerOff=5000},
            {object="rings", color=red, pattern={{-150,-250}, {-50,-75,color=blue}, {-100,-50,color=white}}},

        {object="obstacle", x=-200, y=-400, type="pole", length=1000},
            -- bottom floor
            {object="scenery", x=-450, y=490,  type="fg-spikes-1", size=0.8, layer=4, rotation=25},
            {object="scenery", x=-250, y=550,  type="fg-spikes-1", size=0.8, layer=4, rotation=25},
            {object="scenery", x=100,  y=670,  type="fg-spikes-3", size=0.8, layer=4, rotation=25},
            {object="spike",   x=-250, y=380,  type="fg-wall-divider", rotation=-70, layer=4},
            {object="scenery", x=-200, y=-600, type="fg-flowers-2-green", size=1, layer=4, rotation=135},

            {object="emitter", x=0, y=-300, timer={5000, 15000}, limit=5, layer=4,
                item={
                    object="livebgr", type="brain", color="Purple", direction=right, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.3, 0, 0.3},
                    movement={rangeX={10000, 20000}, rangeY={-200, 450}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },

    -- Level 3:
        --#26
        {object="ledge", x=0, y=150, size="small"},

        {object="ledge", x=400, y=-250, surface=collapsing},
            {object="spike", x=-100, y=-200, type="fg-rock-2", physics={body="dynamic", shape="circle", friction=1, radius=50}, layer=4},
            {object="scenery", x=285, y=-240, type="fg-flowers-1-yellow", size=1, layer=4, flip="y"},

        {object="ledge", x=400, y=0,    surface=collapsing},
            {object="spike", x=-100, y=-200, type="fg-rock-2", physics={body="dynamic", shape="circle", friction=1, radius=45}, layer=4},

        {object="ledge", x=400, y=0,    surface=collapsing},
            {object="spike", x=-100, y=-200, type="fg-rock-2", physics={body="dynamic", shape="circle", friction=1, radius=50}, layer=4},

        --#30
        {object="ledge", x=430, y=50, size="medium", positionFromLedge=26, triggerLedgeIds={27}, rotation=-25},
            {object="rings", color=red, pattern={{-85,-25}}},

        {object="ledge", x=460, y=0, size="medium", triggerLedgeIds={28}, rotation=20},
            {object="rings", color=pink, pattern={{-70,-75}}},

        {object="ledge", x=470, y=0, size="medium", triggerLedgeIds={29}, rotation=-25},
            {object="rings", color=red, pattern={{-80,-20}}},

        {object="ledge", x=600, y=-100, size="big2"},
            {object="rings", color=green, pattern={{-0,-100}}},
            {object="scenery", x=-230, y=0, type="fg-spikes-2", size=1, layer=4},
            {object="scenery", x=180,  y=0, type="fg-spikes-2", size=1, layer=4},

        {object="ledge", x=400, y=-150, size="medium", pointsPos=left, movement={pattern=movePatternVertical, speed=1, distance=300, dontDraw=true}},
            {object="spike", x=-50, y=-330, type="fg-spikes-float-1", size=0.8, flip="y", physics={shape={-90,-130, 90,-130, 0,125}}, layer=4},
            {object="spike", x=-50, y=170,  type="fg-spikes-float-1", size=0.8, physics={shape={0,-125, 90,130, -90,130}}, layer=4},

            {object="enemy", type="heart", x=-770, y=330, size=0.4, color="Red", spineDelay=0,
                behaviour={mode=stateSleeping, awaken=0, range=2, atRange=stateResetting, thefts=5},
                movement={pattern=movePatternFollow, speed=0.75, pause=1000, moveStyle=moveStyleWave, pauseStyle=moveStyleWave}
            },
            {object="enemy", type="heart", x=-650, y=310, size=0.5, color="White", spineDelay=2500,
                behaviour={mode=stateSleeping, awaken=0, range=2, atRange=stateResetting, thefts=5},
                movement={pattern=movePatternFollow, speed=1, pause=0, moveStyle=moveStyleWave, pauseStyle=moveStyleWave}
            },
            {object="enemy", type="heart", x=-520, y=280, size=0.45, color="Red", spineDelay=1250,
                behaviour={mode=stateSleeping, awaken=0, range=2, atRange=stateResetting, thefts=5},
                movement={pattern=movePatternFollow, speed=0.5, pause=1000, moveStyle=moveStyleWave, pauseStyle=moveStyleWave}
            },

            {object="emitter", x=0, y=0, timer={5000, 15000}, limit=5, layer=3,
                item={
                    object="livebgr", type="heart", color="Red", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.4, 0, 0.2},
                    movement={rangeX={-1500, 2000}, rangeY={-1000, -2500}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },

        {object="ledge", x=400, y=150, size="medium3"},

        {object="ledge", x=400, y=-150, size="medium", pointsPos=left, movement={pattern=movePatternVertical, speed=2, distance=300, dontDraw=true}},
            {object="spike", x=-50, y=-330, type="fg-spikes-float-1", size=0.8, flip="y", physics={shape={-90,-130, 90,-130, 0,125}}, layer=4},
            {object="spike", x=-50, y=170,  type="fg-spikes-float-1", size=0.8, physics={shape={0,-125, 90,130, -90,130}}, layer=4},

        {object="ledge", x=400, y=150, size="medium3"},

        {object="ledge", x=400, y=-150, size="medium", pointsPos=left, movement={pattern=movePatternVertical, speed=3, distance=300, dontDraw=true}},
            {object="rings", color=aqua, trajectory={x=100, y=100, xforce=120, yforce=160, arc=75, num=5}},

            {object="spike", x=-50, y=-330, type="fg-spikes-float-1", size=0.8, flip="y", physics={shape={-90,-130, 90,-130, 0,125}}, layer=4},
            {object="spike", x=-50, y=170,  type="fg-spikes-float-1", size=0.8, physics={shape={0,-125, 90,130, -90,130}}, layer=4},
            -- final floor
            {object="scenery", x=400, y=420, type="fg-flowers-6-green", size=1, layer=4, rotation=25},
            {object="wall", x=530, y=200, type="fg-wall-divider", layer=4, rotation=-65},

        {object="ledge", x=600, y=450, type="finish"},
            {object="scenery", x=-140, y=-900, type="fgflt-tree-3-yellow", layer=4, flip="x"},
            {object="scenery", x=-200, type="fg-flowers-6-yellow", onLedge=true, layer=2},
    },
}

return levelData