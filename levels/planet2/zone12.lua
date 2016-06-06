local levelData = {
    name             = "angle of death",
    timeBonusSeconds = 28,
    ceiling          = -1000,
    floor            = 1400,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {0, 12},
        [bgrBack]  = {},
        [bgrSky]   = {1, 2}
    },

    elements = {
        {object="ledge", type="start"},
            {object="rings", color=aqua, trajectory={x=50, y=-50, xforce=150, yforce=240, arc=40, num=5}},

            {object="emitter", x=100, y=800, timer={2000, 4000}, limit=nil, force={ {0, 400}, {-100, -300}, {45, 180} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={8, 10}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={7, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 10}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                }
            },

        {object="ledge", x=280, y=-150, size="big3", movement={pattern={{20,-30},{-10,20},{10,-40},{-20,49}}, speed=1, pause=0, dontDraw=true, steering=steeringSmall}},
            {object="spike", x=500,  y=-218, type="fg-wall-divider-halfsize-dbspiked", copy=4, gap=550, rotation=17, physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            
-- Moving Platform
        {object="ledge", x=270, y=500, size="big", positionFromLedge=2, keylock="Yellow", triggerEvent="unlockLevelEnd",movement={pattern={{1950,0}}, reverse=true, speed=3, pause=1000}},
            {object="rings", color=red, pattern={ {-100,-80} }},
        
        {object="ledge", x=0, y=265, size="big", keylock="Red",  triggerEvent="unlockLevelEnd", movement={pattern={{2200,0}}, reverse=true, speed=3, pause=1000}},
            {object="rings", color=blue, pattern={ {-100,-80} }},

--    1st Row
        --{object="ledge", x=380, y=-235, size="medsmall", positionFromLedge=2},
        {object="ledge", x=380, y=-245, size="medsmall", positionFromLedge=2},
        
        {object="ledge", x=500, y=0, size="medsmall2"},
            {object="key", x=30, y=-60, color="Red", onLedge=true},         
            {object="enemy", type="greynapper", skin="ring-stealer", x=-350, y=-100, size=0.5,
                movement={pattern=moveTemplateTriangleUp, isTemplate=true, distance=500, reverse=true, speed=2.5, pause=3000, pauseStyle=moveStyleSwayBig}
            },

        {object="ledge", x=530, y=0, size="medsmall2"},

            {object="emitter", x=0, y=-699, timer={2000, 6000}, limit=nil, force={ {-500, 500}, {100, 300}, {0, 45} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-blue", size={7, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={6, 10}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-4", size={4, 8}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-left", size={7, 10}} },
                }
            },        
            {object="emitter", x=1000, y=-699, timer={3000, 8000}, limit=nil, force={ {-200, 400}, {100, 300}, {0, 45} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-blue", size={7, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={6, 10}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-4", size={4, 8}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-right", size={7, 10}} },
                }
            },        
            
        {object="ledge", x=530, y=0, size="medsmall2"},
            {object="key", x=-30, y=-60, color="Yellow", onLedge=true},     

        {object="ledge", x=250, y=-125, size="medbig3", rotating={limit=20, speed=25}},
            {object="friend", type="fuzzy", x=30, y=-50, color="Orange", onLedge=true},
  
--  2nd row                
        {object="ledge", x=360, y=275, size="small2", positionFromLedge=5},
        
        {object="ledge", x=250, y=-25, size="small3"},

        {object="ledge", x=900, y=25, size="small2"},
                  
-- 3rd Row

        {object="ledge", x=-195, y=240, surface=oneshot, size="med-small", positionFromLedge=10, destroyAfter=300},
        
        {object="ledge", x=800, y=-25, surface=oneshot, size="med-small", destroyAfter=300},
            
        {object="ledge", x=190, y=25, surface=oneshot, size="med-small", destroyAfter=300},
        
    --- ledges to end 

        {object="ledge", x=1300, y=350, size="big3", positionFromLedge=15, movement={bobbingPattern=moveTemplateBobUp2, speed=1, distance=50}},
            {object="rings", color=aqua, trajectory={x=110, y=-150, xforce=-120, yforce=75, arc=70, num=5}},
            {object="wall", x=461,  y=-218, type="fg-wall-divider",  targetName="moveableEndScenery1", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="wall", x=475,  y=-425, type="fg-wall-divider-fs-completedown1", targetName="moveableEndScenery2", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
        
        {object="ledge", x=400, y=0, type="finish", targetName="endLedge"}
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
                local wall1    = hud:getTarget("scenery", "moveableEndScenery1")
                local wall2    = hud:getTarget("scenery", "moveableEndScenery2")
                local endLedge = hud:getTarget("ledge",   "endLedge")

                globalSoundPlayer(sounds.checkpoint)
                camera:setFocus(endLedge.image)

                after(2000, function()
                    wall1:moveNow({pattern={{0,-5000}}, speed=5, reverse=false})
                    wall2:moveNow({pattern={{0,-5000}}, speed=5, reverse=false})

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