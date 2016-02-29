local planetData = {
    name         = "organia",
    gameUnlocks  = {
        [gameTypeTimeRunner]  = {stars=50},
        [gameTypeClimbChase]  = {stars=60},
        [gameTypeArcadeRacer] = {stars=70},
        [gameTypeSurvival]    = {fuzzies=7},
        [gameTypeTimeAttack]  = {fuzzies=14},
        [gameTypeRace]        = {fuzzies=22},
    },
    unlockFriend = characterSkyanna,
    unlockEnemy  = characterBrainiak,

    -- Story mode zone select scene markers:
    zones = {
        [1]  = { x=180,  y=390, hint={gearTrajectory} },
        [2]  = { x=330,  y=305, hint={gearTrajectory} },
        [3]  = { x=500,  y=350, hint={gearTrajectory} },
        [4]  = { x=610,  y=465, hint={gearGloves} },
        [5]  = { x=830,  y=460, hint={gearSpringShoes} },
        [6]  = { x=1010, y=395, hint={gearReverseJump} },
        [7]  = { x=1180, y=375, special=true, hint={gearGlider, gearGloves} },
        [8]  = { x=1350, y=435, hint={gearJetpack} },
        [9]  = { x=1550, y=465, hint={gearParachute, gearGloves} },
        [10] = { x=1690, y=365, hint={gearTrajectory, gearShield} },
        [11] = { x=1820, y=305, hint={gearTrajectory, gearGlider} },
        [12] = { x=1960, y=375, hint={gearGlider} },
        [13] = { x=2150, y=435, hint={gearShield, gearFreezeTime, gearReverseJump} },
        [14] = { x=2290, y=370, special=true, gameTypeSurvival="no", gameTypeTimeAttack="no", gameTypeRace="no", hint={gearTrajectory, gearGloves} },
        [15] = { x=2450, y=370, hint={gearReverseJump, gearGloves} },
        [16] = { x=2605, y=430, hint={gearShield, gearParachute} },
        [17] = { x=2800, y=495, hint={gearTrajectory, gearGloves} },
        [18] = { x=2960, y=400, hint={gearFreezeTime, gearJetpack, gearParachute} },
        [19] = { x=3180, y=325, hint={gearSpringShoes, gearShield, gearGloves} },
        [20] = { x=3370, y=340, hint={gearTrajectory, gearShield, gearReverseJump} },
        [21] = { x=3550, y=390, special=true, hint={gearShield, gearFreezeTime, gearGlider} },
        -- secret zones:
        [22] = { x=3900, y=350, secret=true, hint={} },
        [23] = { x=4200, y=400, secret=true, hint={} },
        [24] = { x=4350, y=280, secret=true, hint={} },
        [25] = { x=4500, y=450, secret=true, hint={} },
        [26] = { x=4620, y=300, secret=true, hint={} },
    },

    -- Story mode zone select scene - spine objects shown
    animated = {
        {object="friend",   type="fuzzy",         x=465,  y=198, color="Orange", kinetic="bounce"},
        {object="enemy",    type="brain",         x=900,  y=200, size=0.3, color="Purple", theme="rocky", behaviour={mode=stateSleeping}},

        {object="enemy",    type="brain",         x=950,  y=440, size=0.3, color="Purple", theme="rocky", 
            movement={pattern={{0,-80}, {-120,0}, {0,80}, {120,0}}, speed=1, pause=0, moveStyle=moveStyleSway, steering=mildSteering}
        },
        
        {object="friend",   type="ufoboss",       x=1300, y=200, size=0.5, direction=right,
            movement={pattern=movePatternVertical, distance=40, reverse=true, speed=0.5, steering=steeringMild}
        },
        
        {object="enemy",    type="brain",         x=1570, y=220, size=0.4, color="Blue", direction=right, theme="rocky",
            movement={pattern=movePatternVertical, speed=0.5, distance=100, pause=1500, moveStyle=moveStyleSway, pauseStyle=moveStyleSwayBig}
        },
        
        {object="obstacle", type="deathslide",    x=1767, y=183, length={1,0}, speed=1, startAnimation="Deathslide-SLOW"},
        
        {object="enemy",    type="heart",         x=2150, y=270, size=0.4, color="Red", direction=left, theme="rocky", behaviour={},
            movement={pattern={{0,-80}, {-120,0}, {0,80}, {120,0}}, speed=1.5, pause=2000, moveStyle=moveStyleSway, pauseStyle=moveStyleSwayBig}
        },
        
        {object="enemy",    type="heart",         x=2300, y=470, size=0.35, color="White", direction=left, theme="rocky", behaviour={mode=stateSleeping}},
        {object="obstacle", type="ropeswing",     x=2805, y=320, direction=right, length=100, movement={speed=1, arcStart=230, arc=90}},
        {object="scenery",  type="fg-rock-1",     x=2625, y=135, size=0.25, theme="rocky"},
        
        {object="enemy",    type="stomach",       x=2950, y=330, size=0.5, color="Red", direction=left, shooting={velocity={x=0,y=0}}, theme="rocky",
            movement={pattern=movePatternHorizontal, speed=0.5, distance=200, pause=1500, moveStyle=moveStyleWave}
        },
        
        {object="friend",   type="fuzzy",            x=3330, y=380, color="Blue", kinetic="hang", direction=right},
        {object="player",   model=characterSkyanna,  x=3710, y=345, size=0.17, direction=left, animation="Seated"},
        {object="player",   model=characterBrainiak, x=3765, y=350, size=0.17, direction=left},
    },

    -- Unlocking scheme
    unlocks = {
        {type="planet",    name="apocalypsoid",  conditionText="collect 28 stars",    icon="unlock-planet"},
        {type="zones",     name="secret canyon", conditionText="collect 60 awards",   icon="unlock-zones"},
        {type="outfit",    name="space suit",    conditionText="collect all fuzzies", icon="unlock-costume-blue"},
        {type="character", name="skyrianna",     conditionText="complete all zones",  icon="unlock-character-female"}
    },

    -- Background sounds
    backgroundSounds = {
        --{sound=sounds.backgroundSoundWind1, quietTime=4000, minVolume=1, maxVolume=2},
        {sound=sounds.backgroundSoundWind2, quietTime=7000, minVolume=1, maxVolume=2},
        {sound=sounds.backgroundSoundWind3, quietTime=5000, minVolume=1, maxVolume=4},
    },

    -- Scenery element definitions
    sceneryDefs = {
        ["fgflt-tree-1-yellow"] = {image="fgflt-tree-1-yellow", width=378, height=820},
        ["fgflt-tree-2-yellow"] = {image="fgflt-tree-2-yellow", width=417, height=848},
        ["fgflt-tree-3-yellow"] = {image="fgflt-tree-3-yellow", width=427, height=890},
        ["fgflt-tree-4-yellow"] = {image="fgflt-tree-4-yellow", width=348, height=820},
        ["fgflt-tree-5-yellow"] = {image="fgflt-tree-5-yellow", width=282, height=780},
        ["fgflt-tree-6-yellow"] = {image="fgflt-tree-6-yellow", width=279, height=780},
        ["fg-rock-1"]           = {image="fg-rock-1",           width=164, height=169, size=0.6, shape="circle"},
        ["fg-rock-3"]           = {image="fg-rock-3",           width=216, height=163, size=0.6, shape="circle"},
        ["fg-rock-4"]           = {image="fg-rock-4",           width=197, height=184, size=0.6, shape="circle"},
        ["fg-wall-divider"]     = {image="fg-wall-divider",     width=107, height=900, size=0.8, shapeOffset={bottom=-30}, botPull=-70, topPull=50},
        ["fg-spikes-float-1"]   = {image="fg-spikes-float-1",   width=210, height=300, size=0.6, flipTop=true, shape={0,-130, 90,130, -90,130}},
        ["fg-spikes-float-2"]   = {image="fg-spikes-float-2",   width=114, height=351, size=0.6, flipTop=true, shape={0,-150, 60,150, -60,150}},
        ["fg-spikes-float-3"]   = {image="fg-spikes-float-3",   width=179, height=340, size=0.6, flipTop=true, shape={0,-130, 90,130, -90,130}},
        ["fg-spikes-float-4"]   = {image="fg-spikes-float-4",   width=121, height=337, size=0.6, flipTop=true, shape={0,-140, 80,140, -80,140}},
        ["fg-spikes-float-5"]   = {image="fg-spikes-float-5",   width=142, height=343, size=0.6, flipTop=true, shape={0,-150, 80,150, -80,150}},
        ["fg-flowers-1-yellow"] = {image="fg-flowers-1-yellow", width=119, height=134, size={4,7}},
        ["fg-flowers-2-yellow"] = {image="fg-flowers-2-yellow", width=91,  height=154, size={4,7}},
        ["fg-flowers-3-yellow"] = {image="fg-flowers-3-yellow", width=123, height=147, size={4,7}},
        ["fg-flowers-4-yellow"] = {image="fg-flowers-4-yellow", width=78,  height=143, size={4,7}},
        ["fg-flowers-5-yellow"] = {image="fg-flowers-5-yellow", width=77,  height=141, size={4,7}},
        ["fg-flowers-6-yellow"] = {image="fg-flowers-6-yellow", width=59,  height=142, size={4,7}},
        ["fg-foilage-1-yellow"] = {image="fg-foilage-1-yellow", width=147, height=152, size={4,7}},
        ["fg-foilage-2-yellow"] = {image="fg-foilage-2-yellow", width=126, height=148, size={4,7}},
        ["fg-foilage-3-yellow"] = {image="fg-foilage-3-yellow", width=68,  height=85,  size={4,7}},
        ["fg-foilage-4-yellow"] = {image="fg-foilage-4-yellow", width=127, height=118, size={4,7}},
    },

    -- Characters active in this planets space race game
    spaceRace = {
        playerModel = characterNewton,
        --state.data.zoneSelected = 1..9 -- passes
        --state.data.zoneSelected = 10   -- passes - uses fixed jump onto pole ledge and shield to pass enemy on last ledge
        --state.data.zoneSelected = 11   -- passes
        --state.data.zoneSelected = 12   -- passes - needs gloves - moving ledge
        --state.data.zoneSelected = 13   -- passes
        --state.data.zoneSelected = 14   -- not raceable
        --state.data.zoneSelected = 15   -- passes
        --state.data.zoneSelected = 16   -- passes - uses fixed jump and parachute on last ledge cos of last electric ledge
        --state.data.zoneSelected = 17   -- passes
        --state.data.zoneSelected = 18   -- passes - uses fixed jump for first spiked ledge
        --state.data.zoneSelected = 19   -- passes - uses shield to bypass nasty spike section
        --state.data.zoneSelected = 20   -- passes - uses shield to bypass spiked ledge to deathslide
        --state.data.zoneSelected = 21   -- passes
        --[[
        ai = {
            [1] = {
                skin          = "Green Space Man",
                model         = characterNewton,
                inSpaceRace   = true,
                direction     = right,
                startLedge    = 1,
                lives         = 9999,
                waitingTimer  = 17,           -- 4 seconds before AI starts
                personality   = {
                    waitFromLand      = 0,    -- seconds to wait from landing, before performing next action (jump)
                    waitForJump       = 3,    -- seconds to wait in drag mode before they jump (simulating working out jump)
                    reposition        = 30,   -- distance they will reposition themselves on a ledge by
                    dropTrapOnCatchup = true, -- will throw a trap on current ledge when it wait for player to cathup, just before it runs off again
                    tauntOnCatchup    = true, -- will perform taunt animation while waiting for player
                    traps = {                 -- traps AI has to throw (currently infinite)
                        {50,negTrajectory}, {100,negDizzy}
                    },
                },
            },
            [2] = {
                skin          = "Female  Alien",
                model         = characterSkyanna,
                inSpaceRace   = true,
                direction     = right,
                startLedge    = 1,
                lives         = 9999,
                waitingTimer  = 17,           -- 4 seconds before AI starts
                personality   = {
                    waitFromLand      = 0.5,  -- seconds to wait from landing, before performing next action (jump)
                    waitForJump       = 2,    -- seconds to wait in drag mode before they jump (simulating working out jump)
                    reposition        = 30,   -- distance they will reposition themselves on a ledge by
                    dropTrapOnCatchup = true, -- will throw a trap on current ledge when it wait for player to cathup, just before it runs off again
                    tauntOnCatchup    = true, -- will perform taunt animation while waiting for player
                    traps = {                 -- traps AI has to throw (currently infinite)
                        {50,negTrajectory}, {100,negDizzy}
                    },
                },
            },
            [3] = {
                skin          = "Muscle Alien",
                model         = characterHammer,
                inSpaceRace   = false,
                direction     = right,
                startLedge    = 1,
                lives         = 9999,
                waitingTimer  = 16,           -- 4 seconds before AI starts
                personality   = {
                    waitFromLand      = 1,    -- seconds to wait from landing, before performing next action (jump)
                    waitForJump       = 2,    -- seconds to wait in drag mode before they jump (simulating working out jump)
                    reposition        = 30,   -- distance they will reposition themselves on a ledge by
                    dropTrapOnCatchup = true, -- will throw a trap on current ledge when it wait for player to cathup, just before it runs off again
                    tauntOnCatchup    = true, -- will perform taunt animation while waiting for player
                    traps = {                 -- traps AI has to throw (currently infinite)
                        {50,negTrajectory}, {100,negDizzy}
                    },
                },
            },
            [4] = {
                skin          = "Brain Enemy",
                model         = characterBrainiak,
                inSpaceRace   = true,
                direction     = right,
                startLedge    = 1,
                lives         = 9999,
                waitingTimer  = 16,           -- 4 seconds before AI starts
                personality   = {
                    waitFromLand      = 2,    -- seconds to wait from landing, before performing next action (jump)
                    waitForJump       = 1,    -- seconds to wait in drag mode before they jump (simulating working out jump)
                    reposition        = 30,   -- distance they will reposition themselves on a ledge by
                    dropTrapOnCatchup = true, -- will throw a trap on current ledge when it wait for player to cathup, just before it runs off again
                    tauntOnCatchup    = true, -- will perform taunt animation while waiting for player
                    traps = {                 -- traps AI has to throw (currently infinite)
                        {50,negTrajectory}, {100,negDizzy}
                    },
                },
            },
            [5] = {
                skin          = "Grey Enemy",
                model         = characterEarlGrey,
                inSpaceRace   = false,
                direction     = right,
                startLedge    = 1,
                lives         = 9999,
                waitingTimer  = 16,           -- 4 seconds before AI starts
                personality   = {
                    waitFromLand      = 3,    -- seconds to wait from landing, before performing next action (jump)
                    waitForJump       = 0,    -- seconds to wait in drag mode before they jump (simulating working out jump)
                    reposition        = 30,   -- distance they will reposition themselves on a ledge by
                    dropTrapOnCatchup = true, -- will throw a trap on current ledge when it wait for player to cathup, just before it runs off again
                    tauntOnCatchup    = true, -- will perform taunt animation while waiting for player
                    traps = {                 -- traps AI has to throw (currently infinite)
                        {50,negTrajectory}, {100,negDizzy}
                    },
                },
            },
        },]]
    },
}


function planetData:setDefaults(data)
    data.floor               = data.floor               or display.contentHeight
    data.ceiling             = data.ceiling             or -display.contentHeight
    data.defaultLedgeSize    = data.defaultLedgeSize    or big
    data.defaultRingColor    = data.defaultRingColor    or aqua
    data.defaultLedgeSurface = data.defaultLedgeSurface or stone
    data.defaultTheme        = data.defaultTheme        or "rocky"
    data.defaultLedgePoints  = data.defaultLedgePoints  or 100
    data.defaultCloudColor   = data.defaultCloudColor   or function(cloud) cloud:setFillColor(1, math.max(0.7, math.random()), 0.4) end
    data.defaultLedgeShake   = data.defaultLedgeShake   or {pattern={{0,20}, {0,-32}, {0,16}, {0,-4}}, delay=0, speed=4, oneWay=true}
    data.defaultRunSound     = "playerRunRock"
end


return planetData