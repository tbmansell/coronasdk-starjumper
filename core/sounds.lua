-- global sound storage, loader, unloader and tracker
local sounds = {
    -- Character voice sounds
    playerJump = {
        [characterSkyanna]   = {},
        [characterNewton]    = {},
        [characterHammer]    = {},
        [characterBrainiak]  = {},
        [characterEarlGrey]  = {},
    },
    playerLand = {
        [characterSkyanna]   = {},
        [characterNewton]    = {},
        [characterHammer]    = {},
        [characterBrainiak]  = {},
        [characterEarlGrey]  = {},
    },
    playerLandEdge = {
        [characterSkyanna]   = {},
        [characterNewton]    = {},
        [characterHammer]    = {},
        [characterBrainiak]  = {},
        [characterEarlGrey]  = {},
    },
    playerCelebrate = {
        [characterSkyanna]   = {},
        [characterNewton]    = {},
        [characterHammer]    = {},
        [characterBrainiak]  = {},
        [characterEarlGrey]  = {},
    },
    playerTaunt = {
        [characterSkyanna]   = {},
        [characterNewton]    = {},
        [characterHammer]    = {},
        [characterBrainiak]  = {},
        [characterEarlGrey]  = {},
    },

    -- Random sound groups
    rings        = {},
    impacts      = {},
    fuzzies      = {},
    greysTalking = {},
    playerFalls  = {},

    -- In-game ambiant background sounds: sound handler indexed by sound name
    ambient = {},
}


-- Local vars
local playerLoaded = {}

-- Aliases
local loadSound   = audio.loadSound
local unloadSound = audio.dispose
local findChannel = audio.findFreeChannel
local setVolume   = audio.setVolume
local play        = audio.play


---------------- PRIMARY LOADERS ------------------


function sounds:loadStaticSounds()
    self:loadMusic()
    self:loadMenuSounds()
    self:loadShopSounds()
    self:loadHudSounds()
    self:loadPlayerActionSounds()
    self:loadGearSounds()
    self:loadLedgeAndObstacles()
    -- TODO: add system to only load one planets sounds at a time
    self:loadEnemySounds(1)
    self:loadEnemySounds(2)
end


function sounds:loadRandomSounds()
    self:loadImpactGeneral()
    self:loadRings()
    self:loadFuzzies()
    self:loadGreysTalking()
    self:loadPlayerFalls()
end


function sounds:loadPlayer(type)
    local type = characterData[type].soundIndex

    if not playerLoaded[type] and self.playerJump[type] then
        playerLoaded[type] = true
        self:loadJumps(type)
        self:loadLands(type)
        self:loadLandEdges(type)
        self:loadPlayerCelebrate(type)
        self:loadPlayerTaunt(type)
    end
end


function sounds:unloadPlayer(type)
    local type = characterData[type].soundIndex

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


-- Clears out all loaded player sounds except the current player selected (main)
function sounds:unloadPlayerExtras()
    local main = characterData[state.data.playerModel].soundIndex

    for type,loaded in pairs(playerLoaded) do
        if loaded and type ~= main then
            self:unloadPlayer(type)
        end
    end
end


------------------ STATIC GROUP SOUNDS ----------------------

function sounds:loadMusic()
    self.tuneTitle       = loadSound("sounds/tunes/title_time100.mp3")
    self.tuneZoneSelect  = loadSound("sounds/tunes/zoneSelect_time32.mp3")
    self.tuneShop        = loadSound("sounds/tunes/shop_time32.mp3")
    --self.tuneStory       = loadSound("sounds/tunes/story_time183.mp3")
    self.tuneStory       = loadSound("sounds/tunes/zoneSelect_time32.mp3")
end


