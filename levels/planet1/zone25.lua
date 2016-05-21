local levelData = {
    name             = "monster cavern",
    timeBonusSeconds = 180,
--    playerStart      = playerStartWalk,
    ceiling          = -1000,
    floor            = 2500,   
    startLedge       = 24,

    backgroundOrder = {
        [bgrFront] = {2, 3, 4, 1},
        [bgrMid]   = {1, 4, 3},
    },

    elements = {
        {object="ledge", type="start"},

    -- Level 1
        --#2
        {object="ledge", x=440, y=100, size="medium2"},
            -- entrance walls
            {object="wall",   x=-620, y=-1750, type="vertical-wall", rotation=-35},
            {object="spike",  x=-780, y=-270,  type="vertical-wall", rotation=65},
            -- first level ceiling & floor
            {object="wall",  x=200, y=-1300,   type="vertical-wall", rotation=90, copy=5, gap=1000},
            {object="spike", x=200, y=-500,    type="vertical-wall", rotation=90, copy=4, gap=1000},
            -- second floor ceiling & floor
            {object="wall",  x=200, y=-400,    type="vertical-wall", rotation=90, copy=4, gap=1000},
            {object="spike", x=200, y=400,     type="vertical-wall", rotation=90, copy=5, gap=1000},
            -- third level ceiling & floor
            {object="wall",  x=200, y=500,     type="vertical-wall", rotation=90, copy=5, gap=1000},
            {object="spike", x=200, y=1300,    type="vertical-wall", rotation=90, copy=5, gap=1000},

        {object="ledge", x=-300, y=100, size="medium"},

        {object="ledge", x=700, y=-100, size="big2", positionFromLedge=2},

        {object="ledge", x=200, y=-300, size="small"},

        {object="ledge", x=200, y=50, size="small"},

        {object="ledge", x=200, y=50, size="small"},

        --#8
        {object="ledge", x=300, y=50, size="medium4"},

        {object="ledge", x=200, y=-150, size="medium4"},
        {object="ledge", x=200, y=200,  size="medium4", positionFromLedge=8},
        --#11
        {object="ledge", x=300, y=-200, size="medium4"},

        {object="ledge", x=300, y=-150, size="small3"},
        {object="ledge", x=300, y=50,   size="small3"},

        {object="ledge", x=300, y=200, size="small3", positionFromLedge=11},
        {object="ledge", x=300, y=-50, size="small3"},

        {object="obstacle", x=500, y=-400, type="pole", length=1000},
            -- rear wall
            {object="wall", x=550, y=-120, type="vertical-wall", layer=4},
            {object="wall", x=550, y=-710, type="vertical-wall", layer=4},

    -- Level 2:
        --#16
        {object="ledge", x=-50, y=300, size="medium3"},

        {object="ledge", x=350,  y=-200, size="small2"},
        {object="ledge", x=-250, y=-200, size="small2"},
        {object="ledge", x=250,  y=-200, size="small3"},

        {object="ledge", x=-500, y=-150, size="medium", positionFromLedge=16},

        {object="ledge", x=-650, y=150, size="medium"},

        {object="ledge", x=-650, y=-150, size="medium2", movement={pattern=movePatternHorizontal, speed=2, distance=600}},

        {object="ledge", x=-1300, y=-150, size="small2", movement={pattern={{600,0},{-600,0}}, speed=2}},

        {object="ledge", x=-200, y=250, size="medium"},
            -- moving spikes
            {object="spike", x=-550, y=-550, type="fg-spikes-float-1", size=0.8, flip="y", physics={shape={-90,-130, 90,-130, 0,125}},
                movement={pattern=movePatternVertical, distance=200, speed=1}
            },
            {object="spike", x=-550, y=-85,  type="fg-spikes-float-1", size=0.8, physics={shape={0,-125, 90,130, -90,130}}, 
                movement={pattern={{0,-200},{0,200}}, speed=1}
            },

        {object="ledge", x=-500, y=100, size="medium"},

        {object="obstacle", x=-200, y=-400, type="pole", length=1000},
            -- bottom floor
            {object="spike", x=-350, y=180,  type="vertical-wall", rotation=-70, layer=4},

    -- Level 3:
        {object="ledge", x=0, y=150, size="small"},


        {object="ledge", x=15000, y=-100, type="finish"}
        
    },
}

return levelData