local levelData = {
    name             = "catch me if you can",
    timeBonusSeconds = 70,
    defaultLedgeSize = "medium",
    aiRace           = true,
    playerStart      = playerStartWalk,

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
            {object="player", type="ai", model= characterBrainiak, targetName="brainiak", direction=left, waitingTimer=15, lives=1000,
                personality={
                    waitFromLand      = 1,    -- seconds to wait from landing, before performing next action (jump)
                    waitForJump       = 1,    -- seconds to wait in drag mode before they jump (simulating working out jump)
                    reposition        = 30,   -- distance they will reposition themselves on a ledge by
                    dropTrapOnCatchup = true, -- will throw a trap on current ledge when it wait for player to cathup, just before it runs off again
                    tauntOnCatchup    = true, -- will perform taunt animation while waiting for player
                    traps = {                 -- traps AI has to throw (currently infinite)
                        {50,negTrajectory}, {100,negDizzy}
                    },
                }
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

        {object="ledge", x=150, y=280},

        {object="ledge", x=150, y=200, size="medium3", triggerEvent="awakenGiant", ai={loadGear=gearShield}},
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

        {object="ledge", x=300, y=200, size="medium2", ai={loadGear=gearShield}},

            {object="emitter", x=0, y=-150, timer={1000, 2500}, limit=5, layer=4,
                item={
                    object="livebgr", type="heart", color="Red", direction=right, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.4, 0, 0.2},
                    movement={rangeX={-1000, 1000}, rangeY={-350, 150}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },

        {object="ledge", x=250, y=0, surface="electric", timerOn=5000, timerOff=5000},

        {object="ledge", x=300, y=100, size="big2"},

        {object="ledge", x=250, y=0, surface="spiked", timerOff=4000},

        {object="ledge", x=300, y=-100, ai={loadGear=gearGrappleHook}},

        {object="ledge", x=900, movement={pattern=movePatternHorizontal, distance=600, speed=2}},
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

        {object="ledge", x=350, y=0},

            {object="emitter", x=0, y=-200, timer={1000, 3000}, limit=4, layer=4,
                item={
                    object="livebgr", type="stomach", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.3, 0, 0.6},
                    movement={rangeX={-600, 600}, rangeY={-200, 250}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },

        {object="ledge", x=275, y=0, movement={pattern={{500,-150}}, reverse=true,  distance=100, speed=1, pause=1000}},

        {object="ledge", x=800, y=0, size="medium3"},
        
        {object="ledge", x=500, y=0, type="finish"},
            {object="player", type="scripted", x=-200, y=0, model=characterSkyanna, direction=left, animation="Seated", targetName="skyanna"},
            {object="enemy",  type="brain",    x=-320, y=-200, size=0.35, color="Purple", spineDelay=300, targetName="henchman1"},
            {object="enemy",  type="brain",    x=-100,  y=-200, size=0.35, color="Blue",   spineDelay=600, targetName="henchman2"},
    },

    customEvents = {
        -- Whizzes to skyanna and back, then brainiak summons 3 brains
        ["intro"] = {
            conditions   = {
                zoneStart = true,
            },
            targets = {
                {object="player", targetName="brainiak"},
                {object="player", targetName="skyanna"},
                {object="enemy",  targetName="startBrain1"},
                {object="enemy",  targetName="startBrain2"},
                {object="enemy",  targetName="startBrain3"},
            },
            delay        = 1000,
            freezePlayer = true,
            action       = function(camera, player, source, targets)
                -- function called when event triggered and conditions have been met. Params:
                -- camera:  the camera to move around
                -- player:  the main player
                -- source:  the ledge which triggered the event
                -- targets: the list of objects specified in targets ([1]=object1, [2]=object2)
                sounds:loadPlayer(characterBrainiak)

                local brainiak = targets[1]
                local skyanna  = targets[2]
                local brain1   = targets[3]
                local brain2   = targets[4]
                local brain3   = targets[5]

                brainiak:pauseAi(true)
                brainiak:taunt()
                
                after(1000, function()
                    hud:showStory("race-brainiak-zone21", function()
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
            conditions = {},
            targets = {
                {object="player", targetName="brainiak"},
                {object="enemy",  targetName="giantBrain"},
            },
            delay        = 0,
            freezePlayer = true,
            action       = function(camera, player, source, targets)
                local player   = hud.player
                local brainiak = targets[1]
                local giant    = targets[2]

                brainiak:pauseAi(true)
                brainiak:taunt("3 4 Stars")

                after(1000, function() camera:setFocus(giant.image) end)
                after(3000, function()
                    camera:setFocus(player.image)
                    brainiak:pauseAi(false)
                    hud:exitScript()
                end)
            end,
        },
    },

}

return levelData