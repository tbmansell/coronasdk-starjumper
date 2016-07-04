local utils = require("core.utils")

local levelData = {
    name             = "stay up forever",
    timeBonusSeconds = 140,
    ceiling          = -1500,
    floor            = 1000,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {6, 5},
        [bgrBack]  = {},
        [bgrSky]   = {1, 2}
    },

    backgroundSounds = {
        {name="space/space8", quietTime=3000, minVolume=3, maxVolume=4},
        {name="space/space9", quietTime=8000, minVolume=4, maxVolume=6},
    },

    elements = {
        {object="ledge", type="start"},

            {object="player", x=0, y=-300, type="scripted", model=characterEarlGrey, targetName="earlGrey", storyModeOnly=true, direction=right,
                physicsBody="static", loadGear={gearJetpack}, animation="Powerup PARACHUTE",
                movement={pattern=movePatternFollow, offsetY=-200, speed=5, pause=500, moveStyle=moveStyleSwayBig, pauseStyle=moveStyleSwayBig},
            },

        {object="ledge", x=500, y=200, size="small"},

        {object="ledge", x=500, y=200, size="big"},
            {object="emitter", x=100, y=-800, timer={3000, 6000}, limit=nil, force={ {0, 200}, {100, 300}, {0, 45} }, 
                items={
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={2, 5}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-right", size={6, 8}} },
                }
            },
            {object="emitter", x=-100, y=500, timer={3000, 6000}, limit=nil, force={ {0, 400}, {-100, -300}, {45, 180} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-ufo-left", size={6, 9}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={4, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 7}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-right", size={6, 11}} },
                }
            },
                      
        {object="ledge", x=500, y=-150, surface="exploding"},
            {object="rings", color=aqua, trajectory={x=30, y=-200, xforce=110, yforce=170, arc=65, num=3}},
        
        {object="ledge", x=470, y=-150, size="medsmall"},
            {object="spike", x=-330, y=-220, size=0.6, type="fg-spikes-float-1", physics={shape={-80,-10, 80,-90, 80,110, -80,110}}},
            {object="spike", x=200,  y=-300, size=0.6, type="fg-spikes-float-1", physics={shape={-80,-10, 80,-90, 80,110, -80,110}}},
            
        {object="ledge", x=500, y=-150, size="medium", movement={bobbingPattern=moveTemplateBobUp2, speed=1, distance=50}},
            {object="gear", type=gearTrajectory},

        {object="ledge", x=400, y=-150, size="medium", movement={bobbingPattern=moveTemplateBobUp1, speed=1, distance=50}, triggerEvent="rescue"},
            {object="scenery", x=400, y=-325, rotation=20, type="fgflt-pole-1"},

            {object="player", x=400, y=-300, type="scripted", model=characterReneGrey, targetName="reneGrey", storyModeOnly=true, direction=left,
                physicsBody="static", loadGear={gearGlider, gearShield}, animation="Powerup GLIDER",
            },

        {object="ledge", x=300, y=-150, surface="electric"},
            {object="rings", color=aqua, trajectory={x=50, y=-175, xforce=150, yforce=30, arc=45, num=3}},
       
        {object="ledge", x=300, y=-150, surface="ramp"},
            {object="rings", color=blue, pattern={ {950,100}}},

            {object="emitter", x=300, y=-699, timer={3000, 6000}, limit=nil, force={ {-400, 400}, {100, 300}, {0, 45} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={3, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-4", size={5, 8}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-right", size={6, 8}} },
                }
            },        
            
-- 1) set up jump     
            {object="wall", x=900,  y=-1000, type="fg-wall-divider", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="wall", x=900,  y=300, type="fg-wall-divider", physics={shapeOffset={bottom=0, left=0},   bounce=1}},     

-- Jet pack             
        {object="ledge", x=310, y=175, size="small2"},
            {object="gear", type=gearJetpack, x=-30, y=-150, onLedge=true, regenerate=false},
            {object="spike", x=120, y=-220, type="fg-spikes-float-3", size=0.7, physics={shape={-80,-100, 80,-40, 80,150, -80,150}}},

-- Landing
        {object="ledge", x=1300, y=50, surface="ramp"},
            {object="rings", color=white, pattern={ {950,-460}}},

            {object="emitter", x=-500, y=699, timer={3000, 6000}, limit=nil, force={ {-400, 400}, {-100, -300}, {45, 95} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={4, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-4", size={4, 8}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-left", size={6, 8}} },
                }
            },
            {object="emitter", x=0, y=-800, timer={3000, 6000}, limit=nil, force={ {200, 400}, {100, 300}, {45, 90} }, 
                items={
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={2, 5}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-right", size={6, 8}} },
                }
            },
            
-- 2) set up jump     
            {object="wall", x=900,  y=-1600, type="fg-wall-divider", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="wall", x=900,  y=-300, type="fg-wall-divider", physics={shapeOffset={bottom=0, left=0},   bounce=1}},     
            {object="wall", x=1400,  y=-650, type="fg-rock-2", size=1.4, rotation=-45, physics={shape="circle", friction=0.3, bounce=0.4}},

-- Jet pack             
        {object="ledge", x=310, y=175, size="small2"},
            {object="gear", type=gearJetpack, x=-30, y=-150, onLedge=true, regenerate=false},
            {object="spike", x=120, y=-220, type="fg-spikes-float-3", size=0.7, physics={shape={-80,-100, 80,-40, 80,150, -80,150}}},

