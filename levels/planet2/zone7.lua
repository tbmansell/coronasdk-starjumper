local levelData = {
    name             = "bad electric",
    timeBonusSeconds = 28,
    ceiling          = -4000,
    floor            = 1000,
    startLedge       = 1,
    warpChase        = true,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {2, 15},
        [bgrBack]  = {},
        [bgrSky]   = {1, 2}
    },

    elements = {
        {object="ledge", type="start"},
                 {object="spike", x=350,  y=-1700, type="fg-wall-dividerx2-spiked", rotation=45, physics={shapeOffset={bottom=0, left=0},   bounce=1}},
                 {object="spike", x=1325,  y=-1600, type="fg-wall-dividerx2-spiked", rotation=45, physics={shapeOffset={bottom=0, left=0},   bounce=1}},
                 {object="scenery", x=1500, y=-1000, type="fgflt-pole-4", rotation=-35},


            {object="ledge", x=200, y=-255, size="medsmall2"},
            {object="ledge", x=-160, y=-120, size="medsmall3"},
                       {object="rings", color=aqua, trajectory={x=50, y=-180, xforce=185, yforce=40, arc=40, num=3}},

             {object="ledge", x=395, y=-125, size="medsmall"},
              {object="warpfield", x=-110, y=50, size=0.5, radius=50, movement={steering=steeringMild, speed=2, pattern={{0,-20}, {0,20}}}},

                {object="emitter", x=-800, y=-800, timer={3000, 5000}, limit=nil, force={ {0, 300}, {100, 300}, {0, 360} }, 
                items={
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={4, 7}} },
                    {100, {object="scenery", layer=4, type="fg-debris-barrel-red", size={6, 8}} },
                }
            },
            
             {object="ledge", x=155, y=-260, size="medsmall2"},
              {object="ledge", x=-155, y=-220, size="medsmall2"},
                    {object="rings", color=pink, pattern={ {-65,-100}}},
              {object="ledge", x=175, y=-190, size="small2"},
              {object="ledge", x=195, y=-175, size="small2"},
                       {object="rings", color=aqua, trajectory={x=50, y=-175, xforce=130, yforce=35, arc=40, num=3}},
                       {object="rings", color=aqua, trajectory={x=-50, y=-175, xforce=-200, yforce=35, arc=40, num=3}},


        -------Pole Left
              {object="obstacle", x=-500, y=-1200, type="pole", length=900, positionFromLedge=8},
                 {object="ledge", x=0, y=120, size="small2"},
              

        -------Pole Right            
              {object="obstacle", x=900, y=-1048, type="pole", length=900, positionFromLedge=8},
                 {object="ledge", x=0, y=120, size="small2"},



        -----Electric Ledge1 
        
               {object="ledge", x=-275, y=-250, surface="electric"},   
                         {object="rings", color=red, pattern={ {0,-100}}},

                {object="ledge", x=-180, y=-180, size="small2"},
                {object="ledge", x=660, y=0, size="small2"},
   
        -----Electric Ledge2         


                {object="ledge", x=-180, y=-180, surface="electric"},
                        {object="rings", color=blue, pattern={ {0,-100}}},

                 {object="ledge", x=-145, y=-180, size="small2"},
                        {object="spike", x=-217,  y=-549, type="fg-spikes-float-5", size=0.6, physics={shape={-50, 150, 100,150, 50,-80}}},
                {object="ledge", x=590, y=0, size="small2"},
                        {object="spike", x=47,  y=-550, type="fg-spikes-float-5", size=0.6, physics={shape={-50, 150, 100,150, 50,-80}}},
                              {object="scenery", x=450, y=-675, type="fgflt-pole-2", rotation=-15},

                {object="ledge", x=-260, y=-200, size="medsmall2",  movement={bobbingPattern=moveTemplateBobUp1, speed=1, distance=50}},
                        {object="randomizer", x=10, onLedge=true, items={{30,negTrajectory}, {70,gearJetpack}, {100,white}}},
        
                        {object="wall", x=-400, y=-525, type="fg-rock-1", size=1.2, rotation=-45, physics={shape="circle", friction=0.3, bounce=0.4}}, 

                  {object="emitter", x=-400, y=-600, timer={2000, 4000}, limit=nil, force={ {-100, 400}, {100, 300}, {0, 360} }, 
                items={
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={2, 5}} },
                    {100, {object="scenery", layer=4, type="fg-debris-ufo-right", size={6, 8}} },
                }
            },           

                {object="ledge", x=230, y=-300, size="medsmall3",  movement={bobbingPattern=moveTemplateBobDown1, speed=1, distance=50}},
                         {object="rings", color=aqua, pattern={ {200,-250}, {40,-80,color=pink}, {40,80} }},

                     {object="emitter", x=0, y=-750, timer={3000, 6000}, limit=nil, force={ {-200, 500}, {100, 300}, {0, 360} }, 
                items={
                    {10, {object="scenery", layer=4, type="fg-debris-barrel-blue", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-5", size={2, 8}} },
                    {100, {object="scenery", layer=4, type="fg-debris-barrel-grey", size={6, 8}} },
                }
            },               

                {object="ledge", x=300, y=-0, size="medsmall",  movement={bobbingPattern=moveTemplateBobDiamond1, speed=1, distance=50}},




                {object="obstacle", x=350, y=-150, timerOn=1000, timerOff=2000, type="electricgate"},
                            {object="wall", x=-50, y=-525, type="fg-rock-2", size=0.9, physics={shape="circle", friction=0.3, bounce=0.4}},           

                {object="ledge", x=250, y=160, size="medsmall",  movement={bobbingPattern=moveTemplateBobDiamond2, speed=1, distance=50}},
                    {object="rings", color=aqua, trajectory={x=60, y=0, xforce=90, yforce=175, arc=40, num=3}},



                 {object="ledge", x=145, y=180, size="small", positionFromLedge=10},

                 {object="ledge", x=530, y=370, size="small", positionFromLedge=10},
                     {object="friend", type="fuzzy", color="Orange", onLedge=true},

        {object="ledge", x=320, y=-260, type="finish", positionFromLedge=20}
    },
}

return levelData