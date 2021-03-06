local levelData = {
    name             = "key master",
    timeBonusSeconds = 66,
    ceiling          = -1000,
    floor            = 1800,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {0, 1},
        [bgrBack]  = {},
        [bgrSky]   = {1, 2}
    },

    backgroundSounds = {
        {name="space/space8", quietTime=3000, minVolume=4, maxVolume=6},
    },

    elements = {
        {object="ledge", type="start"},
          
        {object="ledge", x=270, y=-150, surface=oneshot, size="medium", destroyAfter=300, rotation=-20},

            {object="emitter", x=-200, y=-900, timer={2000, 5000}, limit=nil, force={ {0, 300}, {100, 300}, {0, 360} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-blue", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 7}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                }
            },
            {object="emitter", x=-100, y=700, timer={2000, 8000}, limit=nil, force={ {0, 150}, {-100, -300}, {0, 360} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={5, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 7}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                }
            },
            
        {object="ledge", x=270, y=-150, size="big2"},
            {object="key", x=0, y=-60, color="Red", onLedge=true},

        {object="ledge", x=600, y=0, size="big2"},
            {object="key", x=0, y=-60, color="Blue", onLedge=true},

        {object="ledge", x=-600, y=-550, size="big2", keylock="Blue", triggerEvent="unlockLevelEnd"},
            {object="rings", color=aqua, trajectory={x=50, y=-50, xforce=200, yforce=50, arc=50, num=5}},
            {object="rings", color=red, pattern={ {447,-390} }},

        {object="ledge", x=600, y=0, size="big2", keylock="Red", triggerEvent="unlockLevelEnd"},

        {object="ledge", x=-1100, y=250, surface=oneshot, size="med-small", destroyAfter=300},
            {object="rings", color=aqua, trajectory={x=30, y=-150, xforce=40, yforce=125, arc=40, num=3}},
        
        {object="ledge", x=725, y=0, surface=oneshot, size="med-small", destroyAfter=300},
            {object="friend", type="fuzzy", x=-30, color="Orange", onLedge=true},

        {object="enemy", type="greyufo", x=-175, y=-400, size=0.6, 
            movement={pattern=moveTemplateHighRec, isTemplate=true, distance=725, speed=2.5, pause=500, reverse=true, moveStyle=moveStyleSwayBig, pauseStyle=moveStyleSwayBig}
        },

        {object="ledge", x=675, y=0, surface=oneshot, size="med-small", destroyAfter=300},
            {object="rings", color=aqua, trajectory={x=-30, y=-150, xforce=-40, yforce=125, arc=40, num=3}},

            {object="emitter", x=100, y=800, timer={2000, 6000}, limit=nil, force={ {-10, -300}, {-100, -300}, {0, 360} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-blue", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 7}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                }
            },
        
            {object="wall", x=430,  y=-925, type="fg-wall-divider", targetName="moveableEndScenery1", physics={shapeOffset={bottom=0, left=0}, bounce=1}},
            {object="wall", x=427,  y=-25,  type="fg-wall-divider", targetName="moveableEndScenery2", physics={shapeOffset={bottom=0, left=0}, bounce=1}, flip="y"},
        
        {object="ledge", x=500, y=257, type="finish", targetName="endLedge"}
    },

    
    customEvents = {
        -- list each event by name: reference this by adding triggerEvent=<name> on the ledge in question
        ["unlockLevelEnd"] = {
            conditions = {
                -- player needs to have the following keys for event to trigger
                keys = {"Blue", "Red"},
            },
            delay        = 1000,  -- time before event starts from when it's triggered (eg. if player lands on ledge, good to give it time)
            freezePlayer = true,  -- means player cannot control the game while event is running
            action       = function(camera, player, source)
                local wall1    = hud:getTarget("scenery", "moveableEndScenery1")
                local wall2    = hud:getTarget("scenery", "moveableEndScenery2")
                local endLedge = hud:getTarget("ledge",   "endLedge")

                globalSoundPlayer(sounds.checkpoint)
                camera:setFocus(endLedge.image)

                after(2000, function()
                    wall1:moveNow({pattern={{0,-5000}}, speed=5, reverse=false})
                    wall2:moveNow({pattern={{0, 5000}}, speed=5, reverse=false})

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