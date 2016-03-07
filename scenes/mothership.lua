local storyboard    = require("storyboard")
local anim          = require("core.animations")
local stories       = require("core.story")
local particles     = require("core.particles")
local builder       = require("level-objects.builders.builder")
local spineStore    = require("level-objects.collections.spine-store")


-- Local vars:
local scene           = storyboard.newScene()
local spineCollection = nil
local lastTime        = 0

-- Lists each characters scene specific data in order of who should be drawn first (furthest back)
local characterPosition = {
    {
        model = characterHammer,
        xpos  = 270, 
        ypos  = 500,
        hologram = {xpos=300, ypos=555}
    },
    {
        model = characterReneGrey,
        xpos  = 380,
        ypos  = 510,
        hologram = {xpos=360, ypos=540}
    },
    {
        model = characterNewton,
        xpos  = 150,
        ypos  = 530,
    },
    {
        model = characterSkyanna,
        xpos  = 220,
        ypos  = 560,
        hologram = {xpos=180, ypos=540}
    },
    {
        model = characterKranio,
        xpos  = 330, 
        ypos  = 580,
        hologram = {xpos=240, ypos=555}
    },
}


-- Aliases:
local play   = globalSoundPlayer
local random = math.random


-- Things that need to happen as fast as possible (every frame e.g 60 loops per second)
local function sceneEnterFrameEvent(event)
    globalFPS = globalFPS + 1
    spineCollection:animateEach(event)
end


-- Called when the scene's view does not exist:
function scene:createScene(event)
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene(event)
    logAnalytics("mothership", "enterScene")

    --state:newScene("mothership")
    clearSceneTransition()
    globalIgnorePhysicsEngine = true

    self.planet = state.data.planetSelected
    self.data   = planetData[self.planet]

    package.loaded["levels.planet"..self.planet..".planet"] = nil
    self.planetSpec = require("levels.planet"..self.planet..".planet")

    spineCollection    = builder:newSpineCollection()
    particleCollection = builder:newParticleEmitterCollection()
    spineStore:load(spineCollection)

    self.tvimage = newImage(self.view, "mothership/tv-logo", centerX, centerY-65)
    newImage(self.view, "mothership/bgr", centerX, centerY)

    Runtime:addEventListener("enterFrame", sceneEnterFrameEvent)

    self:loadStory()
    self:loadBoss()
    self:loadHologramBase()
    self:loadCharacters()
    self:animateCharacters()

    stories:start(scene.story, function()end, function() scene:finishStory() end, nil, self)
end


function scene:loadStory()
    particles:loadEmitter("ufo-trail")

    if state.cutsceneStory == "cutscene-planet-intro" then
        scene.story = state.cutsceneStory .."-".. planetData[state.data.planetSelected].name
        scene.type  = "planetIntro"

    elseif state.cutsceneStory == "cutscene-character-intro" then
        scene.story = state.cutsceneStory .."-".. characterData[state.cutsceneCharacter].name
        scene.type  = "character"
        particles:loadEmitter("collectable-sparks")
    end
end


function scene:loadBoss()
    self.boss = spineStore:showBossChair({x=830, y=250, size=0.35})

    self.boss.particles = particles:showEmitter(nil, "ufo-trail", self.boss:x(), self.boss:y(), "forever", 0.6)
    self.boss.particles:scale(0.1, 0.1)

    self.view:insert(scene.boss.particles)
    self.view:insert(scene.boss.image)

    self:moveBoss()
end


function scene:moveBoss()
    local seq = anim:oustSeq("bossHover", self.boss.image)
    seq.target2 = self.boss.particles

    if self.hoverBossUp then
        self.hoverBossUp = false
        seq:tran({y=self.boss.image.y - 30, time=1333})
    else
        self.hoverBossUp = true
        seq:tran({y=self.boss.image.y + 30, time=1333})
    end

    seq.onComplete = function() self:moveBoss() end
    seq:start()
end


function scene:loadHologramBase()
    self.hologramBase   = newImage(self.view, "effects/hologram/Hologram_base", 745, 550)
    self.hologramEffect = builder:newSpineObject({type="hologram"}, {jsonName="hologram", imagePath="effects/hologram", scale=1, animation="animation"})

    self.hologramEffect:moveTo(745, 550)
    spineStore:addSpine(self.hologramEffect)
    self.view:insert(self.hologramEffect.image)
end


function scene:loadCharacters(event)
    scene.characters = {}
    scene.holograms  = {}
    scene.spineDelay = 0

    for _,data in pairs(characterPosition) do
        local model = data.model
        local char  = characterData[model]

        if char.playable then
            local unlocked = state:characterUnlocked(model)
            -- Show characters that are unlocked
            if unlocked or state.cutsceneCharacter == model then
                scene:createCharacter(data, centerX - data.xpos, data.ypos)
            end
            -- Show holograms for characters locked plus also the focus character as it will become unlocked
            if data.hologram and not unlocked or (scene.type == "character" and unlocked and state.cutsceneCharacter == model) then
                scene:createHologram(data, centerX + data.hologram.xpos, data.hologram.ypos)
            end
        end
    end
end


