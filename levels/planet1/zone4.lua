local levelData = {
    name             = "callamity canyon",
    floor            = display.contentHeight+300,
    timeBonusSeconds = 35,
    turnNight        = true,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {4, 1, 2, 3},
        [bgrMid]   = {8, 11, 8, 11},
        [bgrBack]  = {4, 1, 2, 3},
        [bgrSky]   = {2, 1}
    },

    elements = {
        {object="ledge", type="start"},
            {object="scenery", x=-10, y=-434, type="fg-spikes-5",layer=2, size=1, onLedge=true},

        -- This triggers the collapsing ledge, so the rock falls down
        {object="ledge", x=200, y=-100, size="small3", triggerLedgeIds={4}},

        {object="ledge", x=200, y=-100, rotation=-15},

        -- player doesnt land on this ledge, just carries a rock
        {object="ledge", x=-1, y=-150, surface="collapsing", dontReset=true, ai={ignore=true}},
            {object="rings", color=aqua, pattern={ {510,-150}, {40,-80}, {40,80} }},
            {object="wall", x=-100, y=-160, type="fg-rock-1", size=0.6, rotation=-45, physics={body="dynamic", shape="circle", friction=0.3, bounce=0.4}},

        {object="ledge", x=550, y=150, rotation=15},

        {object="ledge", x=250, y=270, size="medium2"},
            {object="rings", color=pink, pattern={ {x=400,y=-80} }},
            {object="scenery", x=-100, y=-164, type="fg-flowers-2-yellow",layer=2, size=0.7, onLedge=true},

        {object="ledge", x=300, y=230, size="medium2"},
            {object="rings", color=aqua, trajectory={x=30, y=-150, xforce=40, yforce=125, arc=40, num=3}},
            {object="scenery", x=250, y=-50, type="fg-wall-double-l1",layer=2, size=0.7},
            {object="scenery", x=390, y=-116, type="fg-flowers-5-yellow",layer=2, size=0.7},
            {object="scenery", x=450, y=-125, type="fg-foilage-2-yellow",layer=2, size=0.7},

        {object="ledge", x=300, y=-230, size="small3"},
            {object="friend", type="fuzzy", x=0, y=-50, size=0.2, color="Orange", onLedge=true},
            {object="rings", color=aqua, trajectory={x=30, y=-150, xforce=40, yforce=125, arc=40, num=3}},

        {object="ledge", x=200, y=-150, rotation=-20},
        
        {object="obstacle", x=300, y=-400, type="pole", length=500},
            {object="wall", x=-80, y=-270, type="fg-rock-1", physics={shape="circle", bounce=1}},
            {object="scenery", x=275, y=220, type="fg-flowers-3-yellow",layer=2, size=1.5},

        {object="ledge", x=420, y=0, type="finish"}
    },
}

return levelData