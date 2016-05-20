local levelData = {
    name             = "swingalong",
    timeBonusSeconds = 180,
    ceiling          = -3000,
    floor            = 1700,
    startLedge       = 15,

    backgroundOrder = {
        [bgrFront] = {2, 3, 4, 1},
        [bgrMid]   = {1, 4, 1, 4},
        [bgrBack]  = {2, 3, 4, 1},
        [bgrSky]   = {2, 1}
    },

    elements = {
        {object="ledge", type="start"},
            {object="scenery", x=-100, type="fg-foilage-2-yellow", onLedge=true, layer=2, copy=4},
            {object="scenery", x=75,   type="fg-foilage-2-green",  onLedge=true, layer=4, copy=3, flip="x"},

        {object="obstacle", type="ropeswing", x=550, y=-250, direction=right, length=250, movement={speed=1.5, arcStart=220, arc=100}},
            {object="spike", x=-350, y=-300, type="fg-spikes-float-1", size=0.8, flip="y", physics={shape={-90,-130, 90,-130, 0,120}}},
            {object="spike", x=-180, y=170,  type="fg-spikes-float-1", size=0.8, physics={shape={0,-120, 90,130, -90,130}}},
            {object="spike", x=-350, y=200,  type="fg-spikes-float-1", size=0.8, physics={shape={0,-120, 90,130, -90,130}}},
            {object="spike", x=-520, y=170,  type="fg-spikes-float-1", size=0.8, physics={shape={0,-120, 90,130, -90,130}}},

          
        {object="ledge", x=350, y=175, size="medium"},
            {object="scenery", x=-75, type="fg-foilage-2-yellow", size=0.7, onLedge=true, layer=2},
            {object="scenery", x=-10,  type="fg-foilage-2-green",  size=0.7, onLedge=true, layer=4, flip="x"},

        {object="ledge", x=350, y=-100, size="small", movement={pattern=movePatternVertical, distance=-400, speed=2}},

        {object="ledge", x=-350, y=-450, size="medium"},
            {object="scenery", x=-75, y=-145, type="fg-foilage-1-green", size=0.7, layer=2},

        {object="ledge", x=-200, y=-200, size="small", movement={pattern={{-200,-200}, {200,-200}, {200,200}, {-200,200}}, speed=2}}, 

        {object="obstacle", type="deathslide", x=250, y=-750, length={1000,0}, speed=3, animSpeed="MEDIUM"},

        {object="ledge", x=0, y=250, size="small"},

            -- Negable volcano
            {object="spike", type="fg-wall-double-l1", x=800,  y=350, size=1,   rgb={1,0,0}},
            {object="spike", type="fg-wall-l0",        x=1000, y=200, size=1.5, rgb={1,0,0}, physics={shape={-20,-75, 20,-75, 100,50, -100,50}}},

            {object="emitter", x=1100, y=180, timer={500, 3000}, limit=nil, force={{-1000, 1000}, {-1000, -1600}, {0, 50}},
            --{object="emitter", x=1100, y=180, timer={500, 3000}, limit=nil, force={-1000, -1000, 0},
                items={
                    {25,  {object="negable", type=negTrajectory} },
                    {50,  {object="negable", type=negDizzy}      },
                    {75,  {object="negable", type=negBooster}    },
                    {100, {object="negable", type=negRocket}    },
                },
            },

        {object="ledge", x=400, y=100, size="medium"},

        {object="ledge", x=200, y=230, size="small"},

        {object="ledge", x=350, y=-180, size="medium"},

        {object="ledge", x=200, y=150, size="medium"},

        {object="ledge", x=100, y=250, size="small"},

        {object="obstacle", x=-200, y=-75, type="pole", length=700},

        {object="ledge", x=0, y=250, size="small"},
            {object="spike", x=320,  y=-380, type="fg-wall-divider", rotation=90},
            {object="spike", x=1220, y=-380, type="fg-wall-divider", rotation=270, physics={shapeOffset={bottom=-50}}},

            {object="spike", x=250,  y=240, type="fg-wall-divider", rotation=90},
            {object="spike", x=1150, y=240, type="fg-wall-divider", rotation=270},

        {object="ledge", x=-450, y=350, size="small", movement={pattern={{-250,-200}, {250,-200}, {250,200}, {-250,200}}, speed=2}}, 

        {object="ledge", x=100, y=150, size="big"},

        {object="obstacle", type="ropeswing", x=550, y=-250, direction=right, length=200, movement={speed=1, arcStart=220, arc=100}},
        {object="obstacle", type="ropeswing", x=550, y=50,   direction=left, length=275, movement={speed=1, arcStart=320, arc=90}},
        {object="obstacle", type="ropeswing", x=550, y=100,  direction=right, length=300, movement={speed=1, arcStart=220, arc=100}},

        {object="ledge", x=450, y=250, size="big"},

        {object="obstacle", type="deathslide", x=300, y=-250, length={-2700,-2700}, speed=4, animSpeed="MEDIUM"},
            {object="spike", x=250,  y=-750, type="fg-wall-divider", rotation=90},
            {object="spike", x=1150, y=-750, type="fg-wall-divider", rotation=270},

        {object="ledge", x=0, y=250, size="small"},
            {object="spike", x=-220, y=-300, type="fg-spikes-float-5", flip="x", layer=2},
            {object="spike", x=-105, y=-70,  type="fg-spikes-float-1", flip="y", layer=2, size=0.5, physics={shape={-100,-125, 100,-125, 0,150}}},


        {object="ledge", x=450, y=-150, size="medium", length=150, 
            movement={pattern=movePatternCircular, speed=1, arcStart=0, arc=360, dontDraw=true, fullCircle=true}
        },

        {object="ledge", x=450, y=-100, size="medium", length=150, 
            movement={pattern=movePatternCircular, speed=1.5, arcStart=360, arc=0, dontDraw=true, fullCircle=true}
        },

        {object="ledge", x=450, y=-100, size="medium", length=150, 
            movement={pattern=movePatternCircular, speed=1, arcStart=0, arc=360, dontDraw=true, fullCircle=true}
        },

        {object="ledge", x=400, y=-250, type="finish"}
        
    },
}

return levelData