local composer           = require("composer")
local sharedScene        = require("scenes.shared")
local cameraLoader       = require("core.camera")
local anim               = require("core.animations")
local soundEngine        = require("core.sound-engine")
local builder            = require("level-objects.builders.builder")
local obstacleBuilder    = require("level-objects.builders.obstacle-builder")
local enemyBuilder       = require("level-objects.builders.enemy-builder")
local friendBuilder      = require("level-objects.builders.friend-builder")
local collectableBuilder = require("level-objects.builders.collectable-builder")
local sceneryBuilder     = require("level-objects.builders.scenery-builder")
local spineStore         = require("level-objects.collections.spine-store")

-- Locals for performance
local scene              = composer.newScene()
local camera             = nil
local spineCollection    = nil
local movingCollection   = nil
local friendCollection   = nil
local enemyCollection    = nil
local obstacleCollection = nil
local sceneryCollection  = nil
local lastTime           = 0

-- Aliases:
local play      = globalSoundPlayer
local new_image = newImage


-- Things that need to happen as fast as possible (every frame e.g 60 loops per second)
local function sceneEnterFrameEvent(event)
    globalFPS = globalFPS + 1
    
    -- Compute time in seconds since last frame.
    local currentTime = event.time / (1000 / 60)
    local delta       = currentTime - lastTime
    lastTime          = currentTime
    
    spineCollection:animateEach(event, false, delta)
    movingCollection:moveEach(delta, camera)
end


-- Treat phone back button same as back game button
local function sceneKeyEvent(event)
    if event.keyName == "back" and event.phase == "up" then
        scene:exitToPlanetSelect()
        return true
    end
end


local function moveBackground(event)
    if event.phase == "began" then
        scene.startX = scene.moveable.x
    elseif event.phase == "moved" and event.xStart and scene.startX then
        local x = (event.x - event.xStart) + scene.startX

        if x < 0 and x > -3750 then
            scene.moveable.x = x
        end
    end
end


-- Called when the scene's view does not exist:
function scene:create(event)
    globalIgnorePhysicsEngine  = true

    -- assign shared functions
    sharedScene:loadFruityMachine(self)

    movingCollection      = builder:newMovementCollection()
    spineCollection       = builder:newSpineCollection()
    particleCollection    = builder:newParticleEmitterCollection()
    friendCollection      = friendBuilder:newFriendCollection(spineCollection, movingCollection, particleCollection)
    enemyCollection       = enemyBuilder:newEnemyCollection(spineCollection, movingCollection, particleCollection)
    obstacleCollection    = obstacleBuilder:newObstacleCollection(spineCollection, movingCollection, particleCollection)
    sceneryCollection     = sceneryBuilder:newSceneryCollection(spineCollection, movingCollection, particleCollection)
    collectableCollection = collectableBuilder:newCollectableCollection(spineCollection, movingCollection, particleCollection)

    spineStore:load(spineCollection)
    
    self:createSceneMoveableContent(event)
end


-- Called immediately after scene has moved onscreen:
function scene:show(event)
    if event.phase == "did" then
        self:init()

        -- we dont play element sounds on zone select as its not distance managed and they are well annoying
        soundEngine:disable()
        self:startMusic()
        
        setMovementStyleSpeeds()

        Runtime:addEventListener("enterFrame", sceneEnterFrameEvent)
        Runtime:addEventListener("key", sceneKeyEvent)
    end
end


function scene:init()
    logAnalyticsStart()
    state:newScene("select-zone")
    clearSceneTransition()

    self:displayHud()
end


function scene:startMusic()
    if state.data.gameSettings.music then
        local self = scene
        self.musicChannel = audio.findFreeChannel()
        audio.setVolume(0.5, {channel=self.musicChannel})
        audio.setMaxVolume(0.5, {channel=self.musicChannel})
        play(sounds.tuneZoneSelect, {channel=self.musicChannel, fadein=11000, loops=-1})
    end
end


