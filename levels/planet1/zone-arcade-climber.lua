local levelData = {
    name             = "lava chase",
    tip              = "buy items to improve your jumping ability",
    floor            = display.contentHeight,
    ceiling          = -display.contentHeight*20,
    startAtNight     = true,
    lavaChase        = true,

    backgroundOrder = {
        [bgrFront] = {1, 2, 3, 4},
        [bgrMid]   = {1, 2, 3, 4},
        [bgrBack]  = {1, 2, 3, 4},
        [bgrSky]   = {1, 2}
    },

    backgroundSounds = {
        {sound=sounds.backgroundSoundWind4, quietTime=1000, minVolume=2, maxVolume=6},
        {sound=sounds.backgroundSoundWind5, quietTime=3000, minVolume=9, maxVolume=10},
    },

    -- Starting game elements
    elements = {
        {object="ledge", type="start", style="start-middle", stage=1},
            {object="scenery", x=-4230, y=50,  type="fg-wall-middle", size=1, copy=40, stage=1, layer=2},
            {object="scenery", x=-4230, y=100, type="fg-wall-middle", size=1, copy=40, stage=1, layer=2},
            {object="scenery", x=-4380, y=150, type="fg-wall-middle", size=1, copy=40, stage=1, layer=2},
    },

    -- Scenery that can appear in this planets game mode
    sceneryGeneration = {
        foreground = {
            ["foreground-trees"] = {
                chance = {0},
            },
        },
        wall = {
            images = {"fg-rock-1", "fg-rock-3", "fg-rock-4"},
        },
        spike = {
            images = {"fg-spikes-float-1", "fg-spikes-float-2", "fg-spikes-float-3", "fg-spikes-float-4", "fg-spikes-float-5"},
        },
        ledge = {
            chance = {50,50,25,10},
            images = {"fg-flowers-1-yellow", "fg-flowers-2-yellow", "fg-flowers-3-yellow", "fg-flowers-4-yellow", "fg-flowers-5-yellow", "fg-flowers-6-yellow",
                      "fg-foilage-1-yellow", "fg-foilage-2-yellow", "fg-foilage-3-yellow", "fg-foilage-4-yellow", 
                      -- duplicate the fauna to give it more chance of appearing
                      "fg-foilage-1-yellow", "fg-foilage-2-yellow", "fg-foilage-3-yellow", "fg-foilage-4-yellow"},
        }
    },

    --[[
        stage 1: stone,             rotated ledges, randomizers
        stage 2: lava ledges,                       hearts,
        stage 3: collapsing ledges, ropeswings,     brains,
        stage 4: spiked ledges,     deathslides,    stomachs,
        stage 5: invisible ledges,  moving ledges
    ]]
    stageGeneration = {
        -- stage 1: stone, lava ledges, rotated ledges, randomizers
        [1] = {
            ledges = {
                distance  = { x={-450, -400, -350, -300, -250, -200, 200, 250, 300, 350, 400, 450}, y={-280, -250, -200, -150} },
                size      = { {85,"big"}, {100,"medium"} },
                variation = { {50,""}, {85,"2"}, {100,"3"} },
                surface   = { {100,stone} },
                rotated   = { {80,0}, {85,-10}, {90,-5}, {95,5}, {100,10} },
            },
            objects = {
                ["obstruction"] = {
                    chanceAll = 75,
                    physics   = { {75,"wall"}, {100,"spike"} },
                },
                ["randomizer"]  = {
                    chance = {50},
                    gap    = {4,9},
                    items  = { {50,gearGloves}, {100,negTrajectory} },
                },
                ["rings"] = {
                    chance   = {100,100,100},
                    gap      = {2,3},
                    location = { {50,"onledge"}, {100,"inair"} },
                    inair    = {
                        arc  = { 30, 40, 50 },
                        jump = { {50,jumpMaxLow}, {100,jumpMaxHigh} },
                    },
                },
            }
        },
        -- stage 2: lava ledges, hearts,
        [2] = {
            ledges = {
                size    = { {75,"big"}, {95,"medium"}, {100,"small"} },
                surface = { {80,stone}, {100,lava} },
            },
            objects = {
                ["enemy-heart"] = {
                    chance   = {100, 50},
                    gap      = {1,4},
                    distance = { x={0}, y={-150, -100, -5, 0, 50}, },
                    color    = { {100,"Red"} },
                    size     = { {80,0.4}, {100,0.5} },
                    thefts   = {2},
                    range    = {3,4,5},
                    speed    = {2},
                    pause    = {2000},
                },
                ["obstruction"] = {},  -- use prev rule
                ["randomizer"]  = { items={ {50,gearGloves}, {100,negTrajectory} }, },
                ["rings"]       = {},  -- use prev rule
            }
        },
        -- stage 3: collapsing ledges, ropeswings, brains,
        [3] = {
            ledges = {
                size    = { {75,"big"}, {90,"medium"}, {100,"small"} },
                surface = { {80,stone}, {90,lava}, {100,collapsing} },
            },
            obstacles = {
                ["ropeswing"] = {
                    chance   = {100,50},
                    gap      = {2,3},
                    distance = { x={-350, -300, -250, -200, 200, 250, 300, 350}, y={-300, -250} },
                    length   = {200},
                    speed    = {1},
                    scenery  = {object="scenery", x=-300, y=-300, type="fg-rock-3", size=0.5, layer=2}
                },
            },
            objects = {
                ["enemy-brain"] = {
                    chance   = {100,50,25},
                    gap      = {2,4},
                    distance = { x={0}, y={-200, -150, -100}, },
                    color    = { {100,"Purple"} },
                    size     = { {80,0.35}, {100,0.4} },
                    asleep   = 50,
                    pattern  = { {50,moveTemplateVertical}, {100,moveTemplateHorizontal} },
                    speed    = {1},
                    pause    = {2000},
                    range    = {100,150,200},
                },
                ["enemy-heart"] = { chance={75, 30}, },
                ["obstruction"] = { physics={ {50,"wall"}, {100,"spike"} }, },
                ["randomizer"]  = { items={ {50,gearGloves}, {100,negTrajectory} }, },
                ["rings"]       = {},  -- use prev rules
            }
        },
        --stage 4: spiked ledges, deathslides, stomachs,
        [4] = {
            ledges = {
                size    = { {75,"big"}, {85,"medium"}, {100,"small"} },
                surface = { {70,stone}, {80,lava}, {90,collapsing}, {100,spiked} },
            },
            obstacles = {
                ["deathslide"] = {
                    chance   = {100,50},
                    gap      = {2,3},
                    distance = { x={-350, -300, -250, -200, 200, 250, 300, 350}, y={-300, -250} },
                    length   = { {25,{-700,-700}}, {50,{-900,-500}}, {75,{700,-700}}, {100,{900,-500}} },
                    speed    = {3,4}
                },
            },
            objects = {
                ["enemy-brain"] = {
                    chance   = {80,50},
                    asleep   = 25,
                    pattern  = { {35,moveTemplateTriangleDown}, {65,moveTemplateSquare}, {100,moveTemplateDiamond} },
                    speed    = {2,3},
                    pause    = {0},
                    range    = {200,300,400},
                    steering = steeringMild,
                },
                ["enemy-heart"] = {
                    chance   = {80},
                    color    = { {50,"Red"}, {100,"White"} },
                    speed    = {4},
                    pause    = {500},
                },
                ["enemy-stomach"] = {
                    distance = { x={0}, y={-150, -100, -5, 0, 50}, },
                    chance   = {100},
                    gap      = {1,9},
                    size     = { {80,0.7}, {100,0.8} },
                    ammo     = {negDizzy, negTrajectory, negBooster},
                    pattern  = { {100,movePatternFollow} },
                    range    = {4,5,6},
                    speed    = {3},
                    pause    = {1000},
                },
                ["obstruction"] = { physics={ {25,"wall"}, {100,"spike"} }, },
                ["randomizer"]  = { items={ {50,gearGloves}, {100,negTrajectory} }, },
                ["rings"]       = {},  -- use prev rule
            }
        },
        -- stage 5: invisible ledges, moving ledges
        [5] = {
            ledges = {
                special = {
                    ["moving"] = {
                        chance   = {100,75,50},
                        gap      = {2,5},
                        pattern  = { {25,strightUpPattern}, {50,moveTemplateTriangleDown}, {75,moveTemplateSquare}, {100,moveTemplateDiamond} },
                        speed    = {2,3,4},
                        pause    = {1000,1500,2000},
                        distance = {250,300,350,400},
                    },
                    ["invisible"] = {
                        chance       = {100,70,50},
                        gap          = {1,2},
                        invisibleFor = {1000,2000},
                        visibleFor   = {3000,4000},
                        fadeFor      = {250,500},
                        alpha        = {0.5},
                    },
                }
            },
            obstacles = {
                ["ropeswing"]  = { chance={80,60}, },
                ["deathslide"] = { chance={80,60}, },
            },
            otherObjects = {
                ["enemy-brain"] = {
                    asleep   = 0,
                    speed    = {3,4},
                },
                ["enemy-heart"] = {
                    gap      = {1,4},
                    distance = { x={0, 50, 150, 200, 250}, y={-100, -50, 0, 50}, },
                    color    = { {100,"White"} },
                },
                ["enemy-stomach"] = { chance={80}, },
                ["obstruction"]   = {},  -- use prev rule 
                ["randomizer"]    = { items={ {50,gearShield}, {100,negBooster} }, },
                ["rings"]         = {},  -- use prev rule
            }
        },
    }

}

return levelData