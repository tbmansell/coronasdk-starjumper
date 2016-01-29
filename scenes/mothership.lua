local storyboard    = require("storyboard")
local cameraLoader  = require("core.camera")
local anim          = require("core.animations")
local soundEngine   = require("core.sound-engine")
local stories       = require("core.story")
local particles     = require("core.particles")
local utils         = require("core.utils")
local builder       = require("level-objects.builders.builder")
local spineStore    = require("level-objects.collections.spine-store")
--local friendBuilder = require("level-objects.builders.friend-builder")


-- Local vars:
local scene           = storyboard.newScene()
local spineCollection = nil
local lastTime        = 0

-- Lists each characters scene specific data in order of who should be drawn first (furthest back)
local characterPosition = {
    {
        model = characterGygax,
        xpos  = 700,
        ypos  = 300,
    },
    {
        model = characterHammer,
        xpos  = 170, 
        ypos  = 430,
    },
    {
        model = characterGrey,
        xpos  = 280,
        ypos  = 480,
    },
    {
        model = characterNewton,
        xpos  = 50,
        ypos  = 500,
    },
    {
        model = characterSkyanna,
        xpos  = 120,
        ypos  = 530,
    },
    {
        model = characterBrainiak,
        xpos  = 230, 
        ypos  = 550,
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

    newImage(self.view, "mothership/er", centerX, centerY)
    newImage(self.view, "mothership/bgr", centerX, centerY)

    Runtime:addEventListener("enterFrame", sceneEnterFrameEvent)
    Runtime:addEventListener("tap",        scene.skipStory)

    self:loadStory()
    self:loadCharacters()
    self:animateCharacters()
    self:startCutscene()

    --stories:start(scene.story, function()end, function()end)
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


function scene:loadCharacters(event)
    scene.characters = {}
    scene.spineDelay = 0

    for _,pos in pairs(characterPosition) do
        local model = pos.model
        local char  = characterData[model]

        if char.playable then
            print("added "..char.name.." x="..tostring(pos.xpos).." y="..tostring(pos.ypos))

            if state:characterUnlocked(model) then
                scene:createCharacter(model, centerX - pos.xpos, pos.ypos + 30)
            else
                scene:createCharacter(model, centerX + pos.xpos, pos.ypos + 30, true)
            end
        end
    end
end


function scene:createCharacter(model, xpos, ypos, locked)
    local spec = {model=model, x=xpos, y=ypos, size=0.3}

    if locked then
        spec.animation="Seated"
    end

    scene.spineDelay = scene.spineDelay + 133

    local ai = spineStore:showCharacter(spec)--, scene.spineDelay)
    ai.model = model
    self.view:insert(ai.image)

    scene.characters[model] = ai

    if model == state.cutsceneCharacter and state.cutsceneStory == "cutscene-character-intro" then
        ai:x(-300)
        scene.focusCharacter = ai

    elseif locked then
        local seq = anim:oustSeq("hologram-"..model, ai.image)
        ai.image.alpha = 0.7
        seq:add("glow", {time=1000, delay=50, alpha=0.5})
        seq:start()
    end
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
    print(name.." "..sequence.." for "..duration)

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
        local xpos  = centerX - characterData[model].cutscene.x

        ai:loop("Run New")
        print("moving from "..ai:x().." to "..xpos)

        local seq = anim:oustSeq("newCharacter", ai.image)
        --seq:tran({x=xpos, time=6000})
        seq:tran({x=xpos+300, time=6000})
        seq.onComplete = function() 
            print("oncomplete")
            ai:loop("Standard")
        end
        seq:start()
    end
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



function scene:skipStory()
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

    after(2000, function()
        scene:exitMothership()
    end)
end


function scene:exitToStore()
    loadSceneTransition(1)
    after(10, function() storyboard:gotoScene("scenes.inapp-purchases") end)
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
    Runtime:removeEventListener("tap",        scene.skipStory)
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