function scene:createCharacter(charData, xpos, ypos, locked)
    local model = charData.model
    local spec  = {model=model, x=xpos, y=ypos, size=0.3}

    --scene.spineDelay = scene.spineDelay + 100
    --local ai = spineStore:showCharacter(spec, scene.spineDelay)
    local ai  = spineStore:showCharacter(spec)
    ai.model  = model
    ai.scene  = charData

    ai.shadow = newImage(self.view, "mothership/shadow", xpos+5, ypos)
    ai.shadow.alpha = 0.65
    ai.shadow:scale(0.9, 0.9)

    self.view:insert(ai.image)
    self.characters[model] = ai

    if model == state.cutsceneCharacter and state.cutsceneStory == "cutscene-character-intro" then
        ai:hide()
        ai.shadow.alpha = 0
        self.focusCharacter = ai
    end
end


function scene:createHologram(charData, xpos, ypos)
    self.spineDelay = scene.spineDelay + 133
    
    local model = charData.model
    local spec  = {model=model, x=xpos, y=ypos, size=0.2, animation="Hologram", spineDelay=scene.spineDelay}

    local ai = spineStore:showCharacter(spec)
    ai.model = model
    ai.scene = charData
    ai.image:scale(-1,1)
    ai:hide()

    self.view:insert(ai.image)
    self.holograms[model] = ai

    if model == state.cutsceneCharacter and state.cutsceneStory == "cutscene-character-intro" then
        self.focusHologram = ai
    end
end


function scene:animateCharacters()
    for model, character in pairs(self.characters) do
        self:animateCharater(character)
    end
end


function scene:animateCharater(character)
    if character.action then return end

    local sequence, duration = scene:getCharacterAnimation()

    character:loop(sequence)

    local name = characterData[character.model].name

    after(duration, function() scene:animateCharater(character) end)
end


function scene:getCharacterAnimation()
    local duration = random(7) * 1000
    local num      = random(100)

    if num <= 5 then
        -- Small chance its sequence 4 (5th) - scratch head as stands out too much
        return "Stationary 2", 2000
    elseif num <= 25 then
        return "Stationary 1", duration
    elseif num <= 50 then
        return "Stationary 3", duration
    elseif num <= 75 then
        return "Stationary 4", duration
    else
        return "Stationary", duration
    end
end


function scene:fadeTv()
    local seq = anim:oustSeq("tv", self.tvimage, true)
    seq:tran({alpha=0, time=1000})
    seq:start()
end


------ FUNCTIONS CALLED BY CUTSCENE STORY SCRIPTS --------


function scene:actionShowHolograms()
    for i, hologram in pairs(scene.holograms) do
        local seq = anim:oustSeq("hologram-"..i, hologram.image)
        seq:tran({time=500, alpha=0.5})

        -- If showing a new character: display a special sequence where the hologram is replaced with the real character
        if state.cutsceneStory == "cutscene-character-intro" and hologram == self.focusHologram then
            local char = self.focusCharacter.image
            local gram = self.focusHologram.image
            
            seq:wait(1000)
            seq:callback(function()
                local charDust = particles:showEmitter(nil, "collectable-sparks", char.x, char.y, 3500, 1)
                local gramDust = particles:showEmitter(nil, "collectable-sparks", gram.x, gram.y, 3500, 1)
                
                char.xScale, char.yScale = 0.1, 0.1

                local seq2 = anim:oustSeq("characterAppear", char)
                seq2.target2 = self.focusCharacter.shadow
                seq2:tran({alpha=0.75, xScale=1, yScale=1, time=2000, delay=500, ease="bounce"})
                --seq2.onComplete = function() self.focusCharacter.shadow.alpha = 0.65 end
                seq2:start()
            end)
            seq:tran({xScale=-1.5, yScale=1.5, alpha=0, time=2000, delay=500, ease="bounce"})
        else
            seq:add("glow", {time=1250, delay=250, alpha=0.25})
        end

        seq:start()
    end
end


function scene:actionShowPlanet()
    local seq = anim:chainSeq("tv", self.tvimage)
    seq:tran({alpha=0, time=1000})
    seq.onComplete = function() 
        self.tvimage = newImage(self.view, "mothership/tv-planet"..self.planet, centerX+600, 260)
        self.tvimage.alpha = 0
        self.tvimage:toBack()

        local seq2 = anim:oustSeq("tv", self.tvimage)
        seq2:tran({alpha=1, time=2000})
        seq2:tran({x=-120, time=20000})
        seq2:start()
    end
    seq:start()
end


function scene:actionShowNewCharacter()
    local char = scene.focusCharacter
    local data = characterData[char.model]

    local seq = anim:chainSeq("tv", self.tvimage)
    seq:tran({alpha=0, time=1000})
    seq.onComplete = function() 
        self.tvimage:removeSelf()
        self.tvimage = newImage(self.view, "mothership/tv-"..data.name, centerX, centerY-60)
        self.tvimage.alpha = 0
        self.tvimage:toBack()

        local seq2 = anim:oustSeq("tv", self.tvimage)
        seq2:tran({alpha=1, time=1000})
        seq2.onComplete = function() self:actionShowCharacterStats(data) end
        seq2:start()
    end
    seq:start()