function sounds:loadMenuSounds()
    self.gameStart    = loadSound("sounds/gameStart_time1.wav")
    self.sceneEnter   = loadSound("sounds/sceneEnter_time1.wav")
    self.buttonClick  = loadSound("sounds/buttonClick_time1.wav")
    self.generalClick = loadSound("sounds/generalClick_time1.wav")
    self.zoneSummary  = loadSound("sounds/zoneSummary_time1.wav")
    self.zonePopup    = loadSound("sounds/zonePopup_time1.wav")
end


function sounds:loadShopSounds()
    self.shopPurchase = loadSound("sounds/shopPurchase_time1.wav")
    self.shopCantBuy  = loadSound("sounds/shopCantBuy_time1.wav")
    self.shopSelect   = loadSound("sounds/shopSelect_time1.wav")
end


function sounds:loadHudSounds()
    self.awardStar          = loadSound("sounds/awardStar_time1.wav")
    self.bounce             = loadSound("sounds/bounce_time1.wav")
    self.checkpoint         = loadSound("sounds/checkpoint_time1.wav")
    self.countDown          = loadSound("sounds/countDown_time1.wav")
    self.countHigh          = loadSound("sounds/countHigh_time1.wav")
    self.gainAward          = loadSound("sounds/gainAward_time1.wav")
    self.levelComplete      = loadSound("sounds/levelComplete_time4.wav")
    self.progress           = loadSound("sounds/progress_time1.wav")
    self.storyStart         = loadSound("sounds/levelComplete_time4.wav")
    self.storyNotification  = loadSound("sounds/storyNotification_time1.wav")
    self.unlock             = loadSound("sounds/unlock_time4.wav")
    self.whoosh             = loadSound("sounds/whoosh_time1.wav")
end


function sounds:loadPlayerActionSounds()
    -- Player common
    self.playerDeathExplode  = loadSound("sounds/player/deathExplode_time1.wav")
    self.playerDeathLava     = loadSound("sounds/player/deathLava_time1.wav")
    self.playerDeathSpikes   = loadSound("sounds/player/deathSpike_time1.wav")
    self.playerDeathElectric = loadSound("sounds/player/deathElectric_time1.wav")
    self.playerTeleport      = loadSound("sounds/player/teleport_time5.wav")
    self.playerRunRock       = loadSound("sounds/player/runRock_time1.wav")
    self.playerRunMetal      = loadSound("sounds/player/runMetal_time1.wav")
    -- Friends common
    self.friendBossActive    = loadSound("sounds/elements/friendBossActive_time16.mp3")
    self.friendCollected     = loadSound("sounds/elements/friendCollected_time1.wav")
end


function sounds:loadGearSounds()
    -- Collectables
    self.collectGear      = loadSound("sounds/elements/collectGear_time1.wav")
    self.collectKey       = loadSound("sounds/elements/collectKey_time1.wav")
    self.collectTimeBonus = loadSound("sounds/elements/collectTimeBonus_time1.mp3")
    self.collectNegable   = loadSound("sounds/elements/collectNegable_time1.wav")
    -- Gear use
    self.gearAir          = loadSound("sounds/gearAir_time1.wav")
    self.gearAntigrav     = loadSound("sounds/gearAntigrav_time1.wav")
    self.gearFreezeTime   = loadSound("sounds/gearFreezeTime_time3.wav")
    self.gearJetpack      = loadSound("sounds/gearJetpack_time3.wav")
    self.gearShieldUp     = loadSound("sounds/gearShieldUp_time2.mp3")
    self.gearShieldDown   = loadSound("sounds/gearShieldDown_time2.mp3")
    self.gearReverseJump  = loadSound("sounds/gearReverseJump_time1.wav")
    self.gearSpringshoes  = loadSound("sounds/gearSpringShoes_time1.wav")
    self.gearTrajectory   = loadSound("sounds/gearTrajectory_time1.wav")
end


