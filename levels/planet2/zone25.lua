-- All emitters on this zone generate fleeing grey ufos
local emitterItems = {
    {50, {object="livebgr", type="greyother", skin="shooter", imagePath="enemies/space/greyother", size={0.5, 0.4, 0.3, 0.2}, modifyImage={0.5, 0.5, 0.5},
          movement={rangeX={10000, 20000}, rangeY={-10000, -20000}, speed={4, 3, 2, 1}, oneWay=true}}
    },
    {100, {object="livebgr", type="greyufo", imagePath="enemies/space/greyufo", size={0.4, 0.3, 0.2, 0.1}, modifyImage={0.5, 0.5, 0.5},
           movement={rangeX={10000, 20000}, rangeY={-10000, -20000}, speed={4, 3, 2, 1}, oneWay=true}}
    }
}


local levelData = {
    name             = "escape apocalypse",
    timeBonusSeconds = 150,
    ceiling          = -4000,
    floor            = 2500,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {6, 15, 9, 7},
        [bgrBack]  = {},
        [bgrSky]   = {2, 1}
    },

    backgroundSounds = {
        {name="space/space8", quietTime=4000, minVolume=3, maxVolume=4},
        {name="space/space9", quietTime=6000, minVolume=3, maxVolume=4},
    },

    elements = {
        {object="ledge", type="start"},
            {object="scenery", x=100, y=-230, type="fg-debris-barrel-blue", size=0.7, rotation=90,  layer=2},
            {object="scenery", x=180, y=-230, type="fg-debris-barrel-red",  size=0.7, rotation=90,  layer=2},
            {object="scenery", x=240, y=-243, type="fg-debris-barrel-grey", size=0.7, rotation=-45, layer=2},
            {object="scenery", x=400, y=-230, type="fg-debris-barrel-blue", size=0.7, rotation=90,  layer=2},

            {object="emitter", x=0,    y=300, timer={3000, 6000}, limit=5, items=emitterItems},
            {object="emitter", x=2000, y=300, timer={3000, 6000}, limit=5, items=emitterItems},
            {object="emitter", x=4000, y=300, timer={3000, 6000}, limit=5, items=emitterItems},
            {object="emitter", x=6000, y=300, timer={3000, 6000}, limit=5, items=emitterItems},

            {object="spike", x=400, y=-700, type="fg-spikes-float-1", flip="y", size=0.7, physics={shape={0,-120, 90,130, -100,70}}, movement={bobbingPattern=moveTemplateBobDown2, isTemplate=true, speed=1, distance=25}},

        {object="ledge", x=300, y=-150, surface=ramp, movement={bobbingPattern=moveTemplateBobUp1, speed=1, distance=50}},
            {object="rings", color=aqua, trajectory={x=100, y=-200, xforce=60, yforce=200, arc=85, num=7}},
            {object="spike", x=250, y=-280, type="fg-spikes-float-1", size=0.7, physics={shape={-100,-70, 90,-130, 0,120}}, movement={bobbingPattern=moveTemplateBobUp2, isTemplate=true, speed=1, distance=25}},

        {object="ledge", x=400, y=0, surface=ramp, flip="x", movement={bobbingPattern=moveTemplateBobDown1, speed=1, distance=50}},
            {object="scenery", x=250,  y=-350, type="fgflt-pole-1", layer=2},
            {object="scenery", x=1350, y=-350, type="fgflt-pole-1", layer=2},

        {object="ledge", x=400, y=-150, surface=pulley, distance=-600, speed=3, rotation=-10},
            {object="rings", color=aqua, trajectory={x=50, y=-650, xforce=130, yforce=60, arc=40, num=5}},
            {object="wall", x=250, y=-500,  type="fg-wall-divider-spiked"},
            {object="wall", x=250, y=-1900, type="fg-wall-divider-spiked"},

        {object="ledge", x=400, y=-600, surface=pulley, distance=600, speed=3, rotation=15},

        {object="ledge", x=300, y=-150, size=small, rotation=-5},
            {object="randomizer", onLedge=true, spawn=2, items={ {50,gearFreezeTime},{100,gearParachute} }},
            {object="spike", x=150, y=-350, type="fg-spikes-float-5", physics={shape={35,-140, 70,90, -80,90}}},

        {object="ledge", x=0, y=750, size=small, rotation=5, positionFromCenter=true},

        {object="ledge", x=500, y=-100, surface=electric, rotation=-10, movement={bobbingPattern=moveTemplateBobDown1, speed=1, distance=50}},

        {object="ledge", x=400, y=-100, surface=collapsing, rotation=5, movement={bobbingPattern=moveTemplateBobUp2, speed=1, distance=50}},

        {object="ledge", x=350, y=-250, size="medium2"},
            {object="scenery", x=250,  y=-550, type="fgflt-pole-4", layer=2},

        {object="ledge", x=-300, y=-220, surface=collapsing, rotation=-7, movement={bobbingPattern=moveTemplateBobUp3, speed=1, distance=50}},
            {object="rings", color=aqua, trajectory={x=100, y=-100, xforce=50,  yforce=35,  arc=60, num=5}},
            {object="rings", color=aqua, trajectory={x=210, y=-250, xforce=140, yforce=140, arc=60, num=5}},

        {object="ledge", x=500, y=-220, surface=exploding, rotation=10, movement={bobbingPattern=moveTemplateBobUp3, speed=1, distance=50}},

        {object="ledge", x=200, y=-280, size="medium2", flip="x", rotation=-15},
            {object="wall", x=250, y=0,     type="fg-wall-divider-spiked"},
            {object="wall", x=250, y=-1200, type="fg-wall-divider-spiked"},

        {object="ledge", x=250, y=0, surface=exploding},
            {object="rings", color=red, trajectory={x=25, y=-100, xforce=50, yforce=70, arc=55, num=3}},

        {object="ledge", x=150, y=0, surface=exploding},

        {object="ledge", x=300, y=150, size="medium3", movement={bobbingPattern=moveTemplateBobDown3, speed=1, distance=50}},

        {object="ledge", x=400, y=0, surface=pulley, distance=1500, speed=5, rotation=5},
            {object="rings", color=aqua, trajectory={x=25, y=-100, xforce=100, yforce=100, arc=55, num=5}},
            {object="wall", x=250, y=0,     type="fg-wall-divider-spiked"},
            {object="wall", x=250, y=-1400, type="fg-wall-divider-spiked"},

        {object="ledge", x=350, y=0, surface=pulley, distance=1500, speed=5, rotation=-5},
            {object="rings", color=aqua, trajectory={x=25, y=-125, xforce=170, yforce=115, arc=65, num=7}},
            {object="wall", x=350, y=0,     type="fg-wall-divider-spiked"},
            {object="wall", x=350, y=-1400, type="fg-wall-divider-spiked"},

        {object="ledge", x=550, y=0, surface=pulley, distance=1500, speed=5, rotation=5},

        {object="ledge", x=550, y=0, size="big3", rotation=-15},

        {object="ledge", x=150, y=-300, size="medsmall2", movement={bobbingPattern=moveTemplateBobDown1, speed=1, distance=50}},
            {object="wall", x=250, y=-700, type="fg-wall-divider-halfsize-dbspiked", rotation=-13, movement={bobbingPattern=moveTemplateBobDown2, speed=1, distance=50}},

        {object="ledge", x=350, y=150, size="medsmall3", movement={bobbingPattern=moveTemplateBobUp1, speed=1, distance=50}},
            {object="wall", x=450, y=-500, type="fg-wall-divider-halfsize-dbspiked", rotation=7,  movement={bobbingPattern=moveTemplateBobUp2, speed=1, distance=50}},
            {object="wall", x=150, y=-100, type="fg-wall-divider-halfsize-dbspiked", rotation=20, movement={bobbingPattern=moveTemplateBobDown2, speed=1, distance=50}},

        {object="ledge", x=350, y=250, size="medsmall3", movement={bobbingPattern=moveTemplateBobDown1, speed=1, distance=50}},
            {object="wall", x=250, y=-200, type="fg-wall-divider-halfsize-dbspiked", rotation=-15, movement={bobbingPattern=moveTemplateBobDown2, speed=1, distance=50}},

        {object="ledge", x=450, y=-250, size="medbig3", movement={bobbingPattern=moveTemplateBobDown1, speed=1, distance=50}},
            {object="wall", x=300, y=-700, type="fg-wall-divider-halfsize-dbspiked", rotation=55},
        
        {object="ledge", x=500, y=-200, type="finish"},
    },
}

return levelData