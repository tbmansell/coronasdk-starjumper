local storyboard    = require("storyboard")
local physics       = require("physics")
local cameraLoader  = require("core.camera")
local anim          = require("core.animations")
local particles     = require("core.particles")
local soundEngine   = require("core.sound-engine")
local builder       = require("level-objects.builders.builder")
local playerBuilder = require("level-objects.builders.player-builder")

-- local variables for performance
local scene              = storyboard.newScene()
local player             = nil
local remotePlayer       = nil
local camera             = nil
local level              = nil
local levelGenerator     = nil
local cameraDragging     = false
local enterFrameFunction = nil

-- Aliases:
local math_abs   = math.abs
local math_round = math.round


-- Global function to allow other events to activate the game loop which stops level elements from moving
----
function globalSetLevelFreeze(freeze)
    Runtime:removeEventListener("enterFrame", enterFrameFunction)

    if freeze then
        enterFrameFunction = level.updateTimeFrozenFrame
        level:pauseElements()
    else
        enterFrameFunction = level.updateFrame
        level:resumeElements()
    end

    Runtime:addEventListener("enterFrame", enterFrameFunction)
end


-- Called when player taps on a ledge to move them
function globalTapLedge(target, event)
    local ledge    = target.object
    local playerX  = player:x()
    local gameMode = state.data.game

    -- tutorial control
    if not allowPlayerAction("tap-ledge", ledge.key, {to=(event.x - playerX)}) then return true end

    if (gameMode == levelPlaying or gameMode == levelTutorial) and player.mode == playerReady and player.attachedLedge then
        -- normal usage of tapping a ledge: if player on attached ledge they move on it
        if player:onLedge(ledge) then
            hud:levelStartedSequence()

            local dest    = math_round(event.x - playerX)
            local toX     = player:x() + dest
            local left    = ledge:leftEdge(20)
            local right   = ledge:rightEdge(20)

            if toX < playerX and toX < left then
                dest = math_round(left - playerX)
            elseif toX > playerX and toX > right then
                dest = math_round(right - playerX)
            end

            if dest < -10 or dest > 10 then
                player:moveOnLedge(dest)
            end
        -- special use: tapping a ledge a character is not on
        elseif not player:onLedge(ledge) and player.tapOtherLedge then
            player:tapOtherLedge(ledge)
        end
    end
    return true
end


-- Generic touch event
local function sceneTouchEvent(event)
    local gameMode = state.data.game

    if gameMode ~= levelPlaying and gameMode ~= levelTutorial  then
        -- Dont allow interaction if not playing the level
        return false
    end

    local playerMode = player.mode
    local begin      = false

    if event.phase == "began" then begin = true end    

    if playerMode == playerJump and begin then
        -- activate air gear
        if allowPlayerAction("use-air-gear") then 
            player:jumpAction()
        end
    elseif playerMode == playerSwing and begin then
        -- jump off swing
        if allowPlayerAction("jump-off-swing") then
            player:swingOffAction()
        end
    elseif playerMode == playerHang and begin then
        -- let go of obstacle
        if allowPlayerAction("drop-obstacle") then
            player:letGoAction()
        end
    elseif playerMode == playerOnVehicle and begin then
        if allowPlayerAction("escape-vehicle") then
            player:escapeVehicleAction()
        end
    elseif playerMode == playerDrag or playerMode == playerThrowing then
        -- Setup and update the jump
        scene:handleJump(event)
    elseif not cameraDragging and (player:isDead() or event.phase == "ended" or event.phase == "cancelled") then
        -- Ensure the jump is always cleared up
        curve:clearUp(camera)
    elseif playerMode == playerReady or playerMode == playerWalk then --or playerMode == playerHang then
        -- look around the level
        if hud.debugMode then
            scene:handleDebugPeeking(event)
        else
            scene:handlePeeking(event)
        end
    end
end


