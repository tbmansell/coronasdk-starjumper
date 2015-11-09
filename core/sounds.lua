local playerLoaded = {}

local loadSound   = audio.loadSound
local unloadSound = audio.dispose
local findChannel = audio.findFreeChannel
local setVolume   = audio.setVolume
local play        = audio.play

-- global sound 
sounds = {
    playerJump = {
        [characterSkyanna]   = {},
        [characterNewton]    = {},
        [characterHammer]    = {},
        [characterBrainiak]  = {},
        [characterGrey]      = {},
    },

    playerLand = {
        [characterSkyanna]   = {},
        [characterNewton]    = {},
        [characterHammer]    = {},
        [characterBrainiak]  = {},
        [characterGrey]      = {},
    },

    playerLandEdge = {
        [characterSkyanna]   = {},
        [characterNewton]    = {},
        [characterHammer]    = {},
        [characterBrainiak]  = {},
        [characterGrey]      = {},
    },

    playerCelebrate = {
        [characterSkyanna]   = {},
        [characterNewton]    = {},
        [characterHammer]    = {},
        [characterBrainiak]  = {},
        [characterGrey]      = {},
    },

    -- Groups of sounds
    rings        = {},
    impacts      = {},
    fuzzies      = {},
    greysTalking = {},
    playerFalls  = {},


    -- Background tunes:
    tuneTitle                   = loadSound("sounds/tunes/title_time100.mp3"),
    tuneZoneSelect              = loadSound("sounds/tunes/zoneSelect_time32.mp3"),
    tuneShop                    = loadSound("sounds/tunes/shop_time32.mp3"),
    tuneStory                   = loadSound("sounds/tunes/story_time183.mp3"),

    -- Scene & Menus:
    gameStart                   = loadSound("sounds/gameStart_time1.wav"),
    sceneEnter                  = loadSound("sounds/sceneEnter_time1.wav"),
    buttonClick                 = loadSound("sounds/buttonClick_time1.wav"),
    generalClick                = loadSound("sounds/generalClick_time1.wav"),
    zoneSummary                 = loadSound("sounds/zoneSummary_time1.wav"),
    zonePopup                   = loadSound("sounds/zonePopup_time1.wav"),

    -- Shop:
    shopPurchase                = loadSound("sounds/shopPurchase_time1.wav"),
    shopCantBuy                 = loadSound("sounds/shopCantBuy_time1.wav"),
    shopSelect                  = loadSound("sounds/shopSelect_time1.wav"),

    -- HUD sounds
    awardStar                   = loadSound("sounds/awardStar_time1.wav"),
    bounce                      = loadSound("sounds/bounce_time1.wav"),
    checkpoint                  = loadSound("sounds/checkpoint_time1.wav"),
    countDown                   = loadSound("sounds/countDown_time1.wav"),
    countHigh                   = loadSound("sounds/countHigh_time1.wav"),
    gainAward                   = loadSound("sounds/gainAward_time1.wav"),
    levelComplete               = loadSound("sounds/levelComplete_time4.wav"),
    progress                    = loadSound("sounds/progress_time1.wav"),
    storyStart                  = loadSound("sounds/levelComplete_time4.wav"),
    storyNotification           = loadSound("sounds/storyNotification_time1.wav"),
    unlock                      = loadSound("sounds/unlock_time4.wav"),
    whoosh                      = loadSound("sounds/whoosh_time1.wav"),

    -- Collectables
    collectGear                 = loadSound("sounds/elements/collectGear_time1.wav"),
    collectKey                  = loadSound("sounds/elements/collectKey_time1.wav"),
    collectTimeBonus            = loadSound("sounds/elements/collectTimeBonus_time1.mp3"),
    collectNegable              = loadSound("sounds/elements/collectNegable_time1.wav"),

    -- Player generic (cross model) sounds
    playerDeathExplode          = loadSound("sounds/player/deathExplode_time1.wav"),
    playerDeathLava             = loadSound("sounds/player/deathLava_time1.wav"),
    playerDeathSpikes           = loadSound("sounds/player/deathSpike_time1.wav"),
    playerDeathElectric         = loadSound("sounds/player/deathElectric_time1.wav"),
    playerTeleport              = loadSound("sounds/player/teleport_time5.wav"),
        
    -- Gear use:
    gearAir                     = loadSound("sounds/gearAir_time1.wav"),
    gearAntigrav                = loadSound("sounds/gearAntigrav_time1.wav"),
    gearJetpack                 = loadSound("sounds/gearJetpack_time3.wav"),
    gearShield                  = loadSound("sounds/gearShield_time2.mp3"),
    gearReverseJump             = loadSound("sounds/gearReverseJump_time1.wav"),
    gearSpringshoes             = loadSound("sounds/gearSpringShoes_time1.wav"),
    gearTrajectory              = loadSound("sounds/gearTrajectory_time1.wav"),
    
    -- Ambiant level background sounds:
    backgroundSoundWind1        = loadSound("sounds/ambient/wind1_time40.wav"),
    backgroundSoundWind2        = loadSound("sounds/ambient/wind2_time28.wav"),
    backgroundSoundWind3        = loadSound("sounds/ambient/wind3_time24.wav"),
    backgroundSoundWind4        = loadSound("sounds/ambient/wind4_time28.wav"),
    backgroundSoundWind5        = loadSound("sounds/ambient/wind5_time40.wav"),
    backgroundSoundLava1        = loadSound("sounds/ambient/lava1_time15.wav"),

    -- Ledges:
    ledgeCollapsingActivated    = loadSound("sounds/elements/ledgeCollapsingActivated_time4.wav"),
    ledgeCollapsingBreak        = loadSound("sounds/elements/ledgeCollapsingBreak_time1.wav"),
    ledgeExplodingActivated     = loadSound("sounds/elements/ledgeExplodingActivated_time4.wav"),
    ledgeKeylockOpen            = loadSound("sounds/elements/ledgeKeylockOpen_time1.wav"),
    ledgeLavaActivated          = loadSound("sounds/elements/ledgeLavaActivated_time20.wav"),
    ledgeOneshotActivated       = loadSound("sounds/elements/ledgeOneshotActivated_time1.wav"),
    ledgePulleyActivated        = loadSound("sounds/elements/ledgePulleyActivated_time9.wav"),
    ledgeSpikesActivated        = loadSound("sounds/elements/ledgeSpikesActivated_time1.wav"),

    -- Obstacles:
    poleSlide                   = loadSound("sounds/elements/obstaclePoleSlide_time1.wav"),
    deathslide                  = loadSound("sounds/elements/obstacleDeathslide_time15.wav"),
    ropeswing                   = loadSound("sounds/elements/obstacleRopeswing_time1.wav"),
    rocketLaunch                = loadSound("sounds/elements/obstacleRocketLaunch_time2.wav"),

    -- Ledges & Obstacles
    electricActivated           = loadSound("sounds/elements/electricActivated_time23.wav"),    

    -- Friends common:
    friendBossActive            = loadSound("sounds/elements/friendBossActive_time16.mp3"),
    friendCollected             = loadSound("sounds/elements/friendCollected_time1.wav"),

    -- Enemies & other sounds for planet1: organia
    enemyBrainAwaken            = loadSound("sounds/elements/enemyBrainAwaken_time1.wav"),
    enemyBrainMiss              = loadSound("sounds/elements/enemyBrainMiss_time2.wav"),
    enemyBrainKill              = loadSound("sounds/elements/enemyBrainKill_time1.wav"),
    enemyHeartAwaken            = loadSound("sounds/elements/enemyHeartAwaken_time9.wav"),
    enemyHeartSteal             = loadSound("sounds/elements/enemyHeartSteal_time1.wav"),
    enemyStomachAwaken          = loadSound("sounds/elements/enemyStomachAwaken_time4.wav"),
    enemyStomachShoot           = loadSound("sounds/elements/enemyStomachShoot_time1.wav"),

    -- Enemies & other sounds for planet2: apocalypsoid:
    enemyGreyShoot              = loadSound("sounds/elements/greys/shoot_time2.wav"),
    enemyGreyUfoActive          = loadSound("sounds/elements/greys/ufoActive_time16.wav"),
    enemyGreyUfoKill            = loadSound("sounds/elements/greys/ufoKill_time1.wav"),
    warpActive                  = loadSound("sounds/elements/warpActive_time16.wav"),
    warpHit                     = loadSound("sounds/elements/warpHit_time1.wav"),

    -- Common Level terrain sounds
    
        -- [items]
        -- collect key
        -- collect timebonus

        -- [obstacles]
        -- space rocket countdown
        -- space rocket blast off
}


