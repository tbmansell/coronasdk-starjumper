local levelData = {
    name             = "falling apart",
    ceiling          = -display.contentHeight-300,
    floor            = display.contentHeight+300,
    timeBonusSeconds = 70,

    backgroundOrder = {
        [bgrFront] = {4, 1, 2, 3},
        [bgrMid]   = {11, 6, 11, 6},
        [bgrBack]  = {2, 3, 4, 1},
        [bgrSky]   = {2, 1}
    },

    elements = {
        {object="ledge", type="start"},
            {object="wall",    x=600, y=-300, type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=1}},

        {object="ledge", x=400, y=200, size="medium"},
            {object="rings", color=aqua, trajectory={x=75, y=-200, xforce=75, yforce=100, arc=70, num=3}},
            {object="scenery", x=-130, y=-128, type="fg-foilage-2-yellow", layer=2, size=0.5, onLedge=true},
            {object="wall",    x=250, y=-100, type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=1}},

        {object="ledge", x=365, y=175, surface="collapsing"},

        {object="ledge", x=200, y=-100, surface="collapsing"},
            {object="friend", type="fuzzy", x=-30, color="Orange", onLedge=true},

        {object="ledge", x=275, y=-150, surface="collapsing"},
            {object="wall",    x=250, y=-175, type="fg-wall-divider", physics={shapeOffset={bottom=-30}, bounce=1}},
            {object="rings", color=aqua, trajectory={x=75, y=-200, xforce=85, yforce=90, arc=50, num=3}},

        --Furry Ledge
        {object="ledge", x=425, y=0, size="small2"},

        {object="ledge", x=230, y=-150, size="small2"},
            {object="scenery", x=820, y=-400, type="fg-tree-5-yellow", size=1.5},  
            {object="scenery", x=920, y=-250, type="fg-tree-5-yellow", size=1}, 
            {object="scenery", x=700, y=350, type="fg-wall-double-l1", size=1.2},    

        {object="ledge", x=-500, y=-750, size="medium3", movement={pattern={{1200,700}}, reverse=true,  distance=300, speed=2, pause=1000}}, 
            {object="rings", color=aqua, trajectory={x=65, y=-150, xforce=120, yforce=100, arc=50, num=3}},
         
        {object="ledge", x=450, y=0, surface="collapsing"},
             {object="randomizer", x=-100, onLedge=true, items={{30,negBooster}, {70,gearReverseJump}, {100,gearJetpack}}},
        
        {object="ledge", x=100, y=100, size="big3", flip="x"},
           {object="scenery", x=0, y=-185, type="fg-flowers-4-yellow",layer=2, onLedge=true},

        {object="ledge", x=160, y=-300, size="small"},
            {object="rings", color=pink, pattern={ {0,-75} }},
       
        {object="ledge", x=320, y=350, type="finish"}
    },
}

return levelData