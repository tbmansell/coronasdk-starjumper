local anim               = require("core.animations")
local soundEngine        = require("core.sound-engine")
local specialLoader      = require("core.level-special")
local navigationLoader   = require("core.level-navigation")
local particles          = require("core.particles")
local builder            = require("level-objects.builders.builder")
local ledgeBuilder       = require("level-objects.builders.ledge-builder")
local obstacleBuilder    = require("level-objects.builders.obstacle-builder")
local enemyBuilder       = require("level-objects.builders.enemy-builder")
local friendBuilder      = require("level-objects.builders.friend-builder")
local collectableBuilder = require("level-objects.builders.collectable-builder")
local playerBuilder      = require("level-objects.builders.player-builder")
local sceneryBuilder     = require("level-objects.builders.scenery-builder")
local spineStore         = require("level-objects.collections.spine-store")


-- Main class
local level = {
    -- List of rings in this level, plus their value in points and cubes
    rings = {
        [yellow] = {inLevel=0, points=60, cubes=6},
        [aqua]   = {inLevel=0, points=10, cubes=1},
        [pink]   = {inLevel=0, points=20, cubes=2},
        [white]  = {inLevel=0, points=50, cubes=5},
        [red]    = {inLevel=0, points=30, cubes=3},
        [green]  = {inLevel=0, points=70, cubes=7},
        [blue]   = {inLevel=0, points=40, cubes=4},
    }
}


-- Local vars (for this file only)
local levelFloor            = nil
local levelStartX           = 0
local levelEndX             = 0
local lastTime              = 0
local camera                = nil
local mainPlayer            = nil
local hasAiPlayers          = false
local hasEnemies            = false
local hasFriends            = false
local hasObstacles          = false
local hasEmitters           = false

local spineCollection       = nil
local movingCollection      = nil
local particleCollection    = nil
local playerCollection      = nil
local ledgeCollection       = nil
local obstacleCollection    = nil
local enemyCollection       = nil
local friendCollection      = nil
local collectableCollection = nil
local sceneryCollection     = nil
local emitterCollection     = nil

local windDirectionRight    = true
local windSpeed             = 1

-- Local vars (also used in other level files)
local jumpObjectRoute       = nil
local aiRace                = false
local lavaChase             = false
local warpChase             = false
local skyChanging           = false

-- Aliases
local math_abs    = math.abs
local math_floor  = math.floor
local math_random = math.random

-- Aliases to functions for enterframe event
local check_background_movement  = function()end
local check_spine_animation      = function()end
local check_moving_objects       = function()end
local check_moving_players       = function()end
local check_ledge_movement       = function()end
local check_enemy_movement       = function()end
local check_friend_movement      = function()end
local check_obstacle_movement    = function()end
local check_collectable_movement = function()end
local check_scenery_movement     = function()end
local check_chase_movement       = function()end