-- Called when the scene's view does not exist:
function scene:createScene(event)
    local game = state.data.gameSelected
    state.infiniteRunner = (game == gameTypeArcadeRacer or game == gameTypeTimeRunner or game == gameTypeClimbChase)

    scene:initPhysics()
    scene:loadGame()
    scene:createEventHandlers()
    scene:initLocals()
    particles:preLoadEmitters()

    -- these top and bottom borders ensure that devices where the length is greater than 960 (ipad retina) the game doesnt show under or above the background size limits
    local topBorder = display.newRect(centerX, -50, contentWidth, 100)
    local botBorder = display.newRect(centerX, contentHeight+50, contentWidth, 100)
    topBorder:setFillColor(0,0,0)
    botBorder:setFillColor(0,0,0)

    if state.data.multiplayer then
        scene:setupMultiplayer()
    else
        print("#########startLevelSequence")
        self:startLevelSequence(player, scene.startPlaying)
    end
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene(event)
    logAnalytics("play-zone", "enterScene")
    clearSceneTransition()
    -- Save game state so when restored we can know which zone was selected
    state:newScene("play-zone")
    state:saveGame()
    setMovementStyleSpeeds()
end


-- Called when scene is about to move offscreen:
function scene:exitScene(event)
    self:unloadLevel()
    -- Save game regardless of how we left the level
    state:saveGame()
end


-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
    storyboard.purgeScene("scenes.play-zone")
end


function scene:initPhysics()
    physics.start(false)
    physics.pause()
    physics.setGravity(0, curve.Gravity)
    physics.setDebugErrorsEnabled()
    physics.setTimeStep(1/60)
end


function scene:loadGame()
    local game      = state.data.gameSelected
    state.data.game = levelStartShowCase

    -- Create key game objects
    camera = cameraLoader.createView()
    -- Create global and cleanup after this scene
    cameraHolder = { camera = camera }

    self:createLevel()

    -- Race - load the planets set AI & override zone AI
    if game == gameTypeRace or game == gameTypeArcadeRacer or (game == gameTypeStory and level.ai) then
        self:createAiPlayers(level)
    end

    -- create Main player after AI players, so player remains in front
    player = level:createPlayer({type="main", model=state.data.playerModel, failedCallback=hud.levelFailedSequence, completedCallback=hud.levelCompleteSequence})
    player:initForGameType(game)
    level:assignMainPlayerRef()

    if state.infiniteRunner then
        -- Setup hook to trigger more elements in infinite runner
        player.infiniteCallback = function(jumpObject)
            -- update current distance
            if jumpObject.isLedge then
                if raceGameType[state.data.gameSelected] then
                    hud:updateInfiniteRace(jumpObject, player)
                else
                    hud:updateInfiniteStats(jumpObject, player)
                end
            end

            -- check for generating the next stage after a delay so the pause isnt straight on landing
            after(1500, function() 
                levelGenerator:checkGenerateNextStage(camera, jumpObject) 
            end)
        end
    end

    -- position for race after everyone is created
    if game == gameTypeRace or game == gameTypeArcadeRacer then
        self:setupSpaceRace()
    end
    
    soundEngine:setup()
    hud:create(camera, player, level, scene.pauseLevel, scene.resumeLevel)
end


function scene:createLevel()
    if state.infiniteRunner then
        -- stick the camera in the hud NOW as its required for some cerated components
        hud.camera     = camera
        levelGenerator = require("core.level-generator")
        level          = levelGenerator:createLevel(camera)

        self:setupCamera()
        levelGenerator:checkGenerateNextStage(camera)
    else
        level = require("core.level")
        level:new(camera, state.data.gameSelected, state.data.planetSelected, state.data.zoneSelected)
        level:createElements()
        self:setupCamera()
    end
end


function scene:setupCamera()
    camera:setParallax(1.1, 1, 1, 1, 0.2, 0.15, 0.1, 0.05)
    camera:setBounds(-300, level.endXPos, level.data.floor+100, level.data.ceiling)
    camera:setFocusOffset(250, 50)
end


function scene:createEventHandlers()
    enterFrameFunction = level.updateFrame

    Runtime:addEventListener("enterFrame", enterFrameFunction)
    Runtime:addEventListener("touch",      sceneTouchEvent)

    self.gameLoopHandle = timer.performWithDelay(250, level.updateBehaviours, 0)
