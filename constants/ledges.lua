-- sizes
big      = "big"
medbig   = "medbig"
medium   = "medium"
medsmall = "medsmall"
small    = "small"

--ledge surfaces
stone      = "stone"
girder     = "girder"
ice        = "ice"
grass      = "grass"
lava       = "lava"
exploding  = "exploding"
collapsing = "collapsing"
electric   = "electric"
spiked     = "spiked"
spring     = "spring"
pulley     = "pulley"
ramp       = "ramp"
oneshot    = "oneshot"

spineSurfaces = {
    [lava]       = true,
    [exploding]  = true,
    [collapsing] = true,
    [electric]   = true,
    [spiked]     = true,
    [spring]     = true,
    [pulley]     = true,
    [ramp]       = true,
    [oneshot]    = true,
}

deadlyTimedSurfaces = {
    [electric] = true,
    [spiked]   = true,
}

-- ledge score categories
scoreCategoryFirst  = 1
scoreCategorySecond = 2
scoreCategoryThird  = 3
