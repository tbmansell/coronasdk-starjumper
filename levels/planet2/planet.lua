local planetData = {
    name         = "apocalypsoid",
    totalFuzzies = 22,
    gameUnlocks  = {
        [gameTypeTimeRunner]  = {stars=40},
        [gameTypeClimbChase]  = {stars=50},
        [gameTypeArcadeRacer] = {stars=60},
        [gameTypeSurvival]    = {fuzzies=7},
        [gameTypeTimeAttack]  = {fuzzies=14},
        [gameTypeRace]        = {fuzzies=21},
    },
    unlockFriend = characterHammer,
    unlockEnemy  = characterReneGrey,

    -- Story mode zone select scene markers:
    zones = {
        [1]  = { x=180,  y=360, hint={gearShield}},
        [2]  = { x=330,  y=465, hint={gearGlider}},
        [3]  = { x=500,  y=435, hint={gearShield,      gearGlider} },
        [4]  = { x=630,  y=370, hint={gearJetpack}},
        [5]  = { x=830,  y=420, hint={gearJetpack,     gearGrappleHook}},
        [6]  = { x=1010, y=360, hint={gearTrajectory,  gearJetpack,     gearGloves}},
        [7]  = { x=1180, y=285, hint={gearSpringShoes, gearShield,      gearGloves},      special=true},
        [8]  = { x=1350, y=350, hint={gearFreezeTime,  gearGlider,      gearGrappleHook}},
        [9]  = { x=1550, y=475, hint={gearTrajectory,  gearParachute}},
        [10] = { x=1690, y=425, hint={gearSpringShoes, gearParachute,   gearGloves}},
        [11] = { x=1820, y=350, hint={gearFreezeTime,  gearGrappleHook}},
        [12] = { x=1960, y=290, hint={gearFreezeTime,  gearParachute,   gearGrappleHook}},
        [13] = { x=2150, y=320, hint={gearJetpack,     gearReverseJump, gearGloves}},
        [14] = { x=2290, y=410, hint={gearShield,      gearReverseJump, gearGrappleHook}, special=true},
        [15] = { x=2450, y=450, hint={gearShield,      gearParachute,   gearGrappleHook}},
        [16] = { x=2605, y=355, hint={gearFreezeTime,  gearParachute,   gearGrappleHook}},
        [17] = { x=2800, y=230, hint={gearTrajectory,  gearJetpack,     gearGloves}},
        [18] = { x=2960, y=350, hint={gearTrajectory,  gearJetpack,     gearGloves}},
        [19] = { x=3180, y=485, hint={gearFreezeTime,  gearReverseJump, gearGrappleHook}},
        [20] = { x=3370, y=435, hint={gearSpringShoes, gearGlider,      gearJetpack}},
        [21] = { x=3550, y=330, hint={gearTrajectory,  gearGlider,      gearGloves},      special=true},
        -- secret zones:
        [22] = { x=4000, y=350, hint={gearParachute,   gearGloves,      gearGrappleHook}, secret=true},
        [23] = { x=4150, y=400, hint={gearTrajectory,  gearJetpack,     gearGloves},      secret=true},
        [24] = { x=4300, y=280, hint={gearFreezeTime,  gearGlider,      gearGrappleHook}, secret=true},
        [25] = { x=4375, y=450, hint={gearFreezeTime,  gearParachute,   gearJetpack},     secret=true},
        [26] = { x=4500, y=350, hint={gearFreezeTime,  gearParachute,   gearJetpack},     secret=true},


        
    },

    -- Story mode zone select scene - spine objects shown
    animated = {
        {object="friend", type="ufoboss", x=120, y=200, size=0.5, animation="Standard",
            movement={pattern=movePatternVertical, distance=40, reverse=true, speed=0.5, steering=steeringMild}
        },

        {object="obstacle", type="electricgate", x=295, y=430, size=0.5, timerOn=10000, timerOff=0},

        {object="enemy", type="greyufo", x=700, y=200, size=0.5, theme="space",
            movement={pattern=moveTemplateLeftArc, isTemplate=true, distance=50, speed=1, pause=1500, reverse=true, moveStyle=moveStyleSwayBig, pauseStyle=moveStyleSwayBig}
        },

        {object="friend", type="fuzzy", x=755, y=390, color="Pink", kinetic="hangDouble"},

        {object="obstacle", type="electricgate", x=1150, y=320, size=0.5, timerOn=10000, timerOff=0, antishield=true},

        {object="enemy", type="greynapper", skin="ring-stealer", x=1500, y=200, size=0.4, theme="space",
            movement={pattern=moveTemplateVertical, isTemplate=true, distance=50, reverse=true, speed=2, pause=3000, pauseStyle=moveStyleSwayBig, steering=steeringMild}
        },

        {object="enemy", type="greynapper", skin="fuzzy-napper", x=1750, y=150, size=0.4, theme="space",
            movement={pattern=moveTemplateVertical, isTemplate=true, distance=50, reverse=true, speed=2, pause=2000, steering=steeringMild}
        },

        {object="enemy", type="greyshooter", x=2085, y=300, size=0.4, theme="space",
            movement={pattern=moveTemplateVertical, isTemplate=true, reverse=true, distance=25, speed=3, pause=500, steering=steeringMild, moveStyle=moveStyleSwayBig, pauseStyle=moveStyleSwayBig},
            shooting={minWait=1, maxWait=3, velocity={x=700, y=200, varyX=100, varyY=100}, itemsMax=10, ammo={negTrajectory}},
        },

        {object="warpfield", x=2840, y=400, size=0.9, radius=1},

        {object="player", model=characterEarlGrey, x=3650, y=315, size=0.17, direction=left},
        {object="player", model=characterHammer,   x=3670, y=315, size=0.17, direction=left, animation="Seated", rescue=true},
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
        {name="space/space1", quietTime=0, minVolume=2, maxVolume=5},
        {name="space/space2", quietTime=0, minVolume=2, maxVolume=5},
    },

    -- Scenery element definitions
    sceneryDefs = {
        ["fg-rock-1"]                         = {image="fg-rock-1",                width=164, height=169, size=0.6, shape="circle"},
        ["fg-rock-2"]                         = {image="fg-rock-2",                width=164, height=169, size=0.6, shape="circle"},
        ["fg-rock-3"]                         = {image="fg-rock-3",                width=216, height=163, size=0.6, shape="circle"},
        ["fg-rock-4"]                         = {image="fg-rock-4",                width=197, height=184, size=0.6, shape="circle"},
        ["fg-rock-5"]                         = {image="fg-rock-5",                width=221, height=221, size=0.6, shape="circle"},
        ["fg-wall-divider"]                   = {image="fg-wall-divider",          width=107, height=900, size=0.8, shapeOffset={bottom=0}, botPull=-70, topPull=50},
        ["fg-wall-divider-halfsize"]          = {image="fg-wall-divider-halfsize", shapeOffset={bottom=0}, width=107, height=450, size=0.8},
        ["fg-spikes-float-1"]                 = {image="fg-spikes-float-1",        width=210, height=300, size=0.6, flipTop=true, shape={-80,-10, 80,-90, 80,110, -80,110}},
        ["fg-spikes-float-2"]                 = {image="fg-spikes-float-2",        width=114, height=351, size=0.6, flipTop=true, shape={-75,-100, 75,-100, -25,200}},
        ["fg-spikes-float-3"]                 = {image="fg-spikes-float-3",        width=179, height=340, size=0.6, flipTop=true, shape={-80,-100, 80,-40, 80,150, -80,150}},
        ["fg-spikes-float-4"]                 = {image="fg-spikes-float-4",        width=121, height=337, size=0.6, flipTop=true, shape={0,-140, 80,140, -80,140}},
        ["fg-spikes-float-5"]                 = {image="fg-spikes-float-5",        width=142, height=343, size=0.6, flipTop=true, shape={0,-150, 80,150, -80,150}},
        ["fg-wall-divider-spiked"]            = {image="fg-wall-divider-spiked",   width=107, height=900, size=0.8, shapeOffset={bottom=0}, botPull=-70, topPull=50},
        ["fg-wall-divider-halfsize-dbspiked"] = {image="fg-wall-divider-halfsize-dbspiked", shapeOffset={bottom=0}, width=107, height=450, size=0.8},
        ["fg-debris-helmet"]                  = {image="fg-debris-helmet",         width=224, height=316, size=0.25},
        ["fg-debris-barrel-blue"]             = {image="fg-debris-barrel-blue",    width=83,  height=114, size={5,7}},
        ["fg-debris-barrel-grey"]             = {image="fg-debris-barrel-grey",    width=83,  height=114, size={5,7}},
        ["fg-debris-barrel-red"]              = {image="fg-debris-barrel-red",     width=83,  height=114, size={5,7}},
        ["fg-barrel-blue"]                    = {image="fg-barrel-blue",           width=69,  height=95,  size={5,7}},
        ["fg-barrel-grey"]                    = {image="fg-barrel-grey",           width=69,  height=95,  size={5,7}},
        ["fg-barrel-red"]                     = {image="fg-barrel-red",            width=69,  height=95,  size={5,7}},
    },

    -- Characters active in this planets space race game
    spaceRace = {
        playerModel = characterNewton,
    },
}


function planetData:setDefaults(data)
    data.floor               = data.floor               or display.contentHeight+100
    data.ceiling             = data.ceiling             or -display.contentHeight
    data.defaultLedgeSize    = data.defaultLedgeSize    or big
    data.defaultRingColor    = data.defaultRingColor    or aqua
    data.defaultLedgeSurface = data.defaultLedgeSurface or girder
    data.defaultTheme        = data.defaultTheme        or "space"
    data.defaultLedgePoints  = data.defaultLedgePoints  or 100
    data.defaultCloudColor   = data.defaultCloudColor   or function(cloud) cloud:setFillColor(0.2, 0.2, math.max(0.4,math.random())) end
    data.defaultLedgeShake   = data.defaultLedgeShake   or {pattern={{0,50},{0,-50,speed=4}}, delay=0, speed=8, oneWay=true}
    data.defaultRunSound     = "playerRunMetal"
end


return planetData