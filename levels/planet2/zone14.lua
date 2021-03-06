local rockFilter = { categoryBits=32, maskBits=3 }


local levelData = {
    name             = "helter shelter",
    timeBonusSeconds = 150,
    ceiling          = -2700,
    floor            = 1000,
    startLedge       = 1,
 
    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {5, 3},
        [bgrBack]  = {},
        [bgrSky]   = {2, 1}
    },

---- Change the asteroid physics objects in to kinematic and set paths

    backgroundSounds = {
        {name="space/space6", quietTime=7000, minVolume=2, maxVolume=3},
        {name="space/space5", quietTime=7000, minVolume=2, maxVolume=4},
    },

    elements = {
        {object="ledge", type="start"},
             {object="spike", x=118,  y=-1020, type="fg-wall-dividerx2-spiked2", rotation=90, physics={shapeOffset={bottom=0, left=0}, bounce=1}},
             {object="spike", x=982,  y=-1020, type="fg-wall-dividerx2-spiked1", rotation=90, physics={shapeOffset={bottom=0, left=0}, bounce=1}},
        
        {object="ledge", x=320, y=150, size="medbig"},
             {object="rings", color=aqua, trajectory={x=50, y=-50, xforce=75, yforce=170, arc=40, num=3}},
            
        {object="ledge", x=200, y=-200, size="medsmall2"},
            {object="scenery", x=500, y=-400, type="fgflt-pole-1"},
            {object="gear", type=gearShield, x=30, y=-150, onLedge=true, regenerate=false},

        {object="obstacle", x=110, y=-130, timerOn=5000, timerOff=1500, type="electricgate"},    

            {object="emitter", x=150, y=-1000, timer={3000, 6000}, layer=3, limit=2, force={ {0, 0}, {100,300}, {90, 91} }, 
                item={object="spike", type="fg-rock-3", size={5, 6}, rgb={1,0,0}, physics={body="kinematic", gravityScale=0, shape="circle", friction=0.3, bounce=0.8, filter=rockFilter} }
            },
            {object="emitter", x=550, y=-1000, timer={3000, 7000}, layer=3, limit=2, force={ {0, 0}, {100, 300}, {45, 46} }, 
                item={object="spike", type="fg-rock-2", size={5, 8}, rgb={1,0,0}, physics={body="kinematic", gravityScale=0, shape="circle", friction=0.5, bounce=0.8, filter=rockFilter} }
            },
            {object="emitter", x=800, y=-1000, timer={3500, 6500}, layer=3, limit=2, force={ {40, 45}, {100, 300}, {0, 1} }, 
                item={object="spike", type="fg-rock-3", size={4, 6}, rgb={1,0,0}, physics={body="kinematic", gravityScale=0, shape="circle", friction=0.3, bounce=0.8, filter=rockFilter} }
            },

        ----------- Outside Ledges 1
        {object="ledge", x=320, y=150, size="medbig2", rotation=-20, triggerEvent="dropGear1"}, 
            {object="rings", color=red, pattern={ {230,-420}}},
            
        {object="ledge", x=230, y=-200, size="big2", rotation=10, triggerEvent="dropGear1"},
            {object="scenery", x=300, y=-400, type="fgflt-pole-1"},

            -- Friendly help location 1
            {object="player", x=0, y=-200, type="scripted", model=characterReneGrey, direction=left, targetName="reneGrey", storyModeOnly=true, 
                physicsBody="static", loadGear={gearJetpack}, animation="Powerup PARACHUTE",
                movement={pattern=moveTemplateVertical, isTemplate=true, reverse=true, distance=100, speed=2, pause=1500, moveStyle=moveStyleSway, pauseStyle=moveStyleSway}
            },

        ----------- inside ledges 2
        {object="obstacle", x=110, y=-130, timerOn=4000, timerOff=2500, type="electricgate"},  
            {object="spike", x=438,  y=-687, type="fg-wall-dividerx2-spiked2", rotation=90, physics={shapeOffset={bottom=0, left=0}, bounce=1}},
            {object="spike", x=1302,  y=-687, type="fg-wall-dividerx2-spiked1", rotation=90, physics={shapeOffset={bottom=0, left=0}, bounce=1}},    

        {object="ledge", x=275, y=180, size="medium",movement={bobbingPattern=moveTemplateBobUp2, speed=1, distance=50}},
            {object="scenery", x=500, y=-400, type="fgflt-pole-5"},
            {object="rings", color=aqua, trajectory={x=100, y=-100, xforce=75, yforce=110, arc=50, num=3}},

        {object="ledge", x=270, y=200, surface="electric"},    
            {object="rings", color=aqua, trajectory={x=50, y=-100, xforce=50, yforce=170, arc=40, num=3}},

        {object="ledge", x=285, y=-220, size="medium"},

        {object="ledge", x=200, y=130, size="medsmall2"}, ---- Rotating
            {object="scenery", x=500, y=-400, type="fgflt-pole-1"},
            {object="gear", type=gearShield, x=30, y=-150, onLedge=true, regenerate=false},

        {object="obstacle", x=90, y=-250, timerOn=5000, timerOff=1500, type="electricgate"},  

        ----------- Outside Ledges 2          

            {object="emitter", x=200, y=-1000, timer={3500, 6500}, layer=3, limit=2, force={ {0, 0}, {100, 300}, {45, 90} }, 
                item={object="spike", type="fg-rock-1", size={3, 5}, rgb={1,0,0}, physics={body="kinematic", gravityScale=0, shape="circle", friction=0.3, bounce=0.8, filter=rockFilter} }
            },

            {object="emitter", x=700, y=-1000, timer={3500, 7000}, layer=3, limit=2, force={ {-25, -35}, {200, 400}, {45, 90} }, 
                item={object="spike", type="fg-rock-5", size={4, 6}, rgb={1,0,0}, physics={body="kinematic", gravityScale=0, shape="circle", friction=0.5, bounce=0.8, filter=rockFilter} }
            },

            {object="emitter", x=1000, y=-1000, timer={3500, 7500}, layer=3, limit=2, force={ {0, 0}, {100, 300}, {45, 90} }, 
                item={object="spike", type="fg-rock-4", size={5, 7}, rgb={1,0,0}, physics={body="kinematic", gravityScale=0, shape="circle", friction=0.3, bounce=0.8, filter=rockFilter} }
            },

        {object="ledge", x=320, y=50, size="medbig2", rotation=-10, triggerEvent="dropGear2"}, 
            {object="rings", color=blue, pattern={ {230,-390}}},
            
        -- Friendly help location 2
        {object="ledge", x=230, y=175, size="medsmall3", rotation=-20, targetName="targetLedge1", triggerEvent="dropGear2"},
            {object="scenery", x=300, y=-400, type="fgflt-pole-6"},

        {object="ledge", x=260, y=-255, size="medsmall", rotation=-24},
            {object="rings", color=aqua, trajectory={x=103, y=-150, xforce=100, yforce=15, arc=40, num=3}},
        
            {object="emitter", x=0, y=600, timer={2000, 4000}, limit=nil, force={ {-400, 400}, {-100, -300}, {0, 360} }, 
                items={
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={2, 5}} },
                    {100, {object="scenery", layer=4, type="fg-debris-ufo-right", size={6, 8}} },
                }
            },  

    ----------- inside ledges 3

        {object="obstacle", x=110, y=-130, timerOn=4000, timerOff=2500, type="electricgate"},  
        {object="spike", x=438,  y=-687, type="fg-wall-dividerx2-spiked2", rotation=90, physics={shapeOffset={bottom=0, right=-20}, bounce=1}}, 
        {object="spike", x=1302,  y=-687, type="fg-wall-dividerx2-spiked1", rotation=90, physics={shapeOffset={bottom=0, right=-20}, bounce=1}}, 

        {object="ledge", x=275, y=250, size="medium", movement={bobbingPattern=moveTemplateBobUp1, speed=1, distance=50}},
            {object="friend", type="fuzzy", x=230, y=-420, color="Pink", kinetic="hang", direction=left},

        {object="ledge", x=190, y=-70, surface=pulley, distance=-225, speed=2, reverse="true"},
             {object="rings", color=aqua, trajectory={x=103, y=-150, xforce=100, yforce=15, arc=40, num=3}}, 

        {object="ledge", x=340, y=90, size="medium", movement={bobbingPattern=moveTemplateBobUp2, speed=1, distance=50}},

        {object="ledge", x=220, y=-50, size="medsmall2"},
            {object="scenery", x=500, y=-400, type="fgflt-pole-1"},
            {object="gear", type=gearShield, x=30, y=-150, onLedge=true, regenerate=false},

        {object="obstacle", x=170, y=-180, timerOn=5000, timerOff=1500, type="electricgate"},  

        ----------- OUtside Ledges 3          

            {object="emitter", x=200, y=-1000, timer={4000, 7000}, layer=3, limit=2, force={ {-10, -27}, {300, 600}, {45, 90} }, 
                item={object="spike", type="fg-rock-1", size={3, 5}, rgb={1,0,0}, physics={body="kinematic", gravityScale=0, shape="circle", friction=0.3, bounce=0.8, filter=rockFilter} }
            },

            {object="emitter", x=700, y=-1000, timer={3500, 6500}, layer=3, limit=2, force={ {75, 90}, {300, 600}, {45, 90} }, 
                item={object="spike", type="fg-rock-3", size={4,6}, rgb={1,0,0}, physics={body="kinematic", gravityScale=0, shape="circle", friction=0.5, bounce=0.8, filter=rockFilter} }
            },

            {object="emitter", x=1000, y=-1000, timer={4000, 7000}, layer=3, limit=2, force={ {88, 100}, {300, 500}, {45, 90} }, 
                item={object="spike", type="fg-rock-4", size={3, 5}, rgb={1,0,0}, physics={body="kinematic", gravityScale=0, shape="circle", friction=0.3, bounce=0.8, filter=rockFilter} }
            },

            {object="emitter", x=1700, y=-1000, timer={3000, 6500}, layer=3, limit=2, force={ {-15, 35}, {300, 400}, {45, 90} }, 
                item={object="spike", type="fg-rock-2", size={5, 7}, rgb={1,0,0}, physics={body="kinematic", gravityScale=0, shape="circle", friction=0.5, bounce=0.8, filter=rockFilter} }
            },

            {object="emitter", x=2400, y=-1000, timer={3500, 6500}, layer=3, limit=2, force={ {15, 65}, {300, 400}, {45, 90} }, 
                item={object="spike", type="fg-rock-1", size={3, 6}, rgb={1,0,0}, physics={body="kinematic", gravityScale=0, shape="circle", friction=0.3, bounce=0.8, filter=rockFilter} }
            },

        {object="ledge", x=320, y=50, size="medsmall", rotation=-15, triggerEvent="dropGear3"}, 
            
        -- Friendly help location 3
        {object="ledge", x=210, y=-175, size="medsmall2", rotation=25, targetName="targetLedge2", triggerEvent="dropGear3"},
             {object="rings", color=white, pattern={ {230,-350}}},

        {object="ledge", x=280, y=185, size="medsmall3", rotation=-21},
           
        --safe ledge
        {object="ledge", x=255, y=-210, size="small3"},
            {object="spike", x=-100,  y=-430, type="fg-wall-divider-cornertop", rotation=45, physics={shape={-65,-75,  100,-100,  100,-30,  -30,100,   -110,100}, bounce=0.4}},  
            {object="gear", type=gearShield, x=30, y=-150, onLedge=true, regenerate=false},
            {object="scenery", x=300, y=-475, type="fgflt-pole-6"},

        {object="ledge", x=320, y=125, size="medsmall2", rotation=12}, 
            
        {object="ledge", x=240, y=175, size="medsmall3", rotation=-18}, ---- Rotating
            {object="scenery", x=300, y=-400, type="fgflt-pole-6"},

        {object="ledge", x=260, y=-235, size="medsmall", rotation=22},
            {object="rings", color=yellow, pattern={ {240,-330}}},  
        
            {object="emitter", x=0, y=600, timer={2000, 4000}, limit=nil, force={ {-400, 400}, {-100, -300}, {0, 360} }, 
                items={
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={2, 5}} },
                    {100, {object="scenery", layer=4, type="fg-debris-ufo-right", size={6, 8}} },
                }
            },  

        ----------- inside ledges 4

        {object="obstacle", x=170, y=-130, timerOn=4000, timerOff=2500, type="electricgate"},  
            {object="spike", x=450,  y=-690, type="fg-wall-dividerx2-spiked2", rotation=90, physics={shapeOffset={bottom=0, left=0}, bounce=1}},  

        {object="ledge", x=740, y=350, type="finish"}
    },
  
    customEvents = {
        -- ReneGrey: drops gear, then flies away
        ["dropGear1"] = {
            conditions   = {
                storyMode = true,
            },
            delay  = 100,  -- Cant create gear during same cycle as collision which triggers story
            action = function(camera, player, source)
                local reneGrey = hud:getTarget("player", "reneGrey")
                local ledge    = hud:getTarget("ledge",  "targetLedge1")
                local gear     = hud.level:generateGear(reneGrey:x(), reneGrey:y()+50, gearFreezeTime)

                reneGrey:emit("usegear-blue", {xpos=reneGrey:x(), ypos=reneGrey:y()}, false)

                local seq = hud:sequence("oust", "dropGear1", reneGrey.image)
                seq:tran({time=1000, alpha=0, playSound=sounds.playerTeleport})
                seq:callback(function()
                    reneGrey:emit("usegear-blue", {xpos=reneGrey:x(), ypos=reneGrey:y()}, false)
                    reneGrey:moveTo(ledge:x(), ledge:topEdge()-200)
                    reneGrey:visible()
                end)
                seq:start()

                hud:exitScript()
            end,
        },
        -- ReneGrey: drops gear, then flies away
        ["dropGear2"] = {
            conditions   = {
                storyMode = true,
            },
            delay  = 100,  -- Cant create gear during same cycle as collision which triggers story
            action = function(camera, player, source)
                local reneGrey = hud:getTarget("player", "reneGrey")
                local ledge    = hud:getTarget("ledge",  "targetLedge2")
                local gear     = hud.level:generateGear(reneGrey:x(), reneGrey:y()+50, gearReverseJump)

                reneGrey:emit("usegear-blue", {xpos=reneGrey:x(), ypos=reneGrey:y()}, false)

                local seq = hud:sequence("oust", "dropGear2", reneGrey.image)
                seq:tran({time=1000, alpha=0, playSound=sounds.playerTeleport})
                seq:callback(function()
                    reneGrey:emit("usegear-blue", {xpos=reneGrey:x(), ypos=reneGrey:y()}, false)
                    reneGrey:moveTo(ledge:x(), ledge:topEdge()-200)
                    reneGrey:visible()
                end)
                seq:start()

                hud:exitScript()
            end,
        },
        -- ReneGrey: drops gear, then flies away
        ["dropGear3"] = {
            conditions   = {
                storyMode = true,
            },
            delay  = 100,  -- Cant create gear during same cycle as collision which triggers story
            action = function(camera, player, source)
                local reneGrey = hud:getTarget("player", "reneGrey")
                local gear     = hud.level:generateGear(reneGrey:x(), reneGrey:y()+50, gearGloves)

                reneGrey:emit("usegear-blue", {xpos=reneGrey:x(), ypos=reneGrey:y()}, false)

                local seq = hud:sequence("oust", "dropGear3", reneGrey.image)
                seq:tran({time=1000, alpha=0, playSound=sounds.playerTeleport})
                seq:callback(function()
                    reneGrey:emit("usegear-blue", {xpos=reneGrey:x(), ypos=reneGrey:y()}, false)
                    reneGrey:destroy()
                end)
                seq:start()

                hud:exitScript()
            end,
        },
    }


}

return levelData