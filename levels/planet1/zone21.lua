local levelData = {
    name             = "race to the rescue",
    timeBonusSeconds = 70,
    defaultLedgeSize = "medium",
    aiRace           = true,
    playerStart      = playerStartWalk,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {1,  2, 3,  4},
        [bgrMid]   = {11, 2, 11, 2},
        [bgrBack]  = {4,  1, 2,  3},
        [bgrSky]   = {2,  1}
    },

    elements = {
        {object="ledge", type="start"},
            {object="scenery", x=100, y=-400, type="fg-tree-4-yellow", copy=12, gap=400, layer=4, darken=100},
            {object="scenery", x=360, y=-300, type="fg-tree-4-yellow", copy=2,  gap=300, flip="x"},
        
        -- AI start
        {object="ledge", x=300, y=-50},
            
            {object="player", type="ai", model=characterBrainiak, targetName="brainiak", direction=left, waitingTimer=15,
                personality={ waitFromLand=1, waitForJump=1, waitFromAttack=3, reposition=30, attackPlayer=true }
            },

            {object="enemy", type="brain", x=-550, y=-250, size=0.5, color="Purple", spineDelay=250, alpha=0, targetName="startBrain1", behaviour={mode=stateSleeping},
                movement={pattern=movePatternVertical, distance=200, speed=0.2, moveStyle=moveStyleSway }
            },
            {object="enemy", type="brain", x=-280, y=-215, size=0.45, color="Purple", spineDelay=500, alpha=0, targetName="startBrain2", behaviour={mode=stateSleeping},
                movement={pattern=movePatternVertical, distance=250, speed=1.2, moveStyle=moveStyleSwaySmall }
            },
            {object="enemy", type="brain", x=150, y=250, size=0.4, color="Blue", spineDelay=750, alpha=0, targetName="startBrain3", behaviour={mode=stateSleeping},
                movement={pattern=movePatternVertical, distance=-350, speed=1.5, moveStyle=moveStyleSwayBig }
            },

        {object="ledge", x=300, y=-150, size="medium2"},
            {object="emitter", x=0, y=-150, timer={1000, 2000}, limit=4, layer=4,
                item={
                    object="livebgr", type="brain", color="Purple", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.3, 0, 0.2},
                    movement={rangeX={-600, 1000}, rangeY={-250, 250}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },

            --pinacle of scenery
            {object="scenery", x=0,   y=-170, type="fg-tree-4-yellow", rgb={200,100,255}},
            {object="scenery", x=200, y=200,  type="fg-wall-left"},
            {object="scenery", x=300, y=200,  type="fg-wall-right"},
            -- top row of blocks
            {object="scenery", x=0,   y=300, type="fg-wall-left"},
            {object="scenery", x=100, y=300, type="fg-wall-middle"},
            {object="scenery", x=480, y=300, type="fg-wall-right"},
            -- bottom row of blocks
            {object="scenery", x=-150, y=400, type="fg-wall-left"},
            {object="scenery", x=-50,  y=400, type="fg-wall-middle", copy=2},
            {object="scenery", x=710,  y=400, type="fg-wall-right"},
            {object="scenery", x=650,  y=50,  type="fg-tree-4-yellow", rgb={200,100,255}},

        {object="ledge", x=175, y=-200, size="medium2", flip="x"},
            {object="rings", color=aqua, trajectory={x=50, y=-150, xforce=10, yforce=100, arc=70, num=3}},
            {object="scenery", x=650,  y=50,  type="fg-tree-4-yellow", rgb={200,0,255}, copy=4, gap=300},
            {object="scenery", x=1000, y=250, type="fg-tree-4-yellow", rgb={200,150,255}, copy=5, gap=300},

            {object="spike", x=300,  y=-600, type="fg-spikes-float-2", size=0.75, rotation=180, physics={shapeOffset={left=30, right=-30, top=10}} },
            {object="spike", x=370,  y=-600, type="fg-spikes-float-3", size=0.75, rotation=180, physics={shapeOffset={left=30, right=-40, top=10}} },
            {object="spike", x=500,  y=-600, type="fg-spikes-float-2", size=0.75, rotation=180, physics={shapeOffset={left=30, right=-30, top=10}}, flip="x"  },
            {object="spike", x=1000, y=-600, type="fg-spikes-float-2", size=0.75, rotation=180, physics={shapeOffset={left=30, right=-30, top=10}} },
            {object="spike", x=1070, y=-600, type="fg-spikes-float-3", size=0.75, rotation=180, physics={shapeOffset={left=30, right=-40, top=10}} },
            {object="spike", x=1200, y=-600, type="fg-spikes-float-2", size=0.75, rotation=180, physics={shapeOffset={left=30, right=-30, top=10}}, flip="x"  },

        {object="ledge", x=150, y=280},

        {object="ledge", x=150, y=200, size="medium3", triggerEvent="awakenGiant", ai={loadGear=gearShield}},
            {object="rings", color=aqua, trajectory={x=50, y=-250, xforce=50, yforce=0, arc=40, num=3}},

            -- Giant brain that follows player / brainiak
            {object="enemy", type="brain", x=100, y=-600, size=1.1, color="Blue", targetName="giantBrain",
                behaviour={mode=stateSleeping, awaken=0, range=20, atRange=stateResetting},
                movement={pattern=movePatternFollow, speed=0.3, pause=1000, moveStyle=moveStyleSwaySmall, pauseStyle=moveStyleSwayBig}
            },

        {object="ledge", x=300, y=-100, surface="spiked", timerOff=4500},

        {object="ledge", x=350, y=100, ai={loadGear=gearGrappleHook}},
            {object="rings", color=aqua, trajectory={x=150, y=-150, xforce=100, yforce=100, arc=40, num=3}},

        {object="ledge", x=350, y=-400, size="medium2", movement={pattern=movePatternVertical, distance=500, speed=1}, ai={loadGear=gearGloves}},
            {object="rings", color=aqua, trajectory={x=50, y=100, xforce=50, yforce=0, arc=40, num=3}},

            {object="spike", x=200, y=-440, type="fg-spikes-float-2", size=0.75, rotation=180, physics={shapeOffset={left=30, right=-30, top=10}} },
            {object="spike", x=270, y=-440, type="fg-spikes-float-3", size=0.75, rotation=180, physics={shapeOffset={left=30, right=-40, top=10}} },
            {object="spike", x=400, y=-440, type="fg-spikes-float-2", size=0.75, rotation=180, physics={shapeOffset={left=30, right=-30, top=10}}, flip="x"  },

        {object="ledge", x=300, y=200, size="medium2", ai={loadGear=gearShield}},

            {object="emitter", x=0, y=-150, timer={1000, 2500}, limit=5, layer=4,
                item={
                    object="livebgr", type="heart", color="Red", direction=right, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.4, 0, 0.2},
                    movement={rangeX={-1000, 1000}, rangeY={-350, 150}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },

        {object="ledge", x=250, y=0, surface="electric", timerOn=5000, timerOff=5000},
            {object="rings", color=aqua, trajectory={x=10, y=-100, xforce=150, yforce=0, arc=40, num=3}},

            {object="spike", x=450, y=-500, type="fg-spikes-float-4", size=0.75, rotation=180, physics={shapeOffset={left=40, right=-30, top=15}} },
            {object="spike", x=500, y=-500, type="fg-spikes-float-1", size=0.75, rotation=180, physics={shapeOffset={left=30, right=-40, top=10}} },
            {object="spike", x=630, y=-500, type="fg-spikes-float-4", size=0.75, rotation=180, physics={shapeOffset={left=30, right=-35, top=15}}, flip="x"  },

            {object="spike", x=800, y=-500, type="fg-spikes-float-4", size=0.75, rotation=180, physics={shapeOffset={left=40, right=-30, top=15}} },
            {object="spike", x=850, y=-500, type="fg-spikes-float-1", size=0.75, rotation=180, physics={shapeOffset={left=30, right=-40, top=10}} },
            {object="spike", x=980, y=-500, type="fg-spikes-float-4", size=0.75, rotation=180, physics={shapeOffset={left=30, right=-35, top=15}}, flip="x"  },

        {object="ledge", x=300, y=100, size="big2"},

        {object="ledge", x=250, y=0, surface="spiked", timerOff=4000, ai={loadGear=gearGrappleHook}},

        {object="ledge", x=300, y=-100, ai={condition={attempts=3}, loadGear=gearJetpack, jumpVelocity={500,900}, useAirGearAfter={1200, 1600}}},

        {object="ledge", x=900, movement={pattern=movePatternHorizontal, distance=600, speed=2}},
            {object="rings", color=pink, pattern={ {-600,-100}, {150,0,color=white}, {150,0}, {150,0,color=white}, {150,0} }},

            {object="scenery", x=1500, y=150, type="fg-wall-left"},
            {object="scenery", x=1600, y=150, type="fg-wall-middle", copy=4},
            {object="scenery", x=3100, y=150, type="fg-wall-right"},
            -- top row of blocks
            {object="scenery", x=500,  y=250, type="fg-wall-left"},
            {object="scenery", x=600,  y=250, type="fg-wall-middle", copy=7},
            {object="scenery", x=3250, y=250, type="fg-wall-right"},
            -- bottom row of blocks
            {object="scenery", x=-150, y=350, type="fg-wall-left"},
            {object="scenery", x=-50,  y=350, type="fg-wall-middle", copy=9},
            {object="scenery", x=3370, y=350, type="fg-wall-right"},

        {object="ledge", x=350, y=0, ai={condition={attempts=2}, loadGear=gearJetpack, jumpVelocity={500,900}, useAirGearAfter={500,1200}}},

            {object="emitter", x=0, y=-200, timer={1000, 3000}, limit=4, layer=4,
                item={
                    object="livebgr", type="stomach", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.3, 0, 0.6},
                    movement={rangeX={-600, 600}, rangeY={-200, 250}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },

        {object="ledge", x=275, y=0, movement={pattern={{500,-150}}, reverse=true,  distance=100, speed=1, pause=1000}},
            {object="rings", color=white, pattern={ {0,-100}, {110,-40,color=pink}, {110,-40}, {110,-40,color=pink}, {110,-40} }},

        {object="ledge", x=800, y=0, size="medium3", ai={jumpVelocity={600,500}}},
            {object="spike", x=200, y=-620, type="fg-spikes-float-2", size=0.75, rotation=180, physics={shapeOffset={left=30, right=-30, top=10}} },
            {object="spike", x=270, y=-620, type="fg-spikes-float-3", size=0.75, rotation=180, physics={shapeOffset={left=30, right=-40, top=10}} },
            {object="spike", x=400, y=-620, type="fg-spikes-float-2", size=0.75, rotation=180, physics={shapeOffset={left=30, right=-30, top=10}}, flip="x"  },
        
        {object="ledge", x=500, y=0, type="finish"},
            {object="player", type="scripted", x=-200, y=0, model=characterSkyanna, direction=left, animation="Seated", targetName="skyanna"},
            {object="enemy",  type="brain",    x=-320, y=-200, size=0.35, color="Purple", spineDelay=300, targetName="henchman1"},
            {object="enemy",  type="brain",    x=-100, y=-200, size=0.35, color="Blue",   spineDelay=600, targetName="henchman2"},
    },

    customEvents = {
        -- Whizzes to skyanna and back, then brainiak summons 3 brains
        ["intro"] = {
            conditions   = {
                zoneStart = true,
            },
            delay        = 1000,
            freezePlayer = true,
            action       = function(camera, player, source)
                local brainiak = hud:getTarget("player", "brainiak")
                local skyanna  = hud:getTarget("player", "skyanna")
                local brain1   = hud:getTarget("enemy",  "startBrain1")
                local brain2   = hud:getTarget("enemy",  "startBrain2")
                local brain3   = hud:getTarget("enemy",  "startBrain3")

                sounds:loadPlayer(characterBrainiak)

                skyanna.lives = 0
                brainiak.completedCallback = function() hud:triggerEvent("brainiakWins", brainiak) end
                brainiak:pauseAi(true)
                brainiak:taunt()
                
                after(1000, function()
                    hud:showStory("race-brainiak-planet1-zone21", function()
                        after(1000, function()
                            camera:setFocus(skyanna.image)

                            after(2000, function()
                                camera:setFocus(player.image)

                                after(1500, function()
                                    brainiak:animate("3 4 Stars")
                                    local seq = hud:sequence("oust", "zone21-intro", brain1.image, brain2.image, brain3.image)
                                    seq:tran({alpha=1, time=1000})
                                    seq.onComplete = function()
                                        brain1:awaken(player)
                                        brain2:awaken(player)
                                        brain3:awaken(player)
                                    end
                                    seq:start()

                                    hud:exitScript()
                                    brainiak:pauseAi(false)
                                end)
                            end)
                        end)
                    end)
                end)
            end,
        },
        -- Brainiak awakens the giant brain
        ["awakenGiant"] = {
            freezePlayer = true,
            action       = function(camera, player, source)
                local player   = hud.player -- do this as if AI jumps on the ledge, they become the player loaded in
                local brainiak = hud:getTarget("player", "brainiak")
                local giant    = hud:getTarget("enemy",  "giantBrain")

                brainiak:pauseAi(true)
                brainiak:taunt(3)

                after(1000, function() camera:setFocus(giant.image) end)
                after(3000, function()
                    camera:setFocus(player.image)
                    brainiak:pauseAi(false)
                    hud:exitScript()
                end)
            end,
        },
        -- Brainiak arrives on the ledge first and the henchmen eat skyanna
        ["brainiakWins"] = {
            conditions = {
                zoneFinish = true,
                player     = characterBrainiak
            },
            freezePlayer = true,
            action       = function(camera, player, source)
                local player    = hud.player -- do this as if AI jumps on the ledge, they become the player loaded in
                local brainiak  = hud:getTarget("player", "brainiak")
                local henchman1 = hud:getTarget("enemy",  "henchman1")
                local henchman2 = hud:getTarget("enemy",  "henchman2")

                state.data.game = levelOverFailed

                camera:setFocus(brainiak.image)

                after(1000, function() brainiak:animate("3 4 Stars") end)
                after(3000, function()
                    henchman1:changeDirection(right, true)
                    henchman1:setMovement(nil, {pattern={{75,0}},  speed=0.5, oneWay=true, moveStyle=moveStyleSwaySmall})
                    henchman2:setMovement(nil, {pattern={{-50,0}}, speed=0.5, oneWay=true, moveStyle=moveStyleSwaySmall})
                    henchman1:move()
                    henchman2:move()
                    player:animate("Seated")

                    hud:exitScript()
                    player:failedCallback()
                end)
            end,
        },
        ["playerWins"] = {
            conditions = {
                zoneFinish = true,
                player     = "main"
            },
            freezePlayer = true,
            action       = function(camera, player, source)
                local brainiak  = hud:getTarget("player", "brainiak")
                local skyanna   = hud:getTarget("player", "skyanna")
                local henchman1 = hud:getTarget("enemy",  "henchman1")
                local henchman2 = hud:getTarget("enemy",  "henchman2")

                state.data.game = levelOverComplete

                brainiak:pauseAi(true)
                henchman1.deadly = false
                henchman2.deadly = false

                after(2000, function()
                    brainiak:animate("Seated")
                    player:animate("3 4 Stars")
                    skyanna:animate("3 4 Stars")

                    henchman1:changeDirection(right, true)
                    henchman1:setMovement(nil, {pattern={{0,-600}}, speed=2, oneWay=true, moveStyle=moveStyleSwaySmall})
                    henchman2:setMovement(nil, {pattern={{0,-600}}, speed=2, oneWay=true, moveStyle=moveStyleSwaySmall})
                    henchman1:move()
                    henchman2:move()

                    hud:exitScript()
                end)
            end,
        },
    },

}

return levelData