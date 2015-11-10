local levelData = {
    name             = "strobe runner",
    timeBonusSeconds = 28,
    ceiling          = -2700,
    floor            = 1000,
    aiRace           = true,
    playerStart      = playerStartWalk,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {14, 11},
        [bgrBack]  = {},
        [bgrSky]   = {2, 1}
    },

    elements = {
        {object="ledge", type="start"},
            {object="rings", color=aqua, trajectory={x=30, y=-200, xforce=85, yforce=155, arc=65, num=3}},

            {object="emitter", x=100, y=-900, timer={2000, 5000}, limit=nil, force={ {0, 200}, {100, 300}, {0, 360} }, 
                items={
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 7}} },
                    {100, {object="scenery", layer=4, type="fg-debris-barrel-red", size={6, 8}} },
                }
            },

        -- Phase 1
        {object="ledge", x=320, y=-150, size="medbig2", rotation=-20, movement={bobbingPattern=moveTemplateBobDiamond3, speed=1, distance=50}},
            
        {object="ledge", x=230, y=-200, size="big2"}, ---- Rotating
            {object="scenery", x=300, y=-400, type="fgflt-pole-1"},
            {object="warpfield", x=250, y=-150, size=0.5, radius=100, movement={steering=steeringMild, speed=2, pattern={{0,-300}, {575,0}, {0,300}, {0,-300}, {-575,0}, {0,300}}}},    

        {object="ledge", x=275, y=-220, size="big2", rotation=-20},  ---Rotating
            {object="wall", x=456,  y=-842, type="fg-wall-divider-halfsize", copy=2, gap=647, physics={shapeOffset={bottom=0, left=0},   bounce=1}},            
            {object="wall", x=470,  y=-400, type="fg-wall-divider-completeup", physics={shapeOffset={bottom=-30, left=50},   bounce=1}},
            {object="rings", color=pink, pattern={ {500,-150}}},

        --{object="ledge", x=275, y=180, size="medium", movement={pattern={{50,-54},{-50,50},{-50,-54},{50,50}}, speed=1, pause=0, dontDraw=true, steering=steeringSmall}},
        {object="ledge", x=275, y=180, size="medium", movement={bobbingPattern=moveTemplateBobUp2, speed=1, distance=50}},
        
            {object="scenery", x=300, y=-400, type="fgflt-pole-4"},

        --{object="ledge", x=285, y=150, size="medium", movement={pattern={{50,-54},{-50,50},{-50,-54},{50,50}}, speed=1, pause=0, dontDraw=true, steering=steeringSmall}},
        {object="ledge", x=285, y=150, size="medium", movement={bobbingPattern=moveTemplateBobDown3, speed=1, distance=50}},
            
        {object="ledge", x=260, y=-200, size="medbig2", rotation=-15, ai={jumpVelocity={600,700}}},
            {object="rings", color=aqua, trajectory={x=100, y=-150, xforce=130, yforce=15, arc=40, num=3}},
            {object="wall", x=320,  y=-1275, type="fg-wall-divider", physics={shapeOffset={bottom=0, left=0},   bounce=1.5}},
            {object="wall", x=320,  y=-200, type="fg-wall-divider", physics={shapeOffset={bottom=0, left=0},   bounce=1.5}},    

            {object="emitter", x=0, y=600, timer={2000, 4000}, limit=nil, force={ {-400, 400}, {-100, -300}, {0, 360} }, 
                items={
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={2, 5}} },
                    {100, {object="scenery", layer=4, type="fg-debris-ufo-right", size={6, 8}} },
                }
            },

        -- Phase 2
        {object="ledge", x=500, y=0, size="medbig2", rotation=15},    

        {object="ledge", x=300, y=-150, surface=pulley, distance=250, speed=1, reverse="true"},
            {object="scenery", x=435, y=-400, type="fgflt-pole-2"},
            {object="wall",    x=-50, y=-450, type="fg-rock-4", size=1, rotation=-45, physics={shape="circle", friction=0.3, bounce=1}},
            {object="friend", type="fuzzy", x=15, y=-200, color="White", kinetic="hang", direction=left},

        {object="ledge", x=240, y=150, surface=pulley, distance=-150, speed=1, reverse="true"},
            {object="rings", color=red, pattern={ {250,-400}}},

        {object="ledge", x=320, y=-250, surface=pulley, distance=275, speed=2, reverse="true"},
            {object="scenery", x=340, y=-400, type="fgflt-pole-5"},
            {object="wall",    x=-50, y=-390, type="fg-rock-2", size=1, rotation=-45, physics={shape="circle", friction=0.3, bounce=1}},   
        
        {object="ledge", x=275, y=250, surface=pulley, distance=-225, speed=2, reverse="true"},

        {object="ledge", x=260, y=-200, size="medbig2", rotation=-15},     
            {object="rings", color=aqua, trajectory={x=30, y=-150, xforce=100, yforce=150, arc=50, num=5}},

        -- Phase 3
        {object="obstacle", x=250, y=-300, timerOn=1000, timerOff=750, type="electricgate"},
            {object="wall", x=-53,  y=-750, type="fg-wall-divider-halfsize", physics={shapeOffset={bottom=0, left=0}, bounce=1}},
            {object="wall", x=-53,  y=190, type="fg-wall-divider", flip="y", physics={shapeOffset={bottom=0, left=0}, bounce=1}},
      
        {object="ledge", x=325, y=120, size="medbig2", rotation=15},

            {object="emitter", x=0, y=-750, timer={3000, 6000}, limit=nil, force={ {-500, 500}, {100, 300}, {0, 360} }, 
                items={
                    {10, {object="scenery", layer=4, type="fg-debris-barrel-blue", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-5", size={2, 8}} },
                    {100, {object="scenery", layer=4, type="fg-debris-barrel-grey", size={6, 8}} },
                }
            },               

        {object="ledge", x=300, y=-400, size="medium", canShake=false, movement={pattern={{0,800}}, reverse=true, speed=1, pause=0}},
            {object="wall", x=316,  y=-892, type="fg-wall-divider-halfsize", copy=2, gap=647, physics={shapeOffset={bottom=0, left=0},   bounce=1}},            
            {object="wall", x=330,  y=-450, type="fg-wall-divider-completeup", physics={shapeOffset={bottom=-30, left=50},   bounce=1}},
            {object="rings", color=blue, pattern={ {0,-120}}},

        {object="ledge", x=800, y=400, size="medium", canShake=false, positionFromLedge=14, movement={pattern={{0,-800}}, reverse=true, speed=1, pause=0}},

        {object="ledge", x=1300, y=-400, size="medium", canShake=false, positionFromLedge=14, movement={pattern={{0,800}}, reverse=true, speed=2, pause=0}},
            {object="rings", color=white, pattern={ {0,-120}}},

            {object="emitter", x=100, y=-800, timer={3000, 5000}, limit=nil, force={ {-200, 10}, {100, 300}, {0, 360} }, 
                items={
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 7}} },
                    {100, {object="scenery", layer=4, type="fg-debris-barrel-red", size={6, 8}} },
                }
            },

        {object="ledge", x=1700, y=400, size="medium", canShake=false, positionFromLedge=14, movement={pattern={{0,-800}}, reverse=true, speed=2, pause=0}},
            {object="wall", x=350,  y=-1350, type="fg-wall-divider", physics={shapeOffset={bottom=0, left=0}, bounce=1}},
            {object="rings", color=aqua, trajectory={x=30, y=-200, xforce=110, yforce=100, arc=50, num=3}},

        {object="ledge", x=340, y=-200, type="finish"}
    },


    ai = {
        [1] = {
            skin          = "Grey Enemy",
            model         = characterGrey,
            direction     = left,
            startSequence = "taunt",
            startTaunt    = 1,
            startLedge    = 1,
            lives         = 10,
            waitingTimer  = 14,         -- 3.5 seconds before AI starts
            personality   = {
                waitForPlayer     = 4,    -- waits for player if they are this many ledges in front
                waitCatchupTo     = 1,    -- once waited, waits until the player is 1 ledge in front, before continuing
                waitFromLand      = 1,    -- seconds to wait from landing, before performing next action (jump)
                waitForJump       = 1,    -- seconds to wait in drag mode before they jump (simulating working out jump)
                reposition        = 30,   -- distance they will reposition themselves on a ledge by
                dropTrapOnCatchup = true, -- will throw a trap on current ledge when it wait for player to cathup, just before it runs off again
                tauntOnCatchup    = true, -- will perform taunt animation while waiting for player
                traps = {           -- traps AI has to throw (currently infinite)
                    [50]=negTrajectory, [100]=negDizzy
                },
           }
        },

    },
}

return levelData