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

        {object="ledge", x=3200, y=1500, size="medium", length=1500, movement={pattern=movePatternCircular, speed=0.25, arcStart=0, arc=360, fullCircle=true}},

            {object="warpfield", x=-1500, y=-1500, size=2.5, radius=200, layer=4, alwaysAnimate=true},
        
        {object="ledge", x=2700, y=1000, size="medium", length=1000, movement={pattern=movePatternCircular, speed=0.5, arcStart=0, arc=360, fullCircle=true}, positionFromLedge=1},
            {object="key", x=0, color="Yellow", onLedge=true},

        {object="ledge", x=2200, y=500, size="medium", length=500, movement={pattern=movePatternCircular, speed=1, arcStart=0, arc=360, fullCircle=true}, positionFromLedge=1},
            {object="key", x=0, color="Blue", onLedge=true},


        --#5
        {object="ledge", x=470, y=-200, surface=oneshot, size="medium", destroyAfter=1000, positionFromLedge=1},

        {object="ledge", x=500, y=-950, surface=oneshot, size="medium", destroyAfter=1000},

        {object="ledge", x=-600, y=-250, size="medium", keylock="Yellow"},


        --#8
        {object="ledge", x=1600, y=1350, surface=oneshot, size="medium", destroyAfter=1000, positionFromLedge=5},

        {object="ledge", x=600, y=250, size="medium", keylock="Blue"},


        --#10
        {object="ledge", x=1000, y=-1600, size="medium2", positionFromLedge=8},

        {object="ledge", x=500, y=0, size="big3"},

        {object="obstacle", type="spacerocket", x=300, y=0, angle=-30, takeoff="medium", force={1500, -1200}, rotation={time=100, degrees=1}},
        

        {object="ledge", x=2000, y=-200, type="finish"}
    },
}

return levelData