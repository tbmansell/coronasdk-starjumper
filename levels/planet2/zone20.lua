local levelData = {
    name             = "a day at the races",
    timeBonusSeconds = 132,
    ceiling          = -2700,
    floor            = 1000,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {10, 18},
        [bgrBack]  = {},
        [bgrSky]   = {2, 1}
    },

    backgroundSounds = {
        {name="space/space1", quietTime=2000, minVolume=3, maxVolume=4},
        {name="nature/wind4", quietTime=4000, minVolume=1, maxVolume=2},
    },

    elements = {
        {object="ledge", type="start"},

        -- Stage 1
        {object="ledge", x=320, y=-150, size="medium"},

        {object="ledge", x=280, y=-200, size="medium"},
            {object="spike", x=400,  y=0, type="fg-wall-divider-completedown", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="wall", x=387,  y=208, type="fg-wall-divider", copy=2, gap=645, physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="wall", x=5,  y=-600, type="fg-rock-2", size=0.8, physics={shape="circle", friction=0.3, bounce=1}},
        
        {object="ledge", x=175, y=-230, size="medium"},
            {object="rings", color=aqua, trajectory={x=50, y=-175, xforce=130, yforce=15, arc=40, num=3}},

            {object="emitter", x=0, y=1000, timer={2000, 6000}, limit=nil, force={ {-400, 300}, {-100, -300}, {45, 95} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-blue", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={3, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-4", size={3, 8}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-right", size={6, 8}} },
                }
            },
            {object="emitter", x=2500, y=1000, timer={2000, 5000}, limit=nil, force={ {-400, 400}, {-100, -300}, {45, 95} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-blue", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={3, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-4", size={3, 8}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-right", size={6, 8}} },
                }
            },    
            {object="emitter", x=3500, y=1000, timer={2000, 6000}, limit=nil, force={ {-300, 400}, {-100, -300}, {45, 95} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-blue", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={3, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-4", size={3, 8}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-right", size={6, 8}} },
                }
            },    

        {object="ledge", x=240, y=-125, surface="exploding"},
            {object="rings", color=white, pattern={ {275,-250}}},

            {object="enemy", type="greyufo", x=300, y=-550, size=0.6, 
                movement={pattern=moveTemplateSlantedSlight, isTemplate=true, reverse=true, distance=1000, speed=2, pause=250, moveStyle=moveStyleSwayBig, pauseStyle=moveStyleSwayBig}
            },

        {object="ledge", x=150, y=-200, surface="exploding"},

        {object="ledge", x=300, y=165, surface="exploding"},

        {object="ledge", x=190, y=190, surface="exploding"},
            {object="friend", type="fuzzy", y=-340, color="Red", kinetic="hang", direction=right},
            -- Rock above 8
            {object="wall", x=-50,  y=-575, type="fg-rock-4", size=1, rotation=-45, physics={shape="circle", friction=0.3, bounce=1}},
            {object="wall", x=-50,  y=-1000, type="fg-rock-1", size=0.8, rotation=-45, physics={shape="circle", friction=0.3, bounce=1}},
        
        {object="ledge", x=275, y=-270, surface="exploding"},
            {object="rings", color=aqua, trajectory={x=50, y=-100, xforce=130, yforce=15, arc=40, num=3}},

            {object="emitter", x=-400, y=-1699, timer={3000, 6000}, limit=nil, force={ {-400, 300}, {100, 300}, {0, 45} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={2, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={3, 6}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-left", size={6, 8}} },
                }
            },             
            {object="emitter", x=2000, y=-1699, timer={2000, 7000}, limit=nil, force={ {-400, 400}, {100, 300}, {0, 45} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={2, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={3, 6}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-right", size={6, 8}} },
                }
            }, 
            {object="emitter", x=3500, y=-1699, timer={2000, 7000}, limit=nil, force={ {-300, 400}, {100, 300}, {0, 45} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={2, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={3, 6}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-right", size={6, 8}} },
                }
            },           

        --Stage 2
        {object="ledge", x=400, y=50, size="medsmall"},
            {object="wall", x=-100,  y=-1200, type="fg-wall-divider",  physics={shapeOffset={top=50, right=-20},   bounce=1}},

        {object="ledge", x=200, y=-200, size="medsmall2"},

        {object="ledge", x=150, y=210, size="medsmall3"},
            {object="rings", color=aqua, trajectory={x=50, y=-175, xforce=130, yforce=15, arc=40, num=3}},

            {object="enemy", type="greyufo", x=-150, y=-100, size=0.5, 
                movement={pattern=moveTemplateSquare , isTemplate=true, distance=650, speed=3, pause=250, reverse=false, moveStyle=moveStyleSwayBig, pauseStyle=moveStyleSwayBig}
            },

        {object="ledge", x=350, y=-75, surface="exploding"},

        {object="ledge", x=360, y=-150, surface="exploding"},
            {object="rings", color=green, pattern={ {350,-240}}},
            -- rotated pipe above 14
            {object="wall", x=-150,  y=-1050, type="fg-wall-divider", rotation=65,  physics={shapeOffset={top=50, right=-20},   bounce=1}},
            
        {object="ledge", x=400, y=-200, surface="exploding"},
        
        {object="ledge", x=115, y=-245, surface="exploding"},
        
        {object="ledge", x=120, y=-130, surface="exploding"},
            {object="rings", color=aqua, trajectory={x=50, y=-150, xforce=40, yforce=60, arc=40, num=3}},
            {object="scenery", x=150, y=-320, rotation=-15, type="fgflt-pole-3"},

        -- Stage 3
        {object="ledge", x=210, y=210, size="small"},
        
        {object="ledge", x=170, y=270, size="small2"},

        {object="ledge", x=250, y=240, size="small3"},
            {object="rings", color=aqua, trajectory={x=125, y=-175, xforce=130, yforce=15, arc=40, num=3}},
    
            {object="enemy", type="greyshooter", x=-10, y=-700, size=0.5,
                shooting={minWait=2, maxWait=4, velocity={x=700, y=200, varyX=200, varyY=300}, itemsMax=10, ammo={negDizzy, negTrajectory}},
                behaviour={mode=stateSleeping, awaken=3, range=5},--, atRange=stateResetting},
                movement={pattern=movePatternFollow, speed=2.5, pause=250, moveStyle=moveStyleWave, pauseStyle=moveStyleWave}
            },

            {object="wall", x=100,  y=-1250, type="fg-wall-divider",  physics={shapeOffset={top=50, right=-20},   bounce=1}},


        {object="obstacle", type="spacerocket", x=550, y=150, angle=-27, takeoff="fast", force={1100,-1200}, rotation={time=300, degrees=1}},  
             {object="scenery", x=2150, y=-1300, rotation=7, type="fgflt-pole-1"},


        {object="ledge", x=2200, y=-750, surface="exploding"},
            {object="wall", x=456,  y=-892, type="fg-wall-divider-halfsize", copy=2, gap=647, physics={shapeOffset={bottom=0, left=0},   bounce=1}},            
            {object="wall", x=470,  y=-450, type="fg-wall-divider-completeup", physics={shapeOffset={bottom=-30, left=50},   bounce=1}},

        {object="ledge", x=375, y=175, surface="exploding"},
        
        {object="ledge", x=270, y=-200, surface="exploding"},
            {object="rings", color=yellow, pattern={ {520,-200}}},

        {object="ledge", x=410, y=250, surface="exploding"},
            -- big rock above ledge
            {object="wall", x=-50,  y=-575, type="fg-rock-3", size=1.1, physics={shape="circle", friction=0.3, bounce=1}},
            {object="wall", x=150,  y=-975, type="fg-rock-2", size=1.2, physics={shape="circle", friction=0.3, bounce=1}},

        {object="ledge", x=400, y=-150, surface="exploding"},
            {object="rings", color=aqua, trajectory={x=100, y=-100, xforce=250, yforce=150, arc=40, num=5}},

        {object="ledge", x=440, y=-200, type="finish"}
    },
}

return levelData