------------------ GROUP SOUNDS ----------------------


function sounds:loadImpactGeneral()
    for i = 1,3 do
        table.insert(self.impacts, loadSound("sounds/impacts/general"..i..".wav"))
    end
end


function sounds:loadRings()
    for i=1,5 do
        self.rings[i] = loadSound("sounds/elements/rings/ring"..i..".wav")
    end
end

function sounds:loadFuzzies()
    self.fuzzies[1] = {sound=loadSound("sounds/elements/fuzzies/fuzzy1_time2.wav"), duration=2000}
    self.fuzzies[2] = {sound=loadSound("sounds/elements/fuzzies/fuzzy2_time1.wav"), duration=1000}
    self.fuzzies[3] = {sound=loadSound("sounds/elements/fuzzies/fuzzy3_time1.wav"), duration=1000}
end


function sounds:loadGreysTalking()
    self.greysTalking[1] = {sound=loadSound("sounds/elements/greys/talk1_time3.wav"), duration=3000}
    self.greysTalking[2] = {sound=loadSound("sounds/elements/greys/talk2_time5.wav"), duration=5000}
    self.greysTalking[3] = {sound=loadSound("sounds/elements/greys/talk3_time5.wav"), duration=5000}
    self.greysTalking[4] = {sound=loadSound("sounds/elements/greys/talk4_time4.wav"), duration=4000}
    self.greysTalking[5] = {sound=loadSound("sounds/elements/greys/talk5_time1.wav"), duration=1000}
    self.greysTalking[6] = {sound=loadSound("sounds/elements/greys/talk6_time4.wav"), duration=4000}
    self.greysTalking[7] = {sound=loadSound("sounds/elements/greys/talk7_time1.wav"), duration=1000}
