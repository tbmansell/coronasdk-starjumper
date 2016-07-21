local levelData = {
    name             = "a nice breather",
    floor            = display.contentHeight+300,
    timeBonusSeconds = 45,
    startLedge       = 4,

    backgroundOrder = {
        [bgrFront] = {3, 4, 1, 2},
        [bgrMid]   = {7, 9, 7, 9},
        [bgrBack]  = {1, 2, 3, 4},
        [bgrSky]   = {2, 1}
    },

    backgroundSounds = {
        {name="animals/birds4", quietTime=6000, minVolume=1, maxVolume=2},
        {name="animals/birds1", quietTime=8000, minVolume=1, maxVolume=2},
    },

    elements = {
        {object="ledge", type="start"},
        
        {object="ledge", x=170, y=-150, size="small"},
            {object="rings", color=aqua, trajectory={x=30, y=-200, xforce=120, yforce=60, arc=20, num=2}},

        {object="ledge", x=200, y=-220, size="small"},
            {object="scenery", x=-60,  y=50,  type="fg-tree-5-yellow", size=1.2},
            {object="scenery", x=200,  y=200, type="fg-tree-5-yellow", size=1.2},
            {object="scenery", x=-50,  y=770, type="fg-wall-l1"},
            {object="scenery", x=-150, y=900, type="fg-wall-l2"},

        {object="ledge", x=250, y=-200, size="medium2", movement={pattern=movePatternVertical, distance=500, speed=1}},
            {object="friend", type="fuzzy", x=300, y=143, color="Orange", kinetic="hangDouble"},
            {object="wall", x=175, y=-75, type="fg-rock-3", physics={shape="circle", bounce=1, radius=160}},
            {object="rings", color=aqua, trajectory={x=30, y=350, xforce=90, yforce=50, arc=50, num=2}},

             {object="emitter", x=0, y=150, timer={1000, 3000}, limit=3, layer=4,
                item={
                    object="livebgr", type="brain", color="Purple", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.3, 0, 0.3},
                    movement={rangeX={-200, -1000}, rangeY={-50, 150}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },

        {object="ledge", x=340, y=0, size="medium2", movement={pattern=movePatternVertical, distance=500, speed=1}},
       
        {object="ledge", x=300, y=120, size="big2"},
            {object="rings", color=aqua, trajectory={x=30, y=-150, xforce=80, yforce=150, arc=75, num=5}},
            {object="scenery", x=-130, y=-190, type="fg-foilage-2-yellow", layer=2, size=1, onLedge=true},
            {object="scenery", x=675,  y=0,    size=1.2, type="fg-flowers-6-yellow"},
            {object="scenery", x=900,  y=70,   size=1.3, type="fg-foilage-3-yellow"},
            {object="scenery", x=1200, y=25,   type="fg-flowers-4-yellow"},
            {object="scenery", x=600,  y=150,  type="fg-wall-double-l2"}, 

        {object="ledge", x=275, y=0, movement={pattern={{500,-150}}, reverse=true,  distance=100, speed=1, pause=1000}},

            {object="emitter", x=0, y=-100, timer={1000, 3000}, limit=3, layer=4,
                item={
                    object="livebgr", type="brain", color="Purple", direction=right, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.5, 0.1, 0.3},
                    movement={rangeX={600, 1000}, rangeY={-100, -100}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },

        {object="ledge", x=900, y=-220, size="medium3"},
            {object="rings", color=pink, pattern={ {200,-200} }},
            {object="scenery", x=-130, y=-150, type="fg-foilage-2-yellow", layer=2, size=0.5, onLedge=true},
            {object="scenery", x=30,   y=-120,  type="fg-foilage-3-yellow", layer=2, size=0.8, onLedge=true},

        {object="ledge", x=170, y=150, size="small", triggerLedgeIds={10}},
            {object="rings", color=pink, pattern={ {300,-200} }},

        -- #10
        {object="ledge", x=150, y=0, surface="collapsing", dontReset=true},
            {object="wall",    x=-100, y=-160,  type="fg-rock-1", onLedge=true, size=0.6, rotation=-45, physics={body="static", shape="circle", friction=0.3, bounce=0.4}},
            {object="wall",    x=300,  y=-1100, type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=1}},
            {object="scenery", x=-100, y=50,    type="fg-tree-3-yellow", size=1.2},
            {object="scenery", x=170,  y=850,   type="fg-rock-2", size=1.2},

        {object="ledge", x=0, y=200, size="small"},

        {object="ledge", x=250, y=-200, type="finish"}
    },
}

return levelData