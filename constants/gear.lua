-- gear categories
jump     = 1
air      = 2
land     = 3
negGood  = 4
negEnemy = 5

gearNames = {
    [jump]     = "jump",
    [air]      = "air",
    [land]     = "land",
    [negGood]  = "good",
    [negEnemy] = "enemy",
}

-- gear names otherwise if images renamed, then we have to rename all over the code
gearSpringShoes = "springshoes"
gearShield      = "shield"
gearFreezeTime  = "freezetime"
gearTrajectory  = "trajectory"

gearGlider      = "glider"
gearParachute   = "parachute"
gearJetpack     = "jetpack"
gearReverseJump = "reversejump"

gearMagnet      = "magnet"
gearDestroyer   = "destroyer"
gearGrappleHook = "grapplehook"
gearGloves      = "gloves"

-- negable names
negDizzy        = "dizzy"
negBooster      = "fixedbooster"

negTrajectory   = "antitrajectory"
negRocket       = "fixedrocket"
negFreezeTarget = "freezetarget"
negImpactBomb   = "impactbomb"

negGravField    = "gravfield"
negTimeBomb     = "timebomb"
negElectrifier  = "electrifier"
negBackPorter   = "backporter"


gearSlots = {
    [gearShield]        = jump,
    [gearFreezeTime]    = jump,
    [gearSpringShoes]   = jump,
    [gearTrajectory]    = jump,
    [gearGlider]        = air,
    [gearParachute]     = air,
    [gearJetpack]       = air,
    [gearReverseJump]   = air,
    [gearMagnet]        = land,
    [gearDestroyer]     = land,
    [gearGrappleHook]   = land,
    [gearGloves]        = land,
    -- negables used as gear for race throwing
    [negTrajectory]     = negGood,
    [negRocket]         = negGood,
    [negFreezeTarget]   = negGood,
    [negImpactBomb]     = negGood,
    [negGravField]      = negEnemy,
    [negTimeBomb]       = negEnemy,
    [negElectrifier]    = negEnemy,
    [negBackPorter]     = negEnemy,
}

-- when certain negables hijack a player gear, this lists which category they take over
negableSlots = {
    [negTrajectory] = jump,
    [negDizzy]      = jump,
    [negBooster]    = air,
    [negRocket]     = air,
    [negTimeBomb]   = land,
}

gearUnlocks = {
    [gearTrajectory]    = {unlockAfter=1,  buyMode="both"},
    [gearShield]        = {unlockAfter=2,  buyMode="both"},
    [gearFreezeTime]    = {unlockAfter=3,  buyMode="both"},
    [gearSpringShoes]   = {unlockAfter=4,  buyMode="both"},
    [gearGlider]        = {unlockAfter=5,  buyMode="both"},
    [gearParachute]     = {unlockAfter=6,  buyMode="both"},
    [gearJetpack]       = {unlockAfter=7,  buyMode="both"},
    [gearReverseJump]   = {unlockAfter=8,  buyMode="both"},
    [gearMagnet]        = {unlockAfter=9,  buyMode="both"},
    [gearDestroyer]     = {unlockAfter=10, buyMode="both"},
    [gearGrappleHook]   = {unlockAfter=11, buyMode="both"},
    [gearGloves]        = {unlockAfter=12, buyMode="both"},
}
