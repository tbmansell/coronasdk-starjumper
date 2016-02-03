local storyboard    = require("storyboard")
local cameraLoader  = require("core.camera")
local anim          = require("core.animations")
local soundEngine   = require("core.sound-engine")
local stories       = require("core.story")
local particles     = require("core.particles")
local utils         = require("core.utils")
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
        xpos  = 170, 
        ypos  = 500,
        hologram = {xpos=300, ypos=540}
    },
    {
        model = characterGrey,
        xpos  = 280,
        ypos  = 510,
        hologram = {xpos=360, ypos=540}
    },
    {
        model = characterNewton,
        xpos  = 50,
        ypos  = 530,
    },
    {
        model = characterSkyanna,
        xpos  = 120,
        ypos  = 560,
        hologram = {xpos=180, ypos=540}
    },
    {
        model = characterBrainiak,
        xpos  = 230, 
        ypos  = 580,
        hologram = {xpos=240, ypos=540}
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

    --newImage(self.view, "mothership/er", centerX, centerY)
    newImage(self.view, "mothership/bgr", centerX, centerY)

    Runtime:addEventListener("enterFrame", sceneEnterFrameEvent)
    Runtime:addEventListener("tap",        scene.finishStory)

    self:loadStory()
    self:loadBoss()
    self:loadCharacters()
    self:animateCharacters()
    self:startCutscene()

    stories:start(scene.story, function()end, function() scene:finishStory() end, nil, self)
end


function scene:loadStory()
    if state.cutsceneStory == "cutscene-planet-intro" then
        scene.story = state.cutsceneStory .."-".. planetData[state.data.planetSelected].name
        scene.type  = "planetIntro"

    elseif state.cutsceneStory == "cutscene-planet-outro" then
        scene.story = state.cutsceneStory .."-".. planetData[state.data.planetSelected].name
        scene.type  = "planetOutro"

    elseif state.cutsceneStory == "cutscene-character-intro" then
        scene.story = state.cutsceneStory .."-".. characterData[state.cutsceneCharacter].name
        scene.type  = "character"
    end

    print("story="..scene.story)
end


function scene:loadBoss()
    scene.boss = spineStore:showBossChair({x=830, y=250, size=0.35})
    self.view:insert(scene.boss.image)
end


function scene:loadCharacters(event)
    scene.characters = {}
    scene.holograms  = {}
    scene.spineDelay = 0

    for _,data in pairs(characterPosition) do
        local model = data.model
        local char  = characterData[model]

        if char.playable then
            --if state:characterUnlocked(model) then
                scene:createCharacter(data, centerX - data.xpos, data.ypos)
            --else
            if data.hologram then
                scene:createHologram(data, centerX + data.hologram.xpos, data.hologram.ypos)
            end
            --end
        end
    end
end


function scene:createCharacter(charData, xpos, ypos, locked)
    local model = charData.model
    local spec  = {model=model, x=xpos, y=ypos, size=0.3}

    --scene.spineDelay = scene.spineDelay + 100
    --local ai = spineStore:showCharacter(spec, scene.spineDelay)
    local ai = spineStore:showCharacter(spec)
    ai.model = model
    ai.scene = charData
    self.view:insert(ai.image)

    scene.characters[model] = ai

    if model == state.cutsceneCharacter and state.cutsceneStory == "cutscene-character-intro" then
        ai:x(-300)
        scene.focusCharacter = ai
    end
end


function scene:createHologram(charData, xpos, ypos)
    scene.spineDelay = scene.spineDelay + 133
    
    local model = charData.model
    local spec  = {model=model, x=xpos, y=ypos, size=0.2, animation="Hologram", spineDelay=scene.spineDelay}

    local ai = spineStore:showCharacter(spec)
    ai.model = model
    ai.scene = charData
    ai.image:scale(-1,1)
    --ai:visible(0.5)

    self.view:insert(ai.image)
    scene.holograms[model] = ai
    
    local seq = anim:oustSeq("hologram-"..scene.spineDelay, ai.image)
    seq:add("glow", {time=1250, delay=250, alpha=0.5})
    seq:start()
end


function scene:animateCharacters()
    for model, character in pairs(scene.characters) do
        scene:animateCharater(character)
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


function scene:startCutscene()
    if state.cutsceneStory == "cutscene-character-intro" then
        local ai    = scene.focusCharacter
        local model = ai.model
        local xpos  = centerX - ai.scene.xpos
        local ypos  = ai.scene.ypos

        ai.action = true
        ai:loop("Walk")

        local seq = anim:oustSeq("newCharacter", ai.image)
        seq:tran({x=xpos, time=6000})
        seq.onComplete = function() 
            ai.action = false
            scene:animateCharater(ai)
        end
        seq:start()
    end
end


function scene:showTvPlanet1()
    self.tvimage = newImage(self.view, "mothership/tv-planet1", centerX+600, 260)
    self.tvimage.alpha = 0
    self.tvimage:toBack()

    local seq2 = anim:chainSeq("tv", self.tvimage)
    seq2:wait(2000)
    seq2:tran({alpha=1, time=2000})
    seq2:tran({x=-120, time=15000})
    seq2:start()
end



--[[
function scene:summaryCharacter(xpos, ypos, character, unlockText)
    local data = characterData[character]

    newImage(self.view, "hud/player-indicator-"..data.name, xpos, ypos)
    newText(self.view, data.name, xpos+30, ypos, 0.5, data.color, "LEFT")

    if state:characterUnlocked(character) then
        newText(self.view, "unlocked!", xpos-30, ypos+40, 0.4, "green", "LEFT")
    else
        newImage(self.view, "locking/lock", xpos, ypos, 0.5, 0.7)
        newText(self.view, unlockText, xpos-30, ypos+40, 0.4, "white", "LEFT")
    end
end


function scene:summaryNextPlanet(xpos, ypos)
    local nextPlanet = planetData[self.planet+1]

    newImage(self.view, "select-game/tab-planet2", xpos+10, ypos+10, 0.25)
    newText(self.view, nextPlanet.name, xpos+30, ypos-20, 0.5, nextPlanet.color, "LEFT")

    if state:planetUnlocked(self.planet+1) then
        newText(self.view, "unlocked!", xpos+200, ypos+40, 0.45, "green", "RIGHT")
    else
        newImage(self.view, "locking/lock",     xpos, ypos, 0.5, 0.7)
        newText(self.view, "complete 5 zones*", xpos-30, ypos+40, 0.45, "white", "LEFT")
    end
end
]]



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
        -- Turn off TV
        local seqtv = anim:oustSeq("tv", self.tvimage)
        seqtv:tran({alpha=0, time=1000})
        seqtv:start()

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
    Runtime:removeEventListener("tap",        scene.finishStory)
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