end


function scene:actionShowCharacterStats(data)
    local name = newText(self.view, data.name, 530, 150, 0.7, data.color, "CENTER")
    name.alpha = 0

    local seq = anim:chainSeq("charStats", name)
    seq:tran({alpha=1, time=250})

    self:actionShowStat("grade:",   data.bio.grade,   185, data.color)
    self:actionShowStat("home:",    data.bio.home,    210, data.color)
    self:actionShowStat("age:",     data.bio.age,     235, data.color)
    self:actionShowStat("likes:",   data.bio.likes,   260, data.color)
    self:actionShowStat("hates:",   data.bio.hates,   285, data.color)
    self:actionShowStat("ability:", data.bio.ability, 310, "red")
    self:actionShowStat("throws:",  data.bio.throws,  335, data.color)

    anim:startQueue("charStats")
end


function scene:actionShowStat(labelText, valueText, ypos, valueColor)
    local label = newText(self.view, labelText, 480, ypos, 0.35, "black",    "LEFT")
    local value = newText(self.view, valueText, 565, ypos, 0.35, valueColor, "LEFT")
    label.alpha = 0
    value.alpha = 0

    local seq = anim:chainSeq("charStats", label)
    seq.target2 = value
    seq:tran({alpha=1, time=250, ease="whizz"})
end


function scene:actionShowEnemy(name)
    local seq = anim:chainSeq("tv", self.tvimage)
    seq:tran({alpha=0, time=1000})
    seq.onComplete = function() 
        self.tvimage:removeSelf()
        self.tvimage = newImage(self.view, "mothership/tv-"..name, centerX, centerY-60)
        self.tvimage.alpha = 0
        self.tvimage:toBack()

        local seq2 = anim:oustSeq("tv", self.tvimage)
        seq2:tran({alpha=1, time=1000})
        seq2:start()
    end
    seq:start()
end


function scene:actionShowBrainiak()
    self:actionShowEnemy("brainiak")
end

function scene:actionShowEarlGrey()
    self:actionShowEnemy("earlgrey")
end


------ END FUNCTIONS CALLED BY CUTSCENE STORY SCRIPTS --------


function scene:finishStory()
    local delay = 0

    for model, character in pairs(scene.characters) do
        character.action = true

        local num = random(100)

        if     num <= 5  then character:animate("Taunt 1")
        elseif num <= 10 then character:animate("Taunt 2")
        elseif num <= 15 then character:animate("Taunt 3")
        elseif num <= 20 then character:animate("Negable THROW PREP")
        elseif num <= 25 then character:animate("1 2 Stars")
        else                  character:animate("3 4 Stars") end

        delay = delay + 150
    end

    after(1000, function()
        local self = scene

        -- Show Advert + shop button & next button
        local group = display.newGroup()
        group.alpha = 0
        self.view:insert(group)

        newBlocker(group)
        newImage(group, "locking/popup-advert1", 140, 310)

        local continueText   = newText(group,  "continue game", 900, 480, 0.5, "white", "RIGHT")
        local shop, shopOver = newButton(group, 130, 550, "shop", function() scene:exitToStore() end)
        local next, nextOver = newButton(group, 825, 550, "next", function() scene:exitMothership() end)

        local seq1   = anim:chainSeq("button1", shop)
        seq1.target2 = shopOver
        seq1:add("pulse", {time=1500, scale=0.02, baseScale=1})
        
        local seq2   = anim:oustSeq("button2", next)
        seq2.target2 = nextOver
        seq2:add("pulse", {time=1500, scale=0.05, baseScale=1})

        local seq3   = anim:oustSeq("button3", continueText)
        seq3:add("pulse", {time=1500, scale=0.02, baseScale=0.5})

        local seq4 = anim:oustSeq("endsequence", group)
        seq4:tran({time=300, alpha=1})

        seq1:start()
        seq2:start()
        seq3:start()
        seq4:start()
    end)
end


function scene:exitToStore()
    loadSceneTransition(1)
    --after(10, function() storyboard:gotoScene("scenes.inapp-purchases") end)
    storyboard:gotoScene("scenes.inapp-purchases", {effect="fade", time=750})
    return true
end


function scene:exitMothership()
    loadSceneTransition()
    storyboard:gotoScene(state.sceneAfterCutScene, {effect="fade", time=750})
    return true
end


-- Called when scene is about to move offscreen:
function scene:exitScene(event)
    Runtime:removeEventListener("enterFrame", sceneEnterFrameEvent)
    anim:destroy()
    self.planetSpec = nil
end


-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
    storyboard.purgeScene("scenes.title")
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
    local group = self.view
end


-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
    local overlay_name = event.sceneName  -- name of the overlay scene
end


-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
    local overlay_name = event.sceneName  -- name of the overlay scene
end


---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

scene:addEventListener( "createScene", scene )
scene:addEventListener( "willEnterScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "didExitScene", scene )
scene:addEventListener( "destroyScene", scene )
scene:addEventListener( "overlayBegan", scene )
scene:addEventListener( "overlayEnded", scene )

return scene