-- Creates a new level: loading in all the required zone an planet files
function level:new(cameraRef, gameMode, planetNumber, zoneNumber)
    local planet = "planet"..planetNumber
    local zone   = "zone"..zoneNumber

    -- Clear out the global package handler to force a reload of modules, Otherwise require wont reload them
    package.loaded["levels."..planet..".planet"] = nil
    package.loaded["levels."..planet.."."..zone] = nil

    -- load in level zone and planet data from files:
    self.planetDetails    = require("levels."..planet..".planet")
    self.data             = require("levels."..planet.."."..zone)

    -- create object collections:
    self.spines           = builder:newSpineCollection()
    self.movers           = builder:newMovementCollection()
    self.particles        = builder:newParticleEmitterCollection()
    self.players          = playerBuilder:newPlayerCollection(self.spines, self.movers, self.particles)
    self.ledges           = ledgeBuilder:newLedgeCollection(self.spines, self.movers, self.particles)
    self.obstacles        = obstacleBuilder:newObstacleCollection(self.spines, self.movers, self.particles)
    self.enemies          = enemyBuilder:newEnemyCollection(self.spines, self.movers, self.particles)
    self.friends          = friendBuilder:newFriendCollection(self.spines, self.movers, self.particles)
    self.collectables     = collectableBuilder:newCollectableCollection(self.spines, self.movers, self.particles)
    self.scenery          = sceneryBuilder:newSceneryCollection(self.spines, self.movers, self.particles)
    self.emitters         = sceneryBuilder:newEmitterCollection(self.movers)

    -- local aliases:
    self.camera           = cameraRef
    camera                = cameraRef
    spineCollection       = self.spines
    movingCollection      = self.movers
    particleCollection    = self.particles
    playerCollection      = self.players
    ledgeCollection       = self.ledges
    obstacleCollection    = self.obstacles
    enemyCollection       = self.enemies
    friendCollection      = self.friends
    collectableCollection = self.collectables
    sceneryCollection     = self.scenery
    emitterCollection     = self.emitters

    -- set level vars:
    self.ai               = self.data.ai   -- scene looks in this location
    self.planetNumber     = planetNumber
    self.zoneNumber       = zoneNumber
    self.bgrWidth         = 960
    self.floor            = {}
    self.startLedge       = {}
    self.finishLedge      = {}
    self.checkPoints      = {}
    self.scoreMarkers     = {}
    self.regenerate       = {}
    self.goMarker         = nil
    self.windDirection    = left
    self.windSpeed        = 1
    self.skyBlue          = 1
    self.skyChanging      = self.data.skyChanging
    self.startXPos        = 0
    self.endXPos          = 0
    self.rightBoundary    = 0

    -- Some sensible defaults for levels, to avoid repeating same old defaults:
    self.planetDetails:setDefaults(self.data)
    self.ledges:setShakeMovement(self.data.defaultLedgeShake)

    -- Init skyline
    if self.data.startAtNight then
        self.skyBlue = 0
        if self.data.turnDay then self.skyChanging = skyChangingDay end
    else
        self.skyBlue = 1
        if self.data.turnNight then self.skyChanging = skyChangingNight end
    end

    if gameMode == gameTypeRace or gameMode == gameTypeArcadeRacer then
        aiRace  = true
        self.ai = self.planetData.spaceRace.ai
    end
end



-- Called to assign the local event handlers to the levels
function level:createEventHandlers()
    check_spine_animation      = spineCollection.animateEach
    check_moving_objects       = movingCollection.moveEach
    check_moving_players       = playerCollection.checkMovement

    if state.data.gameSettings.backgrounds then
        check_background_movement = self.checkBackgroundMovement
    end
end


-- Makes local assignment to key level vars for faster access
function level:setLocalAssignments()
    levelStartX  = 0
    levelEndX    = 0
    skyChanging  = self.skyChanging
    lavaChase    = self.data.lavaChase
    warpChase    = self.data.warpChase

    ---------- SPECIAL FEATURE CONTROL ----------

    if lavaChase then
        self:createLavaChase(camera)
        check_chase_movement = self.checkLavaChase
    elseif warpChase then
        self:createWarpChase(camera)
        check_chase_movement = self.checkWarpChase
    end

    self:setSpecialLocalAssignments()
    self:setNavigationLocalAssignments(jumpObjectRoute)
end


-- Called to exit the level
function level:destroy()
    package.loaded["levels."..self.planetNumber.."."..self.zoneNumber] = nil

    self:clearBackgrounds(camera)
    ledgeCollection:destroy()
    obstacleCollection:destroy()
    enemyCollection:stopAnimations()
    enemyCollection:destroy()
    friendCollection:destroy()
    collectableCollection:destroy()
    sceneryCollection:destroy()
    emitterCollection:destroy()
    playerCollection:destroy()
    spineCollection:destroy()
    movingCollection:destroy()
    particleCollection:destroy()
    spineStore:destroy()

    self.planetDetails, self.data, self.players, self.ledges, self.obstacles, self.enemies, self.friends, self.collectables, self.scenery = nil,nil,nil,nil,nil,nil,nil,nil,nil
    self.ai, self.floor, self.startLedge, self.finishLedge, self.checkPoints, self.scoreMarkers, self.regenerate = nil,nil,nil,nil,nil,nil, nil

    spineCollection, movingCollection, particleCollection, jumpObjectRoute, mainPlayer, self.camera, camera = nil,nil,nil,nil,nil,nil,nil
    playerCollection, ledgeCollection, obstacleCollection, friendCollection, enemyCollection, collectableCollection, sceneryCollection, emitterCollection = nil,nil,nil,nil,nil,nil,nil,nil

    self:destroyNavigation()
    self:destroySpecial()
end


-- reset the level after the player dies
function level:reset(player)
    if state.data.gameSettings.backgrounds then
        self:clearBackgrounds(camera)
        self:createBackgrounds(camera)
    end

    ledgeCollection:reset(player, camera)
    obstacleCollection:reset(camera)
    enemyCollection:reset()
    friendCollection:reset()
