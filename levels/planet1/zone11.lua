local levelData = {
    name             = "a long way to go",
    floor            = display.contentHeight+200,
    ceiling          = -display.contentHeight*2,
    timeBonusSeconds = 95,
    startLedge       = 8,

    backgroundOrder = {
        [bgrFront] = {4, 1, 2, 3},
        [bgrMid]   = {3, 10, 3, 10},
        [bgrBack]  = {3, 4, 1, 2},
        [bgrSky]   = {2, 1}
    },

    elements = {
        {object="ledge", type="start"},

        {object="ledge", x=350, y=-200, size="big"},
            {object="spike", x=-280, y=-100, type="fg-spikes-1", physics={shape={-20,-90, 70,90, -80,90}}},
            {object="spike", x=200,  y=-100, type="fg-spikes-1", physics={shape={-20,-90, 70,90, -80,90}}},
            {object="spike", x=700,  y=-100, type="fg-spikes-1", physics={shape={-20,-90, 70,90, -80,90}}},
            {object="spike", x=-400, y=140,   type="fg-wall-double-l3", physics={shape={-600,-150, 670,-150, 670,150, -600,150, -670,0}}},

             {object="emitter", x=600, y=-250, timer={1000, 3000}, limit=5, layer=4,
                item={
                    object="livebgr", type="brain", color="Purple", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.3, 0, 0.1},
                    movement={rangeX={-200, 2000}, rangeY={-250, 400}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },    

        {object="ledge", x=300, y=0, size="medium"},

        {object="ledge", x=350, y=200, size="big"},
            {object="rings", color=aqua, pattern={ {x=-65, y=-300}, {x=0, y=-65}, {x=0, y=135} }},
            {object="spike", x=400,  y=-100, type="fg-spikes-1",  physics={shape={-20,-90, 70,90, -80,90}}, flip="x"},
            {object="spike", x=700,  y=-100, type="fg-spikes-1",  physics={shape={-20,-90, 70,90, -80,90}}},
            {object="spike", x=1000, y=-100, type="fg-spikes-1", physics={shape={-20,-90, 70,90, -80,90}}, flip="x"},
            {object="spike", x=1300, y=-100, type="fg-spikes-1", physics={shape={-20,-90, 70,90, -80,90}}},            
            {object="spike", x=200,  y=120,   type="fg-wall-double-l3", physics={shape={-600,-150, 670,-150, 670,150, -600,150, -670,0}}},

        {object="obstacle", type="deathslide", x=200, y=-270, length={1400,0}, speed=4, animSpeed="SLOW"},
            {object="rings", color=aqua, pattern={ {500,100}, {300,0}, {300,0} }},

        {object="ledge", x=0, y=350, size="medium2"},

        -- need glider to get to next ledge
        {object="ledge", x=300, y=-150, size="small2", ai={loadGear=gearGlider, jumpVelocity={600,900}, useAirGearAfter={1000}}},
            {object="gear", type=gearGlider, y=-50, regenerate=true},
            {object="rings", color=aqua, pattern={ {x=650, y=-400}, {x=120, y=25}, {x=120, y=25}, {x=120, y=25}, {x=120, y=25}, {x=120, y=25}, {x=120, y=25} }},
            {object="spike", x=400,  y=-100, type="fg-spikes-1",  physics={shape={-20,-90, 70,90, -80,90}}, flip="x"},
            {object="spike", x=700,  y=-100, type="fg-spikes-1",  physics={shape={-20,-90, 70,90, -80,90}}},
            {object="spike", x=1000, y=-100, type="fg-spikes-1", physics={shape={-20,-90, 70,90, -80,90}}, flip="x"},
            {object="spike", x=1300, y=-100, type="fg-spikes-1", physics={shape={-20,-90, 70,90, -80,90}}},
            {object="spike", x=200,  y=120,   type="fg-wall-double-l3", physics={shape={-600,-150, 670,-150, 670,150, -600,150, -670,0}}},

        {object="ledge", x=1400, y=50, size="big"},

        {object="ledge", x=250, y=150, size="small2"},
            {object="friend", type="fuzzy", onLedge=true, color="Orange"},

         {object="emitter", x=0, y=-450, timer={1000, 2000}, limit=2, layer=4,
                item={
                    object="livebgr", type="heart", color="Red", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.4, 0, 0.1},
                    movement={rangeX={-200, 2000}, rangeY={0, 400}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },        

        {object="ledge", x=300, y=-150, size="big"},
            {object="spike", x=-280, y=-100, type="fg-spikes-1", physics={shape={-20,-90, 70,90, -80,90}}},
            {object="spike", x=200,  y=-100, type="fg-spikes-1", physics={shape={-20,-90, 70,90, -80,90}}},
            {object="spike", x=-400, y=120,  type="fg-wall-double-l3", physics={shape={-600,-150, 670,-150, 670,150, -600,150, -670,0}}},

        {object="ledge", x=300, y=-150, size="big"},

        {object="ledge", x=400, y=-150, size="medium"},
            {object="rings", color=aqua, trajectory={x=50, y=-150, xforce=150, yforce=150, arc=45, num=3}},

        {object="ledge", x=500, y=-150, size="medium"},
              {object="randomizer", x=-65, onLedge=true, items={{30,negTrajectory}, {70,gearTrajectory}, {100,white}}},

        {object="ledge", x=500, y=-150, size="small"},
            {object="spike", x=-280, y=-100, type="fg-spikes-1", physics={shape={-20,-90, 70,90, -80,90}}},
            {object="spike", x=200,  y=-100, type="fg-spikes-1", physics={shape={-20,-90, 70,90, -80,90}}},
            {object="spike", x=-400, y=120,  type="fg-wall-double-l3", physics={shape={-600,-150, 670,-150, 670,150, -600,150, -670,0}}},

        {object="ledge", x=500, y=-150, size="medium3"},

         {object="emitter", x=0, y=-250, timer={1000, 3000}, limit=3, layer=4,
                item={
                    object="livebgr", type="brain", color="Purple", direction=left, size={0.175, 0.15, 0.125, 0.1}, modifyImage={0.3, 0, 0.3},
                    movement={rangeX={-200, 2000}, rangeY={-250, 400}, speed={0.5, 0.4, 0.3, 0.2}, moveStyle=moveStyleSway, oneWay=true},
                }
            },    

        {object="obstacle", type="deathslide", x=200, y=-300, length={1600,350}, speed=4, animSpeed="MEDIUM"},

        {object="ledge", x=-500, y=200, size="small"},
            {object="friend", x=0, y=0, type="fuzzy", color="White"},
            {object="scenery", x=720, y=-272, type="fg-spikes-4",layer=2, size=1},

        {object="ledge", x=370, y=0, type="finish"}
    },
}

return levelData