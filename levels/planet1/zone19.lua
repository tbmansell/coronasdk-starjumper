local levelData = {
    name             = "trick shots.....",
    timeBonusSeconds = 80,
    ceiling          = -display.contentHeight*2,
    turnNight        = true,

    backgroundOrder = {
        [bgrFront] = {4, 1, 2, 3},
        [bgrMid]   = {3, 1, 3, 1},
        [bgrBack]  = {2, 3, 4, 1},
        [bgrSky]   = {2, 1}
    },

    elements = {
        {object="ledge", type="start"},
            {object="scenery", x=520, y=-400, type="fg-tree-1-yellow", layer=1, size=0.8, flip="x"},
            {object="scenery", x=1000, y=-400, type="fg-tree-3-yellow", layer=1, size=1.2},
            {object="scenery", x=1500, y=-400, type="fg-tree-1-yellow", layer=1, size=1.0, flip="x"},
            {object="rings", color=aqua, trajectory={x=96, y=-200, xforce=225, yforce=25, arc=31, num=3}},  

        {object="obstacle", type="deathslide", x=440, y=-320, length={1000,-300}, speed=3, animSpeed="FAST"},
        
        {object="ledge", x=0, y=310, size="medium4"},
            {object="spike", x=100, y=-320, type="fg-spikes-float-4", size=0.5, rotation = -20, flip="x", physics={shape={-30,-75, 30,-75, 0,60}} },

            {object="emitter", x=0, y=-150, timer={1000, 3000}, limit=4, layer=4,
                item={
                    object="livebgr", type="heart", color="Red", direction=right, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.2, 0, 0.2},
                    movement={rangeX={-600, 600}, rangeY={-450, 450}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },              

        {object="ledge", x=-260, y=-270, size="medium3"},
            {object="rings", color=aqua, pattern={ {715,-50}, {0,100}, {0,100}, {0,100}}},
          
        {object="obstacle", x=640, y=-175, type="pole", length=500, sticky=false},
            {object="spike", x=-125, y=-420, type="fg-spikes-float-4", size=0.5, rotation = -90, flip="x", physics={shape={-30,-75, 30,-75, 0,60}} },

        {object="ledge", x=0, y=215, surface="collapsing", ai={loadGear=gearShield}},

        {object="ledge", x=375, y=-215, surface="spiked", timerOff=4000},

        {object="ledge", x=-215, y=-215, size="medium"},
            {object="randomizer", x=-30, onLedge=true, items={{40,gearShield},{90,negtrajectory},{100,pink}}},

        {object="ledge", x=215, y=-215, surface="collapsing"},
            {object="friend", type="fuzzy", x=70, color="Blue", onLedge=true},
            {object="rings", color=aqua, trajectory={x=-100, y=-150, xforce=-60, yforce=100, arc=50, num=3}},

        {object="ledge", x=-220, y=-115, surface="spiked", timerOff=4000},

        {object="ledge", x=-200, y=-280, size="medium3"},
            {object="rings", color=aqua, pattern={ {-75,-85}}},

        ------INTERLUDE-------
        {object="ledge", x=-200, y=200, size="big", invisible={invisibleFor=2500, visibleFor=100, alpha=0.1}, ai={ignore=true}},

        {object="ledge", x=-350, y=-200, size="medium", invisible={invisibleFor=3000, visibleFor=100, alpha=0.1}, ai={ignore=true}},

        {object="ledge", x=-220, y=-100, size="small", invisible={invisibleFor=3000, visibleFor=100, alpha=0.1}, ai={ignore=true}},
            {object="friend", type="fuzzy", color="Orange", onLedge=true},

        ------END INTERLUDE-------

        {object="ledge", x=250, y=-5, size="big", positionFromLedge=9, ai={loadGear=gearJetpack, jumpVelocity={300,600}, useAirGearAfter={1200,1500}}},
            {object="gear", type=gearJetpack, x=0, y=-150, regenerate=true},
            {object="rings", color=white, pattern={ {550,90}}},

             {object="emitter", x=0, y=100, timer={1000, 3000}, limit=4, layer=4,
                item={
                    object="livebgr", type="stomach", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.2, 0, 0.6},
                    movement={rangeX={-600, 1000}, rangeY={-150, 250}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },               

            {object="scenery", x=65, y=-15, type="fg-foilage-2-yellow",layer=2, size=0.8, flip="y"},
            {object="wall",    x=500, y=-1100, type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=.2}},
            {object="wall",    x=500, y=200, type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=.2}},
            {object="scenery", x=460, y=200, type="fg-flowers-2-yellow",layer=2, size=0.8, flip="x", rotation=330},
            {object="scenery", x=555, y=435, type="fg-flowers-1-yellow",layer=2, size=0.5, flip="x", rotation=45},
            {object="scenery", x=450, y=750, type="fg-flowers-2-yellow",layer=2, size=0.8, flip="x", rotation=320},

        {object="ledge", x=650, y=0, size="big", ai={loadGear=gearGlider, jumpVelocity={500,400}, useAirGearAfter={500}}},
            {object="gear", type=gearGlider, x=0, y=-150, regenerate=true},
            {object="rings", color=aqua, pattern={ {500,-190}}},
            {object="rings", color=pink, pattern={ {800, -90}}},
            {object="rings", color=white, pattern={ {1100,00}}},
          
            {object="spike", x=400, y=-530, type="fg-spikes-float-1", size=0.5, physics={shape={-100,-50, 100,-50, 0,110}},  rotation=200},
            {object="spike", x=600, y=-460, type="fg-spikes-float-1", size=0.5, physics={shape={-100,-50, 100,-50, 0,110}},  rotation=200},
            {object="spike", x=800, y=-390, type="fg-spikes-float-1", size=0.5, physics={shape={-100,-50, 100,-50, 0,110}},  rotation=200},
            {object="spike", x=1000, y=-320, type="fg-spikes-float-1", size=0.5, physics={shape={-100,-50, 100,-50, 0,110}}, rotation=200},

            {object="spike", x=450, y=-100, type="fg-spikes-float-1", size=0.5, physics={shape={-100,-50, 100,-50, 0,110}}, rotation=20},
            {object="spike", x=650, y=-30, type="fg-spikes-float-1", size=0.5, physics={shape={-100,-50, 100,-50, 0,110}},  rotation=20},
            {object="spike", x=850, y=40, type="fg-spikes-float-1", size=0.5, physics={shape={-100,-50, 100,-50, 0,110}},   rotation=20},
            {object="spike", x=1050, y=110, type="fg-spikes-float-1", size=0.5, physics={shape={-100,-50, 100,-50, 0,110}}, rotation=20},
           
            {object="wall",  x=800, y=-750, type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=1}, rotation=-72, flip="x"},
            {object="wall",  x=800, y=-250, type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=1}, rotation=-72, flip="x"},

        {object="ledge", x=1250, y=400, type="finish"}
    },
}

return levelData