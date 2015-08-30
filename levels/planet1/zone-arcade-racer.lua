local levelData = {
    name    = "organia race track",
    tip     = "buy items to improve your jumping ability",
    floor   = display.contentHeight*4,
    ceiling = -display.contentHeight*4,

    backgroundOrder = {
        [bgrFront] = {1, 2, 3, 4},
        [bgrMid]   = {3, 4, 1, 2},
        [bgrBack]  = {3, 4, 1, 2},
        [bgrSky]   = {2, 1}
    },

    -- Starting game elements
    elements = {
        {object="ledge", type="start", stage=1},
    },

    -- Scenery that can appear in this planets game mode
    sceneryGeneration = {
        foreground = {
            ["foreground-trees"] = {
                chance = {90,80,60,40,20},
                gap    = {1,4},
                darken = {0.4,1},
                images = {"fgflt-tree-1-yellow", "fgflt-tree-2-yellow", "fgflt-tree-3-yellow", "fgflt-tree-4-yellow", "fgflt-tree-5-yellow", "fgflt-tree-6-yellow"},
            },
        },
        wall = {
            images = {"fg-rock-1", "fg-rock-3", "fg-rock-4", "fg-wall-divider"},
        },
        spike = {
            images = {"fg-spikes-float-1", "fg-spikes-float-2", "fg-spikes-float-3", "fg-spikes-float-4", "fg-spikes-float-5"},
        },
        ledge = {
            chance = {60,70,60,50,40},
            images = {"fg-flowers-1-yellow", "fg-flowers-2-yellow", "fg-flowers-3-yellow", "fg-flowers-4-yellow", "fg-flowers-5-yellow",
                      "fg-flowers-6-yellow", "fg-foilage-1-yellow", "fg-foilage-2-yellow", "fg-foilage-3-yellow", "fg-foilage-4-yellow"},
        }
    },

    --[[
        stage 1: stone,             rotated ledges, randomizers
        stage 2: *collapsing ledges, poles,          *brain
        stage 3: electric ledges,   moving ledges,  *heart
        stage 4: spiked ledges,     *deathslides,    *stomach
        stage 5: *lava ledges,       *ropeswings,     invisible ledges
    ]]
    stageGeneration = {
        -- stage 1: stone ledges, *randomizers, *rotated ledges
        [1] = {
            ledges = {
                distance  = { x={200, 250, 300, 350, 400, 450}, y={-200, -150, -100, -50, 0, 50, 100} },
                size      = { {85,"big"}, {100,"medium"} },
                variation = { {50,""}, {85,"2"}, {100,"3"} },
                surface   = { {100,stone} },
                --rotated   = { {80,0}, {85,-10}, {90,-5}, {95,5}, {100,10} },
                --[[special   = {
                    ["multiroute"] = {
                        chance   = {80},
                        gap      = {2,3},
                        length   = {3,4},
                    },
                }]]
            },
            objects = {
                --[[["obstruction"] = {
                    chanceAll = 50,
                    physics   = { {100,"wall"} },
                },]]
                ["randomizer"] = {
                    chance = {50},
                    gap    = {4,9},
                    items  = { {50,yellow}, {100,negTrajectory} },
                },
            }
        },
        -- stage 2: collapsing ledges, *small ledges, *poles, *brain
        [2] = {
            ledges = {
                size      = { {75,"big"}, {95,"medium"}, {100,"small"} },
                --surface   = { {80,stone}, {100,collapsing} },
                --[[special   = {
                    ["multiroute"] = { chance={80}, },
                }]]
            },
            obstacles = {
                ["pole"] = {
                    chance   = {90,50},
                    gap      = {1,9},
                    distance = { x={200, 250, 300, 350, 400, 450}, y={-150, -100, -50, 0} },
                    length   = { {50,200}, {75,250}, {100,300} },
                },
            },
            objects = {
                --[[["obstruction"] = {
                    chanceAll = 75,
                    physics   = { {75,"wall"}, {100,"spike"} },
                },]]
                ["randomizer"] = {
                    chance = {75},
                    items  = { {40,yellow}, {80,negTrajectory}, {100,gearSpringShoes} },
                },
                --[[["enemy-brain"] = {
                    chance   = {100, 75},
                    gap      = {1,4},
                    distance = { x={0}, y={-150, -100, -50, 0}, },
                    color    = { {100,"Purple"} },
                    size     = { {80,0.35}, {100,0.4} },
                    asleep   = 50,
                    moving   = {
                        pattern = { {100,moveTemplateVertical} },
                        speed   = {0.5},
                        pause   = {2000},
                        range   = {100,150,200},
                    },
                },]]
            }
        },
        -- stage 3: electric ledges, *moving ledges, *heart
        [3] = {
            ledges = {
                size      = { {60,"big"}, {85,"medium"},   {100,"small"} },
                --surface   = { {75,stone}, {85,collapsing}, {100,electric} },
                surface   = { {75,stone}, {100,electric} },
                special   = {
                    ["moving"] = {
                        chance   = {100,50},
                        gap      = {2,5},
                        pattern  = { {25,moveTemplateVertical}, {50,moveTemplateHorizontal}, {75,moveTemplateDiagonalUp}, {100,moveTemplateLeanedUp} },
                        speed    = {1},
                        pause    = {3000},
                        distance = {150,200,250},
                    },
                }
            },
            obstacles = {
                ["pole"] = { chance={50,50}, },
            },
            objects = {
                --[[["enemy-heart"] = {
                    chance   = {100, 50},
                    gap      = {1,4},
                    distance = { x={0, 50, 150, 200, 250}, y={-150, -100, -50, 0}, },
                    color    = { {100,"Red"} },
                    size     = { {80,0.4}, {100,0.5} },
                    thefts   = {2},
                    range    = {3,4,5},
                    speed    = {2},
                    pause    = {2000},
                },
                ["enemy-brain"] = {
                    chance   = {80,40},
                    size     = { {50,0.35}, {100,0.4} },
                    movement = {
                        pattern = { {50,moveTemplateVertical}, {100,moveTemplateHorizontal} },
                        speed   = {0.5, 0.75},
                    },
                },
                ["obstruction"] = {},]]  -- use prev rules
                ["randomizer"]  = {
                    chance = {90,10},
                    items  = { {40,yellow}, {80,negDizzy}, {100,gearTrajectory} },
                },
            }
        },
        -- stage 4: spiked ledges, deathslides, *stomach
        [4] = {
            ledges = {
                size      = { {50,"big"}, {75,"medium"}, {100,"small"} },
                --surface   = { {75,stone}, {80,collapsing}, {90,electric}, {100,spiked} },
                surface   = { {75,stone}, {100,spiked} },
                special   = {
                    ["moving"] = {
                        pattern  = { {25,moveTemplateDiagonalUp}, {50,moveTemplateSlantedUp}, {75,moveTemplateTriangleDown}, {100,moveTemplateSquare} },
                        speed    = {1.5},
                        distance = {200,250,300},
                    },
                }
            },
            obstacles = {
                --[[["deathslide"] = {
                    chance   = {100,75},
                    gap      = {2,3},
                    distance = { x={200, 250, 300, 350, 400, 450}, y={-250, -200, -150} },
                    length   = { {25,{700,0}}, {50,{700,300}}, {75,{700,-300}}, {100,{900,-500}} },
                    speed    = {3,4}
                },]]
                ["pole"] = { chance={50,30}, },
            },
            objects = {
                --[[["enemy-stomach"] = {
                    chance   = {100},
                    gap      = {2,4},
                    distance = { x={0, 50, 150, 200, 250}, y={-150, -100, -50, 0}, },
                    size     = { {80,0.7}, {100,0.8} },
                    ammo     = {negDizzy, negTrajectory, negBooster},
                    pattern  = { {100,movePatternFollow} },
                    range    = {4,5,6},
                    speed    = {3},
                    pause    = {1000},
                },
                ["enemy-heart"] = {
                    chance   = {80, 40},
                    range    = {4,5,6},
                    pause    = {1000,2000},
                },
                ["enemy-brain"] = {
                    chance   = {70,70},
                    size     = { {50,0.4}, {75,0.45}, {100,0.5} },
                    asleep   = 25,
                    pattern  = { {30,moveTemplateVertical}, {60,moveTemplateHorizontal}, {100,moveTemplateTriangleDown} },
                    speed    = {0.5, 0.75, 1},
                    steering = steeringMild,
                },
                ["obstruction"] = {},]]  -- use prev rules
                ["randomizer"]  = {
                    chance = {100,50},
                    items  = { {40,yellow}, {80,negBooster}, {100,gearParachute} },
                },
            }
        },
        -- stage 5: lava ledges, ropeswings, *invisible ledges
        [5] = {
            ledges = {
                size      = { {40,"big"}, {70,"medium"}, {100,"small"} },
                --surface   = { {70,stone}, {75,collapsing}, {80,electric}, {90,spiked}, {100,lava} },
                surface   = { {70,stone}, {80,electric}, {100,spiked} },
                special   = {
                    ["moving"] = {
                        chance   = {50,50},
                        pattern  = { {25,moveTemplateSlantedUp}, {50,moveTemplateTriangleDown}, {75,moveTemplateSquare}, {100,moveTemplateDiamond} },
                        speed    = {2},
                        distance = {250,300,350},
                    },
                    ["invisible"] = {
                        chance       = {100,70,50},
                        gap          = {1,2},
                        invisibleFor = {1000,2000},
                        visibleFor   = {3000,4000},
                        fadeFor      = {250,500},
                        alpha        = {0.5},
                    }
                }
            },
            obstacles = {
                --[[["ropeswing"] = {
                    chance   = {100,50},
                    gap      = {2,3},
                    distance = { x={350, 400, 450}, y={-300, -250, -200} },
                    length   = {200},
                    speed    = {1},
                    scenery  = {object="scenery", x=-300, y=-300, type="fg-rock-3", size=0.5, layer=2}
                },
                ["deathslide"] = {
                    chance   = {75,50},
                    gap      = {1,9},
                },]]
                ["pole"] = { chance={50,50}, },
            },
            objects = {
                --[[["enemy-stomach"] = {
                    chance   = {90,50},
                    speed    = {5},
                },
                ["enemy-heart"] = {
                    chance   = {70, 40},
                    color    = { {100,"White"} },
                    thefts   = {3},
                    range    = {5,6,7},
                    speed    = {3},
                    pause    = {0,1000},
                },
                ["enemy-brain"] = {
                    chance   = {90, 80},
                    asleep   = 0,
                    pattern  = { {25,moveTemplateVertical}, {50,moveTemplateHorizontal}, {75,moveTemplateSquare}, {100,moveTemplateDiamond} },
                    speed    = {0.75, 1, 1.25},
                    pause    = {1500},
                    range    = {150,200,250,300},
                },
                ["obstruction"] = {
                    physics   = { {50,"wall"}, {100,"spike"} },
                },]]
                ["randomizer"] = {
                    chance = {100,100},
                    items  = {{40,yellow},{80,negBooster},{100,gearShield}},
                },
            }
        },
    },

}

return levelData