function sounds:loadLedgeAndObstacles()
    -- Ledges:
    self.ledgeCollapsingActivated = loadSound("sounds/elements/ledgeCollapsingActivated_time4.wav")
    self.ledgeCollapsingBreak     = loadSound("sounds/elements/ledgeCollapsingBreak_time1.wav")
    self.ledgeExplodingActivated  = loadSound("sounds/elements/ledgeExplodingActivated_time4.wav")
    self.ledgeKeylockOpen         = loadSound("sounds/elements/ledgeKeylockOpen_time1.wav")
    self.ledgeLavaActivated       = loadSound("sounds/elements/ledgeLavaActivated_time20.wav")
    self.ledgeOneshotActivated    = loadSound("sounds/elements/ledgeOneshotActivated_time1.wav")
    self.ledgePulleyActivated     = loadSound("sounds/elements/ledgePulleyActivated_time9.wav")
    self.ledgeSpikesActivated     = loadSound("sounds/elements/ledgeSpikesActivated_time1.wav")
    -- Obstacles:
    self.poleSlide                = loadSound("sounds/elements/obstaclePoleSlide_time1.wav")
    self.deathslide               = loadSound("sounds/elements/obstacleDeathslide_time15.wav")
    self.ropeswing                = loadSound("sounds/elements/obstacleRopeswing_time1.wav")
    self.rocketLaunch             = loadSound("sounds/elements/obstacleRocketLaunch_time2.wav")
    self.rocketActive             = loadSound("sounds/gearJetpack_time3.wav")
    -- Ledges & Obstacles
    self.electricActivated        = loadSound("sounds/elements/electricActivated_time23.wav")
end


function sounds:loadEnemySounds(planet)
    if planet == 1 then
        self.enemyBrainAwaken   = loadSound("sounds/elements/enemyBrainAwaken_time1.wav")
        self.enemyBrainMiss     = loadSound("sounds/elements/enemyBrainMiss_time2.wav")
        self.enemyBrainKill     = loadSound("sounds/elements/enemyBrainKill_time1.wav")
        self.enemyHeartAwaken   = loadSound("sounds/elements/enemyHeartAwaken_time9.wav")
        self.enemyHeartSteal    = loadSound("sounds/elements/enemyHeartSteal_time1.wav")
        self.enemyStomachAwaken = loadSound("sounds/elements/enemyStomachAwaken_time4.wav")
        self.enemyStomachShoot  = loadSound("sounds/elements/enemyStomachShoot_time1.wav")
    elseif planet == 2 then
        self.enemyGreyShoot     = loadSound("sounds/elements/greys/shoot_time2.wav")
        self.enemyGreyUfoActive = loadSound("sounds/elements/greys/ufoActive_time16.wav")
        self.enemyGreyUfoKill   = loadSound("sounds/elements/greys/ufoKill_time1.wav")
        self.warpActive         = loadSound("sounds/elements/warpActive_time16.wav")
        self.warpHit            = loadSound("sounds/elements/warpHit_time1.wav")
    end
end


function sounds:unloadEnemySounds(planet)
    if planet == 1 then
        unloadSound(self.enemyBrainAwaken)
        unloadSound(self.enemyBrainMiss)
        unloadSound(self.enemyBrainKill)
        unloadSound(self.enemyHeartAwaken)
        unloadSound(self.enemyHeartSteal)
        unloadSound(self.enemyStomachAwaken)
        unloadSound(self.enemyStomachShoot)
    elseif planet == 2 then
        unloadSound(self.enemyGreyShoot)
        unloadSound(self.enemyGreyUfoActive)
        unloadSound(self.enemyGreyUfoKill)
        unloadSound(self.warpActive)
        unloadSound(self.warpHit)
    end
end