end


-- reset the level after an AI dies
function level:resetForAi(player)
    ledgeCollection:reset(player, camera)
    obstacleCollection:reset(camera)
    enemyCollection:reset()
end


-- Creates all the level game elements, adding them to the physics engine, camera, etc
-- For infinite game modes - only creates the initial ledge and sets up the level
function level:createElements(levelElements)
    jumpObjectRoute  = {}

    local source     = levelElements or self.data.elements
    local jumpObject = self:createElementsFromData(source)

    self:createFloor()
    self:setLocalAssignments()
    self:assignTriggerLedges()
    self:createBackgrounds(camera)
    self:createEventHandlers()

    spineStore:load(spineCollection)

    return jumpObject
end


-- Used by infinite game modes to add new items into the level, from the jumpObject passed in (typically the last)
function level:appendElements(source, jumpObject)
    jumpObject = self:createElementsFromData(source, jumpObject)
    
    self:setNavigationLocalAssignments(jumpObjectRoute)

    return jumpObject
end


-- Create the level floor marker, which kills the player if they go below it
function level:createFloor()
    self.floor = display.newCircle(-50, self.data.floor, 25)
    self.floor.alpha = 1
    camera:add(self.floor, 3)
    levelFloor = self.floor
end


-- moves the level floor when required for infinite levels
function level:moveFloor(toy)
    if self.floor.y and self.floor.y < toy then
        self.floor.y = self.floor.y + toy
    end
end


-- Used for cutscenes to specify the level width
function level:createCustomWidth(startPos, endPos)
    self.startXPos = startPos
    self.endXPos   = endPos
    levelStartX    = startPos
    levelEndX      = endPos
end


-- Loops through the element data and creates all the level components
-- levelElements optional dynamic data loaded in, if not provided will load this data from the zone file
function level:createElementsFromData(source, jumpObject)
    local zoneState  = state:zoneState(self.zoneNumber, self.planetNumber)
    local gameType   = state.data.gameSelected

    for _,item in pairs(source) do
        -- items can be marked as only story mode, in which case they wont appear when re-used for other game modes
        if not item.storyModeOnly or gameType == gameTypeStory then
            local objectType = item.object
            local element    = nil

            if     objectType == "ledge"         then jumpObject = self:createLedge(item, jumpObject, zoneState)
            elseif objectType == "obstacle"      then jumpObject = self:createObstacle(item, jumpObject)
            elseif objectType == "enemy"         then element    = self:createEnemy(item, jumpObject)
            elseif objectType == "friend"        then element    = self:createFriend(item, jumpObject, zoneState)
            elseif objectType == "emitter"       then element    = self:createEmitter(item, jumpObject)
            elseif collectableObject[objectType] then element    = self:createCollectable(item, jumpObject)
            elseif sceneryObject[objectType]     then element    = self:createScenery(item, jumpObject) end
            
            if objectType == "ledge" or objectType == "obstacle" then
                local index = #jumpObjectRoute + 1
                jumpObject.zoneRouteIndex = index
                jumpObjectRoute[index]    = jumpObject
            end

            -- Bind non jumpObjects to a jumpObject here after they've been added to their master collections:
            if element and not item.inPhysics and (item.onLedge or item.regenerate) then
                jumpObject:bind(element)

                if item.y == nil then
                    if element.isScenery then
                        element.image.anchorY = 1
                        element:y(jumpObject:topEdge() + 3)
                    else
                        element:y(jumpObject:topEdge() - element.image.height/2)
                    end
                end

                if item.regenerate then
                    element.originalPos = { x=item.x or 0, y=item.y or 0 }
                end
            end
        end
    end
    return jumpObject
end


function level:createLedge(item, jumpObject, zoneState)
    -- Override to allow positioning from a jumpObject other than prev (for complex levels)
    if item.positionFromLedge then
        jumpObject = ledgeCollection:get(item.positionFromLedge)
    end

    -- set defaults to input item (done here as some defaults gained from level data):
    item.surface   = item.surface   or self.data.defaultLedgeSurface
    item.size      = item.size      or self.data.defaultLedgeSize
    item.theme     = item.theme     or self.data.defaultTheme
    item.points    = item.points    or self.data.defaultLedgePoints
    item.pointsPos = item.pointsPos or center

    local ledge = ledgeBuilder:newLedge(camera, item, jumpObject)
    ledgeCollection:add(ledge, zoneState)

    -- Note: if keylock added to ledge: keylock needs adding to the scenery collection:
    if ledge.keylock then
        sceneryCollection:add(ledge.keylock)
        ledge:bind(ledge.keylock)
    end

    if item.type == "start" then
        self.startLedge  = ledge
        self.startXPos   = ledge:x() - (ledge:width()/2)
        levelStartX      = self.startXPos

    elseif item.type == "finish" then
        self.finishLedge = ledge
        self.endXPos     = ledge:x()
        levelEndX        = self.endXPos
    end

    if state.infiniteRunner then
        self:modifyLevelBounds(ledge)
    end
    
    return ledge
