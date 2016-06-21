local levelData = {
    name             = "time to escape",
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

            {object="emitter", x=0, y=300, timer={3000, 6000}, limit=5, 
                items={
                    {50, {object="livebgr", type="greyother", skin="shooter", imagePath="enemies/space/greyother", size={0.5, 0.4, 0.3, 0.2, 0.1}, modifyImage={0.5, 0.5, 0.5},
                           movement={rangeX={10000, 20000}, rangeY={-10000, -20000}, speed={4, 3, 2, 1}, oneWay=true}}
                    },
                    {100, {object="livebgr", type="greyufo", imagePath="enemies/space/greyufo", size={0.5, 0.4, 0.3, 0.2, 0.1}, modifyImage={0.5, 0.5, 0.5},
                           movement={rangeX={10000, 20000}, rangeY={-10000, -20000}, speed={4, 3, 2, 1}, oneWay=true}}
                    }
                }
            },
        
        
        {object="ledge", x=2500, y=-200, type="finish"},
        
    },
}

return levelData