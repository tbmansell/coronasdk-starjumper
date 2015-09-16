local levelData = {
    name             = "hard to stomach",
    ceiling          = -display.contentHeight-400,
    timeBonusSeconds = 75,
    startLedge       = 9,

    backgroundOrder = {
        [bgrFront] = {1, 2, 3, 4},
        [bgrMid]   = {10, 9, 10, 9},
        [bgrBack]  = {4, 1, 2, 3},
        [bgrSky]   = {2, 1}
    },

    elements = {
        {object="ledge", type="start"},

        {object="ledge", x=300, y=-150, size="small"},

        {object="ledge", x=300, y=-130, size="small2"},
            {object="friend", type="fuzzy", x=-30, color="Orange", kinetic="bounce", onLedge=true},

            {object="scenery", x=120,  y=-830, type="fg-tree-4-yellow", size=1.2},
            {object="scenery", x=210,  y=-100, type="fg-rock-2", size=1.2},
            {object="scenery", x=860,  y=-750, type="fg-tree-1-yellow", size=1.2},
            {object="scenery", x=1000, y=-85, type="fg-rock-1", size=1.2},
            {object="rings", color=aqua, pattern={ {-200,-120}, {0,-320,color=pink}, {0,-370} }},

        {object="ledge", x=-300, y=-150, size="small"},

        {object="ledge", x=300,  y=-170, size="small2"},

        {object="ledge", x=-300, y=-190, size="small"},
            {object="enemy", type="stomach", x=-250, y=275, size=0.8, 
                shooting={minWait=2, maxWait=4, velocity={varyX=50, varyY=10}, itemsMax=3, ammo={negDizzy, negTrajectory}},
                behaviour={mode=stateSleeping, awaken=3},
                movement={pattern=movePatternVertical, distance=-500, speed=2, pause=1000, moveStyle=moveStyleSwayBig}
            },

        {object="ledge", x=-300, y=150, size="small", positionFromLedge=4, ai={ignore=true}},
            {object="gear", type=gearGloves, y=-40, onLedge=true},

        {object="ledge", x=300, y=-200, size="small2", positionFromLedge=6},

        {object="ledge", x=300, y=-150, size="medium3"},

        {object="obstacle", type="deathslide", x=250, y=-100, length={500,850}, speed=10, animSpeed="FAST"},
            {object="rings", color=aqua, pattern={ {50,200},  {118,200}, {118,200}, {118, 200} }},

        {object="ledge", x=0, y=250, size="medium3"},

        {object="ledge", x=200, y=150, size="small3", ai={ignore=true}},
            {object="rings", color=aqua, pattern={ {-30,-50}, {30,-60,color=pink}, {30,60} }},
              
        {object="ledge", x=200, y=-150, size="medium3"},

            {object="enemy", type="stomach", x=400, y=-200, size=0.7, 
                shooting={minWait=1, maxWait=3, velocity={varyX=200, varyY=100}, itemsMax=10, ammo={negDizzy, negTrajectory, negBooster}},
                behaviour={mode=stateSleeping, awaken=2, range=6, atRange=stateResetting},
                movement={pattern=movePatternFollow, followXOnly=true, speed=5, pause=1000, moveStyle="sway-small"}
            },
        
        {object="ledge", x=200, y=200, size="small3", ai={ignore=true}},
            {object="rings", color=aqua, pattern={ {-30,-50}, {30,-60,color=pink}, {30,60} }},
       
        {object="ledge", x=200, y=-200, size="medium3"},
       
        {object="ledge", x=200, y=250, size="small3", ai={ignore=true}},
            {object="rings", color=aqua, pattern={ {-30,-50}, {30,-60,color=pink}, {30,60} }},
       
        {object="ledge", x=200, y=-250, size="medium3"},

        {object="ledge", x=500, y=200, type="finish"}
    },
}

return levelData