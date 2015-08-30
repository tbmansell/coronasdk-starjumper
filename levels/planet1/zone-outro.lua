local levelData = {
    windSpeed    = 2,
    cameraOffset = {350,150},

    backgroundOrder = {
        [bgrFront] = {1, 2, 3, 4},
        [bgrMid]   = {1, 2, 3, 4},
        [bgrBack]  = {1, 2, 3, 4},
        [bgrSky]   = {1, 2}
    },

    elements = {
        {object="ledge", type="start"},
            {object="scenery", x=100, y=-400, type="fg-tree-4-yellow", copy=20, gap=400, layer=4, darken=100},
            {object="scenery", x=450, y=-300, type="fg-tree-4-yellow", copy=25, gap=300, flip="x"},

        {object="ledge", x=200, y=0, size="mega", canShake=false},
        
        {object="ledge", x=300, y=0, size="mega", canShake=false},

            {object="enemy", type="brain", x=-350, y=-350, size=0.5, color="Purple", spineDelay=0,   
                movement={pattern=movePatternVertical, speed=1, distance=20, pause=5000, pauseStyle=moveStyleSwaySmall}, behaviour={}
            },
            {object="enemy", type="brain", x=250, y=-250,  size=0.5, color="Purple", spineDelay=700, 
                movement={pattern=movePatternVertical, speed=1, distance=20, pause=5000, pauseStyle=moveStyleSwaySmall}, behaviour={}
            },
            {object="enemy", type="brain", x=700, y=-350,  size=0.5, color="Blue",   spineDelay=0,   
                movement={pattern=movePatternVertical, speed=1, distance=20, pause=5000, pauseStyle=moveStyleSwaySmall}, behaviour={}
            },

        {object="ledge", x=300, y=0, size="mega", canShake=false},
            {object="enemy", type="heart", x=-350, y=-350, size=0.5, color="Red",   spineDelay=0,   
                movement={pattern=movePatternVertical, speed=1, distance=20, pause=5000, pauseStyle=moveStyleSwaySmall}, behaviour={}
            },
            {object="enemy", type="heart", x=250, y=-250,  size=0.5, color="White", spineDelay=700, 
                movement={pattern=movePatternVertical, speed=1, distance=20, pause=5000, pauseStyle=moveStyleSwaySmall}, behaviour={}
            },
            {object="enemy", type="heart", x=700, y=-350,  size=0.5, color="Red",   spineDelay=0,   
                movement={pattern=movePatternVertical, speed=1, distance=20, pause=5000, pauseStyle=moveStyleSwaySmall}, behaviour={}
            },

        {object="ledge", x=300, y=0, size="mega", canShake=false},

            {object="enemy", type="stomach", x=-350, y=-350, size=0.5, color="Red",   spineDelay=0,   
                movement={pattern=movePatternVertical, speed=1, distance=20, pause=5000, pauseStyle=moveStyleSwaySmall}, 
                shooting={frequency=4000, velocity={varyX=200, varyY=200}, itemsMax=0, ammo={negDizzy}}, 
                behaviour={}
            },
            {object="enemy", type="stomach", x=250, y=-250,  size=0.5, color="White", spineDelay=700, 
                movement={pattern=movePatternVertical, speed=1, distance=20, pause=5000, pauseStyle=moveStyleSwaySmall}, 
                shooting={frequency=4000, velocity={varyX=200, varyY=200}, itemsMax=0, ammo={negTrajectory}}, 
                behaviour={}
            },
            {object="friend", x=2100, y=-230, type="ufoboss", size=0.7, direction=right, animation="Stationary"},

        {object="ledge", x=300, type="finish"},
    },

    ai = {
        [1] = {
            skin          = "Green Space Man",
            model         = characterNewton,
            direction     = right,
            startLedge    = 2,
            lives         = 10,
            waitingTimer  = 1,            -- 3 seconds before AI starts
            xpos          = 50,
            personality   = {
                waitFromLand      = 0,    -- seconds to wait from landing, before performing next action (jump)
                waitForJump       = 0,    -- seconds to wait in drag mode before they jump (simulating working out jump)
                reposition        = 0,   -- distance they will reposition themselves on a ledge by
            }
        },
        [2] = {
            skin          = "Female  Alien",
            model         = characterSkyanna,
            direction     = right,
            startLedge    = 2,
            lives         = 10,
            waitingTimer  = 1,            -- 3 seconds before AI starts
            jumpXBoost    = 50,
            personality   = {
                waitFromLand      = 0,    -- seconds to wait from landing, before performing next action (jump)
                waitForJump       = 0,    -- seconds to wait in drag mode before they jump (simulating working out jump)
                reposition        = 0,    -- distance they will reposition themselves on a ledge by
            }
        },
    },

    customEvent = {
        delay = 3000,
        start = function(scene)
            scene.player.constRunSpeed = scene.player.constRunSpeed - 1
            after(3000,  function() scene.player.constRunSpeed = scene.player.constRunSpeed - 1   end)
            after(6000,  function() scene.player.constRunSpeed = scene.player.constRunSpeed - 0.5 end)
            after(9000,  function() scene.player.constRunSpeed = scene.player.constRunSpeed + 1   end)
            after(12000, function() scene.player.constRunSpeed = scene.player.constRunSpeed + 2   end)
            after(20000, function() scene.player.constRunSpeed = scene.player.constRunSpeed - 2   end)
        end
    },
}

return levelData