end


function level:createObstacle(item, jumpObject)
    local obstacle = obstacleBuilder:newObstacle(camera, item, jumpObject)
    obstacleCollection:add(obstacle)
    hasObstacles = true
    
    return obstacle
end


function level:createEnemy(item, jumpObject)
    item.theme = item.theme or self.data.defaultTheme

    local x, y = 0, 0
    if jumpObject then x, y = jumpObject:pos() end

    local enemy = enemyBuilder:newEnemy(camera, item, x, y, jumpObject)

    if enemy then
        enemyCollection:add(enemy)
        hasEnemies = true
    end

    return enemy
end


function level:createFriend(item, jumpObject, zoneState)
    local x, y   = 0, 0
    if jumpObject then x, y = jumpObject:pos() end

    local friend = friendBuilder:newFriend(camera, item, x, y, jumpObject)

    if friend then
        friendCollection:add(friend, zoneState)
        hasFriends = true
    end
    
    return friend
end


function level:createCollectable(item, jumpObject)
    local collectable = nil
    local object = item.object
    local x, y   = jumpObject:pos()

    if     object == "rings"      then self:createRings(item, jumpObject)
    elseif object == "gear"       then collectable = collectableBuilder:newGear(       camera, item, x, y, jumpObject)
    elseif object == "negable"    then collectable = collectableBuilder:newNegable(    camera, item, x, y, jumpObject)
    elseif object == "key"        then collectable = collectableBuilder:newKey(        camera, item, x, y, jumpObject)
    elseif object == "timebonus"  then collectable = collectableBuilder:newTimeBonus(  camera, item, x, y, jumpObject)
    elseif object == "warpfield"  then collectable = collectableBuilder:newWarpField(  camera, item, x, y, jumpObject)
    elseif object == "randomizer" then collectable = collectableBuilder:newRandomizer( camera, item, x, y, jumpObject) end

    if collectable then
        collectableCollection:add(collectable)
    end
    return collectable
end


function level:createRings(item, jumpObject)
    -- Time Attack, Survival, Race - dont show rings
    if not challengeGameType[gameType] then
        local x, y  = jumpObject:pos()
        local rings = collectableBuilder:newRings(camera, item, x, y, jumpObject)
        local num   = #rings

        for i=1,num do
            local ring = rings[i]
            collectableCollection:add(ring)
        end
    end
end


function level:createScenery(item, jumpObject)
    item.theme = item.theme or self.data.defaultTheme

    if item.copy then
        local x, y      = jumpObject:pos()
        local sceneries = sceneryBuilder:newSceneryGroup(camera, item, x, y, jumpObject)
        local num       = #sceneries

        for i=1,num do
            local scenery = sceneries[i]
            sceneryCollection:add(scenery)

            -- Bind here as the main loop only does this for one item
            if scenery.onLedge then
                jumpObject:bind(scenery)
                if item.y == nil then
                    scenery.image.anchorY = 1
                    scenery:y(jumpObject:topEdge() + 3)
                end
            end
        end
        return nil
    else
        local x, y    = jumpObject:pos()
        local scenery = sceneryBuilder:newScenery(camera, item, x, y, jumpObject)
        sceneryCollection:add(scenery)
        return scenery
    end
end


function level:createEmitter(item, jumpObject)
    local x, y    = jumpObject:pos()
    local emitter = sceneryBuilder:newEmitter(camera, item, x, y, jumpObject)

    emitterCollection:add(emitter)
    hasEmitters = true
    return emitter
end


function level:createLiveBackground(item, jumpObject)
    item.theme = item.theme or self.data.defaultTheme

    local background = sceneryBuilder:newLiveBackground(camera, item)

    sceneryCollection:add(background)
    return background
end


