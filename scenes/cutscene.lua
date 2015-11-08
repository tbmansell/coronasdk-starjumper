local storyboard   = require("storyboard")
local physics      = require("physics")
local cameraLoader = require("core.camera")
local anim         = require("core.animations")
local soundEngine  = require("core.sound-engine")
local stories      = require("core.story")
local particles    = require("core.particles")
local builder      = require("level-objects.builders.builder")

-- local variables for performance
local scene              = storyboard.newScene()
local player             = nil
local camera             = nil
local level              = nil
local enterFrameFunction = nil


-- Called when the scene's view does not exist:
function scene:createScene(event)
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene(event)
    logAnalytics("cutscene", "enterScene")
    setMovementStyleSpeeds()
    self:initPhysics()
    self:loadCutScene()
    self:playCutScene()
end


function scene:initPhysics()
    physics.start(false)
    physics.pause()
    physics.setGravity(0, curve.Gravity)
    physics.setDebugErrorsEnabled()
    physics.setTimeStep(1/60)
end


function scene:loadCutScene()
    state.data.game = levelStartShowCase

    -- Create global game objects
    camera       = cameraLoader.createView()
    -- Create global and cleanup after this scene
    cameraHolder = { camera = camera }
    level        = require("core.level")

    level:new(camera, state.data.gameSelected, state.data.planetSelected, state.data.zoneSelected)
    level:createElements()

    self:setupCamera()
    self:createAIPlayers()
    self:createEventHandlers()

    soundEngine:setup()
end


function scene:setupCamera()
    if level.data.cameraBounds then
        level:createCustomWidth(level.data.cameraBounds[1], level.data.cameraBounds[2])
    end

    camera:setAlpha(0)
    camera:setParallax(1.1, 1, 1, 1, 0.2, 0.15, 0.1, 0.05)

    if level.data.cameraBounds then
        camera:applyBounds(false)
    else
        camera:setBounds(0, level.endXPos, level.data.floor, level.data.ceiling)
    end

    if level.data.cameraOffset then
        camera:setFocusOffset(level.data.cameraOffset[1], level.data.cameraOffset[2])
    end

    hud.camera = camera
end


function scene:createEventHandlers()
    enterFrameFunction  = level.updateFrame
    self.gameLoopHandle = timer.performWithDelay(250, level.updateBehaviours, 0)

    Runtime:addEventListener("enterFrame", enterFrameFunction)
end


-- Function which loads in an AI player
function scene:createAIPlayers()
    local spineDelay = 0

    if level.ai then
        for key,ai in pairs(level.ai) do
            local spec = builder:newClone(ai)
            spec.type  = "ai"

            spec.failedCallback    = function() end
            spec.completedCallback = function() end
            spec.spineDelay        = spineDelay

            local aiPlayer = level:createPlayer(spec)
            aiPlayer:initForGameType(state.data.gameSelected)
            aiPlayer:wait(aiPlayer.waitingTimer)

            sounds:loadPlayer(aiPlayer.model)

            if ai.startSequence == "stand" then
                aiPlayer:stand()
            elseif ai.startSequence == "taunt" then
                aiPlayer:taunt(ai.startTaunt, 10)
            end

            -- set first AI to be the player (with the focus)
            if player == nil then
                player = aiPlayer
                camera:add(player.image, 3, true)
                level:defaultMainPlayer()
            end

            spineDelay = spineDelay + 250
        end
    end
end


function scene:playCutScene()
    -- Allow the scene to play out but keep it hidden by the scene transition and slowly fade scene in
    globalSceneTransitionGroup:toFront()
    camera:setAlpha(1)
    clearSceneTransition(1000)

    camera:track()
    physics:start()

    local pauseHandler  = function() end
    local resumeHandler = function() scene:nextScene() end

    stories:start("cutscene-planet"..state.data.planetSelected..state.data.zoneSelected, pauseHandler, resumeHandler)

    level:startConstantSounds()

    if level.data.customEvent then
        local event  = level.data.customEvent
        -- Allow custom code to access these
        scene.player = player
        --scene.aiPlayers = aiPlayers
        scene.level  = level

        after(event.delay, function() event.start(scene) end)
    end
end


function scene:nextScene()
    loadSceneTransition(3000)

    after(3000, function()
        state.data.zoneSelected = 1
        storyboard:gotoScene(state.sceneAfterCutScene)
    end)
end


-- Called when scene is about to move offscreen:
function scene:exitScene(event)
    self:unloadCutScene()
end


function scene:unloadCutScene()
    Runtime:removeEventListener("enterFrame", enterFrameFunction)
    timer.cancel(self.gameLoopHandle)
    track:cancelEventHandles()

    -- TODO: unload sounds for AI players?

    physics.stop()
    anim:destroy()
    particles:destroy()
    level:destroy()
    soundEngine:destroy()
    camera:destroy()

    cameraHolder, camera, level, player = nil, nil, nil, nil
    scene.player, scene.aiPlayers, scene.level = nil, nil, nil
end


-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
    storyboard.purgeScene("scenes.cutscene")
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