end


function scene:initLocals()
    dragScreenX    = 0
    dragScreenY    = 0
    cameraDragging = false
    fingerPoint    = nil
end


function scene:setupMultiplayer()
    hub = hubLoader:createHub()
    netHud:create()
    hub:join()
    -- Post out a message to wait for a game to start, btu dont start until other player connected
    hud:displayMessage("waiting for other player")
    hub:publicMessage("game-start")
end


-- NOTE: this loads player directly after so they stay in front
function scene:createAiPlayers(level)
    local playerModel  = state.data.playerModel
    local spineDelay   = 1000
    local indicatorPos = 0

    for key,ai in pairs(level.ai) do
        -- dont load an AI player currently the same as the players selected character
        if ai.model ~= playerModel then
            local aiFailed    = function() print("AI player "..key.." lost all lives") end
            local aiCompleted = function() local pos = hud:racerCompletedZone(aiPlayer); aiPlayer:moveOnLedge(pos*40) end
            local spec        = builder:newClone(ai)

            spec.type              = "ai"
            spec.failedCallback    = aiFailed
            spec.completedCallback = aiCompleted
            spec.spineDelay        = spineDelay

            local aiPlayer = level:createPlayer(spec)
            aiPlayer:initForGameType(state.data.gameSelected)
            aiPlayer.indicatorAdjustment = indicatorPos * 25

            -- Setup hook to trigger more elements in infinite runner
            if state.infiniteRunner then
                aiPlayer.infiniteCallback = function(jumpObject)
                    if jumpObject.isLedge then
                        hud:updateInfiniteRace(jumpObject, aiPlayer)
                    end
                    -- check for generating the next stage after a delay so the pause isnt straight on landing
                    after(1500, function() 
                        levelGenerator:checkGenerateNextStage(camera, jumpObject)
                    end)
                end
            end

            sounds:loadPlayer(ai.model)
            aiPlayer:wait(aiPlayer.waitingTimer)

            if ai.startSequence == "stand" then
                aiPlayer:stand()
            elseif ai.startSequence == "taunt" then
                aiPlayer:taunt(ai.startTaunt, 10)
            end

            spineDelay   = spineDelay   + 1000
            indicatorPos = indicatorPos + 1
        end
    end
end


function scene:setupSpaceRace(zoneFile)
    if state.data.gameSelected == gameTypeArcadeRacer then
        scene:randomiseRacePositions()
    end

    for pos,playerModel in pairs(state.racePositions) do
        local moveBy = 0
        if     pos == 1 then moveBy = 80
        elseif pos == 2 then moveBy = 40 
        elseif pos == 3 then moveBy = 0
        elseif pos == 4 then moveBy = -40
        elseif pos == 5 then moveBy = -80  end

        print("Racer "..playerModel.." position "..pos.." moveBy "..moveBy)

        level.players:IAPData(function(object)
            if object.main then
                object.moveByAfterStart = moveBy
            else
                object:x(moveBy)
            end
        end)

        --[[if playerModel == player.model then
            player.moveByAfterStart = moveBy
        else
            for i=1,#aiPlayers do
                local ai = aiPlayers[i]
                if playerModel == ai.model then
                    ai:x(moveBy)
                end
            end
        end]]
    end
end


-- TODO: actually make this random
function scene:randomiseRacePositions()
    level.players:forEach(function(object)
        state.racePositions[object.model] = object.model
    end)

    --[[for i=1, #aiPlayers do
        local ai = aiPlayers[i]
        state.racePositions[ai.model] = ai.model
    end
    state.racePositions[player.model] = player.model]]
end


