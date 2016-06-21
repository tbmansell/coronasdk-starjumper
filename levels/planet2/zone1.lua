local levelData = {
    name             = "no on can hear you scream",
    timeBonusSeconds = 28,
    ceiling          = -1000,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {13, 5},
        [bgrBack]  = {},
        [bgrSky]   = {1, 2}
    },

    backgroundSounds = {
        {name="space/space1", quietTime=3000, minVolume=4, maxVolume=6},
        {name="nature/wind1", quietTime=6000, minVolume=2, maxVolume=3},
    },

    elements = {
        {object="ledge", type="start"},

            {object="emitter", x=100, y=-900, timer={3000, 6000}, limit=nil, force={ {0, 200}, {100, 300}, {0, 360} }, 
                items={
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 7}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                }
            },
        
        {object="obstacle", x=250, y=-100, timerOn=3000, timerOff=4000, type="electricgate"},
        
        {object="ledge", x=280, y=200, size="big3"},
            {object="key", color="Red", onLedge=true},
            {object="rings", color=aqua, pattern={ {190,-250}, {50,-50}, }},
            {object="scenery", x=300, y=-400, type="fgflt-pole-3"},

            {object="emitter", x=0, y=300, timer={3000, 6000}, limit=nil, force={ {-400, 400}, {-100, -300}, {0, 360} }, 
                items={
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={2, 5}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-right", size={6, 8}} },
                }
            },

        {object="ledge", x=350, y=-180, size="big2", rotation=-30},

        {object="obstacle", x=250, y=-200, timerOn=2000, timerOff=3000, type="electricgate"},
        
        {object="ledge", x=320, y=220, size="big2", rotation=20}, 
        
        {object="ledge", x=230, y=-200, size="medbig2"},
            {object="rings", color=aqua, trajectory={x=50, y=-50, xforce=250, yforce=20, arc=40, num=5}},
            {object="scenery", x=300, y=-400, type="fgflt-pole-2"},

        {object="ledge", x=480, y=50, size="medium2"},
            {object="wall", x=475,  y=100, type="fg-wall-divider", physics={shapeOffset={bottom=0, left=0}, bounce=1}},
            {object="wall", x=487,  y=-87, type="fg-wall-divider-cornertop", physics={shapeOffset={bottom=0, left=0}, bounce=1}},
            {object="spike", x=855,  y=-273, type="fg-wall-divider-halfsize", physics={shapeOffset={bottom=0, left=0}, bounce=1}, rotation=90},

        {object="ledge", x=250, y=-220, rotation=15},
            {object="rings", color=aqua, trajectory={x=50, y=-100, xforce=130, yforce=15, arc=40, num=3}},

            {object="emitter", x=0, y=-699, timer={3000, 6000}, limit=nil, force={ {-400, 400}, {100, 300}, {0, 360} },
                items={
                    {10,  {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={2, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-4", size={2, 8}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-left", size={6, 8}} },
                }
            },

        {object="ledge", x=300, y=-30, size="medium2"},
        
        {object="ledge", x=230, y=200, size="medbig3", keylock="Red", triggerObstacleIds={3}},

            {object="emitter", x=100, y=-875, timer={3000, 6000}, limit=nil, force={ {-200, 10}, {100, 300}, {0, 360} }, 
                items={
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 7}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                }
            },

        {object="obstacle", x=100, y=-100, timerOn=4000, timerOff=1000, type="electricgate"},
            {object="wall", x=-54,  y=-750, type="fg-wall-divider-halfsize", physics={shapeOffset={bottom=0, left=0}, bounce=1}},
            {object="wall", x=-51,  y=190, type="fg-wall-divider", flip="y", physics={shapeOffset={bottom=0, left=0}, bounce=1}},
        
        {object="ledge", x=600, y=250, type="finish"}
    },
}

return levelData