local levelData = {
    cameraOffset = {350,-50},
    cameraBounds = {-1000, 2000},

    backgroundOrder = {
        [bgrFront] = {1, 2, 3, 4},
        [bgrMid]   = {1, 2, 3, 4},
        [bgrBack]  = {1, 2, 3, 4},
        [bgrSky]   = {1, 2}
    },

    elements = {
        {object="friend", x=250, y=250, type="ufoboss", isCameraFocus=true, animation="Standard", hasPassenger=true, playerModel=characterNewton,
            movement={
                speed=10,
                pause=0,
                pattern = {
                    {150, 150},
                    {150, -150},
                },
                steering={cap=0.5, mass=150, radius=50}
            }
        },
    },
}

return levelData