function scene:startLevelSequence(player, startGameCallback)
    state.data.game = levelStartStarted

    local game = state.data.gameSelected

    if game == gameTypeStory then
        local startSequence = level.data.playerStart or playerStartStand

        if startSequence == playerStartWalk then
            player:walkOntoLevel(startGameCallback)
        elseif startSequence == playerStartFall then
            local spec      = {object="friend", type="ufoboss", x=0, y=0, size=0.7, hasPassenger=true, playerModel=player.model}
            local spaceship = level:createFriend(spec, level.startLedge)
            
            player:fallFromShip(camera, spaceship, startGameCallback)
        else
            print("############player standing ready")
            player:standingReady(startGameCallback)
        end
    else
        if game == gameTypeClimbChase then
            player:startClimbChase(camera, startGameCallback)
        end

        hud:startLevelSequence(level, player)
        hud:countDownSequence(startGameCallback, player, level)
    end
end


function scene:startPlaying(player)
    state.data.game = levelPlaying
    print("########################game started")

    math.randomseed(os.time())

    after(200, function() physics:start() end)
    
    if state.data.gameSelected == gameTypeStory then
        hud:startLevelSequence(level, player)
    end

    camera:track()

    player.startLedge:bind(player)
    player:stand()

    soundEngine:loadBackgroundSounds(level.data.backgroundSounds or level.planetDetails.backgroundSounds)
    level:startConstantSounds()

    -- check if this zone has an intro script:
    if state.data.gameSelected == gameTypeStory then
        hud:showStory("intro-planet"..state.data.planetSelected.."-zone"..state.data.zoneSelected)
        hud:showTutorial(level.data.tutorial)
    end
    
    hud:startTimer()
end


-- Function which loads in the remote player
function remotePlayerConnected()
    -- Only load main player if the game has not already started
    --[[if state.data.game == levelStartShowCase then
        scene:startLevelSequence(player, scene.startPlaying)
    end

    remotePlayer = playerLoader:new("player-remote",  "Green Space Man", characterNewton, 
        function() print("remote player lost all lives") end, 
        function() print("remote player completed level") end)
    
    remotePlayer:load(level)
    remotePlayer:stand()]]
    --scene:startLevelSequence(remotePlayer, scene.startRemote)
end


function scene:pauseLevel()
    state.data.game = levelPaused
    Runtime:removeEventListener("enterFrame", enterFrameFunction)
    physics:pause()
    timer.pause(scene.gameLoopHandle)
    anim:pause()
end


function scene:resumeLevel()
    state.data.game = levelPlaying
    Runtime:addEventListener("enterFrame", enterFrameFunction)
    physics:start()
    timer.resume(scene.gameLoopHandle)
    anim:resume()
end


function scene:handleJump(event)
    if event.phase == "moved" then
        scene:jumpPreperationMoving(event)

    elseif event.phase == "ended" or event.phase == "cancelled" then
        -- if locked then we dont allow the jump to turn into a run until they are near the jump point
        if curve.lock and not allowPlayerAction("jump", nil, {player=player, event=event}) then
            curve:clearUp(camera)
            player:cancelJump()
        else
            scene:jumpPreperationGo(event)
        end
    end
end


function redrawTrajectory() end


function scene:jumpPreperationMoving(event)
    local px, py, ex, ey, cancelJump = curve:calcPull(player, event)

    -- check if we should cancel the pull if players moves high
    if cancelJump and curve.lock == nil then
        curve:clearUp(camera)

        if player.mode == playerDrag then
            player:cancelJump()
        elseif player.mode == playerThrow then
            player:cancelThrow()
        end

        return
    end

    -- check if on start ledge and dissalow jumping left
    if player:onStartLedge() and ex > player:x() then
        return
    end

    curve:drawLine(camera, px, py, ex, ey)

    if curve.showTrajectory then
        curve:drawTrajectory(camera, px, py, ex, ey, camera.scaleVelocity)
        --curve:drawTrajectoryScaled(camera, px, py, ex, ey, camera.scaleVelocity)
        -- if on a moving ledge, create a global function that the movement code can call to force the trajectory to redraw itself
        if player.attachedLedge.movement then
            redrawTrajectory = function() curve:drawTrajectory(camera, px, py, ex, ey) end
        end
    end

    -- Move the camera according to the direction and relative to the players movement left or right
    local cameraX = camera:getXPosition()
    local vdiff   = (ex - cameraX)
    camera:setXPosition(vdiff)

    if curve.lock == nil then
        if ex > player:x() and player.direction == right then
            curve:flipGrid(player)
            player:changeDirection(left)

        elseif ex < player:x() and player.direction == left then
            curve:flipGrid(player)
            player:changeDirection(right)
        end
    end

    --curve:debug(player, px, py, ex, ey)
