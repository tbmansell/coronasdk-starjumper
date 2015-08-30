local messages = {
    ["gear"] = {
        [jump] = {
            [gearSpringShoes] = {"spring shoes",    "jump from the spot without running to the end of the ledge",           3},
            [gearFreezeTime]  = {"freeze time",     "pause time until your jump completes, use icon below you to cancel",   6},
            [gearShield]      = {"force shield",    "dangerous enemies and obstacles cannot harm you for 10 seconds",       8},
            [gearTrajectory]  = {"jump trajectory", "computer display calculates the jump path as you plan your jump",      10},
        },
        [air] = {
            [gearGlider]      = {"glider",          "tap screen mid-jump to activate your glider wings for long distances", 5},
            [gearParachute]   = {"parachute",       "tap screen mid-jump to activate a parachute to avoid missing a ledge", 6},
            [gearJetpack]     = {"jetpack",         "tap screen mid-jump to boost your jump, until the fuel runs out",      6},
            [gearReverseJump] = {"reverse time",    "tap screen mid-jump to reverse time and return to the ledge",          10},
        },
        [land] = {
            [gearMagnet]      = {"item magnet",     "nearby items will shoot towards you for 10 seconds",                   5},
            [gearDestroyer]   = {"destroyer",       "destroys any enemies nearby when landing on a ledge",                  5},
            [gearGloves]      = {"climbing gloves", "automatically climb up a ledge if you hit it from the front",          10},
            [gearGrappleHook] = {"grapple hook",    "automatically hook on the back of a ledge if you overshoot it",        10},
        }
    },
    ["negable"] = {
        [jump] = {
            [negTrajectory]   = {"no jump grid",    "your computer is malfunctioning and the jump grid is not displayed"},
            [negDizzy]        = {"dizzy",           "things are looking quite strange, try and keep your head together"},
        },
        [air]  = {
            [negBooster]      = {"bad booster",     "a booster has attached to you increasing your jump distance"},
            [negRocket]       = {"bad rocket",      "a rocket has attached to you increasing your jump height"},
        },
    },

    ["jump"] = {
        ["top-score"] = {
            "great landing!",
            "great jump!",
            "top scoring jump!",
            "you aced it!",
            "you made it look easy"
        },
    },
    ["died"] = {
        ["jump-missed-wide"]  = {
            "way out!",
            "missed by miles",
            "what ledge?",
            "woah there!",
            "too far out"
        },
        ["jump-missed-close"] = {
            "so close!",
            "oh no just missed!",
            "nearly had it!",
            "almost there",
            "very nearly there"
        },
        ["jump-missed-slip"]  = {
            "whoops!",
            "wha - oh noooo!",
            "yikes!",
            "just slipped!",
            "oh so close!",
        },
        ["lava-ledge"] = {
            "toasted!",
            "ouch hot stuff!",
            "burnt out!",
            "jump before it burns",
            "you are fired",
        },
        ["electric-ledge"] = {
            "shocking stuff",
            "fried!",
            "electrifying!",
            "jump burn it charges",
            "zzzzzaaap!",
        },
        ["exploding-ledge"] = {
            "you bombed out",
            "booooom!",
            "explosive stuff",
            "jump before it blows",
            "mind blowing",
        },
        ["spiked-ledge"] = {
            "ouch!",
            "mind the spikes!",
            "jump before the spikes strike",
            "sharpen up",
            "sliced n diced"
        },
        ["collapsing-ledge"] = {
            "woah mind the gap!",
            "lay off the pies!",
            "a hole appeared to swallow you up",
            "you fell for it"
        },
        ["spike"] = {
            "ouch!",
            "mind the spikes!",
            "sharpen up",
            "sliced n diced"
        },
        ["enemy-brain"] = {
            "mmmmm brain harvest!",
            "watch the flying brain eaters!"
        },
        ["enemy-greyufo"] = {
            "we do not come in peace",
            "mind the paintwork!",
            "get outer this space"
        },
    }
}


return messages