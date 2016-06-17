local levelData = {
    name             = "eye of the storm",
    timeBonusSeconds = 220,
    ceiling          = -4000,
    floor            = 2500,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {5, 8, 4},
        [bgrBack]  = {},
        [bgrSky]   = {2, 1}
    },

    elements = {
        {object="ledge", type="start"},

            {object="emitter", x=500, y=-500, timer={3000, 6000}, limit=nil, force={ {-100, 300}, {100, 300}, {45, 90} }, 
                items={
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={2, 5}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-right", size={6, 8}} },
                }
            },
        
        
        {object="ledge", x=2500, y=-200, type="finish"},
        
    },
}

return levelData