local levelData = {
    name             = "landing zone",
    timeBonusSeconds = 28,
    ceiling          = -1000,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {1, 2, 3},
        [bgrBack]  = {},
        [bgrSky]   = {1, 2}
    },

    elements = {
        {object="ledge", type="start"},

          {object="ledge", x=280, y=200, size="big3"},

          {object="warpfield", x=-350, y=-50, size=0.75, radius=100, movement={steering=steeringMild, speed=4, pattern={{50, 0}, {-50, 0}}}},



        {object="obstacle", type="spacerocket", x=300, y=0, angle=-25, takeoff="fast", force={1000,-700}, rotation={time=100, degrees=1}},

            --{object="enemy", type="greyufo", x=1800, y=-280, size=0.7 },

--[[
        {object="obstacle", type="spacerocket", x=300, y=0, angle=-25, timer="fast", force={600,-600}},

        {object="obstacle", type="spacerocket", x=300, y=0, angle=-35, timer="fast", force={600,-600}},

        {object="obstacle", type="spacerocket", x=300, y=0, angle=-45, timer="fast", force={600,-600}},

        {object="obstacle", type="spacerocket", x=300, y=0, angle=15, timer="fast", force={-600,-600}},

        {object="obstacle", type="spacerocket", x=300, y=0, angle=25, timer="fast", force={-600,-600}},

        {object="obstacle", type="spacerocket", x=300, y=0, angle=35, timer="fast", force={-600,-600}},

        {object="obstacle", type="spacerocket", x=300, y=0, angle=45, timer="fast", force={-600,-600}},

        {object="ledge", x=1000, y=0},
]]

--[[
            -- moving rings where each ring moves along the pattern on its own
            {object="rings", color=aqua, 
                pattern={ {700,-400}, {75,75}, {75,-75}, {75,75}, {75,-75} }, 
                movement={speed=1, stagger=true, steering={cap=0.5,mass=30,radius=30}, 
                          pattern={{75,75}, {75,-75}, {75,75}, {75,-75}, {75,150},   {-75,75}, {-75,-75}, {-75,75}, {-75,-75}, {-75,-150}}
            }},

            -- grey shooter:
            {object="enemy", type="greyshooter", x=900, y=-300, size=0.5, 
                shooting={minWait=1, maxWait=3, velocity={x=700, y=200, varyX=100, varyY=100}, itemsMax=10, ammo={negDizzy, negTrajectory}},
                movement={pattern=moveTemplateShooter1, isTemplate=true, distance=200, speed=2, pause=1500, moveStyle=moveStyleSwayBig, pauseStyle=moveStyleSwayBig}
            },

            -- ring napper
            {object="enemy", type="greynapper", skin="ring-stealer", x=900, y=-300, size=0.5,
                movement={pattern=movePatternVertical, distance=50, speed=1, pause=1500, pauseStyle=moveStyleSwayBig, steering=steeringMild}
            },


            -- fuzzy napper
            {object="enemy", type="greynapper", skin="fuzzy-napper", x=900, y=-350, size=0.5,
                movement={pattern=movePatternHorizontal, distance=500, speed=1, pause=1500, pauseStyle=moveStyleSwayBig, steering=steeringMild}
            },

            -- UFO mostly based on one point:
            {object="enemy", type="greyufo", x=750, y=-250, size=0.7, movement={steering=steeringMild, speed=4, pattern=movePatternCross} },

            -- UFO dashing from one side of the screen to the other
            {object="enemy", type="greyufo", x=1400, y=-900, size=0.7, movement={steering=steeringMild, speed=7, pattern=movePatternWhooshOval} },
]]


--[[
        {object="ledge", x=300},
            {object="key", x=-100, y=-50, color="Blue", onLedge=true},
            {object="key", x=100,  y=-50, color="Red",  onLedge=true},

            {object="warpfield", x=-350, y=-50, size=0.75, radius=100, movement={steering=steeringMild, speed=4, pattern=movePatternCross}},

            {object="timebonus", y=-200},


        {object="ledge", x=250, keylock="Red", triggerObstacleIds={1}},

        {object="obstacle", x=250, y=-50, timerOn=1000, timerOff=3000, type="electricgate"},


        -- bobbing ledge without its movement path shown
        {object="ledge", x=300, keylock="Blue", triggerObstacleIds={2},
            movement={pattern={{50,-50},{-50,50},{-50,-50},{50,50}}, speed=1, pause=0, dontDraw=true, steering=steeringSmall}
        },

            -- moving rings where all rings move as one
            {object="rings", color=aqua, pattern={ {700,-400}, {0,-75}, {75,0}, {0,75} }, 
                movement={pattern={{75,75},{-75,75},{-75,-75},{75,-75}}, speed=1, steering={cap=0.5,mass=30,radius=30} }},

        {object="obstacle", x=250, y=-50, timerOn=3000, timerOff=2000, type="electricgate"},



        -- 1 ITEM 
        {object="emitter", x=-400, y=-800, timer={3000, 6000}, limit=nil, force={ {200, 400}, {100, 300}, {45, 90} }, 
            item={object="spike", type="fg-rock-3", size={6, 8}, physics={body="kinematic", shape="circle", friction=0.3, bounce=0.4}}},


        -- MULTI ITEM
        {object="emitter", x=-400, y=-800, timer={3000, 6000}, limit=nil, force={ {200, 400}, {100, 300}, {45, 90} }, 
            items={
                {30,  {object="wall",    type="fg-rock-3", size={6, 8}, physics={body="kinematic", shape="circle", friction=0.3, bounce=0.4}} },
                {70,  {object="scenery", type="fg-rock-3", size={6, 8}, physics={body="kinematic", shape="circle", friction=0.3, bounce=0.4}} },
                {100, {object="spike",   type="fg-rock-3", size={6, 8}, physics={body="kinematic", shape="circle", friction=0.3, bounce=0.4}} },
            }
        },



        {object="emitter", x=-200, y=800, timer={2000, 4000}, limit=nil, force={ {200, 400}, {-200, -400}, {90, 180} }, 
            item={object="spike", type="fg-rock-1", size={6, 8}, physics={body="kinematic", shape="circle", friction=0.3, bounce=0.4}}},

        {object="ledge", x=350, surface=exploding},

        {object="ledge", x=300, surface=ramp},

        {object="ledge", x=300, surface=pulley},

        {object="ledge", x=300},

        {object="obstacle", x=250, y=-50, timerOn=3000, timerOff=2000, type="electricgate"},

        {object="ledge", x=300, surface=collapsing},

        {object="emitter", x=-200, y=-800, timer={3000, 6000}, limit=nil, force={ {300, 500}, {100, 300}, {45, 90} }, 
            item={object="wall", type="fg-rock-3", size={6, 8}, physics={body="kinematic", shape="circle", friction=0.3, bounce=0.4}}},

        {object="emitter", x=-200, y=800, timer={2000, 4000}, limit=nil, force={ {300, 400}, {-200, -300}, {90, 180} }, 
            item={object="wall", type="fg-rock-1", size={6, 8}, physics={body="kinematic", shape="circle", friction=0.3, bounce=0.4}}},

        {object="ledge", x=300, surface=electric},
        
        {object="ledge", x=280},
        
        {object="ledge", x=280, y=-50},
            {object="rings", color=aqua, trajectory={x=50, y=-50, xforce=250, yforce=20, arc=40, num=5}},

        {object="ledge", x=450, y=50, size="big2"},

        {object="ledge", x=200, y=-200},
            {object="rings", color=aqua, trajectory={x=50, y=-100, xforce=130, yforce=15, arc=40, num=3}},

        {object="ledge", x=300, y=-30, size="medium2"},
            {object="rings", color=aqua, pattern={ {350,-225}, {100,70}, }},

        {object="ledge", x=300, y=200},
]]
        {object="ledge", x=3000, y=0, type="finish"}

    },
}

return levelData