local levelData = {
    name             = "stay up forever",
    timeBonusSeconds = 28,
    ceiling          = -1500,
    floor            = 1000,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {6, 5},
        [bgrBack]  = {},
        [bgrSky]   = {1, 2}
    },

    elements = {
        {object="ledge", type="start"},

        {object="ledge", x=500, y=200, size="small"},

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
            --[[
            {object="enemy", type="greyshooter", x=-600, y=-225, size=0.5, 
                shooting={minWait=2, maxWait=5, velocity={x=700, y=200, varyX=200, varyY=300}, itemsMax=10, ammo={negDizzy, negTrajectory}},
                movement={pattern=moveTemplateHorizontal, reverse=true, isTemplate=true, distance=800, speed=3, pause=500, moveStyle=moveStyleSwayBig, pauseStyle=moveStyleSwayBig}},
            ]]
          --[[  {object="enemy", type="greyshooter", x=450, y=-200, size=0.5,
                shooting={minWait=2, maxWait=5, velocity={x=700, y=200, varyX=200, varyY=300}, itemsMax=10, ammo={negDizzy, negTrajectory}},
                behaviour={mode=stateSleeping, awaken=2, range=3},--, atRange=stateResetting},
                movement={pattern=movePatternFollow, speed=1, pause=1000, moveStyle=moveStyleWave, pauseStyle=moveStyleWave}
            },
]]
        {object="ledge", x=500, y=-150, size="medium", movement={bobbingPattern=moveTemplateBobUp2, speed=1, distance=50}},
            {object="gear", type=gearTrajectory},

        {object="ledge", x=400, y=-150, size="medium", movement={bobbingPattern=moveTemplateBobUp1, speed=1, distance=50}},
                 {object="scenery", x=400, y=-325, rotation=20, type="fgflt-pole-1"},
       

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
            {object="rings", color=aqua, trajectory={x=50, y=-100, xforce=130, yforce=120, arc=40, num=3}},


        {object="obstacle", type="spacerocket", x=500, y=-150, angle=-20, takeoff="slow", force={1000,-700}, rotation={time=100, degrees=-1}},	    
                {object="scenery", x=2200, y=-500, rotation=-11, type="fgflt-pole-2"},

        {object="ledge", x=1700, y=-150, size="medium", movement={bobbingPattern=moveTemplateBobUp3, speed=1, distance=50}},
            {object="gear", type=gearTrajectory},

        {object="ledge", x=400, y=-150, size="medium", movement={bobbingPattern=moveTemplateBobUp2, speed=1, distance=50}},  

        {object="ledge", x=350, y=150, surface="exploding"},
            {object="rings", color=aqua, trajectory={x=30, y=-150, xforce=40, yforce=140, arc=40, num=3}},

        -- need glider to get to next ledge

        {object="ledge", x=275, y=-300, type="finish"}
    },
}

return levelData