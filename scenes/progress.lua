local composer = require("composer")
local anim       = require("core.animations")
local builder    = require("level-objects.builders.builder")
local spineStore = require("level-objects.collections.spine-store")

-- Local vars:
local scene           = composer.newScene()
local spineCollection = nil
local lastTime        = 0

-- Aliases:
local play = globalSoundPlayer


-- Things that need to happen as fast as possible (every frame e.g 60 loops per second)
local function sceneEnterFrameEvent(event)
    globalFPS = globalFPS + 1
    spineCollection:animateEach(event)
end


-- Treat phone back button same as back game button
local function sceneKeyEvent(event)
    if event.keyName == "back" and event.phase == "up" then
        scene:exitProgress()
        return true
    end
end


-- Called when the scene's view does not exist:
function scene:create(event)
    self.planet  = state.data.planetSelected
    self.data    = planetData[self.planet]
    self.locks   = {}
    self.animate = 0

    package.loaded["levels.planet"..self.planet..".planet"] = nil
    self.planetSpec = require("levels.planet"..self.planet..".planet")

    spineCollection = builder:newSpineCollection()
    spineStore:load(spineCollection)

    newBackground(self.view, "select-zone/progress-bgr")
    self:summary()
end


-- Called immediately after scene has moved onscreen:
function scene:show(event)
    if event.phase == "did" then
        self:init()

        play(sounds.zoneSummary)
        Runtime:addEventListener("enterFrame", sceneEnterFrameEvent)
        Runtime:addEventListener("key", sceneKeyEvent)
    end
end


function scene:init()
    logAnalyticsStart()
    clearSceneTransition()
    state:newScene("progress")

    self:displayHud()
end


function scene:displayHud()
    local data = planetData[state.data.planetSelected]

    self.labelCubes, self.labelScore, self.playerIcon = newMenuHud(self.view, spineStore, scene.exitToShop, scene.exitToPlayerStore)

    newText(self.view, data.name.." - progress", centerX, 590, 0.8, data.color, "CENTER")
    newButton(self.view, 55, 50, "back", scene.exitProgress)
end


function scene:summary()
    self:summaryProgress()
    self:summaryGameModes()
    self:summarySpecialItems()
    self:runAnimations()
end


function scene:summaryProgress()
    local zonesDone   = state:numberZonesCompleted(self.planet, gameTypeStory)
    local zonesTotal  = self.data.normalZones + self.data.secretZones
    local starsDone   = state:planetStarRanking(self.planet, gameTypeStory)
    local starsTotal  = zonesTotal * 5
    local fuzzyDone   = state:numberFuzziesCollected(self.planet)
    local fuzzyTotal  = self.data.fuzzies
    local awardsDone  = state:numberAwardsCollected(self.planet, gameTypeStory)
    local awardsTotal = zonesTotal * 6
    
    self:createStatStatus(120, 435, "zones",   zonesDone,  zonesTotal)
    self:createStatStatus(360, 435, "stars",   starsDone,  starsTotal)
    self:createStatStatus(585, 435, "fuzzies", fuzzyDone,  fuzzyTotal)
    self:createStatStatus(815, 435, "awards",  awardsDone, awardsTotal)
end


function scene:createStatStatus(xpos, ypos, title, collected, total)
    local label = newText(self.view, 0,     xpos+35, ypos,   0.7, "green", "RIGHT")
                  newText(self.view, "/",   xpos+40, ypos+3, 0.5, "white", "LEFT")
                  newText(self.view, total, xpos+55, ypos+3, 0.5, "white", "LEFT")

    self.animate = self.animate + 1

    if collected > 0 then
        local delay = 10
        if self.animate == 1 or self.animate == 3 then delay = 100 end

        local seq1 = anim:chainSeq("progress-"..self.animate, label)
        seq1:add("countnum", {
            countFrom  = 0, 
            countTo    = collected, 
            countStep  = 1, 
            countDelay = delay,
            align      = "RIGHT",
            xpos       = xpos+35,
        })
    end
end


function scene:summaryGameModes()
    local unlock = self.planetSpec.gameUnlocks
    local ypos   = 120

    for _,game in pairs({gameTypeTimeRunner, gameTypeClimbChase, gameTypeArcadeRacer}) do
        self:createGameModeStatus(370, ypos, game, unlock[game].stars.."*")
        ypos = ypos + 100
    end

    ypos = 120

    for _,game in pairs({gameTypeSurvival, gameTypeTimeAttack, gameTypeRace}) do
        self:createGameModeStatus(600, ypos, game, unlock[game].fuzzies.."*")
        ypos = ypos + 100
    end
end