end


function sounds:loadPlayerFalls()
    for i = 1,3 do
        table.insert(self.playerFalls, loadSound("sounds/player/fall"..i.."_time2.wav"))
    end
end


function sounds:loadJumps(type)
    local path = "sounds/player/"..characterData[type].name.."/"
    for i = 1,8 do
        table.insert(self.playerJump[type], loadSound(path.."jump-"..i..".wav"))
    end
end


function sounds:loadLands(type)
    local path = "sounds/player/"..characterData[type].name.."/"
    for i = 1,8 do
        table.insert(self.playerLand[type], loadSound(path.."land-"..i..".wav"))
    end
end


function sounds:loadLandEdges(type)
    local path = "sounds/player/"..characterData[type].name.."/"
    for i = 1,4 do
        table.insert(self.playerLandEdge[type], loadSound(path.."land-edge-"..i..".wav"))
    end
end


function sounds:loadPlayerCelebrate(type)
    local path = "sounds/player/"..characterData[type].name.."/"
    for i = 1,3 do
        table.insert(self.playerCelebrate[type], loadSound(path.."land-special-perfectjump"..i..".wav"))
    end
end


---------------- LOADERS ------------------


function sounds:loadRandom()
    self:loadImpactGeneral()
    self:loadRings()
    self:loadFuzzies()
    self:loadGreysTalking()
    self:loadPlayerFalls()
end


function sounds:loadPlayer(type)
    if not playerLoaded[type] and self.playerJump[type] then
        playerLoaded[type] = true
        self:loadJumps(type)
        self:loadLands(type)
        self:loadLandEdges(type)
        self:loadPlayerCelebrate(type)
    end
end


function sounds:unloadPlayer(type)
    if self.playerJump[type] then
        for handle in pairs(self.playerJump[type]) do unloadSound(handle) end
        for handle in pairs(self.playerLand[type]) do unloadSound(handle) end
        for handle in pairs(self.playerLandEdge[type])  do unloadSound(handle) end
        for handle in pairs(self.playerCelebrate[type]) do unloadSound(handle) end
    end

    self.playerJump[type]      = {}
    self.playerLand[type]      = {}
    self.playerLandEdge[type]  = {}
    self.playerCelebrate[type] = {}

    playerLoaded[type] = false
end



-- Global function to play sound instead of: audio.play
-- Because we need to ensure the channels volume has been reset
function globalSoundPlayer(sound, options)
    local channel = nil

    if options and options.channel then
        channel = options.channel
    else
        channel = findChannel()
        if options then
            options.channel = channel
        else
            options = {channel=channel}
        end
    end

    setVolume(options.volume or 1, options)
    play(sound, options)

    --print("play(key="..tostring(options.key).." channel="..tostring(options.channel).." volume="..tostring(options.volume) .." loops="..tostring(options.loops).." duration="..tostring(options.duration)..")")
end
