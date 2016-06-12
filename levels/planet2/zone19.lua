local levelData = {
    name             = "3 lifts and a rift",
    timeBonusSeconds = 28,
    ceiling          = -2000,
    floor            = 1000,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {0, 15},
        [bgrBack]  = {},
        [bgrSky]   = {1, 2}
    },

 backgroundSounds = {
        {name="space/space2", quietTime=7000, minVolume=4, maxVolume=5},
           {name="space/space6", quietTime=7000, minVolume=4, maxVolume=5},      
    },

    elements = {
        {object="ledge", type="start"},

            {object="emitter", x=30, y=-2200, timer={2000, 4000}, limit=nil, force={ {100, 500}, {100, 300}, {45, 180} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-blue", size={7, 9}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={4, 6}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-2", size={4, 7}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={7, 10}} },
                }
            },
            {object="emitter", x=30, y=400, timer={2000, 4000}, limit=nil, force={ {100, 500}, {-100, -300}, {45, 90} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-red", size={7, 9}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 6}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-4", size={4, 7}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={7, 10}} },
                }
            },
        
        {object="spike", x=100,  y=-1000, type="fg-wall-divider-spiked", rotation=90, physics={shapeOffset={top=0, right=-20},   bounce=1}},     

        {object="ledge", x=270, y=-150, surface=oneshot, size="medium", destroyAfter=300, rotation=-20},
            -- ring napper
            {object="enemy", type="greynapper", skin="ring-stealer", x=750, y=-1100, size=0.5,
                movement={pattern=moveTemplateVertical, isTemplate=true, reverse=true, distance=1000, speed=2.5, pause=500, pauseStyle=moveStyleSwayBig, steering=steeringMild}
            },
            -- fuzzy napper
            {object="enemy", type="greynapper", skin="fuzzy-napper", x=1175, y=-1100, size=0.5,
                movement={pattern=moveTemplateVertical, isTemplate=true, reverse=true, distance=1000, speed=2, pause=1500, pauseStyle=moveStyleSwayBig, steering=steeringMild}
            },   

        -- Moving Platform
        {object="ledge", x=750, y=-1500, size="medium", canShake=false, positionFromLedge=1, movement={pattern={{0,1500}}, reverse=true, speed=2, pause=0}},
            {object="spike", x=-415,  y=1440, type="fg-wall-divider-completedown", size=.8, copy=2, gap=60},
            {object="spike", x=-150,  y=1433, type="fg-spikes-row-big", size=0.8, copy=2, gap=590},
            {object="rings", color=white, pattern={ {230,100} }},
            {object="rings", color=pink, pattern={ {230,800} }},
            --{object="key", x=-50, y=-60, color="Yellow", onLedge=true},
            --{object="key", x=50, y=-60, color="Red", onLedge=true},
        
        {object="ledge", x=1200, y=-1500, size="medium2", canShake=false, positionFromLedge=1, movement={pattern={{0, 1500}}, reverse=true, speed=2.5, pause=0}},
            {object="spike", x=-440,  y=-310, type="fg-wall-divider-completeup", size=0.8},
            {object="spike", x=-175,  y=-160, type="fg-spikes-row-big", size=0.8, flip="y"},
            {object="rings", color=white, pattern={ {230,85} }},
            {object="rings", color=pink, pattern={ {230,785} }},
        
        {object="ledge", x=1650, y=-0, size="medium3", positionFromLedge=1, canShake=false,movement={pattern={{0,-1500}}, reverse=true, speed=2, pause=0}},
        
        --- Left Side
        {object="ledge", x=325, y=-500, size="medium3", positionFromLedge=1, keylock="Yellow", triggerEvent="unlockLevelEnd",},
            {object="rings", color=pink, pattern={ {230,40} }},

        {object="ledge", x=325, y=-1000, size="medium2", positionFromLedge=1, keylock="Red", triggerEvent="unlockLevelEnd",},
            {object="rings", color=pink, pattern={ {230,40} }},
   
        --- Right Side
        {object="ledge", x=2100, y=-500, size="medium3", positionFromLedge=1},
            {object="key", x=0, y=-60, color="Yellow", onLedge=true},
            {object="rings", color=pink, pattern={ {-230,40} }},

            {object="emitter", x=0, y=1000, timer={3000, 6000}, limit=nil, force={ {-300, 300}, {-100, -300}, {45, 95} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={3, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-4", size={3, 8}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-right", size={6, 8}} },
                }
            },    
            {object="emitter", x=-400, y=-1699, timer={3000, 6000}, limit=nil, force={ {-400, 400}, {100, 300}, {0, 45} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={2, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={3, 6}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-left", size={6, 8}} },
                }
            },

        {object="ledge", x=2100, y=-1000, size="medium3", positionFromLedge=1},
            {object="key", x=0, y=-60, color="Red", onLedge=true},
            {object="rings", color=pink, pattern={ {-230,40} }},

        {object="ledge", x=300, y=250, size="medium3"},     

 				{object="obstacle", type="spacerocket", x=400, y=0, angle=-30, takeoff="fast", force={1000,-900}, rotation={time=100, degrees=1}},    

           {object="emitter", x=600, y=-1000, timer={1000, 2000}, targetName="moveableEndScenery1", limit=nil, force={ {50, 150}, {100, 300}, {45, 90} }, 
                items={
                    {50,  {object="wall", layer=3, type="fg-rock-3", size={6, 12}, physics={body="kinematic", shape="circle", friction=0.3, bounce=0.4}} },
                    {100, {object="wall", layer=3, type="fg-rock-4", size={7, 10}, physics={body="kinematic", shape="circle", friction=0.3, bounce=0.4}} },
                }
            },
            {object="emitter", x=1000, y=-1000, timer={500, 1500}, targetName="moveableEndScenery2", limit=nil, force={ {100, 200}, {200, 500}, {45, 90} }, 
                items={
                    {50,  {object="wall", layer=3, type="fg-rock-1", size={7, 10}, physics={body="kinematic", shape="circle", friction=0.3, bounce=0.4}} },
                    {100, {object="wall", layer=3, type="fg-rock-2", size={6, 12}, physics={body="kinematic", shape="circle", friction=0.3, bounce=0.4}} },
                }
            },
            {object="emitter", x=1400, y=-1000, timer={1000, 2000}, targetName="moveableEndScenery3", limit=nil, force={ {-50, 150}, {100, 300}, {45, 90} }, 
                items={
                    {50,  {object="wall", layer=3, type="fg-rock-5", size={6, 12}, physics={body="kinematic", shape="circle", friction=0.3, bounce=0.4}} },
                    {100, {object="wall", layer=3, type="fg-rock-3", size={7, 10}, physics={body="kinematic", shape="circle", friction=0.3, bounce=0.4}} },
                }
            },
            {object="emitter", x=1800, y=-1000, timer={500, 1500}, targetName="moveableEndScenery4", limit=nil, force={ {-50, 100}, {200, 500}, {45, 90} }, 
                items={
                    {50,  {object="wall", layer=3, type="fg-rock-1", size={7, 10}, physics={body="kinematic", shape="circle", friction=0.3, bounce=0.4}} },
                    {100, {object="wall", layer=3, type="fg-rock-2", size={6, 10}, physics={body="kinematic", shape="circle", friction=0.3, bounce=0.4}} },
                }
            },    

        {object="ledge", x=2300, y=0, type="finish", targetName="endLedge"}
    },


    customEvents = {
        -- list each event by name: reference this by adding triggerEvent=<name> on the ledge in question
        ["unlockLevelEnd"] = {
            conditions = {
                -- player needs to have the following keys for event to trigger
                keys = {"Yellow", "Red"},
            },
            delay        = 1000,  -- time before event starts from when it's triggered (eg. if player lands on ledge, good to give it time)
            freezePlayer = true,  -- means player cannot control the game while event is running
            action       = function(camera, player, source)
                local wall1    = hud:getTarget("emitter", "moveableEndScenery1")
                local wall2    = hud:getTarget("emitter", "moveableEndScenery2")
                local wall3    = hud:getTarget("emitter", "moveableEndScenery3")
                local wall4    = hud:getTarget("emitter", "moveableEndScenery4")
                local endLedge = hud:getTarget("ledge",   "endLedge")

                globalSoundPlayer(sounds.checkpoint)
                camera:setFocus(endLedge.image)

                after(2000, function()
                    wall1:destroy()
                    wall2:destroy()
                    wall3:destroy()
                    wall4:destroy()

                    after(2000, function() 
                        camera:setFocus(player.image) 
                        hud:exitScript()
                    end)
                end)
            end
        },
    }

}

return levelData