function scene:createSceneMoveableContent(event)
    camera = cameraLoader.createView()
    -- Create global and cleanup after this scene
    cameraHolder = { camera = camera }
    
    local group    = self.view
    local moveable = display.newGroup()
    local front    = display.newGroup()
    local planet   = "planet"..state.data.planetSelected

    self.moveable = moveable
    self.front    = front
    group:insert(moveable)
    moveable:insert(front)

    local bgr = display.newImageRect(moveable, "levels/"..planet.."/images/zone-select.png", system.ResourceDirectory, 4900, backgroundHeight)
    bgr:addEventListener("touch", moveBackground)
    bgr:addEventListener("tap", scene.closePopup)
    bgr.x, bgr.y = 2350, centerY

    -- Clear out the global package handler to force a reload of modules, Otherwise require wont reload them
    package.loaded["levels."..planet..".planet"] = nil
    self.planetData = require("levels."..planet..".planet")

    self.player = self:createCharacter({model=state.data.playerModel, x=130, y=305, size=0.17}, moveable)
    self:createZones(moveable)

    self.player.image:toFront()
    self.front:toFront()

    self:createAnimatedItems(camera, moveable)

    local overlay = display.newImageRect(moveable, "levels/"..planet.."/images/zone-select-overlay.png", system.ResourceDirectory, 4800, backgroundHeight)
    overlay.x, overlay.y = 2400, centerY-10

    local  px = state.data.zoneSelected or 1
    if     px < 5 then  -- dont move along
    elseif px < 9 then  scene.moveable.x = -750
    elseif px < 14 then scene.moveable.x = -1500
    elseif px < 18 then scene.moveable.x = -2200
    elseif px < 22 then scene.moveable.x = -2900
    elseif px < 26 then scene.moveable.x = -3600
    end

    moveable:insert(camera)
end


function scene:createAnimatedItems(camera, moveable)
    local x, y = 0, 0

    for number=1, #self.planetData.animated do
        local item = self.planetData.animated[number]

        if item.object == "player" then
            if item.rescue and state:characterUnlocked(item.model) then
                -- dont show rescued character
            else
                self:createCharacter(item, moveable)
            end

        elseif item.object == "obstacle" then
            local obstacle = obstacleBuilder:newObstacle(camera, item)
            obstacleCollection:add(obstacle)

        elseif item.object == "enemy" then
            local enemy = enemyBuilder:newEnemy(camera, item, x, y)
            enemyCollection:add(enemy)

        elseif item.object == "friend" then
            local friend = friendBuilder:newFriend(camera, item, x, y)
            friendCollection:add(friend)

        elseif sceneryObject[item.object] then
            local scenery = sceneryBuilder:newScenery(camera, item, x, y)
            sceneryCollection:add(scenery)

        elseif item.object == "static" then
            local object = new_image(item.type, item.x, item.y, item.size)
            camera:add(object, 3)
            moveable:insert(object)

        elseif item.object == "warpfield"  then 
            local collectable = collectableBuilder:newWarpField(camera, item, x, y)
            collectableCollection:add(collectable)
        end
    end
end


function scene:createCharacter(item, moveable)
    local ai = spineStore:showCharacter(item)
    moveable:insert(ai.image)
        
    if item.direction == left then
        ai.skeleton.flipX = true
    end

    if state.data.planetSelected == 2 then
        ai.skeleton:setAttachment("Head - Gear Skin", "Head - Gear Skin")
    end

    if item.loop then
        ai:loop(item.animation)
    end

    return ai
end


