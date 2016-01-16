local levelData = {
    name             = "out on your own!",
    timeBonusSeconds = 28,
    playerStart      = playerStartWalk,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {2, 3, 4, 1},
        [bgrMid]   = {1, 4, 1, 4},
        [bgrBack]  = {2, 3, 4, 1},
        [bgrSky]   = {2, 1}
    },

    elements = {
        {object="ledge", type="start"},

        {object="ledge", x=230, y=-150},
            {object="scenery", x=-900, y=-150, type="fg-tree-4-yellow", size=1.2},  
            {object="scenery", x=-130, y=-128, type="fg-foilage-2-yellow", layer=2, size=0.5, onLedge=true},
            {object="scenery", x=30,   y=-90,  type="fg-foilage-3-yellow", layer=2, size=0.8, onLedge=true},

         -- brain background emitter:
            {object="emitter", x=600, y=-400, timer={2000, 5000}, limit=5, layer=4,
                item={
                    object="livebgr", type="brain", color="Purple", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.4, 0, 0.3},
                    movement={rangeX={-500, -2000}, rangeY={0, -150}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },    

        {object="ledge", x=280, y=-50, size="medium2"},
            {object="rings", color=aqua, trajectory={x=110, y=-150, xforce=120, yforce=75, arc=70, num=5}},
            {object="scenery", x=350, y=-150, type="fg-tree-5-yellow", size=1.2},

        {object="ledge", x=450, y=200},

        {object="ledge", x=300, y=-70, size="medium"},
            {object="rings", color=aqua, trajectory={x=30, y=-150, xforce=70, yforce=150, arc=65, num=5}},
            {object="scenery", x=-70,  y=-93,  type="fg-foilage-3-yellow", layer=2, size=0.9, flip="x", onLedge=true},
            {object="scenery", x=30,   y=-91,  type="fg-foilage-3-yellow", layer=2, size=0.8, onledge=true},

        {object="ledge", x=280, y=-50},
            {object="scenery", x=450, y=-150, type="fg-tree-5-yellow"},

        
            {object="emitter", x=600, y=0, timer={2000, 4000}, limit=5, layer=4,
                item={
                    object="livebgr", type="brain", color="Purple", direction=right, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.5, 0, 0.3},
                    movement={rangeX={300, 700}, rangeY={-100, -100}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },   


        {object="ledge", x=300, y=200},
            {object="scenery", x=-155, y=-25, type="fg-foilage-2-yellow", layer=2, size=0.6, flip="y", onLedge=true},
            {object="scenery", x=30,   y=0,   type="fg-foilage-3-yellow", layer=2, size=0.8, flip="y", onLedge=true},
        
            {object="scenery", x=800,   y=-269,  type="fg-rock-3", layer=2, size=0.8},
        {object="ledge", x=300, y=-100, type="finish"}
        
    },
}

return levelData