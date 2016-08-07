local levelData = {
    name             = "all right, gear up",
    timeBonusSeconds = 120,
    ceiling          = -2700,
    floor            = 2400,
    startLedge       = 1,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {10, 3},
        [bgrBack]  = {},
        [bgrSky]   = {2, 1}
    },

    backgroundSounds = {
        {name="space/space3", quietTime=2000, minVolume=3, maxVolume=4},
        {name="nature/wind1", quietTime=4000, minVolume=1, maxVolume=2},
    },

    elements = {
        {object="ledge", type="start"},   
             {object="ledge", x=240, y=-125, surface="exploding"},
           

           -- {object="enemy", type="greyufo", x=300, y=-550, size=0.6, 
          --      movement={pattern=moveTemplateSlantedSlight, isTemplate=true, reverse=true, distance=1000, speed=2, pause=250, moveStyle=moveStyleSwayBig, pauseStyle=moveStyleSwayBig}
           -- },

        {object="ledge", x=150, y=-240, surface="exploding"},
             {object="rings", color=aqua, pattern={ {375,-250}, {50,50}, {50,50}}},
              {object="enemy", type="greyshooter", x=600, y=-250, size=0.5, 
                shooting={minWait=2, maxWait=5, velocity={x=700, y=200, varyX=200, varyY=100}, itemsMax=5, ammo={negDizzy, negTrajectory}},
                movement={pattern=movePatternHorizontal, reverse=true, distance=800, speed=3, pause=500, moveStyle=moveStyleSwayBig, pauseStyle=moveStyleSwayBig}
            },

        {object="ledge", x=310, y=180, surface="exploding"},
            {object="wall", x=-50,  y=-575, type="fg-rock-4", size=1, rotation=-45, physics={shape="circle", friction=0.3, bounce=1}},
            {object="wall", x=-50,  y=-1000, type="fg-rock-1", size=0.8, rotation=-45, physics={shape="circle", friction=0.3, bounce=1}},
        

        {object="ledge", x=215, y=-230, surface="exploding"},
          
          
        {object="ledge", x=265, y=-280, surface="exploding"},
            {object="rings", color=aqua, trajectory={x=50, y=-225, xforce=140, yforce=15, arc=40, num=3}},


        {object="ledge", x=320, y=-150, size="medium"},

            {object="emitter", x=100, y=800, timer={3000, 6000}, limit=nil, force={ {-10, -250}, {-100, -300}, {0, 180} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-red", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={3, 5}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-4", size={4, 7}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-blue", size={6, 8}} },
                }
            },
           
         --------Cave of moving ledges   
            --Top rail
            {object="spike", x=600,  y=-1075, type="fg-wall-divider-spiked", rotation=-90, physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="spike", x=1425,  y=-1075, type="fg-wall-divider-spiked", rotation=-90, physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="spike", x=2250,  y=-1075, type="fg-wall-divider-spiked", rotation=-90, physics={shapeOffset={bottom=0, left=0},   bounce=1}},    

            --Bottom rail    
            {object="spike", x=600,  y=50, type="fg-wall-divider-spiked", rotation=90, physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="spike", x=1425,  y=50, type="fg-wall-divider-spiked", rotation=90, physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="spike", x=2250,  y=50, type="fg-wall-divider-spiked", rotation=90, physics={shapeOffset={bottom=0, left=0},   bounce=1}},

        {object="ledge", x=300, y=-500, size="medium", canShake=false, movement={pattern={{0,1000}}, reverse=true, speed=2, pause=0}},
         
        {object="ledge", x=800, y=500, size="medium", canShake=false, positionFromLedge=7, movement={pattern={{0,-1000}}, reverse=true, speed=1.5, pause=0}},

        {object="ledge", x=1300, y=-500, size="medium", canShake=false, positionFromLedge=7, movement={pattern={{0,1000}}, reverse=true, speed=3, pause=0}},
             {object="rings", color=white, pattern={ {-250, 425}, {500,0}}},

        {object="ledge", x=1800, y=500, size="medium", canShake=false, positionFromLedge=7, movement={pattern={{0,-1000}}, reverse=true, speed=1.5,pause=0}},


        {object="ledge", x=2300, y=-500, size="medium", canShake=false, positionFromLedge=7, movement={pattern={{0,1000}}, reverse=true, speed=2, pause=0}},
            {object="rings", color=aqua, trajectory={x=50, y=575, xforce=90, yforce=95, arc=40, num=3}},


        --- Out of Cave
        {object="ledge", x=250, y=500, size="medsmall3"},
          {object="emitter", x=100, y=-1500, timer={2000, 4000}, limit=nil, force={ {0, 300}, {100, 300}, {45, 180} }, 
                items={
                    {10, {object="scenery", layer=1, type="fg-debris-barrel-blue", size={8, 9}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-2", size={7, 8}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-4", size={4, 10}} },
                    {100, {object="scenery", layer=1, type="fg-debris-barrel-grey", size={7, 8}} },
                }
            },

        -- Glider cave

            --Rock Positions
              {object="wall", x=900,  y=-250, type="fg-rock-1", size=0.8, rotation=-45, physics={shape="circle", friction=0.3, bounce=1, radius=100}},

                    --last walls
           -- {object="spike", x=3860,  y=220, type="fg-wall-divider-spiked", rotation=-72, physics={shapeOffset={left=20},   bounce=1}},
           -- {object="spike", x=3860,  y=720, type="fg-wall-divider-spiked", rotation=-72, flip="x", physics={shapeOffset={right=-20,  left=0},   bounce=1}},

            -- middle walls
            {object="spike", x=3070,  y=-35, type="fg-wall-divider-spiked", rotation=-72, physics={shapeOffset={left=20},   bounce=1}},
            {object="spike", x=3070,  y=465, type="fg-wall-divider-spiked", rotation=-72, flip="x", physics={shapeOffset={right=-20,  left=0},   bounce=1}},
            
            --last walls
            {object="spike", x=2280,  y=-290, type="fg-wall-divider-spiked", rotation=-72, physics={shapeOffset={left=20},   bounce=1}},
            {object="spike", x=2280,  y=210, type="fg-wall-divider-spiked", rotation=-72, flip="x", physics={shapeOffset={right=-20,  left=0},   bounce=1}},

            -- middle walls
            {object="spike", x=1490,  y=-545, type="fg-wall-divider-spiked", rotation=-72,  physics={shapeOffset={left=20},   bounce=1}},
            {object="spike", x=1490,  y=-45, type="fg-wall-divider-spiked", rotation=-72, flip="x", physics={shapeOffset={right=-20,  left=0},   bounce=1}},
            --first walls
            {object="spike", x=700,  y=-800, type="fg-wall-divider-spiked", rotation=-72,  physics={shapeOffset={left=20},   bounce=1}},
            {object="spike", x=700,  y=-300, type="fg-wall-divider-spiked", rotation=-72, flip="x", physics={shapeOffset={right=-20, left=0},   bounce=1}},


        -- Glider Cave Ledges
            {object="ledge", x=1150, y=225, size="small"},
                {object="wall", x=200,  y=-60, type="fg-rock-2", size=0.8, rotation=-45, physics={shape="circle", friction=0.3, bounce=1, radius=100}},
                      {object="rings", color=pink, pattern={ {-100, -250}}},

             {object="ledge", x=1350, y=465, size="small"},
               {object="rings", color=pink, pattern={ {0, -125}}},
                {object="wall", x=200,  y=-60, type="fg-rock-2", size=0.8, rotation=-45, physics={shape="circle", friction=0.3, bounce=1, radius=100}}, 
                 {object="wall", x=700,  y=190, type="fg-rock-2", size=0.4, rotation=-45, physics={shape="circle", friction=0.3, bounce=1, radius=40}}, 
                 {object="wall", x=855,  y=-100, type="fg-rock-1", size=1.4, rotation=-45, physics={shape="circle", friction=0.3, bounce=1}},    
   

        -- cave exit pole
             {object="obstacle", x=925, y=0, type="pole", length=600},   
                     {object="rings", color=aqua, pattern={ {-40,-100}, {0,90}, {0,90}}},

                 {object="ledge", x=0, y=300, size="medsmall"},     


        -- {Pulley ledge cave}
            {object="spike", x=220,  y=-1175, type="fg-wall-divider-spiked", flip="x", physics={shapeOffset={bottom=-20, left=0},   bounce=1}},
            {object="spike", x=220,  y=-2000, type="fg-wall-divider-spiked", flip="x", physics={shapeOffset={top=-20, left=0},   bounce=1}},

            {object="spike", x=950,  y=-875, type="fg-wall-divider-spiked",  physics={shapeOffset={bottom=0, left=0},   bounce=1}},
            {object="spike", x=950,  y=-1700, type="fg-wall-divider-spiked", physics={shapeOffset={top=30, left=0},   bounce=1}},

            {object="ledge", x=270, y=200, surface=pulley, distance=-800, speed=2},
                  {object="spike", x=-55,  y=-1325, type="fg-wall-divider-spiked", rotation=-90, size=0.2, physics={shapeOffset={bottom=-120, top=120},   bounce=1}},
            {object="ledge", x=200, y=-500, surface=pulley, distance=-600, speed=2},
                 {object="spike", x=-55,  y=-1125, type="fg-wall-divider-spiked", rotation=-90, size=0.2, physics={shapeOffset={bottom=-120, top=120},   bounce=1}},
                 {object="rings", color=pink, pattern={ {60, -100}}},
            {object="ledge", x=-200, y=-450, surface=pulley, distance=-500, speed=2},
                 {object="spike", x=-55,  y=-1025, type="fg-wall-divider-spiked", rotation=-90, size=0.2, physics={shapeOffset={bottom=-120, top=120},   bounce=1}},
                 {object="rings", color=pink, pattern={ {-60, -100}}},


                
          {object="ledge", x=275, y=-500, size="small"},
          
           {object="ledge", x=-300, y=-275, size="small"},

           {object="ledge", x=370, y=-215, size="small"},   

           {object="ledge", x=-335, y=-100, size="medium"},  

        -- Secret off shot
            {object="ledge", x=-220, y=150, size="medsmall3"}, 
                  {object="rings", color=red, pattern={ {-45,-80}, {30,-50, color=blue}, {30,50}}},   

            {object="ledge", x=-375, y=250, size="medsmall2"},  
                 {object="rings", color=green, pattern={ {-45,-80}, {30,-50, color=white}, {30,50}}},
                   {object="emitter", x=0, y=-1000, timer={2000, 6000}, limit=nil, force={ {-400, 400}, {100, 300}, {0, 360} }, 
                items={
                    {10,  {object="scenery", layer=1, type="fg-debris-barrel-blue", size={6, 8}} },
                    {50,  {object="scenery", layer=4, type="fg-bg-rock-1", size={2, 6}} },
                    {90,  {object="scenery", layer=4, type="fg-bg-rock-3", size={2, 8}} },
                    {100, {object="scenery", layer=1, type="fg-debris-ufo-right", size={4, 8}} },
                }
            },

            {object="ledge", x=-270, y=0, size="small"}, 
                 {object="randomizer", onLedge=true, spawn=1, items={ {30,yellow},{70,gearJetpack},{100,gearGloves} }},      

        -- Run off to end


        {object="ledge", x=150, y=-240, surface="exploding", positionFromLedge=22},

        {object="ledge", x=280, y=220, surface="exploding"},
            {object="wall", x=-50,  y=-475, type="fg-rock-4", size=1, rotation=-45, physics={shape="circle", friction=0.3, bounce=1}},
            {object="wall", x=-50,  y=-800, type="fg-rock-1", size=1.4, rotation=-45, physics={shape="circle", friction=0.3, bounce=1}},
             {object="rings", color=pink, pattern={ {-110, -350}}},
                {object="enemy", type="greyshooter", x=0, y=-300, size=0.5, 
                shooting={minWait=2, maxWait=5, velocity={x=600, y=200, varyX=200, varyY=100}, itemsMax=5, ammo={negTrajectory}},
                movement={pattern=movePatternHorizontal, reverse=true, distance=800, speed=3, pause=500, moveStyle=moveStyleSwayBig, pauseStyle=moveStyleSwayBig}
            },

        

        {object="ledge", x=290, y=-230, surface="exploding"},
              {object="rings", color=aqua, trajectory={x=50, y=-175, xforce=90, yforce=150, arc=40, num=3}},

          

        {object="ledge", x=275, y=-220, type="finish"}
    },
}

return levelData