end


function scene:jumpPreperationGo(event)
    curve:clearUp(camera)

    local px, py, ex, ey = curve:calcPull(player, event)
    local diffx, diffy   = px-ex, py-ey

    if curve.lock then
        diffx, diffy = -curve.lock[1], -curve.lock[2]
    end

    if (math_abs(diffx) > 40 or math_abs(diffy) > 40) and
       ((diffx < 0 and player.direction == left) or (diffx > 0 and player.direction == right)) 
    then
        if player.mode == playerDrag then
            return player:runup(curve:calcVelocity(diffx, diffy))
        elseif player.mode == playerThrowing then
            return player:throwNegable(curve:calcVelocity(diffx, diffy))
        end
    else
        if player.mode == playerDrag then
            return player:cancelJump()
        elseif player.mode == playerThrowing then
            return player:cancelThrow()
        end
    end
end


function scene:handleDebugPeeking(event)
    if event.phase == "began" then
        dragScreenX, dragScreenY = event.x, event.y

        if not cameraDragging then
            local distX, distY = math_abs(event.x - player:x()), math_abs(event.y - player:midHeight())
            if distX > 120 or distY > 150 then
                scene.lastDebugPointX, scene.lastDebugPointY = player:x(), player:y()
                cameraDragging = true
            end
        end

    elseif cameraDragging then
        if event.phase == "moved" then
            local ex, ey = event.x - dragScreenX, event.y - dragScreenY
            local dx, dy = scene.lastDebugPointX-ex, scene.lastDebugPointY-ey
            scene:addPointAtFingerPosition(dx,dy)
        end
    end
end


function scene:handlePeeking(event)
    if event.phase == "began" then
        dragScreenX, dragScreenY = event.x, event.y

        -- dont allow user to drag screen near the player to avoid mistakes
        local distX, distY = math_abs(event.x - player:x()), math_abs(event.y - player:midHeight())
        
        if distX > 120 or distY > 150 then
            cameraDragging = true
        end

    elseif cameraDragging then
        if event.phase == "moved" then
            local ex, ey = event.x - dragScreenX, event.y - dragScreenY
            local dx, dy = player:x()-ex, player:y()-ey
            -- Because this function doesnt work without forever scrolling
            --camera:toPoint(dx, dy)
            -- Have cheated and added a focus element on every move:
            scene:addPointAtFingerPosition(dx,dy)

        elseif event.phase == "ended" or event.phase == "cancelled" then
            cameraDragging = false
            scene:removePointAtFingerPosition()
            camera:restoreFocus(player.image)
            --camera:forceWithinBoundaries()
        end
    end
end


function scene:addPointAtFingerPosition(x,y)
    scene:removePointAtFingerPosition()
        
    fingerPoint = display.newCircle(x,y, 1)
    fingerPoint.alpha = 0
    camera:add(fingerPoint,3,true)
end


function scene:removePointAtFingerPosition()
    if fingerPoint ~= nil then
        camera:remove(fingerPoint)
        fingerPoint:removeSelf()
        fingerPoint = nil
    end
end


function scene:unloadLevel()
    Runtime:removeEventListener("enterFrame", enterFrameFunction)
    Runtime:removeEventListener("touch",      sceneTouchEvent)
    --Runtime:removeEventListener("tap",        sceneTapEvent)
    timer.cancel(self.gameLoopHandle)
    track:cancelEventHandles()

    -- TODO: unload sounds for AI players?

    physics.stop()
    anim:destroy()
    particles:destroy()
    level:destroy()
    soundEngine:destroy()
    hud:destroy()
    netHud:destroy()
    camera:destroy()

    if levelGenerator then levelGenerator:destroy() end

    cameraHolder, camera, player, level, levelGenerator = nil, nil, nil, nil, nil
    collectgarbage("collect")
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