local levelData = {
    cameraOffset = {350,-50},
    cameraBounds = {-1000, 2000},

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14},
        [bgrBack]  = {},
        [bgrSky]   = {1, 2}
    },

    elements = {
        {object="friend", x=250, y=-250, type="ufoboss", isCameraFocus=true, animation="Standard", hasPassenger=true, playerModel=characterNewton,
            movement={speed=15, pause=0,
                pattern = {
                    {100, 100},
                    {100, -100},
                },
                steering={cap=0.5, mass=150, radius=50}
            }
        },
    },

    movement = {
        speedX = 4,
        speedY = 0,
    },
}

return levelData