local levelData = {
    name             = "monster cave",
    timeBonusSeconds = 180,
    playerStart      = playerStartWalk,
    ceiling          = -1000,
    floor            = 2000,   
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {2, 3, 4, 1},
        [bgrMid]   = {1, 4, 1, 4},
        [bgrBack]  = {2, 3, 4, 1},
        [bgrSky]   = {2, 1}
    },

    elements = {
        {object="ledge", type="start"},

        {object="ledge", x=300, y=-100, type="finish"}
        
    },
}

return levelData