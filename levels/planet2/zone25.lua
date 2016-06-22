local levelData = {
    name             = "time to escape",
    timeBonusSeconds = 220,
    ceiling          = -4000,
    floor            = 2500,
    startLedge       = 10,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {6, 15, 9, 7},
        [bgrBack]  = {},
        [bgrSky]   = {2, 1}
    },

    elements = {
        {object="ledge", type="start"},

            {object="emitter", x=0, y=300, timer={3000, 6000}, limit=5, 
                items={
                    {50, {object="livebgr", type="greyother", skin="shooter", imagePath="enemies/space/greyother", size={0.5, 0.4, 0.3, 0.2}, modifyImage={0.5, 0.5, 0.5},
                          movement={rangeX={10000, 20000}, rangeY={-10000, -20000}, speed={4, 3, 2, 1}, oneWay=true}}
                    },
                    {100, {object="livebgr", type="greyufo", imagePath="enemies/space/greyufo", size={0.5, 0.4, 0.3, 0.2}, modifyImage={0.5, 0.5, 0.5},
                           movement={rangeX={10000, 20000}, rangeY={-10000, -20000}, speed={4, 3, 2, 1}, oneWay=true}}
                    }
                }
            },

            {object="emitter", x=1500, y=300, timer={3000, 6000}, limit=5, 
                items={
                    {50, {object="livebgr", type="greyother", skin="shooter", imagePath="enemies/space/greyother", size={0.5, 0.4, 0.3, 0.2}, modifyImage={0.5, 0.5, 0.5},
                          movement={rangeX={10000, 20000}, rangeY={-10000, -20000}, speed={4, 3, 2, 1}, oneWay=true}}
                    },
                    {100, {object="livebgr", type="greyufo", imagePath="enemies/space/greyufo", size={0.5, 0.4, 0.3, 0.2}, modifyImage={0.5, 0.5, 0.5},
                           movement={rangeX={10000, 20000}, rangeY={-10000, -20000}, speed={4, 3, 2, 1}, oneWay=true}}
                    }
                }
            },

            {object="emitter", x=3000, y=300, timer={3000, 6000}, limit=5, 
                items={
                    {50, {object="livebgr", type="greyother", skin="shooter", imagePath="enemies/space/greyother", size={0.5, 0.4, 0.3, 0.2}, modifyImage={0.5, 0.5, 0.5},
                          movement={rangeX={10000, 20000}, rangeY={-10000, -20000}, speed={4, 3, 2, 1}, oneWay=true}}
                    },
                    {100, {object="livebgr", type="greyufo", imagePath="enemies/space/greyufo", size={0.5, 0.4, 0.3, 0.2}, modifyImage={0.5, 0.5, 0.5},
                           movement={rangeX={10000, 20000}, rangeY={-10000, -20000}, speed={4, 3, 2, 1}, oneWay=true}}
                    }
                }
            },

            {object="spike", x=400, y=-700, type="fg-spikes-float-1", flip="y", size=0.7, physics={shape={0,-120, 90,130, -100,70}}, movement={bobbingPattern=moveTemplateBobDown2, isTemplate=true, speed=1, distance=25}},

        {object="ledge", x=300, y=-150, surface=ramp, movement={bobbingPattern=moveTemplateBobUp1, speed=1, distance=50}},
            {object="spike", x=250, y=-280, type="fg-spikes-float-1", size=0.7, physics={shape={-100,-70, 90,-130, 0,120}}, movement={bobbingPattern=moveTemplateBobUp2, isTemplate=true, speed=1, distance=25}},

        {object="ledge", x=400, y=0, surface=ramp, flip="x", movement={bobbingPattern=moveTemplateBobDown1, speed=1, distance=50}},

        {object="ledge", x=400, y=-150, surface=pulley, distance=-600, speed=3, rotation=-10},
            {object="wall", x=250, y=-500,  type="fg-wall-divider-spiked"},
            {object="wall", x=250, y=-1900, type="fg-wall-divider-spiked"},

        {object="ledge", x=400, y=-600, surface=pulley, distance=600, speed=3, rotation=15},

        {object="ledge", x=300, y=-150, size=small, rotation=-5},

        {object="ledge", x=0, y=750, size=small, rotation=5, positionFromCenter=true},

        {object="ledge", x=500, y=-100, surface=electric, rotation=-10, movement={bobbingPattern=moveTemplateBobDown1, speed=1, distance=50}},

        {object="ledge", x=400, y=-100, surface=collapsing, rotation=5, movement={bobbingPattern=moveTemplateBobUp2, speed=1, distance=50}},

        {object="ledge", x=350, y=-250, size="medium2"},

        {object="ledge", x=-300, y=-220, surface=collapsing, rotation=-7, movement={bobbingPattern=moveTemplateBobUp3, speed=1, distance=50}},

        {object="ledge", x=500, y=-220, surface=exploding, rotation=10, movement={bobbingPattern=moveTemplateBobUp3, speed=1, distance=50}},

        {object="ledge", x=200, y=-280, size="medium2", flip="x", rotation=-15},
            {object="wall", x=250, y=0,     type="fg-wall-divider-spiked"},
            {object="wall", x=250, y=-1200, type="fg-wall-divider-spiked"},

        {object="ledge", x=250, y=0, surface=exploding},

        {object="ledge", x=150, y=0, surface=exploding},

        {object="ledge", x=300, y=150, size="medium3", movement={bobbingPattern=moveTemplateBobDown3, speed=1, distance=50}},
        
        
        {object="ledge", x=2500, y=-200, type="finish"},
        
    },
}

return levelData