function level:createPlayer(item)
    local player = nil

    if item.type == "main" then
        local ledgeId = self.data.startLedge or 1

        player = playerBuilder:newMainPlayer(camera, item, self:getLedge(ledgeId))
        mainPlayer = player

    elseif item.type == "ai" then
        local ledgeId = item.startLedge or 1
        hasAiPlayers  = true
        player = playerBuilder:newAiPlayer(camera, item, self:getLedge(ledgeId))
    end

    playerCollection:add(player)
    return player
end


-- assign ref to main player for other AI players and any UFOBosses
function level:assignMainPlayerRef()
    self.players:forEach(function(player) 
        if player.ai then
            player.mainPlayerRef = mainPlayer
        end
    end)

    self.friends:forEach(function(friend)
        if friend.isBossShip then
            friend.player = mainPlayer
        end
    end)
end


-- Used by cutscene to treat first player loaded as mainPlayer ref as there are only AIs
function level:defaultMainPlayer()
    mainPlayer = self.players.items[1]
end


-- Creates enough clouds to fill the whole level
--[[
function level:createInitialClouds(camera)
    self.windSpeed     = self.data.windSpeed or 1
    self.windDirection = self.data.windDirection or left

    windSpeed          = self.windSpeed
    windDirectionRight = self.windDirection == right

    local colourer = self.data.defaultCloudColor
    local x = levelEndX

    while x > levelStartX do
        self.scenery:createCloud(camera, x, levelStartX, levelEndX, windDirectionRight, windSpeed, colourer)
        x = x - (200 + (math_random(6)*100))  -- space between 300 and 800
    end
end
]]


-- Creates gear dynamically in-game
function level:generateRing(x, y, color)
    local ring  = collectableBuilder:newRing(camera, {type="ring", color=color}, x, y)
    ring.isTemp = true
    
    collectableCollection:add(ring)
    return ring
end


-- Creates gear dynamically in-game
function level:generateGear(x, y, name)
    local gear  = collectableBuilder:newGear(camera, {x=0, y=0, type=name}, x, y)
    gear.isTemp = true

    collectableCollection:add(gear)
    return gear
end


-- Creates a negable dynamically in-game
function level:generateNegable(x, y, name)
    local negable  = collectableBuilder:newNegable(camera, {x=0, y=0, type=name}, x, y)
    negable.isTemp = true

    collectableCollection:add(negable)
    return negable
end


-- Creates a fuzzy dynamically in-game
function level:generateFuzzy(x, y, color)
    local fuzzy  = friendBuilder:newFuzzy(camera, {x=0, y=0, type="fuzzy", color=color}, x, y)
    fuzzy.isTemp = true

    friendCollection:add(fuzzy)
    return fuzzy
end


-- Creates keycard dynamically in-game
function level:generateKey(x, y, color)
    local key = collectableBuilder:newKey(camera, {x=0, y=0, color=color, onLedge=true}, x, y)
    collectableCollection:add(key)
    return key
end


function level:generateScenery(x, y, type, jumpObject)
    local scenery = sceneryBuilder(camera, {object="scenery", type=type, theme=self.data.defaultTheme}, x, y, jumpObject)
    sceneryCollection:add(scenery)
    return scenery
end


function level:modifyLevelBounds(ledge)
    if ledge:leftEdge() < levelStartX then
        self.startXPos = ledge:leftEdge() - ledge:width()
        levelStartX    = self.startXPos
    end

    if ledge:rightEdge() > levelEndX then
        self.endXPos = ledge:rightEdge() + ledge:width()
        levelEndX    = self.endXPos
    end

    camera:increaseRightBoundary(ledge:rightEdge() + 1000)
    camera:increaseTopBoundary(ledge:topEdge()     - 1000)

    if state.data.gameSelected == gameTypeClimbChase then
        camera:increaseLeftBoundary(ledge:leftEdge() - 1000)
    else
        camera:increaseBottomBoundary(ledge:bottomEdge() + 1000)
        level:moveFloor(ledge:bottomEdge())
    end
end


