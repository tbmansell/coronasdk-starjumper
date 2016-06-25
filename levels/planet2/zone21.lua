local utils = require("core.utils")


local levelData = {
    name             = "strobe runner",
    timeBonusSeconds = 90,
    ceiling          = -2700,
    floor            = 1000,
    aiRace           = true,
    playerStart      = playerStartWalk,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {14, 11},
        [bgrBack]  = {},
        [bgrSky]   = {2, 1}
    },

    backgroundSounds = {
        {name="space/space6", quietTime=3000, minVolume=3, maxVolume=4},
        {name="space/space1", quietTime=4000, minVolume=3, maxVolume=4},
    },

    elements = {
        {object="ledge", type="start"},
            {object="rings", color=aqua, trajectory={x=30, y=-200, xforce=85, yforce=155, arc=65, num=3}},

            {object="emitter", x=100, y=-900, timer={2000, 5000}, limit=nil, force={ {0, 200}, {100, 300}, {0, 360} }, 
                items={
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 7}} },
                    {100, {object="scenery", layer=4, type="fg-debris-barrel-red", size={6, 8}} },
                }
            },

        -- AI start
        -- Phase 1
        {object="ledge", x=320, y=-150, size="medbig2", rotation=-20, movement={bobbingPattern=moveTemplateBobDiamond3, speed=1, distance=50}},

            {object="player", type="ai", x=0, y=0, onLedge=true, model=characterEarlGrey, targetName="earlGrey", direction=left, waitingTimer=15, storyModeOnly=true,
                personality={waitFromLand=1, waitForJump=1, waitFromAttack=3, reposition=30, attackPlayer=true}
            },
            {object="enemy", type="greyufo", x=500, y=-1000, size=0.7, targetName="startShip" },
            
        {object="ledge", x=230, y=-200, size="big2"},
            {object="scenery", x=300, y=-400, type="fgflt-pole-1"},
            {object="warpfield", x=250, y=-150, size=0.5, radius=100, movement={steering=steeringMild, speed=2, pattern={{0,-300}, {575,0}, {0,300}, {0,-300}, {-575,0}, {0,300}}}},    

        {object="ledge", x=275, y=-220, size="big2", rotation=-20},
            {object="wall", x=456,  y=-842, type="fg-wall-divider-halfsize", copy=2, gap=647, physics={shapeOffset={bottom=0, left=0},   bounce=1}},            
            {object="wall", x=470,  y=-400, type="fg-wall-divider-completeup", physics={shapeOffset={bottom=-30, left=50},   bounce=1}},
            {object="rings", color=pink, pattern={ {500,-150}}},

        {object="ledge", x=275, y=180, size="medium", movement={bobbingPattern=moveTemplateBobUp2, speed=1, distance=50}},
            {object="scenery", x=300, y=-400, type="fgflt-pole-4"},

        {object="ledge", x=285, y=150, size="medium", movement={bobbingPattern=moveTemplateBobDown3, speed=1, distance=50}},
            
        {object="ledge", x=260, y=-200, size="medbig2", rotation=-15, ai={jumpVelocity={600,700}}},
            {object="rings", color=aqua, trajectory={x=100, y=-150, xforce=130, yforce=15, arc=40, num=3}},
            {object="wall", x=320,  y=-1275, type="fg-wall-divider", physics={shapeOffset={bottom=0, left=0},   bounce=1.5}},
            {object="wall", x=320,  y=-200, type="fg-wall-divider", physics={shapeOffset={bottom=0, left=0},   bounce=1.5}},    

            {object="emitter", x=0, y=600, timer={2000, 4000}, limit=nil, force={ {-400, 400}, {-100, -300}, {0, 360} }, 
                items={
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={2, 5}} },
                    {100, {object="scenery", layer=4, type="fg-debris-ufo-right", size={6, 8}} },
                }
            },

        -- Phase 2
        {object="ledge", x=500, y=0, size="medbig2", rotation=15},    

        {object="ledge", x=300, y=-150, surface=pulley, distance=250, speed=1, reverse="true"},
            {object="scenery", x=435, y=-400, type="fgflt-pole-2"},
            {object="wall",    x=-50, y=-450, type="fg-rock-4", size=1, rotation=-45, physics={shape="circle", friction=0.3, bounce=1}},
            {object="friend", type="fuzzy", x=15, y=-200, color="White", kinetic="hang", direction=left},

        {object="ledge", x=240, y=150, surface=pulley, distance=-150, speed=1, reverse="true"},
            {object="rings", color=red, pattern={ {250,-400}}},

        {object="ledge", x=320, y=-250, surface=pulley, distance=275, speed=2, reverse="true"},
            {object="scenery", x=340, y=-400, type="fgflt-pole-5"},
            {object="wall",    x=-50, y=-490, type="fg-rock-2", size=1, rotation=-45, physics={shape="circle", friction=0.3, bounce=1}},   
        
        {object="ledge", x=275, y=250, surface=pulley, distance=-225, speed=2, reverse="true"},       

        -- AI uses teleport
        {object="ledge", x=260, y=-200, size="medbig2", rotation=-15, ai={useSpecialAbility={after=3000, target=14, targetType="ledge"}}},     
            {object="rings", color=aqua, trajectory={x=30, y=-150, xforce=100, yforce=150, arc=50, num=5}},

        -- Phase 3
        {object="obstacle", x=250, y=-300, timerOn=1000, timerOff=1000, type="electricgate"},
            {object="wall", x=-53,  y=-750, type="fg-wall-divider-halfsize", physics={shapeOffset={bottom=0, left=0}, bounce=1}},
            {object="wall", x=-53,  y=190, type="fg-wall-divider", flip="y", physics={shapeOffset={bottom=0, left=0}, bounce=1}},
      
        {object="ledge", x=325, y=120, size="medbig2", rotation=15},

            {object="emitter", x=0, y=-750, timer={3000, 6000}, limit=nil, force={ {-500, 500}, {100, 300}, {0, 360} }, 
                items={
                    {10, {object="scenery", layer=4, type="fg-debris-barrel-blue", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-5", size={2, 8}} },
                    {100, {object="scenery", layer=4, type="fg-debris-barrel-grey", size={6, 8}} },
                }
            },               

        {object="ledge", x=300, y=-400, size="medium", canShake=false, ai={loadGear=gearGloves},
            movement={pattern={{0,800}}, reverse=true, speed=1, pause=0}
        },
            {object="wall", x=316,  y=-892, type="fg-wall-divider-halfsize", copy=2, gap=647, physics={shapeOffset={bottom=0, left=0},   bounce=1}},            
            {object="wall", x=330,  y=-450, type="fg-wall-divider-completeup", physics={shapeOffset={bottom=-30, left=50},   bounce=1}},
            {object="rings", color=blue, pattern={ {0,-120}}},

        {object="ledge", x=800, y=400, size="medium", canShake=false, positionFromLedge=14, ai={loadGear=gearGloves},
            movement={pattern={{0,-800}}, reverse=true, speed=1, pause=0}
        },

        {object="ledge", x=1300, y=-400, size="medium", canShake=false, positionFromLedge=14, ai={loadGear=gearGloves}, 
            movement={pattern={{0,800}}, reverse=true, speed=2, pause=0}
        },
            {object="rings", color=white, pattern={ {0,-120}}},

            {object="emitter", x=100, y=-800, timer={3000, 5000}, limit=nil, force={ {-200, 10}, {100, 300}, {0, 360} }, 
                items={
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 7}} },
                    {100, {object="scenery", layer=4, type="fg-debris-barrel-red", size={6, 8}} },
                }
            },

        {object="ledge", x=1700, y=400, size="medium", canShake=false, positionFromLedge=14, ai={loadGear=gearGloves}, 
            movement={pattern={{0,-800}}, reverse=true, speed=2, pause=0}
        },
            {object="wall", x=350,  y=-1350, type="fg-wall-divider", physics={shapeOffset={bottom=0, left=0}, bounce=1}},
            {object="rings", color=aqua, trajectory={x=30, y=-200, xforce=110, yforce=100, arc=50, num=3}},

        {object="ledge", x=340, y=-200, type="finish"},
            {object="scenery", x=-400, onLedge=true, type="fgflt-pole-4", size=0.5, layer=2},
            {object="player", type="scripted", x=-130, y=-178, model=characterHammer, direction=left, physicsBody="static", 
                animation="Death JUMP HIGH", dontLoop=true, targetName="hammer", storyModeOnly=true
            },
            {object="enemy", type="greyshooter", x=-200, y=-225, size=0.4, targetName="henchman", shooting={velocity={x=-100, y=-200}, itemsMax=0, ammo={negTrajectory}} },
        },

    customEvents = {
        -- Whizzes to skyanna and back, then brainiak summons 3 brains
        ["intro"] = {
            conditions   = {
                storyMode = true,
                zoneStart = true,
            },
            delay        = 1000,
            freezePlayer = true,
            action       = function(camera, player, source)
                local earlGrey = hud:getTarget("player", "earlGrey")
                local hammer   = hud:getTarget("player", "hammer")
                local ship     = hud:getTarget("enemy",  "startShip")

                hammer.lives = 0
                earlGrey.completedCallback = function() hud:triggerEvent("earlGreyWins", earlGrey) end
                earlGrey:pauseAi(true)

                if player.model == characterHammer then
                    hammer:hide()
                end
                
                after(1500, function()
                    camera:setFocus(hammer.image)

                    after(2000, function()
                        camera:setFocus(player.image)

                        after(1500, function()
                            hud:showStory("race-earlgrey-planet2-zone21", function()
                                earlGrey:animate("3 4 Stars")

                                transition.to(ship.image, {time=1500, x=player:x()+150, y=player:y()-250, transition=easing.inOutCirc, onComplete=function() 
                                    local negables = { {20,negTrajectory}, {40,negDizzy}, {70,negBooster}, {100,negRocket} }
                                    local forces   = { -200, -150, -100, -50, 0, 50, 100, 150, 200 }

                                    for i=1, 9 do
                                        local name    = utils.percentFrom(negables)
                                        local negable = hud.level:generateNegable(ship:x(), ship:y()+60, name)

                                        negable:applyForce(forces[i], 0)
                                    end

                                    hud:exitScript()
                                    earlGrey:pauseAi(false)
                                end})
                            end)
                        end)
                    end)
                end)
            end,
        },
        -- Brainiak arrives on the ledge first and the henchmen eat skyanna
        ["earlGreyWins"] = {
            conditions = {
                storyMode  = true,
                zoneFinish = true,
                player     = characterEarlGrey
            },
            freezePlayer = true,
            action       = function(camera, player, source)
                local player    = hud.player -- do this as if AI jumps on the ledge, they become the player loaded in
                local earlGrey  = hud:getTarget("player", "earlGrey")
                local henchman  = hud:getTarget("enemy",  "henchman")

                state.data.game = levelOverFailed

                camera:setFocus(earlGrey.image)

                after(1000, function() earlGrey:animate("3 4 Stars") end)
                after(3000, function()
                    player:animate("Seated")

                    hud:exitScript()
                    player:failedCallback()
                end)
            end,
        },
        ["playerWins"] = {
            conditions = {
                storyMode  = true,
                zoneFinish = true,
                player     = "main"
            },
            freezePlayer = true,
            action       = function(camera, player, source)
                local earlGrey = hud:getTarget("player", "earlGrey")
                local hammer   = hud:getTarget("player", "hammer")
                local henchman = hud:getTarget("enemy",  "henchman")

                state.data.game = levelOverComplete

                earlGrey:pauseAi(true)

                after(2000, function()
                    earlGrey:animate("Seated")
                    
                    hammer.physicsBody = nil
                    hammer.mode        = playerFall
                    hammer:setPhysicsFilter()

                    after(1500, function()
                        hammer:animate("Attack GRAB")
                        henchman:setMovement(camera, {pattern={{500,-350}}, speed=15})
                        henchman:applySpin(-100)
                    end)
                    after(2000, function() henchman:move() end)
                    after(3500, function()
                        player:animate("3 4 Stars")
                        hammer:animate("3 4 Stars")
                        hud:exitScript()
                    end)
                end)
            end,
        },
    },
}

return levelData