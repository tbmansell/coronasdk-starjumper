local sharedRules = {
    ["bobbing-movement"] = {
        chanceAll = 10,
        pattern   = { {35,moveTemplateTriangleDown}, {65,moveTemplateSquare}, {100,moveTemplateDiamond} },
        speed     = {1},
        distance  = {50,100},
        steering  = steeringMild,
    },
    ["wall-images"]    = {"fg-rock-1", "fg-rock-2", "fg-rock-3", "fg-rock-4", "fg-rock-5"},
    ["spike-images"]   = {"fg-spikes-float-1", "fg-spikes-float-2", "fg-spikes-float-3", "fg-spikes-float-4", "fg-spikes-float-5"},
    ["emitter-images"] = {"fg-debris-helmet", "fg-debris-barrel-blue", "fg-debris-barrel-grey", "fg-debris-barrel-red"},
}


local levelData = {
    name        = "escape the apocalypsoid singularity",
    tip         = "buy items to improve your jumping ability",
    floor       = display.contentHeight,
    ceiling     = -display.contentHeight*20,
    warpChase   = true,

    backgroundOrder = {
        [bgrFront] = {},
        [bgrMid]   = {1, 2, 3},
        [bgrBack]  = {},
        [bgrSky]   = {1, 2}
    },

    -- Starting game elements
    elements = {
        {object="ledge", type="start", style="start-middle", stage=1},
    },

    -- Scenery that can appear in this planets game mode
    sceneryGeneration = {
        foreground = {},
        wall       = { images=sharedRules["wall-images"] },
        spike      = { images=sharedRules["spike-images"] },
        ledge      = {
            chance = {50,50,25,10},
            images = {"fg-barrel-blue", "fg-barrel-grey", "fg-barrel-red"},
        }
    },

    --[[
        stage 1: ramp       ledges, rotated ledges,     randomizers,        bobbing ledges & obstructions, 
        stage 2: oneshot    ledges, *rocket ledges,     enemy-ringstealers, 
        stage 3: collapsing ledges, asteroid emitters   enemy-ufos,         *moving rings,
        stage 4: rotating   ledges, warpfields,         enemy-shooters,
        stage 5: exploding  ledges, invisible ledges,   moving ledges
    ]]
    stageGeneration = {
        -- stage 1: ramp ledges, rotated ledges, randomizers, bobbing ledges & obstructions, 
        [1] = {
            ledges = {
                distance  = { x={-450, -400, -350, -300, -250, -200, 200, 250, 300, 350, 400, 450}, y={-250, -200, -150} },
                size      = { {70,"big"}, {85,"medbig"}, {100,"medium"} },
                variation = { {50,""}, {85,"2"}, {100,"3"} },
                surface   = { {85,girder}, {100,ramp} },
                rotated   = { {80,0}, {85,-10}, {90,-5}, {95,5}, {100,10} },
                bobbing   = sharedRules["bobbing-movement"],
            },
            objects = {
                ["emitter"] = {
                    chance   = {100,100},
                    gap      = {1,2},
                    distance = { x={0}, y={-3000} },
                    timer    = {2000, 4000},
                    limit    = nil,
                    force    = { {-300,300}, {100,800}, {45,365} },
                    items    = {
                        {25,  {"scenery", sharedRules["emitter-images"][1]} },
                        {50,  {"scenery", sharedRules["emitter-images"][2]} },
                        {75,  {"scenery", sharedRules["emitter-images"][3]} },
                        {100, {"scenery", sharedRules["emitter-images"][4]} },
                    }
                },
                ["obstruction"] = {
                    chanceAll = 75,
                    physics   = { {75,"wall"}, {100,"spike"} },
                    bobbing   = sharedRules["bobbing-movement"],
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
        -- stage 2: oneshot ledges, *rocket ledges, enemy-ringstealers, 
        [2] = {
            ledges = {
                size    = { {75,"big"}, {95,"medium"}, {100,"small"} },
                surface = { {85,girder}, {90,ramp}, {100,oneshot} },
                bobbing = { chanceAll=20 },
            },
            objects = {
                ["emitter"] = {},  -- use prev rule
                ["enemy-greynapper"] = {
                    chance   = {100, 50},
                    gap      = {1,4},
                    distance = { x={0,100,150}, y={-250, -200, -150, -100}, },
                    moving   = {
                        pattern  = { {25,moveTemplateSquare}, {50,moveTemplateDiamond}, {75,moveTemplateWhooshOval}, {100,moveTemplateShooter1} },
                        followYOnly = { {100,true} },
                        speed       = {4,6},
                        pause       = {1,500,1000,1500},
                        range       = {150,200,250},
                        steering    = steeringMild,
                    },
                },
                ["obstruction"] = { bobbing={ chanceAll=20 }, },
                ["randomizer"]  = { items={ {50,gearGloves}, {100,negTrajectory} }, },
                ["rings"]       = {},  -- use prev rule
            }
        },
        -- stage 3: collapsing ledges, asteroid emitters, enemy-ufos, moving rings,
        [3] = {
            ledges = {
                size    = { {70,"big"}, {80,"medbig"}, {90,"medium"}, {100, "medsmall"} },
                surface = { {85,girder}, {90,oneshot}, {100,collapsing} },
                bobbing = { chanceAll=20 },
            },
            objects = {
                ["emitter"] = {
                    chance = {50,50},
                    timer  = {4000, 6000},
                    items  = {
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
                ["enemy-greyufo"] = {
                    chance   = {100, 75},
                    gap      = {2,4},
                    distance = { x={0}, y={-200, -150, -100}, },
                    moving   = {
                        pattern  = { {25,moveTemplateLeftArc}, {50,moveTemplateRightArc}, {75,moveTemplateTriangleDown}, {100,moveTemplateSquare} },
                        speed    = {4,6},
                        pause    = {0},
                        range    = {150,200,250},
                        steering = steeringMild,
                    },
                },
                ["enemy-greynapper"] = { chance={75, 30}, },
                ["obstruction"] = {
                    physics = { {50,"wall"}, {100,"spike"} }, 
                    bobbing = { chanceAll=30 },
                },
                ["randomizer"]  = { items={ {50,gearGloves}, {100,negTrajectory} }, },
                ["rings"]       = {},  -- use prev rules
            }
        },
        -- stage 4: rotating ledges, enemy-shooters, warpfields,
        [4] = {
            ledges = {
                size     = { {60,"big"}, {70,"medbig"}, {80,"medium"}, {90, "medsmall"}, {100,"small"} },
                rotating = { {15,15}, {30,25} },
                bobbing  = { chanceAll=40 },
            },
            obstacles = {
                ["electricgate"] = {
                    chance   = {100},
                    gap      = {2,3},
                    distance = { x={-450,-400,-350,-300,-250,-200, 200,250,300,350,400,450}, y={-200, -150, -100} },
                    timer    = {2000,2500,3000},
                },
            },
            objects = {
                ["emitter"] = {},  -- use prev rule
                ["enemy-greyufo"] = {
                    chance = {80, 40, 20},
                    moving = {
                        pattern = { {50,moveTemplateDiamond}, {75,moveTemplateTriangleDown}, {100,moveTemplateSquare} },
                        range   = {200,250,300},
                    },
                },
                ["enemy-greynapper"] = {
                    chance = {80},
                    speed  = {8},
                    pause  = {500},
                },
                ["enemy-greyshooter"] = {
                    chance   = {100, 75},
                    gap      = {1,4},
                    distance = { x={0,100,150}, y={-150, -100}, },
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
                ["obstruction"] = { 
                    physics = { {25,"wall"}, {100,"spike"} }, 
                    bobbing = { chanceAll=40 },
                },
                ["randomizer"]  = { items={ {50,gearGloves}, {100,negTrajectory} }, },
                ["rings"]       = {},  -- use prev rule
            }
        },
        -- stage 5: exploding ledges, invisible ledges, moving ledges
        [5] = {
            ledges = {
                size     = { {50,"big"}, {60,"medbig"}, {70,"medium"}, {90, "medsmall"}, {100,"small"} },
                surface  = { {70,girder}, {100,exploding} },
                rotating = { {15,10}, {30,15}, {50,25} },
                bobbing  = { chanceAll=50 },
                special  = {
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
                ["electricgate"] = { chance={80}, },
            },
            otherObjects = {
                ["emitter"] = {},  -- use prev rule
                ["enemy-greyufo"] = {
                    chance = {70,40},
                    moving = {
                        pattern = { {50,moveTemplateDiamond}, {100,moveTemplateCross} },
                        range   = {250,300,350},
                    },
                },
                ["enemy-greynapper"] = {},  -- use prev rule
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
                ["obstruction"]   = { bobbing={ chanceAll=50 }, },
                ["randomizer"]    = { items={ {50,gearShield}, {100,negBooster} }, },
                ["rings"]         = {},  -- use prev rule
            }
        },
    }

}

return levelData