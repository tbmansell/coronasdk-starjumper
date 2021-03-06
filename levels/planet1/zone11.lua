local levelData = {
    name             = "a long way to go",
    floor            = display.contentHeight+200,
    ceiling          = -display.contentHeight*2,
    timeBonusSeconds = 95,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {4, 1, 2, 3},
        [bgrMid]   = {3, 10, 3, 10},
        [bgrBack]  = {3, 4, 1, 2},
        [bgrSky]   = {2, 1}
    },

    backgroundSounds = {
        {name="animals/cats3", quietTime=10000, minVolume=1, maxVolume=2},
        {name="nature/wind1", quietTime=8000, minVolume=1, maxVolume=3},
    },

    elements = {
        {object="ledge", type="start"},

        {object="ledge", x=350, y=-200, size="big"},
            {object="spike", x=-325, y=-100, type="fg-spikes-float-1", physics={shape={-10,-135, 70,90, -80,90}}},
            {object="spike", x=200,  y=-160, type="fg-spikes-float-1", physics={shape={-10,-135, 70,90, -80,90}}},
            {object="spike", x=700,  y=-100, type="fg-spikes-float-1", physics={shape={-10,-135, 70,90, -80,90}}},

             {object="emitter", x=600, y=-250, timer={1000, 3000}, limit=5, layer=4,
                item={
                    object="livebgr", type="brain", color="Purple", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.3, 0, 0.1},
                    movement={rangeX={-200, 2000}, rangeY={-250, 400}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },

        {object="ledge", x=300, y=0, size="medium"},
            {object="gear", type=gearGlider, y=-50, regenerate=true},

        {object="ledge", x=350, y=200, size="big"},
            {object="rings", color=aqua, pattern={ {x=-65, y=-300}, {x=0, y=-65}, {x=0, y=135} }},
            {object="spike", x=400,  y=-100, type="fg-spikes-float-3",  physics={shape={-20,-125, 70,90, -80,90}}, flip="x"},
            {object="spike", x=700,  y=-100, type="fg-spikes-float-3",  physics={shape={-20,-125, 70,90, -80,90}}},
            {object="spike", x=1000, y=-100, type="fg-spikes-float-3", physics={shape={-20,-125, 70,90, -80,90}}, flip="x"},
            {object="spike", x=1300, y=-100, type="fg-spikes-float-3", physics={shape={-20,-125, 70,90, -80,90}}},            

        {object="obstacle", type="deathslide", x=200, y=-270, length={1400,0}, speed=4, animSpeed="SLOW"},
            {object="rings", color=aqua, pattern={ {500,100}, {300,0}, {300,0} }},

        {object="ledge", x=0, y=350, size="medium2", triggerEvent="brainiakTrap"},

        -- need glider to get to next ledge
        {object="ledge", x=300, y=-150, size="small2", targetName="focusLedge", ai={loadGear=gearGlider, jumpVelocity={600,900}, useAirGearAfter={1000}}},
            {object="rings", color=aqua, pattern={ {x=650, y=-400}, {x=120, y=25}, {x=120, y=25}, {x=120, y=25}, {x=120, y=25}, {x=120, y=25}, {x=120, y=25} }},
            {object="spike", x=400,  y=-100, type="fg-spikes-float-5",  physics={shape={35,-140, 70,90, -80,90}}, flip="x"},
            {object="spike", x=700,  y=-100, type="fg-spikes-float-5",  physics={shape={-35,-140, 70,90, -80,90}}},
            {object="spike", x=1000, y=-100, type="fg-spikes-float-5", physics={shape={35,-140, 70,90, -80,90}}, flip="x"},
            {object="spike", x=1300, y=-100, type="fg-spikes-float-5", physics={shape={-35,-140, 70,90, -80,90}}},

        {object="ledge", x=300, y=-150, size="medium", targetName="tempLedge"},
            {object="player", type="scripted", model=characterBrainiak, x=0, y=0, direction=left, targetName="brainiak", storyModeOnly=true},

        {object="ledge", x=905, y=200, size="big"},

        {object="ledge", x=250, y=150, size="small2"},
            {object="friend", type="fuzzy", onLedge=true, color="Orange"},

            {object="emitter", x=0, y=-450, timer={1000, 2000}, limit=2, layer=4,
                item={
                    object="livebgr", type="heart", color="Red", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.4, 0, 0.1},
                    movement={rangeX={-200, 2000}, rangeY={-50, 250}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },        

        {object="ledge", x=300, y=-150, size="big"},
            {object="spike", x=-280, y=-100, type="fg-spikes-float-2", physics={shape={0,-140, 30,120, -30,120}}},
            {object="spike", x=200,  y=-100, type="fg-spikes-float-2", physics={shape={0,-140, 30,120, -30,120}}},

        {object="ledge", x=300, y=-150, size="big"},

        {object="ledge", x=400, y=-150, size="medium"},
            {object="rings", color=aqua, trajectory={x=50, y=-150, xforce=150, yforce=150, arc=45, num=3}},

        {object="ledge", x=500, y=-150, size="medium"},
              {object="randomizer", x=-65, onLedge=true, items={{30,negTrajectory}, {70,gearTrajectory}, {100,white}}},

        {object="ledge", x=500, y=-150, size="small"},
            {object="spike", x=-280, y=-100, type="fg-spikes-float-4", physics={shape={-15,-140, 40,120, -40,120}}},
            {object="spike", x=200,  y=-250, type="fg-spikes-float-4", physics={shape={-15,-140, 40,120, -40,120}}},

        {object="ledge", x=500, y=-150, size="medium3"},

            {object="emitter", x=0, y=-250, timer={1000, 3000}, limit=3, layer=4,
                item={
                    object="livebgr", type="brain", color="Purple", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.3, 0, 0.3},
                    movement={rangeX={-200, 2000}, rangeY={-250, 400}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },

        {object="obstacle", type="deathslide", x=200, y=-300, length={1600,350}, speed=4, animSpeed="MEDIUM"},

        {object="ledge", x=-500, y=200, size="small"},
            {object="friend", x=0, y=0, type="fuzzy", color="White"},
            {object="scenery", x=720, y=-172, type="fg-spikes-4",layer=2, size=1},

        {object="ledge", x=370, y=100, type="finish"}
    },

    customEvents = {
        -- Brainiak: taunts player next to rock trap before it collapse then runs off
        ["brainiakTrap"] = {
            conditions   = {
                storyMode = true,
            },
            delay        = 1000,
            freezePlayer = true,
            action       = function(camera, player, source)
                local brainiak   = hud:getTarget("player", "brainiak")
                local ledgeFocus = hud:getTarget("ledge",  "focusLedge")
                local ledgeTemp  = hud:getTarget("ledge",  "tempLedge")
                local bomb       = nil

                camera:setFocus(ledgeFocus.image)
                
                brainiak:setIndividualGear(gearJetpack)

                after(1000, function() 
                    brainiak:sound("randomCelebrate")
                    bomb = brainiak:dropNegable(negTimeBomb) 
                end)
                after(2000, function() 
                    brainiak:changeDirection()
                    brainiak:runup(200, -2600) 
                end)

                after(3000, function() 
                    hud:showEffect("explosion", ledgeTemp)
                    player:sound("ledgeExplodingActivated")
                    after(250, function()
                        bomb:destroy()
                        ledgeTemp:destroy() 
                    end)
                end)
                after(4500, function()
                    camera:setFocus(player.image)
                    brainiak:destroy()
                    hud:exitScript()
                end)

            end,
        },
    }
}

return levelData