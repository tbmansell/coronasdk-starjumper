local levelData = {
    name             = "tricks and traps",
    timeBonusSeconds = 70,
    ceiling          = -(display.contentHeight*3) + 100,
    defaultLedgeSize = medium,
    startAtNight     = true,
    turnDay          = true,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {2, 3, 4, 1},
        [bgrMid]   = {1, 1, 1, 1},
        [bgrBack]  = {3, 4, 1, 2},
        [bgrSky]   = {1, 2}
    },

    elements = {
        {object="ledge", type="start"},
            {object="scenery", x=100, onLedge=true, type="fg-foilage-3-green",  layer=4, size=0.4, copy=5},
            {object="scenery", x=100, onLedge=true, type="fg-flowers-3-yellow", layer=2},
            {object="scenery", x=190, onLedge=true, type="fg-flowers-3-green",  size=0.4, layer=2, rotation=-5, flip="x"},
            {object="scenery", x=250, onLedge=true, type="fg-flowers-3-yellow", size=0.4, layer=2, rotation=15},

        {object="ledge", x=300, y=-100, size="medium3"},
            {object="randomizer", onLedge=true, items={{100,gearReverseJump}}},

        {object="ledge", x=300, y=-200, size="big3", rotation=-15, triggerLedgeIds={5}, triggerEvent="brainiakTrap"},
            -- top row of blocks
            {object="scenery", x=-100, y=355, type="fg-wall-left"},
            {object="scenery", x=0,    y=355, type="fg-wall-middle"},
            {object="scenery", x=380,  y=355, type="fg-wall-right"},
            -- bottom row of blocks
            {object="scenery", x=-400, y=455, type="fg-wall-left"},
            {object="scenery", x=-300, y=455, type="fg-wall-middle", copy=3},
            {object="scenery", x=840,  y=455, type="fg-wall-right"},
            -- gap for falling rock
            {object="scenery", x=1500, y=455, type="fg-wall-left"},
            {object="scenery", x=1600, y=455, type="fg-wall-middle", copy=3},
            {object="scenery", x=2740, y=455, type="fg-wall-right"},

            {object="emitter", x=0, y=-125, timer={1000, 3000}, limit=3, layer=4,
                item={
                    object="livebgr", type="brain", color="Purple", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.2, 0, 0.3},
                    movement={rangeX={-300, 600}, rangeY={-205, 75}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },

        {object="ledge", x=25, y=-175, size="big", rotation=-45, ai={ignore=true}},

        -- #5
        {object="ledge", x=0, y=-250, positionFromCenter=true, surface="collapsing", targetName="trapLedge", ai={ignore=true}},
            {object="spike", x=-150, y=-160, type="fg-rock-1", size=0.6, rotation=-45, physics={body="dynamic", shape="circle", friction=0.3, bounce=0.4}},
            {object="spike", x=-30,  y=-160, type="fg-rock-2", size=0.6, rotation=-45, physics={body="dynamic", shape="circle", friction=0.3, bounce=0.4}},

        {object="ledge", x=-500, y=170},
            {object="spike", x=-450, y=-300, type="fg-spikes-float-1"},

        {object="ledge", x=150, y=-240},
            {object="randomizer", onLedge=true, items={{100,negBooster}}},

        -- rock fall between ledges
        {object="ledge", x=450, y=0, size="big2"},
            {object="player", type="scripted", model=characterBrainiak, x=-140, y=0, direction=left, targetName="brainiak"},

            {object="scenery", x=-130, y=-105, type="fg-foilage-3-green", layer=2, size=0.4, copy=5, gap=-30, onLedge=true},
            {object="rings", color=aqua, trajectory={x=50, y=-100, xforce=150, yforce=150, arc=65, num=5}},
            
            -- EMITTER
            {object="emitter", x=370, y=-1600, timer=4000, limit=nil, force={0,0,-45}, emitFrom={0, -100},
                item={object="wall", type="fg-rock-3", size=0.6, physics={body="dynamic", shape="circle", friction=0.3, bounce=0.4}}
            },

        {object="ledge", x=550, y=0, size="big2", flip="x"},
            {object="scenery", x=-130, y=-105, type="fg-foilage-3-yellow", layer=2, size=0.5, copy=3, gap=-10, onLedge=true},
            {object="scenery", x=-200, y=100,  type="fg-wall-double-l1", layer=2},
            {object="scenery", x=55,   y=-100, type="fg-spikes-5", size=0.6, layer=2},
            {object="scenery", x=115,  y=-100, type="fg-spikes-5", size=0.6, layer=2, flip="x"},

        -- #10
        {object="ledge", x=450, y=-200, size="big", invisible={invisibleFor=5000, visibleFor=100, alpha=0.1}},

        {object="ledge", x=-300, y=-200, positionFromLedge=10, size="medium", invisible={invisibleFor=3000, visibleFor=100, alpha=0.1}},

        {object="ledge", x=-250, y=-200, size="medium", invisible={invisibleFor=5500, visibleFor=200, alpha=0.1}},
            {object="friend", type="fuzzy", color="Orange", onLedge=true},
            
            {object="emitter", x=0, y=-350, timer={1000, 3000}, limit=3, layer=4,
                item={
                    object="livebgr", type="brain", color="Purple", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.3, 0, 0.4},
                    movement={rangeX={-600, 600}, rangeY={-300, 150}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },

        {object="ledge", x=-500, y=0, size="big3", flip="x"},
            {object="randomizer", onLedge=true, items={{100,blue}}},

        {object="ledge", x=-250, y=-150, rotation=25},
            {object="rings", color=aqua, trajectory={x=50, y=-200, xforce=50, yforce=150, arc=45, num=5}},
            {object="spike", x=-450, y=-300, type="fg-spikes-float-1"},
            {object="spike", x=-450, y=-700, type="fg-spikes-float-1", flip="y"},
            
            {object="enemy", type="heart", x=0, y=160, size=0.5, color="White",
                behaviour={mode=stateWaiting, awaken=0, range=25, atRange=stateResetting, thefts=20},
                movement={pattern=movePatternFollow, speed=4, pause=500, pauseStyle=moveStyleWaveBig}
            },

        {object="ledge", x=250, y=-250},
            {object="scenery", x=-500,  y=-500, type="fg-wall-l2", flip="y", layer=3},
            {object="scenery", x=650,   y=-500, type="fg-wall-l2", flip="y", layer=3},

        {object="obstacle", x=200, y=-250, type="deathslide", length={800,0}, speed=5, animSpeed="SLOW"},

        {object="ledge", x=0, y=250, surface="lava"},
            {object="rings", color=pink, trajectory={x=100, y=-100, xforce=100, yforce=20, arc=45, num=3}},

        {object="ledge", x=430, y=100, rotation=-15},
            {object="rings", color=red, trajectory={x=100, y=-100, xforce=200, yforce=150, arc=45, num=5}},

            {object="scenery", x=900, y=-450, type="fg-tree-6-yellow", layer=3},
        {object="ledge", x=500, y=100, type="finish"}
    },

    -- Brainiak: taunts player next to rock trap before it collapse then runs off
    customEvents = {
        ["brainiakTrap"] = {
            delay        = 500,
            freezePlayer = true,
            action       = function(camera, player, source)
                local brainiak = hud:getTarget("player", "brainiak")

                sounds:loadPlayer(characterBrainiak)

                camera:setFocus(brainiak.image)
                brainiak:taunt()

                after(2000, function() 
                    camera:setFocus(player.image)
                    hud:exitScript()

                    brainiak:setIndividualGear(gearJetpack)
                    brainiak:runup(-700, -700)

                    after(1000, function()
                        brainiak:destroy()
                    end)
                end)
            end,
        },
    }
}

return levelData