-- Once the ledges have been created, loop back though them and where some reference other ledges, make assignments
----
function level:assignTriggerLedges()
    local allLedges = ledgeCollection.items
    local num       = #allLedges

    for i=1,num do
        local ledge = allLedges[i]

        if ledge.triggerLedgeIds then
            local ids = ledge.triggerLedgeIds
            ledge.triggerLedges = {}

            for _,id in pairs(ids) do
                ledge.triggerLedges[#ledge.triggerLedges+1] = self:getLedge(id)
            end
        end

        if ledge.triggerObstacleIds then
            local ids = ledge.triggerObstacleIds
            ledge.triggerObstacles = {}

            for _,id in pairs(ids) do
                ledge.triggerObstacles[#ledge.triggerObstacles+1] = self:getObstacle(id)
            end
        end
    end
end


-- scales all items in the level
----
function level:scaleAll()
    levelFloor.x = 100 --levelFloor.x * camera.scalePosition
    levelFloor.y = levelFloor.y * camera.scalePosition

    ledgeCollection:scale(camera)
    obstacleCollection:scale(camera)
    playerCollection:scale(camera)
    enemyCollection:scale(camera)
    friendCollection:scale(camera)
    sceneryCollection:scale(camera)
    collectableCollection:scale(camera)
    emitterCollection:scale(camera)
    particles:scale(camera)

    if lavaChase then
        self:scaleLavaChase(camera.scalePosition)
    elseif warpChase then
        self:scaleWarpChase(camera.scalePosition)
    end
end


function level:removeBodyAll(scale)
    ledgeCollection:removeBodyAll(scale)
end


-- Destroys all game elements marked for a stage, so infinite levels dont keep increasing in memory
----
function level:destroyStageElements(stage)
    ledgeCollection:destroyStage(stage)
    obstacleCollection:destroyStage(stage)
    enemyCollection:destroyStage(stage)
    friendCollection:destroyStage(stage)
    collectableCollection:destroyStage(stage)
    sceneryCollection:destroyStage(stage)
    emitterCollection:destroyStage(stage)
end


-- Pauses all element timers
function level:pauseElements()
    ledgeCollection:pauseTimers()
    obstacleCollection:pauseTimers()
    enemyCollection:pauseTimers()
    friendCollection:pauseTimers()
    collectableCollection:pauseTimers()
    sceneryCollection:pauseTimers()
    emitterCollection:pauseTimers()
end


-- Pauses all element timers
function level:resumeElements()
    ledgeCollection:resumeTimers()
    obstacleCollection:resumeTimers()
    enemyCollection:resumeTimers()
    friendCollection:resumeTimers()
    collectableCollection:resumeTimers()
    sceneryCollection:resumeTimers()
    emitterCollection:resumeTimers()
end


-- Called each game loop to update any animated and moving items
----
function level.updateFrame(event)
    globalFPS = globalFPS + 1

    -- Compute time in seconds since last frame.
    local currentTime = event.time / 1000
    local delta       = currentTime - lastTime
    lastTime          = currentTime

    check_background_movement(delta)
    check_spine_animation(spineCollection, delta, true)
    check_moving_objects(movingCollection, delta, camera)
    check_moving_players(playerCollection, delta)

    -- AI race:
    if aiRace then
        level.players:checkOffScreenIndicator(camera)
    end
    
    -- Special level events
    if lavaChase or warpChase then
        check_chase_movement(level, delta, mainPlayer)
    end
end


-- A special version of updateFrame, which is used when player activates a freeze time collectable
-- Only the player moves, but everything animates
----
function level.updateTimeFrozenFrame(event)
    globalFPS = globalFPS + 1

    -- Compute time in seconds since last frame.
    local currentTime = event.time / 1000
    local delta       = currentTime - lastTime
    lastTime          = currentTime

    check_background_movement(delta)
    check_spine_animation(spineCollection, delta, true)
    check_moving_players(playerCollection, delta)
end


-- Called on a controlled game loop to check if any in-level entities need to change their behaviour
----
function level:updateBehaviours()
    local floorY = levelFloor.y

    playerCollection:checkBehaviours(camera, floorY)
    particleCollection:checkEach()

    if hasAiPlayers then
        playerCollection:checkAIBehaviour(level)
    end

    if hasEnemies then
        enemyCollection:checkBehaviours(mainPlayer, playerCollection, floorY)
    end

    if hasFriends then
        friendCollection:checkBehaviourChange()
    end

    if hasEmitters then
        emitterCollection:checkEmittedOutOfPlay(camera)
    end

    if skyChanging then
        level:checkDaytimeChanging()
    end

    -- Might as well be done here, as it's the only non-level thing needing updating
    soundEngine:updateSounds()
end


-- Load functions to generate specific objects from another file (too large otherwise)
specialLoader:load(level)
navigationLoader:load(level)


return level