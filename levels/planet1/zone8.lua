local levelData = {
    name             = "pole position",
    floor            = display.contentHeight+300,
    timeBonusSeconds = 40,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {1, 2, 3, 4},
        [bgrMid]   = {2, 1, 2, 1},
        [bgrBack]  = {4, 1, 2, 3},
        [bgrSky]   = {1, 2}
    },

    elements = {
        {object="ledge", type="start"},
            {object="scenery", x=50, y=-400, type="fg-tree-1-yellow", size=1.5},  
            {object="scenery", x=25, y=400, type="fg-wall-l1", size=1.2},

        {object="ledge", x=350, y=-200, size="medium2", movement={pattern=movePatternVertical, distance=500, speed=1}},
            {object="rings", color=aqua, trajectory={x=50, y=150, xforce=30, yforce=200, arc=50, num=3}},

         --Furry Ledge
        {object="ledge", x=150, y=450, size="small2", ai={ignore=true, nextJump={[100]=2}}},
            {object="friend", type="fuzzy", x=-30, color="Orange", onLedge=true},
            {object="spike", x=300, y=-300, type="fg-spikes-float-3", physics={shape="circle", bounce=1}},

        {object="ledge", x=1, y=-400, rotation=10},
            {object="obstacle", x=400, y=-250, type="pole", length=500},
            {object="wall",    x=-53, y=-1000, type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=1}},
         
        {object="ledge", x=20, y=250, surface="collapsing"},
            {object="rings", color=aqua, trajectory={x=50, y=-150, xforce=75, yforce=150, arc=70, num=3}},
         
        {object="ledge", x=300, y=-100, rotation=-20},
         
        {object="ledge", x=150, y=-300, size="big3"},
            {object="scenery", x=0, y=-185, type="fg-flowers-1-yellow",layer=2, onLedge=true},

        {object="ledge", x=225, y=-250, size="medium3"},
            {object="rings", color=aqua, pattern={ {765,-250}, {0,90}, {0,90}, {0,90}}},
            {object="scenery", x=785, y=50, type="fg-tree-4-yellow", size=1.2},
            {object="scenery", x=860, y=775, type="fg-rock-2", size=1.2},

        {object="obstacle", x=700, y=-350, type="pole", length=500},
            {object="wall", x=-80, y=-300, type="fg-rock-1", physics={shape="circle", bounce=1}},
         

        {object="ledge", x=-0, y=400, size="medium3", ai={loadGear=gearJetpack, jumpVelocity={310,930}, useAirGearAfter={700,1200}}},
            {object="gear",  x=-80, y=-50, type=gearJetpack, regenerate=true},
            {object="spike", x=450, y=-400, type="fg-wall-divider", flip="y", physics={shapeOffset={bottom=-30}, bounce=1}},

        {object="ledge", x=650, y=-200, type="finish"}
    },
}

return levelData