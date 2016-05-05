playerFilter           = { categoryBits=1,    maskBits=2016 }   -- groupIndex=-2
pathFilter             = playerFilter
playerOnObstacleFilter = { categoryBits=2,    maskBits=1952 }   -- groupIndex=-5
playerShieldedFilter   = { categoryBits=4,    maskBits=1504 }   -- groupIndex=-3
ledgeFilter            = { categoryBits=32,   maskBits=1445 }   -- groupIndex=-5
obstacleFilter         = { categoryBits=64,   maskBits=135 }
sceneryFilter          = { categoryBits=128,  maskBits=487 }
collectableFilter      = { categoryBits=256,  maskBits=295 }
enemyFilter            = { categoryBits=512,  maskBits=3 }      -- groupIndex=-3
friendFilter           = { categoryBits=1024, maskBits=39 }     -- groupIndex=-4