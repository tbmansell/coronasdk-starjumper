local storyboard    = require("storyboard")
local cameraLoader  = require("core.camera")
local anim          = require("core.animations")
local soundEngine   = require("core.sound-engine")
local stories       = require("core.story")
local particles     = require("core.particles")
local builder       = require("level-objects.builders.builder")
local spineStore    = require("level-objects.collections.spine-store")
--local friendBuilder = require("level-objects.builders.friend-builder")


-- Local vars:
local scene           = storyboard.newScene()
local spineCollection = nil
local lastTime        = 0

-- Aliases:
local play = globalSoundPlayer


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

    state:newScene("mothership")
    clearSceneTransition()
    globalIgnorePhysicsEngine  = true

    self.planet = state.data.planetSelected
    self.data   = planetData[self.planet]

    package.loaded["levels.planet"..self.planet..".planet"] = nil
    self.planetSpec = require("levels.planet"..self.planet..".planet")

    spineCollection    = builder:newSpineCollection()
    particleCollection = builder:newParticleEmitterCollection()
    spineStore:load(spineCollection)

    newImage(self.view, "mothership/background", centerX, centerY)

    Runtime:addEventListener("enterFrame", sceneEnterFrameEvent)
    Runtime:addEventListener("tap",        scene.skipStory)

    self:loadStory()
    self:loadCharacters()
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

    for model,data in pairs(characterData) do
        local char = characterData[model]

        if char.playable then
            if state:characterUnlocked(model) then
                scene:createCharacter(model, centerX - char.cutscene.x, char.cutscene.y + 30)
            else
                scene:createCharacter(model, centerX + char.cutscene.x, char.cutscene.y + 30, true)
            end
        end
    end
end


function scene:createCharacter(model, xpos, ypos, locked)
    local spec = {model=model, x=xpos, y=ypos, size=0.3}

    if locked then
        spec.animation="Seated"
    end

    local ai = spineStore:showCharacter(spec)
    ai.model = model
    self.view:insert(ai.image)

    scene.characters[characterNewton] = ai

    if model == state.cutsceneCharacter then
        ai:x(-300)
        scene.focusCharacter = ai

    elseif locked then
        local seq = anim:oustSeq("hologram-"..model, ai.image)
        ai.image.alpha = 0.7
        seq:add("glow", {time=1000, delay=50, alpha=0.5})
        seq:start()
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
        seq:tran({x=xpos, time=3000})
        seq.onComplete = function() 
            print("oncoplete")
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
    scene:exitMothership()
end


function scene:exitToStore()
    loadSceneTransition(1)
    after(10, function() storyboard:gotoScene("scenes.inapp-purchases") end)
    return true
end


function scene:exitMothership()
    loadSceneTransition(1)
    after(10, function() storyboard:gotoScene(state.sceneAfterCutScene) end)
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