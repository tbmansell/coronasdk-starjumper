local levelData = {
    name             = "over and under",
    timeBonusSeconds = 28,
    ceiling          = -1000,
    floor            = 1800,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {0, 2},
        [bgrBack]  = {},
        [bgrSky]   = {1, 2}
    },

    backgroundSounds = {
        {name="space/space3", quietTime=3000, minVolume=4, maxVolume=6},
        {name="nature/wind2", quietTime=7000, minVolume=2, maxVolume=3},
    },
    elements = {
        {object="ledge", type="start"},

        {object="ledge", x=280, size="big3"},

            {object="emitter", x=100, y=-900, timer={3000, 6000}, limit=nil, force={ {0, 200}, {100, 300}, {0, 360} }, 
                items={
                    {10,  {object="scenery", layer=1, type="fg-debris-barrel-blue", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={4, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 7}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                }
            },

            {object="emitter", x=100, y=-900, timer={3000, 6000}, limit=nil, force={ {0, 200}, {100, 300}, {0, 360} }, 
                items={
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={4, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 7}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                }
            },

            {object="spike", x=400,  y=0, type="fg-wall-divider-completedown", physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="wall", x=387,  y=208, type="fg-wall-divider", copy=2, gap=645, physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            --{object="wall", x=200,  y=100, type="grid", physics={shapeOffset={bottom=0, left=0},   bounce=1}},

        {object="ledge", x=270, y=-150, size="big2"},
            {object="rings", color=aqua, trajectory={x=30, y=-150, xforce=70, yforce=150, arc=65, num=5}},

            {object="emitter", x=0, y=-799, timer={3000, 6000}, limit=nil, force={ {-400, 400}, {100, 300}, {0, 360} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={2, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-4", size={2, 8}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-left", size={6, 8}} },
                }
            },

        {object="ledge", x=300, y=70, size="medbig2"}, 

        {object="ledge", x=230, y=-200, size="medbig2"},             
            {object="wall", x=456,  y=-842, type="fg-wall-divider-halfsize", copy=2, gap=647, physics={shapeOffset={bottom=0, left=0},   bounce=1}},            
            {object="wall", x=470,  y=-400, type="fg-wall-divider-completeup", physics={shapeOffset={bottom=-30, left=50},   bounce=1}},

        {object="ledge", x=300, y=200, size="medium3"},
            {object="friend", type="fuzzy", x=220, y=-345, color="Green", kinetic="hang", direction=left},

        {object="ledge", x=250, y=-40, rotation=-20},
        
        {object="ledge", x=200, y=-65, size="medsmall"},
            {object="rings", color=aqua, trajectory={x=50, y=-100, xforce=100, yforce=15, arc=40, num=3}},

        {object="ledge", x=185, y=-50, size="big2", rotation=-20},
            {object="rings", color=aqua, pattern={ {350,-350}, {100,70}, }},

            {object="emitter", x=0, y=700, timer={3000, 6000}, limit=nil, force={ {-400, 400}, {-100, -300}, {0, 360} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={2, 5}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-left", size={6, 8}} },
                }
            },

            {object="spike", x=170,  y=0, type="fg-wall-divider-completedown", physics={shapeOffset={top=50, right=-20},   bounce=1}},
            {object="wall", x=155,  y=208, type="fg-wall-divider", copy=2, gap=648, physics={shapeOffset={bottom=0, left=0},   bounce=1}},

        {object="ledge", x=205, y=-85, size="big"},   

        {object="obstacle", x=550, y=-400, type="pole", length=1200},

        {object="wall", x=75,  y=-400, type="fg-wall-divider", copy=2, gap=645, physics={shapeOffset={top=0, left=0},   bounce=1}},
        
        {object="ledge", x=300, y=0, type="finish"}
    },
}

return levelData