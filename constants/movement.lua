-- Builtin movement patterns
movePatternHorizontal = 1
movePatternVertical   = 2
movePatternCircular   = 3
movePatternFollow     = 4

-- Builtin movement style modifications
moveStyleRandom    = 1
moveStyleSway      = 2
moveStyleSwaySmall = 3
moveStyleSwayBig   = 4
moveStyleWave      = 5
moveStyleWaveTiny  = 6
moveStyleWaveSmall = 7
moveStyleWaveBig   = 8

-- Preset movement patterns:
movePatternLeftArc    = { {-300,-300}, {300,300}, {-300,300}, {300,-300},  }
movePatternCross      = { {-200,-200}, {200,200,2}, {-200,200}, {200,-200,2}, {200,200}, {-200,-200,2}, {200,-200}, {-200,200,2}, }
movePatternWhooshOval = { {-1500,0,speed=15}, {0,300}, {1500,0,speed=15}, {0,-300} }
movePatternShooter1   = { {-100,0}, {100,-200,speed=5}, {0,200}, {100,0}, {-100,-200,speed=5}, {0,200} }

-- Preset steering configs:
steeringBig   = { cap=0.5, mass=60, radius=60 }
steeringMild  = { cap=0.5, mass=30, radius=30 }
steeringSmall = { cap=0.5, mass=20, radius=20 }
steeringTiny  = { cap=0.5, mass=10, radius=10 }

-- Template movement patterns which require running through *parseMovementPattern() to get the final pattern:
moveTemplateVertical     = { {0,1} }
moveTemplateHorizontal   = { {1, 0} }
moveTemplateDiagonalUp   = { {1,1} }
moveTemplateSlantedUp    = { {0.5,1} }
moveTemplateLeanedUp     = { {1,0.5} }

moveTemplateTriangleDown = { {0.5,0.5}, {0.5,-0.5}, {-1,0} }
moveTemplateTriangleUp   = { {0.5,-0.5}, {0.5,0.5}, {-1,0} }

-- bobbing patterns that loop on themselves (no need to set reverse)
moveTemplateBobUp1       = { {0.5,-1},  {0.5,1},   {-0.5,-1},  {-0.5,1} }
moveTemplateBobUp2       = { {0.75,-1}, {0.75,1},  {-0.75,-1}, {-0.75,1} }
moveTemplateBobUp3       = { {1,-1},    {1,1},     {-1,-1},    {-1,1} }
moveTemplateBobDown1     = { {0.5,1},   {0.5,-1},  {-0.5,1},   {-0.5,-1} }
moveTemplateBobDown2     = { {0.75,1},  {0.75,-1}, {-0.75,1},  {-0.75,-1} }
moveTemplateBobDown3     = { {1,1},     {1,-1},    {-1,1},     {-1,-1} }
moveTemplateBobDiamond1  = { {1,1},     {1,-1},    {-1,-1},    {-1,1} }
moveTemplateBobDiamond2  = { {0.5,1},   {0.5,-1},  {-0.5,-1},  {-0.5,1} }
moveTemplateBobDiamond3  = { {1,0.5},   {1,-0.5},  {-1,-0.5},  {-1,0.5} }

moveTemplateSquare       = { {0,0.5}, {0.5,0}, {0,-0.5}, {-0.5,0} }
moveTemplateDiamond      = { {0.5,0.5}, {0.5,-0.5}, {-0.5,-0.5}, {-0.5,0.5} }
moveTemplateLeftArc      = { {-1,-1}, {1,1}, {-1,1}, {1,-1} }
moveTemplateRightArc     = { {1,-1}, {-1,1}, {1,1}, {-1,-1} }
moveTemplateCross        = { {1,1}, {-1,-1}, {1,-1}, {-1,1}, {-1,-1}, {1,1}, {-1,1}, {1,-1} }
moveTemplateWhooshOval   = { {4,0,speed=10}, {0,-0.5}, {-4,0,speed=10}, {0,0.5} }
moveTemplateShooter1     = { {-0.5,0}, {0.5,-1,speed=5}, {0,1}, {0.5,0}, {-0.5,-1,speed=5}, {0,1} }

moveTemplateJerky        = { {-0.25,0},{0.25,0},  {-0.5,0,speed=1.5},{0.5,0,speed=1.5},  {-0.75,0,speed=1.75},{0.75,0,speed=1.75},  {-1,0,speed=2},{1,0,speed=2} }
moveTemplateJerkyReverse = { {0.25,0}, {-0.25,0}, {0.5,0,speed=1.5}, {-0.5,0,speed=1.5}, {0.75,0,speed=1.75}, {-0.75,0,speed=1.75}, {1,0,speed=2}, {-1,0,speed=2} }

moveTemplateHighRec      = { {0,1}, {0.5,0}, {0,-1}, {-0.5,0} }
moveTemplateSlantedSlight  = { {1,0.3} }