function scene:createZones(moveable)
    self.zones = {
        stars  = display.newGroup(),
        awards = display.newGroup()
    }
    self.zones.stars.alpha  = 0
    self.zones.awards.alpha = 0

    local planet   = state.data.planetSelected
    local nextZone = nil

    for number=1, #self.planetData.zones do
        local zone = {
            id       = number,
            data     = self.planetData.zones[number],
            state    = state:zoneState(number),
            unlocked = state:zoneUnlocked(planet, number),
        }

        local tabType = "todo"
        local x, y    = zone.data.x, zone.data.y

        if zone.state.completed then tabType = "completed" end

        zone.image = new_image(moveable, "select-zone/zone-"..self:zoneColor(zone), x+45, y-10)

        -- only show tab to select zone if unlocked (playable) or secret
        if zone.unlocked or zone.data.secret then
            zone.tab        = new_image(moveable, "select-zone/tab-"..tabType, x+55, y-100)
            zone.textNumber = newText(moveable, zone.id, x+45, y-150, 0.5, "white", "CENTER")

            zone.tab.zone   = zone
            zone.tab.tap    = scene.selectZone
            zone.tab:addEventListener("tap", zone.tab)

            zone.image.zone = zone
            zone.image.tap  = scene.selectZone
            zone.image:addEventListener("tap", zone.image)

            if zone.data.secret and not zone.unlocked then
                new_image(moveable, "locking/lock", x+40, y-100, 0.6, 0.9)
            end

            if zone.state.completed then
                self:createZoneRanking(self.zones.stars, zone.data, zone.state.ranking, zone.data)
            end
        end

        if number == state.data.zoneSelected then
            self.player.image.x = zone.image.x - 5
            self.player.image.y = zone.image.y - 10
        end

        if nextZone == nil and not zone.state.completed and zone.unlocked then
            self:animateNextZone(moveable, zone.tab, zone.textNumber)
            nextZone = number
        end

        self.zones[#self.zones+1] = zone
    end

    moveable:insert(self.zones.stars)
    moveable:insert(self.zones.awards)
    self:showZoneResults()
end


-- draw star ranking for zone icon
function scene:createZoneRanking(group, data, ranking)
    for i=1, ranking do
        local x, y = data.x+45, data.y-123

        if     i == 1 then x, y = x-21, y
        elseif i == 2 then x, y = x,    y
        elseif i == 3 then x, y = x+20, y
        elseif i == 4 then x, y = x-10, y+19
        elseif i == 5 then x, y = x+10, y+19 end

        new_image(group, "hud/star-ranking", x, y, 0.2)
    end
end


-- determines which group to show: zone star rankings or zone awards
function scene:showZoneResults()
    if state.data.zoneHudAwards then
        self.zones.awards.alpha = 1
        self.zones.stars.alpha  = 0
    else
        self.zones.awards.alpha = 0
        self.zones.stars.alpha  = 1
    end
end


function scene:toggleZoneResults()
    if state.data.zoneHudAwards then
        state.data.zoneHudAwards = false
    else
        state.data.zoneHudAwards = true
    end

    scene:showZoneResults()
    return true
end


function scene:zoneColor(zone)
    if zone.state.completed then
        return "completed"
    elseif state:zoneUnlocked(state.data.planetSelected, zone.id) then
        if zone.data.special then return "todo-special"
        else return "playable" end
    else
        if zone.data.special then return "todo-special"
        else return "todo" end
    end
end


function scene:displayHud()
    local data = planetData[state.data.planetSelected]

    self.borderGroup = display.newGroup()

    newMenuHud(self.borderGroup, spineStore, scene.exitToShop, scene.exitToPlayerStore)
    newMenuHudIcons(self.borderGroup, scene.exitToInAppStore, scene.exitToPlanetProgress, scene.exitToFruityMachine)

    newImage(self.borderGroup, "select-game/banner-planet"..state.data.planetSelected, 310, 597)
    newText(self.borderGroup, data.name, centerX, 600, 0.8, data.color, "CENTER")
    newButton(self.view, 55, 50, "back", scene.exitToPlanetSelect)
end


-- Creates popup display for zone details when player selects a zone
function scene:selectZone(event)
    local icon = self
    local self = scene
    local zone = event.target.zone

    -- Dont allow viewing zone details unless it's playable
    if not state:zoneUnlocked(state.data.planetSelected, zone.id) then
        if zone.data.secret then
            local planet = state.data.planetSelected
            newLockedPopup(self.view, planet, "zones", planetData[planet].name.."|secret zones")
        end
        return
    end

    self:closePopup()

    self.zoneId     = zone.id
    self.popupGroup = display.newGroup()

    play(sounds.zonePopup)
    self:createZonePopup(zone)

    local seq = anim:oustSeq("zonePopup", self.popupGroup)
    seq:tran({time=500, alpha=1, playSound=sounds.selection})
    seq:start()
    return true
end


function scene:createZonePopup(zone)
    local group     = self.popupGroup
    local planet    = state.data.planetSelected
    local completed = zone.state.completed
    local zoneData  = require("levels.planet"..planet..".zone"..zone.id)
    local bgrName   = "todo"
    local zoneColor = "red"

    if completed then
        bgrName   = "completed"
        zoneColor = "green"
    end

    local bgr          = new_image(group, "select-zone/info-"..bgrName, centerX, 215)
    local labelPlay    = newText(group, "zone "..zone.id, centerX, 55,  0.6, "white",   "CENTER")
    local labelName    = newText(group, zoneData.name,    centerX, 100, 0.7, zoneColor, "CENTER")
    local labelAwards  = newText(group, "awards",         190,     240, 0.6, "white",   "CENTER")
    local labelFuzzies = newText(group, "fuzzies",        420,     240, 0.6, "white",   "CENTER")
    local labelHint    = newText(group, "hint",           590,     240, 0.6, "white",   "CENTER")
    local btnPlay      = newButton(group, 775, 320, "next", scene.playZone)

    if completed then
        if zone.state.plays > 1 then
            newText(group, "retries: "..(zone.state.plays-1), 775, 250, 0.5, "purple")
        end
        self:createZoneCompletedInfo(zone, zoneData)
    else
        for i=1, self:getNumberFuzzies(zoneData) do
            new_image(group, "select-zone/fuzzy-shadow", 390+((i-1)*50), 310)
        end
    end

    self:createZoneHint(zone.id)

    group.alpha = 0
    self.view:insert(group)
    self.borderGroup:toFront()

    bgr:addEventListener("tap",   function() return true end)
    bgr:addEventListener("touch", function() return true end)

    package.loaded["levels.planet"..planet..".zone"..zone.id] = nil
end


function scene:getNumberFuzzies(zoneData)
    local fuzzies = 0
    for _,object in pairs(zoneData.elements) do
        if object.object == "friend" and object.type == "fuzzy" then
            fuzzies = fuzzies + 1
        end
    end
    return fuzzies
end


function scene:createZoneCompletedInfo(zone, zoneData)
    local group = self.popupGroup

    for i=1, zone.state.ranking do
        new_image(group, "hud/star-ranking", 301+((i-1)*80), 165, 0.7)
    end

    if zone.state.awards then
        local numAwards = zone.state.numberAwards
        local i = 1

        for key,award in pairs(zone.state.awards) do
            local x, y = 90+(i*50), 285

            if i > 3 then x, y = x - 50*3, 330 end

            new_image(group, "hud/award-"..award.icon, x, y, 0.5)
            i=i+1
        end
    end

    if zone.state.fuzzies then
        self.popupSpineObjects = {}
        local i = 1

        for key,data in pairs(zone.state.fuzzies) do
            local item  = {object="friend", type="fuzzy", x=0, y=0, size=0.45, color=data.color, kinetic=data.kinetic, direction=data.direction}
            local fuzzy = friendBuilder:newFriend(camera, item, 370+((i-1)*50), 310)
            fuzzy.key   = key.."_collected"   -- needs to differ from keys in zone-select background sene

            group:insert(fuzzy.image)
            spineCollection:add(fuzzy)
            self.popupSpineObjects[i] = fuzzy
            i = i + 1
        end

        for i=i, self:getNumberFuzzies(zoneData) do
            new_image(group, "select-zone/fuzzy-shadow", 370+((i-1)*50), 300)
        end
    end
end


function scene:createZoneHint(zoneNumber)
    local group = self.popupGroup
    local hints = self.planetData.zones[zoneNumber].hint

    if hints and #hints == 1 then
        local hint     = hints[1]
        local category = gearNames[gearSlots[hint]]
        new_image(group, "collectables/gear-"..category.."-"..hint, 590, 320, 0.3)

    elseif hints and #hints > 0 then
        for i=1,#hints do
            local hint     = hints[i]
            local category = gearNames[gearSlots[hint]]
            local icon     = new_image(group, "collectables/gear-"..category.."-"..hint, 595, 280, 0.3)

            if     i == 1 then icon.x, icon.y = 565, 320
            elseif i == 2 then icon.x, icon.y = 620, 320 end
        end
    end
end


function scene:playZone()
    play(sounds.gameStart)
    state.data.zoneSelected  = scene.zoneId
    loadSceneTransition()
    after(1000, function() composer.gotoScene("scenes.play-zone", {effect="fade", time=750}) end)
end


function scene:fadeoutPopup()
    scene.scoreToggle:setText("view planet summary")

    local seq = anim:oustSeq("zonePopup", scene.popupGroup)
    seq:tran({time=150, alpha=0, playSound=sounds.selection})
    seq.onComplete = function() scene:closePopup() end
    seq:start()
end


function scene:closePopup()
    local self = scene
    if self.popupGroup then
        self.popupGroup:removeSelf()
        self.popupGroup = nil
    end

    if self.popupSpineObjects then
        for _,item in pairs(self.popupSpineObjects) do
            item:destroy()
            item = nil
        end
        self.popupSpineObjects = nil
    end
    return true
end


function scene:animatePlayerProgression()
    local seq = anim:chainSeq("levelProgression", self.player.image)
    local nextZone = state:numberZonesPlayable()

    if state.data.zoneSelected < #self.zones then
        local i     = state.data.zoneSelected+1
        local next  = self.zones[i]
        local sound = soundEngine:getRandomPlayerCelebrate(state.data.playerModel)
        
        seq:callback(function()
            if next.image.x < scene.player.image.x then
                scene.player:loop("Walk BACKWARD")
            else
                scene.player:loop("Walk")
            end
        end)

        seq:tran({time=2000, x=next.image.x-5, y=next.image.y-15, playSound=sound})
        seq:callback(function() scene.player:loop("Stationary") end)
        seq:wait(500)

        if i == nextZone then
            self:animateNextZone(next.image)
        end
    end

    seq:start()
end


function scene:animateNextZone(moveable, zoneImage, zoneNumber)
    local group = display.newGroup()

    group.x      = zoneImage.x
    group.y      = zoneImage.y
    zoneNumber.x = zoneNumber.x - zoneImage.x
    zoneNumber.y = zoneNumber.y - zoneImage.y
    zoneImage.x  = 0
    zoneImage.y  = 0

    group:insert(zoneImage)
    group:insert(zoneNumber)
    moveable:insert(group)

    local seq   = anim:oustSeq("selectedZone", group)
    seq:add("pulse", {time=1500, scale=0.05})
    seq:start()
end


function scene:exitToPlanetSelect()
    loadSceneTransition()
    after(1000, function() composer.gotoScene(state:backScene(), {effect="fade", time=750}) end)
    return true
end


function scene:exitToShop()
    play(sounds.sceneEnter)
    composer.gotoScene("scenes.shop")
    return true
end


function scene:exitToPlayerStore()
    play(sounds.sceneEnter)
    composer.gotoScene("scenes.select-player")
    return true
end


function scene:exitToPlanetProgress()
    play(sounds.sceneEnter)
    composer.gotoScene("scenes.progress")
    return true
end


function scene:exitToInAppStore()
    play(sounds.sceneEnter)
    composer.gotoScene("scenes.inapp-purchases")
    return true
end


-- Called when scene is about to move offscreen:
function scene:hide(event)
    if event.phase == "will" then
        audio.fadeOut({channel=self.musicChannel, time=1000})

        Runtime:removeEventListener("enterFrame", sceneEnterFrameEvent)
        Runtime:removeEventListener("key", sceneKeyEvent)
        track:cancelEventHandles()

        anim:destroy()
        friendCollection:destroy()
        enemyCollection:destroy()
        obstacleCollection:destroy()
        sceneryCollection:destroy()
        collectableCollection:destroy()
        spineCollection:destroy()
        particleCollection:destroy()
        movingCollection:destroy()
        spineStore:destroy()
        camera.destroy()
        soundEngine:destroy()

        self:closePopup()
        self.player:destroy()
        self.zones.stars:removeSelf()
        self.zones.awards:removeSelf()
        self.borderGroup:removeSelf()
        self.moveable:removeSelf()
        self.front:removeSelf()

        cameraHolder      = nil
        globalIgnorePhysicsEngine = false
        self.player       = nil
        self.borderGroup  = nil
        self.moveable     = nil
        self.front        = nil
        self.zones        = nil
        camera            = nil
        friendCollection  = nil
        enemyCollection   = nil
        obstacleCollection= nil
        sceneryCollection = nil
        collectableCollection = nil
        movingCollection  = nil
        spineCollection   = nil

        logAnalyticsEnd()

    elseif event.phase == "did" then
        composer.removeScene("scenes.select-zone")
    end
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroy(event)
end


---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

scene:addEventListener("create",  scene)
scene:addEventListener("show",    scene)
scene:addEventListener("hide",    scene)
scene:addEventListener("destroy", scene)

return scene