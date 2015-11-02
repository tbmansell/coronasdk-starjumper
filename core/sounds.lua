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

    rings     = {},
    landLedge = {},
    fuzzies   = {},

    -- Scene & Menus
    gameStart   = loadSound("sounds/gear-trajectory1.wav"),
    sceneEnter  = loadSound("sounds/gui-click5.wav"),
    buttonClick = loadSound("sounds/click.mp3"),
    hudClick    = loadSound("sounds/gui-click4.wav"),
    zoneSummary = loadSound("sounds/gui-bleep1.wav"),
    zonePopup   = loadSound("sounds/gui-bleep3.wav"),
    zoneEnter   = loadSound("sounds/gear-trajectory1.wav"),

    -- Shop:
    shopPurchase = loadSound("sounds/shop_purchase.wav"),
    shopCantBuy  = loadSound("sounds/shop_failtobuy.wav"),
    shopSelect   = loadSound("sounds/shop_selection.wav"),

    -- Background sounds:
    backgroundSoundWind1 = loadSound("sounds/ambientsound1.wav"),
    backgroundSoundWind2 = loadSound("sounds/ambientsound2.wav"),
    backgroundSoundWind3 = loadSound("sounds/ambientsound3.wav"),
    backgroundSoundWind4 = loadSound("sounds/ambientsound4.wav"),
    backgroundSoundWind5 = loadSound("sounds/ambientsound5.wav"),
    backgroundSoundZones = loadSound("sounds/background-music-zones.mp3"),
    backgroundSoundShop  = loadSound("sounds/background-music-shop.mp3"),
    backgroundSoundTitle = loadSound("sounds/background-music-title2.mp3"),

    -- HUD sounds
    klaxon         = loadSound("sounds/gui-outoftime.wav"),
    collectGear    = loadSound("sounds/gear-collect.wav"),
    collectNegable = loadSound("sounds/negable-collect.wav"),
    rankstar       = loadSound("sounds/gui-stab1.wav"),
    award          = loadSound("sounds/gui-acid4.wav"),
    progress       = loadSound("sounds/gui-pop.wav"),
    unlock         = loadSound("sounds/ledge-exploding.wav"),

    -- Story sounds:
    storyStart     = loadSound("sounds/levelComplete.wav"),
    storyMusic     = loadSound("sounds/story-background.mp3"),

    -- ledges:
    ledgeElectricActivated   = loadSound("sounds/ledge-electric2.wav"),
    ledgeCollapsingActivated = loadSound("sounds/ledge-collapsing1.wav"),
    ledgeCollapsingBreak     = loadSound("sounds/ledge-collapsing3.wav"),
    ledgeLavaActivated       = loadSound("sounds/ledge-lava3.wav"),
    ledgeSpikesActivated     = loadSound("sounds/ledge-spiked2.wav"),
    ledgeOneshotActivated    = loadSound("sounds/ledge-oneshot.wav"),
    ledgeExplodingActivated  = loadSound("sounds/ledge-exploding.wav"),
    ledgePulleyActivated     = loadSound("sounds/ledge-pulley.wav"),

    -- obstacles:
    poleSlide           = loadSound("sounds/obstacle-pole.wav"),
    deathslideActivated = loadSound("sounds/obstacle-deathslide.wav"),
    ropeswingAmbient    = loadSound("sounds/obstacle-ropeswing.wav"),

    -- player generic (cross model) sounds
    playerFall          = loadSound("sounds/fall.mp3"),
    playerDeathExplode  = loadSound("sounds/enviromental-fallonspike.wav"),
    playerDeathElectric = loadSound("sounds/ledge-electric1.wav"),
    playerDeathSpikes   = loadSound("sounds/enviromental-fallonspike.wav"),
    playerDeathLava     = loadSound("sounds/enviromental-genericdeath1.wav"),
    playerTeleport      = loadSound("sounds/gear-reversetime2.wav"),

    -- friends common:
    friendBossHover     = loadSound("sounds/ufo-hover.mp3"),

    -- enemies for organia
    enemyBrain1         = loadSound("sounds/enemy-brain-growl1.wav"),
    enemyBrain2         = loadSound("sounds/enemy-brain-growl2.wav"),
    enemyBrain3         = loadSound("sounds/enemy-brain-growl3.wav"),
    enemyHeart1         = loadSound("sounds/enemy-heart1.wav"),
    enemyHeart2         = loadSound("sounds/enemy-heart2.wav"),
    enemyStomach1       = loadSound("sounds/enemy-stomach1.wav"),
    enemyStomach2       = loadSound("sounds/enemy-stomach2.wav"),

    -- OLD sounds
        checkpoint      = loadSound("sounds/checkpoint.wav"),
        levelComplete   = loadSound("sounds/levelComplete.wav"),
        bounce          = loadSound("sounds/bounce.mp3"),
        whoosh          = loadSound("sounds/whoosh.mp3"),
        gearSelect      = loadSound("sounds/selection.mp3"),
        friendCollected = loadSound("sounds/friendCollected.wav"),
        gearSpringshoes = loadSound("sounds/gear-springshoes.wav"),
        gearAntigrav    = loadSound("sounds/gear-antigrav.mp3"),
        gearTrajectory  = loadSound("sounds/gear-trajectory.mp3"),
        gearShield      = loadSound("sounds/gear-shield.mp3"),
        gearAir         = loadSound("sounds/gear-air.wav"),
        gearJetpack     = loadSound("sounds/gear-jetpack.mp3"),
        gearReverseJump = loadSound("sounds/gear-reversejump.wav"),
        negable         = loadSound("sounds/negable.wav"),    
}


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


function sounds:loadLandLedge()
    for i = 1,3 do
        table.insert(self.landLedge, loadSound("sounds/ground-standard-"..i..".wav"))
    end
end


function sounds:loadRings()
    for i=1,5 do
        self.rings[i] = loadSound("sounds/ring"..i..".wav")
    end
end

function sounds:loadFuzzies()
    for i=1,3 do
        self.fuzzies[i] = loadSound("sounds/fuzzy"..i..".wav")
    end
end


function sounds:loadRandom()
    self:loadLandLedge()
    self:loadRings()
    self:loadFuzzies()
end


function sounds:loadPlayer(type)
    --self.playerJump[type]
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
function globalSoundPlayer(sound, options, volume)
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

    setVolume(volume or 1, options)
    play(sound, options)
end
