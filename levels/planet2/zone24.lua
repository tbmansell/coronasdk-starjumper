local levelData = {
    name             = "eye of the storm",
    timeBonusSeconds = 220,
    ceiling          = -4000,
    floor            = 2500,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {5, 8, 4},
        [bgrBack]  = {},
        [bgrSky]   = {2, 1}
    },

    elements = {
        {object="ledge", type="start"},
            {object="scenery", type="fg-debris-ufo-left", x=50, y=-300, layer=4, rotation=-10},

        {object="ledge", x=3200, y=1500, size="medium", length=1500, movement={pattern=movePatternCircular, speed=0.25, arcStart=0, arc=360, fullCircle=true}},

            {object="warpfield", x=-1500, y=-1500, size=2.5, radius=200, layer=4, alwaysAnimate=true},
        
        {object="ledge", x=2700, y=1000, size="medium", length=1000, movement={pattern=movePatternCircular, speed=0.5, arcStart=0, arc=360, fullCircle=true}, positionFromLedge=1},
            {object="key", x=0, color="Yellow", onLedge=true},

        {object="ledge", x=2200, y=500, size="medium", length=500, movement={pattern=movePatternCircular, speed=1, arcStart=0, arc=360, fullCircle=true}, positionFromLedge=1},
            {object="key", x=0, color="Blue", onLedge=true},

        --#5
        {object="ledge", x=470, y=-200, surface=oneshot, size="medium", destroyAfter=1000, positionFromLedge=1},
            {object="rings", color=pink, pattern={{-100,0},{100,100},{100,-100},{-100,-100}}, 
                movement={pattern=moveTemplateDiamond, isTemplate=true, speed=1, distance=200, stagger=250}
            },

        {object="ledge", x=500, y=-950, surface=oneshot, size="medium", destroyAfter=1000},
            {object="rings", color=red, pattern={{-100,0},{100,100},{100,-100},{-100,-100},{50,-50}}, 
                movement={pattern=moveTemplateCross, isTemplate=true, speed=1, distance=200, stagger=25}
            },

        {object="ledge", x=-600, y=-250, size="medium", keylock="Yellow", triggerEvent="unlockWallYellow"},
            {object="spike", type="fg-spikes-float-2", x=-250, y=-325},

        --#8
        {object="ledge", x=1600, y=1350, surface=oneshot, size="medium", destroyAfter=1000, positionFromLedge=5},
            {object="rings", color=blue, pattern={{-100,-100},{50,50},{50,-50},{50,50},{50,-50}}, 
                movement={pattern=moveTemplateJerky, isTemplate=true, speed=1, distance=300, stagger=25}
            },

        {object="ledge", x=600, y=250, size="medium", keylock="Blue", triggerEvent="unlockWallBlue"},
            {object="spike", type="fg-spikes-float-4", x=200, y=-300},

        --#10
        {object="ledge", x=1000, y=-1600, size="medium2", positionFromLedge=8},
            {object="randomizer", x=-50, onLedge=true, spawn=3, items={ {35,gearTrajectory},{70,gearJetpack},{100,gearGloves} }},

        {object="ledge", x=500, y=0, size="medium3", targetName="escapeLedge"},
            {object="randomizer", x=-50, onLedge=true, spawn=3, items={ {35,blue},{70,white},{100,yellow} }},
            {object="randomizer", x=50,  onLedge=true, spawn=3, items={ {35,blue},{70,white},{100,yellow} }},

            {object="spike", type="fg-wall-divider-completeup",   x=-265, y=0, physics={shapeOffset={top=50}}},
            {object="spike", type="fg-wall-divider-spiked",       x=-280, y=-880, targetName="moveableWallBlue"},
            {object="spike", type="fg-wall-divider-spiked",       x=475,  y=-880, targetName="moveableWallYellow"},
            {object="spike", type="fg-wall-divider-completedown", x=-265, y=-1085},

        {object="obstacle", type="spacerocket", x=250, y=30, angle=-30, takeoff="medium", force={1500, -1200}, rotation={time=100, degrees=1}, targetName="escapeRocket"},

        {object="ledge", x=2000, y=-400, size="big"},
            {object="randomizer", x=-75, onLedge=true, spawn=3, items={ {35,gearFreezeTime},{70,gearGlider},{100,gearGrappleHook} }},
            {object="randomizer", x=75,  onLedge=true, spawn=3, items={ {35,blue},{70,white},{100,yellow} }},
            {object="spike", type="fg-spikes-float-5", x=-350, y=-150},
            {object="spike", type="fg-spikes-float-5", x=250,  y=-150, flip="x", physics={shapeOffset={top=50}}},
            {object="spike", type="fg-spikes-row-big", x=-125, y=105, size=1.5},

        {object="ledge", x=500, y=-200, type="finish"},
            {object="scenery", type="fg-debris-ufo-right", x=-250, y=-290, layer=4, rotation=10},
    },

    customEvents = {
        ["unlockWallBlue"] = {
            conditions = {
                keys = {"Blue"},
            },
            delay        = 1000,  -- time before event starts from when it's triggered (eg. if player lands on ledge, good to give it time)
            freezePlayer = true,  -- means player cannot control the game while event is running
            action       = function(camera, player, source)
                local wall  = hud:getTarget("scenery", "moveableWallBlue")
                local ledge = hud:getTarget("ledge",   "escapeLedge")

                globalSoundPlayer(sounds.checkpoint)
                camera:setFocus(ledge.image)

                after(2000, function()
                    wall:moveNow({pattern={{0,-5000}}, speed=5, reverse=false})

                    after(3000, function() 
                        camera:setFocus(player.image) 
                        hud:exitScript()
                    end)
                end)
            end
        },
        ["unlockWallYellow"] = {
            conditions = {
                keys = {"Yellow"},
            },
            delay        = 1000,  -- time before event starts from when it's triggered (eg. if player lands on ledge, good to give it time)
            freezePlayer = true,  -- means player cannot control the game while event is running
            action       = function(camera, player, source)
                local wall   = hud:getTarget("scenery",  "moveableWallYellow")
                local rocket = hud:getTarget("obstacle", "escapeRocket")

                globalSoundPlayer(sounds.checkpoint)
                camera:setFocus(rocket.image)

                after(2000, function()
                    wall:moveNow({pattern={{0,-5000}}, speed=5, reverse=false})

                    after(3000, function() 
                        camera:setFocus(player.image) 
                        hud:exitScript()
                    end)
                end)
            end
        },
    }

}

return levelData