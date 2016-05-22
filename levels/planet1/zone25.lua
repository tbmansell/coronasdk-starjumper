local levelData = {
    name             = "creepy cavern",
    timeBonusSeconds = 180,
--    playerStart      = playerStartWalk,
    ceiling          = -1000,
    floor            = 3000,   
    startLedge       = 33,

    backgroundOrder = {
        [bgrFront] = {2, 3, 4, 1},
        [bgrMid]   = {1, 4, 3},
    },

    elements = {
        {object="ledge", type="start"},

    -- Level 1
        --#2
        {object="ledge", x=440, y=100, size="medium2"},
            -- entrance walls
            {object="wall",   x=-620, y=-1750, type="vertical-wall", rotation=-35},
            {object="spike",  x=-780, y=-270,  type="vertical-wall", rotation=65},
            -- first level ceiling & floor
            {object="wall",  x=200, y=-1300,   type="vertical-wall", rotation=90, copy=5, gap=1000},
            {object="spike", x=200, y=-500,    type="vertical-wall", rotation=90, copy=4, gap=1000},
            -- second floor ceiling & floor
            {object="wall",  x=200, y=-400,    type="vertical-wall", rotation=90, copy=4, gap=1000},
            {object="spike", x=200, y=400,     type="vertical-wall", rotation=90, copy=5, gap=1000},
            -- third level ceiling & floor
            {object="wall",  x=200, y=500,     type="vertical-wall", rotation=90, copy=5, gap=1000},
            {object="spike", x=200, y=1300,    type="vertical-wall", rotation=90, copy=5, gap=1000, physics={shapeOffset={left=20}}},

        {object="ledge", x=-300, y=100, size="medium"},

        {object="ledge", x=700, y=-100, size="big2", positionFromLedge=2},
             {object="enemy", type="brain", x=300,  y=85, size=0.5, color="Purple", spineDelay=0,   behaviour={mode=stateSleeping}},
             {object="enemy", type="brain", x=650,  y=85, size=0.4, color="Purple", spineDelay=333, behaviour={mode=stateSleeping}, direction=right},
             {object="enemy", type="brain", x=1000, y=85, size=0.6, color="Blue", spineDelay=666, behaviour={mode=stateSleeping}},

        {object="ledge", x=200, y=-300, size="small"},

        {object="ledge", x=200, y=50, size="small"},

        {object="ledge", x=200, y=50, size="small"},

        --#8
        {object="ledge", x=300, y=50, size="medium4"},

        {object="ledge", x=200, y=-150, size="medium4"},
        {object="ledge", x=150, y=200,  size="medium4", positionFromLedge=8},
        --#11
        {object="ledge", x=350, y=-200, size="medium4"},
            {object="enemy", type="brain", x=300,  y=200, size=0.3, color="Purple", spineDelay=0, behaviour={mode=stateSleeping, awaken=0},
                movement={pattern={{0,-400}, {400,0}, {0,400}, {-400,0}}, speed=2, moveStyle=moveStyleSway, steering=steeringMild}
            },

        {object="ledge", x=300, y=-150, size="small3"},
        {object="ledge", x=300, y=50,   size="small3"},

        {object="ledge", x=250, y=200, size="small3", positionFromLedge=11},
        {object="ledge", x=300, y=-50, size="small3"},
            {object="enemy", type="brain", x=400,  y=-180, size=0.5, color="Purple", spineDelay=0, behaviour={mode=stateSleeping, awaken=2},
                movement={pattern={{150,100}, {-150,100}, {150,100}, {-150,100}}, reverse=true, speed=2, moveStyle=moveStyleSway, steering=steeringMild}
            },


        {object="obstacle", x=550, y=-400, type="pole", length=1000},
            -- rear wall
            {object="wall", x=550, y=-120, type="vertical-wall", layer=4},
            {object="wall", x=550, y=-710, type="vertical-wall", layer=4},

    -- Level 2:
        --#16
        {object="ledge", x=-50, y=300, size="medium3"},

        {object="ledge", x=350,  y=-200, size="small2"},
        {object="ledge", x=-250, y=-200, size="small2"},
        {object="ledge", x=250,  y=-200, size="small3"},

        {object="ledge", x=-500, y=-150, size="medium", positionFromLedge=16},
            {object="enemy", type="brain", x=-300, y=20, size=0.5, color="Purple", spineDelay=0, behaviour={mode=stateSleeping, awaken=4},
                movement={pattern=movePatternCircular, distance=150, arcStart=360, arc=0, dontDraw=true, fullCircle=true, speed=1}
            },

        {object="ledge", x=-650, y=150, size="medium"},

        {object="ledge", x=-650, y=-150, size="medium2", movement={pattern=movePatternHorizontal, speed=2, distance=600}},
            {object="enemy", type="brain", x=400, y=150, size=1, color="Blue", spineDelay=333, behaviour={mode=stateSleeping, awaken=0},
                movement={pattern=movePatternHorizontal, distance=3000, speed=0.5, moveStyle=moveStyleSway,}
            },

        {object="ledge", x=-1300, y=-150, size="small2", movement={pattern={{600,0},{-600,0}}, speed=2}},

        {object="ledge", x=-200, y=250, size="medium"},
            -- moving spikes
            {object="spike", x=-550, y=-550, type="fg-spikes-float-1", size=0.8, flip="y", physics={shape={-90,-130, 90,-130, 0,125}},
                movement={pattern=movePatternVertical, distance=200, speed=1}
            },
            {object="spike", x=-550, y=-85,  type="fg-spikes-float-1", size=0.8, physics={shape={0,-125, 90,130, -90,130}}, 
                movement={pattern={{0,-200},{0,200}}, speed=1}
            },

        {object="ledge", x=-500, y=100, surface="spiked", timerOff=5000},

        {object="obstacle", x=-200, y=-400, type="pole", length=1000},
            -- bottom floor
            {object="spike", x=-350, y=180,  type="vertical-wall", rotation=-70, layer=4},

    -- Level 3:
        --#26
        {object="ledge", x=0, y=150, size="small"},


        {object="ledge", x=400, y=-250, surface=collapsing},
            {object="spike", x=-100, y=-200, type="fg-rock-2", physics={body="dynamic", shape="circle", friction=1, radius=50}, layer=4},

        {object="ledge", x=400, y=0,    surface=collapsing},
            {object="spike", x=-100, y=-200, type="fg-rock-2", physics={body="dynamic", shape="circle", friction=1, radius=50}, layer=4},

        {object="ledge", x=400, y=0,    surface=collapsing},
            {object="spike", x=-100, y=-200, type="fg-rock-2", physics={body="dynamic", shape="circle", friction=1, radius=50}, layer=4},

        --#30
        {object="ledge", x=430, y=50, size="medium", positionFromLedge=26, triggerLedgeIds={27}, rotation=-25},

        {object="ledge", x=460, y=0, size="medium", triggerLedgeIds={28}, rotation=20},

        {object="ledge", x=470, y=0, size="medium", triggerLedgeIds={29}, rotation=-25},

        {object="ledge", x=600, y=-100, size="big2"},

        {object="ledge", x=400, y=-150, size="medium", pointsPos=left, movement={pattern=movePatternVertical, speed=1, distance=300, dontDraw=true}},
            {object="spike", x=-50, y=-330, type="fg-spikes-float-1", size=0.8, flip="y", physics={shape={-90,-130, 90,-130, 0,125}}},
            {object="spike", x=-50, y=170,  type="fg-spikes-float-1", size=0.8, physics={shape={0,-125, 90,130, -90,130}}},

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

        {object="ledge", x=400, y=150, size="medium3"},

        {object="ledge", x=400, y=-150, size="medium", pointsPos=left, movement={pattern=movePatternVertical, speed=2, distance=300, dontDraw=true}},
            {object="spike", x=-50, y=-330, type="fg-spikes-float-1", size=0.8, flip="y", physics={shape={-90,-130, 90,-130, 0,125}}},
            {object="spike", x=-50, y=170,  type="fg-spikes-float-1", size=0.8, physics={shape={0,-125, 90,130, -90,130}}},

        {object="ledge", x=400, y=150, size="medium3"},

        {object="ledge", x=400, y=-150, size="medium", pointsPos=left, movement={pattern=movePatternVertical, speed=3, distance=300, dontDraw=true}},
            {object="spike", x=-50, y=-330, type="fg-spikes-float-1", size=0.8, flip="y", physics={shape={-90,-130, 90,-130, 0,125}}},
            {object="spike", x=-50, y=170,  type="fg-spikes-float-1", size=0.8, physics={shape={0,-125, 90,130, -90,130}}},
            -- final floor
            {object="wall", x=530, y=100, type="vertical-wall", layer=4, rotation=-65},

        {object="ledge", x=600, y=450, type="finish"}
        
    },
}

return levelData