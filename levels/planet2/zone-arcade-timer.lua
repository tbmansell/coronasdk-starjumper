local sharedRules = {
    ["bobbing-movement"] = {
        chanceAll = 10,
        pattern   = { {35,moveTemplateTriangleDown}, {65,moveTemplateSquare}, {100,moveTemplateDiamond} },
        speed     = {1},
        distance  = {50,100},
        steering  = steeringMild,
    },
    ["wall-images"]    = {"fg-rock-1", "fg-rock-2", "fg-rock-3", "fg-rock-4", "fg-rock-5", "fg-wall-divider", "fg-wall-divider-halfsize"},
    ["spike-images"]   = {"fg-spikes-float-1", "fg-spikes-float-2", "fg-spikes-float-3", "fg-spikes-float-4", "fg-spikes-float-5", "fg-wall-divider-spiked", "fg-wall-divider-halfsize-dbspiked"},
    ["emitter-images"] = {"fg-debris-helmet", "fg-debris-barrel-blue", "fg-debris-barrel-grey", "fg-debris-barrel-red"},
}


local levelData = {
    name             = "event horizon",
    tip              = "buy items to improve your chances of survival",
    timeBonusSeconds = 300,
    floor            = display.contentHeight*4,
    ceiling          = -display.contentHeight*4,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {1, 2, 3},
        [bgrBack]  = {},
        [bgrSky]   = {1, 2}
    },

    -- Starting game elements
    elements = {
        {object="ledge", type="start", stage=1},
    },

    -- Scenery that can appear in this planets game mode
    sceneryGeneration = {
        foreground = {},
        wall       = { images=sharedRules["wall-images"]  },
        spike      = { images=sharedRules["spike-images"] },
        ledge      = {
            chance = {50,50,25,10},
            images = {"fg-barrel-blue", "fg-barrel-grey", "fg-barrel-red"},
        }
    },

    --[[
        stage 1: collapsing ledges, rotated ledges,      bobbing ledges,  randomizers
        stage 2: ramp ledges,       moving ledges,       poles,           bobbing obstructions, enemy-ufos
        stage 3: oneshot ledges,    moving time bonuses, electric gates,  *asteroid emitters,   enemy-ringstealers
        stage 4: pulley ledges,     rotating ledges,     *rocket,         warp fields,          enemy-shooters
        stage 5: exploding ledges,  invsible ledges
    ]]
    stageGeneration = {
        --stage 1: collapsing ledges, rotated ledges, bobbing ledges, randomizers
        [1] = {
            ledges = {
                distance  = { x={200, 250, 300, 350, 400, 450, 500}, y={-200, -150, -100, -50, 0, 50, 100, 150, 200} },
                size      = { {70,"big"}, {85,"medbig"}, {100,"medium"} },
                variation = { {50,""}, {75,"2"}, {100,"3"} },
                surface   = { {70,girder}, {100,collapsing} },
                rotated   = { {80,0}, {85,-15}, {90,-10}, {95,10}, {100,15} },
                bobbing   = sharedRules["bobbing-movement"],
                special   = {
                    ["multiroute"] = {
                        chance   = {50},
                        gap      = {2,3},
                        length   = {3,4},
                    },
                }
            },
            objects = {
                ["emitter"] = {
                    chance   = {100,50},
                    gap      = {1,2},
                    distance = { x={0}, y={-1000,1000} },
                    timer    = {2000, 4000},
                    limit    = nil,
                    force    = { {50,200}, {100,300}, {45,365} },
                    items    = {
                        {25,  {"scenery", sharedRules["emitter-images"][1]} },
                        {50,  {"scenery", sharedRules["emitter-images"][2]} },
                        {75,  {"scenery", sharedRules["emitter-images"][3]} },
                        {100, {"scenery", sharedRules["emitter-images"][4]} },
                    }
                },
                ["obstruction"] = {
                    chanceAll = 50,
                    physics   = { {100,"wall"} },
                    bobbing   = sharedRules["bobbing-movement"],
                },
                ["randomizer"] = {
                    chance = {50},
                    gap    = {4,9},
                    items  = { {50,yellow}, {100,negDizzy} },
                },
                ["timebonus"] = {
                    chance   = {100,100,100},
                    gap      = {2,4},
                    location = { {50,"onledge"}, {75,"inair"}, {100,"moving"} },
                    inair    = {
                        jump = { {50,jumpMaxLow}, {100,jumpMaxHigh} },
                        arc  = { 30, 40, 50 },
                    },
                    moving = {
                        pattern  = { {35,moveTemplateTriangleDown}, {65,moveTemplateSquare}, {100,moveTemplateDiamond} },
                        speed    = {1,2,3},
                        distance = {50,100,150,200,250},
                        steering = steeringMild,
                    },
                },
            }
        },
        -- stage 2: ramp ledges, moving ledges, poles, bobbing obstructions
        [2] = {
            ledges = {
                surface = { {70,girder}, {100,ramp} },
                bobbing = { chanceAll=20 },
                special = {
                    ["multiroute"] = {},  -- use prev rule
                    ["moving"] = {
                        chance   = {100,50},
                        gap      = {2,5},
                        pattern  = { {25,moveTemplateVertical}, {50,moveTemplateHorizontal}, {75,moveTemplateDiagonalUp}, {100,moveTemplateSlantedUp} },
                        speed    = {1},
                        pause    = {3000},
                        distance = {150,200,250},
                    },
                }
            },
            objects = {
                ["enemy-greyufo"] = {
                    chance   = {100, 75},
                    gap      = {1,4},
                    distance = { x={0}, y={-150, -100, -50, 0}, },
                    moving   = {
                        pattern  = { {25,moveTemplateLeftArc}, {50,moveTemplateRightArc}, {75,moveTemplateTriangleDown}, {100,moveTemplateSquare} },
                        speed    = {4,6},
                        pause    = {0},
                        range    = {150,200,250},
                        steering = steeringMild,
                    },
                },
                ["emitter"]     = {},  -- use prev rule
                ["obstruction"] = {
                    physics   = { {75,"wall"}, {100,"spike"} },
                    bobbing   = { chanceAll=20 },
                },
                ["randomizer"] = { items={ {40,yellow}, {80,negDizzy}, {100,gearSpringShoes} }, },
                ["timebonus"]  = {},  -- use prev rule
            },
        },
        -- stage 3: oneshot ledges, moving time bonuses, electric gates, asteroid emitters
        [3] = {
            ledges = {
                size    = { {70,"big"}, {80,"medbig"}, {90,"medium"}, {100, "medsmall"} },
                surface = { {70,girder}, {100,oneshot} },
                bobbing = { chanceAll=30, },
                special = {
                    ["multiroute"] = {},  -- use prev rule
                    ["moving"] = {
                        chance   = {50,50},
                        pattern  = { {25,moveTemplateDiagonalUp}, {50,moveTemplateLeanedUp}, {75,moveTemplateTriangleDown}, {100,moveTemplateSquare} },
                        speed    = {1.5},
                        distance = {200,250,300},
                    },
                }
            },
            obstacles = {
                ["electricgate"] = {
                    chance   = {100,50},
                    gap      = {2,3},
                    distance = { x={200, 250, 300, 350, 400, 450}, y={-150, -100, -50, 0} },
                    timer    = {2000,2500,3000},
                },
            },
            objects = {
                ["enemy-greyufo"] = {
                    chance = {80, 40, 20},
                    moving = {
                        pattern = { {50,moveTemplateDiamond}, {75,moveTemplateTriangleDown}, {100,moveTemplateSquare} },
                        range   = {200,250,300},
                    },
                },
                ["enemy-greynapper"] = {
                    chance   = {100, 75},
                    gap      = {1,4},
                    distance = { x={0,100,150}, y={-250, -200, -150, -100}, },
                    moving   = {
                        pattern  = { {25,moveTemplateSquare}, {50,moveTemplateDiamond}, {75,moveTemplateWhooshOval}, {100,moveTemplateShooter1} },
                        followXOnly = { {100,true} },
                        speed       = {4,6},
                        pause       = {1,500,1000,1500},
                        range       = {150,200,250},
                        steering    = steeringMild,
                    },
                },
                ["emitter"]    = {
                    chance   = {50,50},
                    timer    = {4000, 6000},
                    items    = {
                        {12,  {"scenery", sharedRules["emitter-images"][1]} },
                        {25,  {"scenery", sharedRules["emitter-images"][2]} },
                        {38,  {"scenery", sharedRules["emitter-images"][3]} },
                        {50,  {"scenery", sharedRules["emitter-images"][4]} },
                        {60,  {"wall",    sharedRules["wall-images"][1]} },
                        {70,  {"wall",    sharedRules["wall-images"][2]} },
                        {80,  {"wall",    sharedRules["wall-images"][3]} },
                        {90,  {"wall",    sharedRules["wall-images"][4]} },
                        {100, {"wall",    sharedRules["wall-images"][5]} },
                    }
                },
                ["obstruction"] = {
                    physics   = { {50,"wall"}, {100,"spike"} },
                    bobbing   = { chanceAll=30 },
                },
                ["randomizer"] = { items={ {40,yellow}, {80,negTrajectory}, {100,gearFreezeTime} }, },
                ["timebonus"] = {},  -- use prev rule
            }
        },
        -- stage 4: pulley ledges, rotating ledges, rocket, warp fields
        [4] = {
            ledges = {
                size      = { {60,"big"}, {70,"medbig"}, {80,"medium"}, {90, "medsmall"}, {100,"small"} },
                surface   = { {70,girder}, {100,pulley} },
                pulley    = { {50,-2000}, {100,2000} },
                rotating  = { {15,15}, {30,25} },
                bobbing   = { chanceAll=40 },
                special   = {
                    ["multiroute"] = {},  -- use prev rule
                    ["moving"] = {
                        pattern  = { {35,moveTemplateTriangleDown}, {65,moveTemplateSquare}, {100,moveTemplateDiamond} },
                        speed    = {3},
                        distance = {250,300,350},
                    },
                }
            },
            obstacles = {
                ["electricgate"] = { chance={75}, },
            },
            objects = {
                ["enemy-greyufo"] = {
                    chance = {70,40},
                    moving = {
                        pattern = { {50,moveTemplateDiamond}, {100,moveTemplateCross} },
                        range   = {250,300,350},
                    },
                },
                ["enemy-greynapper"] = {
                    chance   = {80, 40},
                    moving   = {
                        pattern = { {25,moveTemplateSquare}, {50,moveTemplateDiamond}, {75,moveTemplateWhooshOval}, {100,moveTemplateShooter1} },
                        speed   = {7,8,9},
                        range   = {150,200,250,300,350},
                    },
                },
                ["enemy-greyshooter"] = {
                    chance   = {100, 75},
                    gap      = {1,4},
                    distance = { x={0,100,150}, y={-250, -200, -150, -100}, },
                    moving   = {
                        pattern  = { {25,moveTemplateSquare}, {50,moveTemplateDiamond}, {100,moveTemplateShooter1} },
                        followXOnly = { {100,true} },
                        speed       = {4,6},
                        pause       = {1,500,1000,1500},
                        range       = {150,200,250},
                        steering    = steeringMild,
                    },
                    shooting = {
                        ammo     = {negDizzy, negTrajectory},
                        wait     = { {100,{1,3}} },
                        velocity = { {100,{100,100}} },
                        maxItems = { {100,10} },
                    },
                },
                ["emitter"]     = {},  -- use prev rule
                ["obstruction"] = { bobbing={ chanceAll=40 }, },
                ["randomizer"]  = { items={ {20,yellow}, {20,negTrajectory}, {60,negBooster}, {80,gearFreezeTime}, {100,gearGloves} }, },
                ["timebonus"]   = {},  -- use prev rule
                ["warpfield"]   = {
                    chance   = {100,50},
                    gap      = {2,3},
                    size     = {0.5}
                },
            }
        },
        -- stage 5: exploding ledges, invsible ledges
        [5] = {
            ledges = {
                size      = { {50,"big"}, {60,"medbig"}, {70,"medium"}, {90, "medsmall"}, {100,"small"} },
                surface   = { {70,girder}, {100,exploding} },
                rotating  = { {15,10}, {30,15}, {50,25} },
                bobbing   = { chanceAll=50 },
                special   = {
                    ["multiroute"] = {},  -- use prev rule
                    ["moving"] = {
                        speed = {4},
                        pause = {2000},
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
                ["electricgate"] = { chance={75, 50}, },
            },
            objects = {
                ["enemy-greyufo"] = {
                    chance = {100,50},
                    moving = {
                        pattern = { {25,moveTemplateCross}, {75,moveTemplateWhooshOval}, {100,moveTemplateShooter1} },
                    },
                },
                ["enemy-greynapper"] = {
                    chance = {80,50},
                    moving = {
                        pattern = { {25,moveTemplateSquare}, {50,moveTemplateDiamond}, {75,moveTemplateWhooshOval}, {100,moveTemplateShooter1} },
                    },
                },
                ["enemy-greyshooter"] = {
                    chance   = {80,50},
                    moving   = {
                        pattern  = { {25,moveTemplateSquare}, {50,moveTemplateDiamond}, {100,moveTemplateShooter1} },
                    },
                    shooting = {
                        ammo     = {negDizzy, negTrajectory},
                        wait     = { {100,{1,3}} },
                        maxItems = { {100,10} },
                    },
                },
                ["emitter"]     = {},  --use prev rule
                ["obstruction"] = { bobbing={ chanceAll=50 }, },
                ["randomizer"]  = { items={ {20,yellow}, {20,negTrajectory}, {60,negBooster}, {80,gearFreezeTime}, {100,gearShield} }, },
                ["timebonus"]   = {},  -- use prev rule
                ["warpfield"] = {
                    chance = {90,60,40},
                    size   = {0.6}
                },
            }
        },
    },
}
--412
return levelData