-- Landing
          
        {object="ledge", x=1500, y=-200, size="big2"},              

        {object="ledge", x=300, y=-150, size="small3", movement={bobbingPattern=moveTemplateBobUp1, speed=1, distance=50}},

        {object="ledge", x=270, y=225, size="small2", movement={bobbingPattern=moveTemplateBobUp2, speed=1.5, distance=50}},

            {object="enemy", type="greynapper", skin="ring-stealer", x=0, y=-550, size=0.5,
                movement={pattern=moveTemplateVertical, isTemplate=true, distance=100, reverse=true, speed=2.5, pause=3000, pauseStyle=moveStyleSwayBig, --[[steering=steeringMild]]}
            },

        {object="ledge", x=325, y=-210, size="small3", movement={bobbingPattern=moveTemplateBobUp3, speed=1, distance=50}},        

        {object="ledge", x=300, y=-150, surface="electric"},   
            {object="rings", color=aqua, trajectory={x=50, y=-150, xforce=130, yforce=130, arc=40, num=3}},


        {object="obstacle", type="spacerocket", x=500, y=-170, angle=-30, takeoff="slow", force={1400,-1000}, rotation={time=100, degrees=-1}},	    
                {object="scenery", x=2200, y=-500, rotation=-11, type="fgflt-pole-2"},

        {object="ledge", x=1700, y=-150, size="medium", movement={bobbingPattern=moveTemplateBobUp3, speed=1, distance=50}},
            {object="gear", type=gearTrajectory},
            {object="wall", x=350,  y=-650, type="fg-rock-1", size=.8, rotation=-45, physics={shape="circle", friction=0.3, bounce=0.4}},    

        {object="ledge", x=400, y=-150, size="medium", movement={bobbingPattern=moveTemplateBobUp2, speed=1, distance=50}},  

        {object="ledge", x=350, y=150, surface="exploding"},
            {object="rings", color=aqua, trajectory={x=30, y=-150, xforce=40, yforce=140, arc=40, num=3}},

        -- need glider to get to next ledge

        {object="ledge", x=275, y=-300, type="finish"}
    },

    customEvents = {
        -- EarlGrey: creates the function which triggers has action each time he reaches the player
        ["setupGreys"] = {
            conditions   = {
                storyMode = true,
                zoneStart = true,
            },
            delay        = 1000,
            action       = function(camera, player, source)
                local earlGrey = hud:getTarget("player", "earlGrey")
                local reneGrey = hud:getTarget("player", "reneGrey")

                reneGrey:hide()

                function earlGrey:reachedPatternPoint() 
                    local player  = self.mainPlayerRef
                    local playerX = player:x()
                    local earlX   = self:x()
                    local earlDir = self.direction
                    
                    -- check if should change direction:
                    if earlX < playerX and earlDir == left then
                        self:changeDirection(right)

                    elseif earlX > playerX and earlDir == right then
                        self:changeDirection(left)
                    end

                    -- show jetpack flame (only show on right as position incorrect on left):
                    if earlDir == left then
                        self:sound("gearJetpack")
                        self:showJetpack()
                    end

                    -- check if should drop a negable:
                    if not self.waitingForNextDrop then
                        self.waitingForNextDrop = true

                        self:sound("randomCelebrate")

                        local negName = utils.percentFrom({ {20,negTrajectory}, {40,negDizzy}, {70,negBooster}, {100,negRocket} })
                        local negable = hud.level:generateNegable(self:x(), self:y() + 60, negName)

                        -- Check if should drop it on player or throw it slightly in front
                        if math.random(2) == 2 then
                            local force = 100
                            if self.direction == right then force = -force end
                            negable:applyForce(-100,0)
                        end

                        after(3000, function() self.waitingForNextDrop=false end)
                    end
                end
                
                hud:exitScript()
            end,
        },
        -- ReneGrey appears and sees off EarlGrey
        ["rescue"] = {
            conditions   = {
                storyMode = true,
                playerNot = characterEarlGrey,
            },
            freezePlayer = true,
            delay        = 1000,
            action       = function(camera, player, source)
                local earlGrey = hud:getTarget("player", "earlGrey")
                local reneGrey = hud:getTarget("player", "reneGrey")

                reneGrey:visible()
                earlGrey:stop()
                camera:setFocus(earlGrey.image)

                after(500, function()
                    if earlGrey.direction == left then
                        earlGrey:changeDirection()
                    end

                    earlGrey:sound("randomWorry")
                    player:sound("gearAir")  -- run sound off player as scripted player may be too far away from player to hear sound

                    after(1350, function() earlGrey:emit("usegear-red") end)

                    transition.to(reneGrey.image, {time=1500, x=earlGrey:x()+75, y=earlGrey:y(), transition=easing.inOutQuart, onComplete=function() 
                        player:sound("randomImpact")
                        camera:setFocus(reneGrey.image)

                        hud:showStory("rescue-renegrey-planet2-zone17", function()
                            earlGrey:loop("Death JUMP NEAR EDGE")
                            earlGrey:setMovement(camera, {pattern={{-3000,-3000}}, speed=10})
                            reneGrey:setMovement(camera, {pattern={{-3000,0}},     speed=5})
                            earlGrey:move()
                            reneGrey:move()
                            
                            after(1500, function() 
                                camera:setFocus(player.image)
                                hud:exitScript()
                            end)
                            after(2500, function()
                                earlGrey:destroy()
                                reneGrey:destroy()
                            end)
                        end)
                    end})
                end)
            end,
        },
    }
}

return levelData