-- Special function that checks if each ambient sound is already loaded and if so doesnt reload it, or if not unloads it
-- @param soundList - name of sounds to be loaded - gets edited with sound handler
----
function sounds:replaceAmbientSounds(soundList)
    local names = {}

    -- loop through existing sounds
    for i=1,#soundList do
        local spec   = soundList[i]
        local name   = spec.name
        local loaded = self.ambient[name]

        if loaded == nil then
            -- sound not currently loaded
            spec.sound = loadSound("sounds/ambient/"..name..".mp3")
            self.ambient[name] = spec.sound
        else
            spec.sound = loaded
        end

        -- create an easy list of sound names to check against to avoi a for loop
        names[#names+1] = name
    end

    -- found existing loaded sounds no longer needed
    for name,sound in pairs(self.ambient) do
        if table.indexOf(names, name) == nil then
            unloadSound(sound)
            self.ambient[name] = nil
        end
    end
end


------------------ RANDOM GROUP SOUNDS ----------------------


function sounds:loadImpactGeneral()
    for i = 1,3 do
        self.impacts[i] = loadSound("sounds/impacts/general"..i..".wav")
    end
end


function sounds:loadRings()
    for i = 1,5 do
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
        self.playerFalls[i] = loadSound("sounds/player/fall"..i.."_time2.wav")
    end
end


------------------ PLAYER VOICES ------------------------


function sounds:loadJumps(type)
    local type = characterData[type].soundIndex
    local path = "sounds/player/"..characterData[type].soundFolder.."/"
    local num  = 0
    
    if     type == characterNewton   then num = 8
    elseif type == characterSkyanna  then num = 7
    elseif type == characterHammer   then num = 7
    elseif type == characterBrainiak then num = 4
    elseif type == characterEarlGrey then num = 6 end

    for i = 1,num do
        self.playerJump[type][i] = loadSound(path.."jump-"..i..".wav")
    end
end


function sounds:loadLands(type)
    local type = characterData[type].soundIndex
    local path = "sounds/player/"..characterData[type].soundFolder.."/"
    local num  = 0

    if     type == characterNewton   then num = 8
    elseif type == characterSkyanna  then num = 8
    elseif type == characterHammer   then num = 8
    elseif type == characterBrainiak then num = 4
    elseif type == characterEarlGrey then num = 6 end

    for i = 1,num do
        self.playerLand[type][i] = loadSound(path.."land-"..i..".wav")
    end
end


function sounds:loadLandEdges(type)
    local type = characterData[type].soundIndex
    local path = "sounds/player/"..characterData[type].soundFolder.."/"
    local num  = 0

    if     type == characterNewton   then num = 4
    elseif type == characterSkyanna  then num = 4
    elseif type == characterHammer   then num = 4
    elseif type == characterBrainiak then num = 1
    elseif type == characterEarlGrey then num = 2 end

    for i = 1,num do
        self.playerLandEdge[type][i] = loadSound(path.."land-edge-"..i..".wav")
    end
end


function sounds:loadPlayerCelebrate(type)
    local type = characterData[type].soundIndex
    local path = "sounds/player/"..characterData[type].soundFolder.."/"
    local num  = 0

    if     type == characterNewton   then num = 3
    elseif type == characterSkyanna  then num = 3
    elseif type == characterHammer   then num = 3
    elseif type == characterBrainiak then num = 2
    elseif type == characterEarlGrey then num = 2 end

    for i = 1,num do
        self.playerCelebrate[type][i] = loadSound(path.."land-special-perfectjump"..i..".wav")
    end
end


function sounds:loadPlayerTaunt(type)
    local type = characterData[type].soundIndex
    local path = "sounds/player/"..characterData[type].soundFolder.."/"
    local num  = 0

    if     type == characterNewton   then num = 0
    elseif type == characterSkyanna  then num = 0
    elseif type == characterHammer   then num = 0
    elseif type == characterBrainiak then num = 2
    elseif type == characterEarlGrey then num = 2 end

    for i = 1,num do
        self.playerCelebrate[type][i] = loadSound(path.."taunt-"..i..".wav")
    end
end


--------------- GLOBAL FUNCTIONS ------------------


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
end


return sounds