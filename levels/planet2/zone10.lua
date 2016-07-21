local levelData = {
    name             = "break away marathon",
    timeBonusSeconds = 167,
    ceiling          = -2000,
    floor            = 1800,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {5, 5},
        [bgrBack]  = {},
        [bgrSky]   = {1, 2}
    },

    backgroundSounds = {
        {name="space/space2", quietTime=5000, minVolume=4, maxVolume=6},
        {name="space/space4", quietTime=5000, minVolume=3, maxVolume=5},        
    },

    elements = {
        {object="ledge", type="start"},
            {object="wall", x=900,  y=-1200, type="fg-wall-divider", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="wall", x=2200,  y=-1200, type="fg-wall-divider", physics={shapeOffset={bottom=0, left=0},   bounce=1}},

            {object="emitter", x=100, y=-900, timer={2000, 4000}, limit=nil, force={ {0, 400}, {100, 300}, {0, 360} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={3, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 7}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-left", size={6, 10}} },
                }
            },
-- Center Ledge
        {object="ledge", x=1020, y=-600, size="medium3"},
            {object="gear", type=gearParachute, x=0, y=-100, regenerate=false},

-- JBase Level
        {object="ledge", x=375, y=200, size="medium", positionFromLedge=1},
        
        {object="ledge", x=445, y=0, size="medium"},
        
        {object="ledge", x=445, y=0, size="medium"},
-- Key Ledges
        {object="ledge", x=123, y=220, surface=oneshot, size="medium", destroyAfter=300, positionFromLedge=3},
            {object="key", x=0, y=-60, color="Yellow", onLedge=true},

        {object="ledge", x=123, y=220, surface=oneshot, size="medium", destroyAfter=300, positionFromLedge=4},
            {object="key", x=0, y=-60, color="Blue", onLedge=true},

-- Above Base Level Ledges
        {object="ledge", x=123, y=-250, surface=oneshot, size="medium", destroyAfter=300, positionFromLedge=3},
            {object="rings", color=pink, pattern={ {120,-80} }},

        {object="ledge", x=123, y=-250, surface=oneshot, size="medium", destroyAfter=300, positionFromLedge=4},
            {object="rings", color=pink, pattern={ {-120,-80} }},

-- Center Low
        {object="ledge", x=123, y=-220, size="medium", positionFromLedge=8},   
        
 -- Above Base Level Ledges
        {object="ledge", x=200, y=120,  surface=oneshot, size="medium", destroyAfter=300, positionFromLedge=2},
        {object="ledge", x=-200, y=120, surface=oneshot, size="medium", destroyAfter=300, positionFromLedge=2},
          
--To Key Pad Ledges
        {object="ledge", x=120, y=-250,  surface=oneshot, size="medium", destroyAfter=300, positionFromLedge=2},
            {object="rings", color=aqua, trajectory={x=-0, y=-150, xforce=40, yforce=125, arc=40, num=3}},

        {object="ledge", x=-120, y=-250, surface=oneshot, size="medium", destroyAfter=300, positionFromLedge=2},
            {object="rings", color=aqua, trajectory={x=0, y=-150, xforce=-40, yforce=125, arc=40, num=3}},
  
-- Key Pad
        {object="ledge", x=450, y=-530, size="medium", positionFromLedge=2, keylock="Yellow", triggerEvent="unlockLevelEnd"},      
            {object="wall", x=400,  y=220, type="fg-wall-divider-fs-completedown1", flip="y", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="wall", x=1040,  y=220, type="fg-wall-divider-fs-completedown2", flip="y", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="wall", x=386,  y=-218, type="fg-wall-divider-halfsize", targetName="moveableEndScenery2", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="wall", x=383,  y=-1050, type="fg-wall-divider", targetName="moveableEndScenery1", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            
        {object="ledge", x=-450, y=-530, size="medium", positionFromLedge=2, keylock="Blue", triggerEvent="unlockLevelEnd"},
    
-- Landing to Blue Key
        {object="ledge", x=75, y=-150, size="medsmall2", positionFromLedge=5}, --ledge 18
            {object="rings", color=aqua, pattern={ {0,-700, color=red}, {0,-150, color=pink}, {0,-150, }}},

-- Top Middle Ledge
        {object="ledge", x=400, y=-30, surface=oneshot, size="medium", destroyAfter=300, positionFromLedge=16}, 

            {object="enemy", type="greynapper", skin="fuzzy-napper", x=-240, y=-250, size=0.5,
                movement={pattern=moveTemplateTriangleUp, isTemplate=true, distance=250, reverse=true, speed=2.5, steering=steeringMild}
            },

            {object="emitter", x=100, y=-875, timer={2000, 5000}, limit=nil, force={ {-300, 300}, {100, 300}, {45, 90} }, 
                  items={
                      {10, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={6, 9}} },    
                      {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={4, 5}} },
                      {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 7}} },
                      {100, {object="scenery", layer=1, type="fg-debris-barrel-red", size={7, 8}} },
                  }
            },
            {object="emitter", x=0, y=2000, timer={3000, 6000}, limit=nil, force={ {-500, 400}, {-100, -300}, {0, 180} }, 
                items={
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-5", size={5, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-2", size={3, 8}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-left", size={8, 9}} },
                }
            },    
        
        {object="ledge", x=500, y=100, type="finish", positionFromLedge=15, targetName="endLedge"}
    },
    

    customEvents = {
        -- list each event by name: reference this by adding triggerEvent=<name> on the ledge in question
        ["unlockLevelEnd"] = {
            conditions = {
                -- player needs to have the following keys for event to trigger
                keys = {"Yellow", "Blue"},
            },
            delay        = 1000,  -- time before event starts from when it's triggered (eg. if player lands on ledge, good to give it time)
            freezePlayer = true,  -- means player cannot control the game while event is running
            action       = function(camera, player, source)
                globalSoundPlayer(sounds.checkpoint)
                
                local wall1    = hud:getTarget("scenery", "moveableEndScenery1")
                local wall2    = hud:getTarget("scenery", "moveableEndScenery2")
                local endLedge = hud:getTarget("ledge",   "endLedge")

                camera:setFocus(endLedge.image)

                after(2000, function()
                    wall1:moveNow({pattern={{0,-5000}}, speed=5, reverse=false})
                    wall2:moveNow({pattern={{0,-100}},  speed=5, reverse=true, steering=steeringMild})

                    after(4000, function() 
                        camera:setFocus(player.image) 
                        hud:exitScript()
                    end)
                end)
            end
        },
    }
}

return levelData