function scene:createGameModeStatus(xpos, ypos, game, unlockText)
    local group  = display.newGroup()
    local data   = gameTypeData[game]
    local player = state.data.playerModel
    local icon   = newImage(group, "select-game/tab-"..data.icon, xpos, ypos, 0.5, 0.6)
    
    if state:gameUnlocked(self.planet, game) then
        icon.alpha = 1
        local text = ""

        if infiniteGameType[game] then
            local zone = state:zoneState(1, self.planet, game)
            text = "stage:"..(zone.topStage or 0).." ledge:"..(zone.topLedge or 0)
                    
        elseif challengeGameType[game] then
            local zones = state:numberZones(self.planet, game)
            local character, completed = state:highestZonesCompleted(self.planet, game)

            if character then
                text = characterData[character].name..": "..completed.."/"..zones
            end
        end

        newText(group, text, xpos-40, ypos+10, 0.3, "white", "LEFT")
    else
        newImage(group, "locking/lock", xpos-65, ypos,    0.6, 0.9)
        newText(group,  unlockText,     xpos-45, ypos+15, 0.7, "white", "LEFT")

        self.locks[#self.locks+1] = group
    end

    self.view:insert(group)
end


function scene:summarySpecialItems()
    self:summaryCharacter(75,  350, self.planetSpec.unlockFriend, "complete "..planetData[self.planet].normalZones.." zones")
    self:summaryCharacter(760, 340, self.planetSpec.unlockEnemy,  "buy planet pack")
    self:summaryNextPlanet(135,  235)
    self:summarySecretZones(820, 200)
end


function scene:summaryCharacter(xpos, ypos, character, unlockText)
    local group = display.newGroup()
    local data  = characterData[character]

    newImage(group, "hud/player-indicator-"..data.name, xpos, ypos)
    newText(group,  data.name, xpos+30, ypos, 0.5, data.color, "LEFT")

    if not state:characterUnlocked(character) then
        newImage(group, "locking/lock", xpos,    ypos,    0.6, 0.9)
        newText(group,  unlockText,     xpos-35, ypos+30, 0.4, "white", "LEFT")

        self.locks[#self.locks+1] = group
    end

    self.view:insert(group)
end


function scene:summaryNextPlanet(xpos, ypos)
    local group      = display.newGroup()
    local pid        = self.planet+1
    local nextPlanet = planetData[pid]

    newImage(group, "select-game/tab-planet"..pid, xpos-40, ypos, 0.35)

    if not state:planetUnlocked(self.planet+1) then
        newImage(group, "locking/lock",    xpos-50, ypos-15, 0.6,  0.9)
        newText(group, "complete 5 zones", xpos,    ypos+40, 0.4, "white", "CENTER")

        self.locks[#self.locks+1] = group
    end

    newText(group, nextPlanet.name, xpos, ypos-30, 0.5, nextPlanet.color, "CENTER")

    self.view:insert(group)
end


function scene:summarySecretZones(xpos, ypos)
    local group = display.newGroup()

    newImage(group, "select-game/race-zone-red", xpos-50, ypos+5,  0.8)
    newText(group,  "?",                         xpos-65, ypos-10, 0.7, "red", "LEFT")
    newText(group,  "secret zones!",             xpos,    ypos-55, 0.5, "red", "CENTER")

    -- just assume that if first two zones after 21 are unlocked, then secrets are unlocked
    if not state:zoneUnlocked(self.planet, 22) or not state:zoneUnlocked(self.planet, 23) then
        newImage(group, "locking/lock",   xpos-55, ypos-10, 0.6, 0.9)
        newText(group, "buy planet pack", xpos,    ypos+50, 0.4, "white", "CENTER")

        self.locks[#self.locks+1] = group
    end

    self.view:insert(group)
end


function scene:runAnimations()
    -- Count up items collected so far
    anim:startQueue("progress-1")
    anim:startQueue("progress-2")
    anim:startQueue("progress-3")
    anim:startQueue("progress-4")

    -- Glow locked items and make them linsk to inapp scene
    for i,group in pairs(self.locks) do
        group:addEventListener("tap", scene.gotoInAppPurchase)

        local seq = anim:oustSeq("bobLocked"..i, group)
        seq:add("glow", {time=2000, delay=50, alpha=0.5})
        seq:start()
    end

    -- Animate progress text
    local tips = {
        {text="purchase planet to unlock items marked with *",   rgb={1,    1,    1}},
        {text="complete all zones to unlock new character",      rgb={1,    0.5,  0.25}},
        {text="earn stars to unlock arcade games",               rgb={1,    1,    0}},
        {text="rescue fuzzies to unlock challenge games",        rgb={0.25, 0.5,  1}},
        {text="rescue fuzzies to unlock challenge games",        rgb={0.5,  0.5,  1}},
    }

    self.tip  = newText(self.view, tips[1].text, centerX, 520, 0.45, "white", "CENTER")
    local tip = self.tip
    tip.counter = 1

    animateText(tip, function() 
        tip.counter = tip.counter + 1
        if tip.counter > #tips then tip.counter = 1 end

        local rgb = tips[tip.counter].rgb
        tip.text  = tips[tip.counter].text
        tip:setColor(rgb[1], rgb[2], rgb[3])
    end)
end


function scene:gotoInAppPurchase()
    play(sounds.generalClick)

    state.inappPurchaseType = "planet"
    composer.gotoScene("scenes.inapp-purchases")
    return true
end


function scene:exitToShop()
    state.musicSceneContinue = false
    play(sounds.sceneEnter)
    composer.gotoScene("scenes.shop")
    return true
end


function scene:exitToPlayerStore()
    state.musicSceneContinue = false
    play(sounds.sceneEnter)
    composer.gotoScene("scenes.select-player")
    return true
end



function scene:exitProgress()
    loadSceneTransition(1)
    after(10, function() composer.gotoScene(state:backScene()) end)
    return true
end


-- Called when scene is about to move offscreen:
function scene:hide(event)
    if event.phase == "will" then
        Runtime:removeEventListener("enterFrame", sceneEnterFrameEvent)
        Runtime:removeEventListener("key", sceneKeyEvent)

        track:cancelEventHandles()
        anim:destroy()
        spineStore:destroy()

        if self.tip then
            self.tip:removeInOutTransition()
            self.tip:removeSelf()
            self.tip = nil
        end

        self.planetSpec = nil
        logAnalyticsEnd()

    elseif event.phase == "did" then
        composer.removeScene("scenes.progress")
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