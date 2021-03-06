local composer    = require("composer")
local sharedScene = require("scenes.shared")
local anim        = require("core.animations")
local particles   = require("core.particles")
local builder     = require("level-objects.builders.builder")
local spineStore  = require("level-objects.collections.spine-store")

-- Locals:
local scene           = composer.newScene()
local spineCollection = nil
local lastTime        = 0

local planetSparkles = {
    {x=100, y=110}, {x=250, y=110}, {x=100, y=420}, {x=250, y=420},
    {x=400, y=110}, {x=550, y=110}, {x=400, y=420}, {x=550, y=420},
}

local gameModeSparkles = {
    {x=500, y=115}, {x=720, y=115},
    {x=500, y=255}, {x=720, y=255}
}

local zoneSparkles = {
    {x=500, y=50}, {x=600, y=50}, {x=700, y=50}, {x=800, y=50}, {x=900, y=50},
}

-- Aliases:
local play        = globalSoundPlayer
local new_group   = display.newGroup
local new_image   = newImage
local math_random = math.random


-- Things that need to happen as fast as possible (every frame e.g 60 loops per second)
local function sceneEnterFrameEvent(event)
    globalFPS = globalFPS + 1
    spineCollection:animateEach(event)
end


-- Treat phone back button same as back game button
local function sceneKeyEvent(event)
    if event.keyName == "back" and event.phase == "up" then
        scene:contextBack()
        return true
    end
end


-- Called when the scene's view does not exist:
function scene:create(event)
    self.creating = true
    self.context  = "selectPlanet"

    -- assign shared functions
    sharedScene:loadFruityMachine(self)

    -- Adding this call here means that we always show a single advert, only once, the first time anyone starts the game, but after they have picked an initial game choice
    adverts:forceAdvert()
    
    -- Allow the code from show() to run before this
    after(1000, function()
        self:displayBackground()
        self:displayHud()
        self:loadPlanetTabs()
        self:loadAllGameModes()
        self:loadPlayers()
        self:loadZones()
        self:setPlayerState()
        self:updateGameProgress()

        newButton(self.view, 55, 50, "back", scene.contextBack, 1000)

        self:startAnimations("primaryAnims")
    end)
end


-- Called immediately after scene has moved onscreen:
function scene:show(event)
    if event.phase == "did" then
        self:init()

        if scene.context == "exitScene" then
            scene.context = "selectPlanet"
        end

        if self.creating then
            self.creating = false
        else
            self:updateScene()
        end

        self:startMusic()
        self:startSparkles()
        Runtime:addEventListener("enterFrame", sceneEnterFrameEvent)
        Runtime:addEventListener("key", sceneKeyEvent)
    end
end


function scene:init()
    logAnalyticsStart()
    state:newScene("select-game")

    clearTransitionTimer()
    globalSceneTransitionGroup:removeSelf()
    globalSceneTransitionGroup = display.newGroup()

    -- Clear initial splash screen if its still here
    if globalSplashScreen then
        globalSplashScreen:removeSelf()
        globalSplashScreen = nil
    end

    -- Allow interaction again
    self.blockInput = false
end


function scene:updateScene()
    self:displayBackground(true)
    self:setGameTypeState()
    self:updateGameProgress()
    self:setZoneState()
    self:setPlayerState()

    -- Show current number of cubes and points
    if self.labelCubes then
        self.labelCubes:setText(state.data.holocubes)
        self.labelScore:setText(state.data.score)
    end
end


function scene:startMusic()
    -- If music not playing then start it
    if not state.musicSceneContinue and state.data.gameSettings.music then
        state.musicSceneContinue = true
        self.musicChannel = audio.findFreeChannel()
        audio.setVolume(0.5,    {channel=self.musicChannel})
        audio.setMaxVolume(0.5, {channel=self.musicChannel})
        play(sounds.tuneTitle, {channel=self.musicChannel, fadein=8000, loops=-1})
    end
end


---------- DISPLAY CREATORS ----------


function scene:displayBackground(redraw)
    local game    = state.data.gameSelected
    local bgrName = "story"

    if infiniteGameType[game]  then bgrName = "arcade"    end
    if challengeGameType[game] then bgrName = "challenge" end

    if redraw then
        self.background:removeSelf()
        self.hudTitle:removeSelf()
    end
    
    self.background = newBackground(self.view, "select-game/bgr-"..bgrName)
    self.background:toBack()

    if game == gameTypeStory then
        self.hudTitle = newText(self.view, "story mode",  centerX, 600, 1, "green",  "CENTER")
    elseif infiniteGameType[game] then
        self.hudTitle = newText(self.view, "arcade mode", centerX, 600, 1, "yellow", "CENTER")
    elseif challengeGameType[game] then
        self.hudTitle = newText(self.view, "challenges",  centerX, 600, 1, "pink",   "CENTER")
    end
end


function scene:displayHud()
    local game  = state.data.gameSelected
    local group = self.view

    spineCollection = builder:newSpineCollection()
    spineStore:load(spineCollection)

    self.labelCubes, self.labelScore, self.playerIcon = newMenuHud(group, spineStore, scene.exitToShop, scene.exitToPlayerStore)
    newMenuHudIcons(group, scene.exitToInApStore, scene.exitToPlanetProgress, scene.exitToFruityMachine)

    self.holobar = new_image(self.view, "select-game/challenges-holobar", centerX, 55, nil, 0)
end


-- Duplicates the logic from newMenuHud() because this scene is not deleted and the image needs recreating when player changed
function scene:displayHudPlayer()
    if self.playerIcon then
        self.playerIcon:removeSelf()
    end

    local playerName = characterData[state.data.playerModel].name
    self.playerIcon  = new_image(self.view, "hud/player-head-"..playerName, 890, 580, 0.85, 0.3)

    self.playerIcon.tap = scene.exitToPlayerStore
    self.playerIcon:addEventListener("tap", self.playerIcon)
    self.labelScore:toFront()
end


function scene:loadPlanetTabs()
    self.planets = {}

    for i=1, #planetData do
        local planetGroup = new_group()
        local planetTab   = new_image(planetGroup, "select-game/tab-planet"..i, 0, 0, 0.85)
        local comingSoon  = planetData[i].comingSoon

        if comingSoon then
            planetGroup.soon = newText(planetGroup, "coming soon", -20, -80, 0.8, "red", "CENTER")
            planetGroup.soon:rotate(15)
        else
            -- Create planet progress summary for use with story mode
            local progress       = new_group()
            planetGroup.progress = progress
            planetGroup:insert(progress)
            progress.alpha = 0
            
            new_image(progress, "select-game/progress", -135, 0)
        end

        planetGroup.planet = i
        planetGroup.x      = 1500
        planetGroup.y      = 280
        planetGroup.tab    = planetTab
        planetTab:addEventListener("tap", function() scene:selectPlanet(planetGroup) end)
        
        self.planets[#self.planets+1] = planetGroup
        self.view:insert(planetGroup)
    end
end


function scene:loadAllGameModes()
    self.allGameModes = {
        ["arcade"]    = self:loadGameModesFor(infiniteGameType),
        ["challenge"] = self:loadGameModesFor(challengeGameType),
    }
    self:setGameTypeState()
end


function scene:loadGameModesFor(gameTypeList)
    local planet = state.data.planetSelected
    local list   = {}
    local i      = 1

    for mode,_ in pairs(gameTypeList) do
        local gameData  = gameTypeData[mode]
        local gameGroup = new_group()
        local gameTab   = new_image(gameGroup, "select-game/tab-"..gameData.icon, 0, 0, 0.75)

        if gameData.comingSoon then
            gameGroup.soon = newText(gameGroup, "coming soon", 0, 0, 0.8, "red", "CENTER")
            gameGroup.soon:rotate(15)
        end

        gameGroup.game  = mode
        gameGroup.x     = 1500
        gameGroup.y     = (150 + ((i-1) * 125))
        gameGroup.origX = gameGroup.x
        gameGroup.origY = gameGroup.y
        gameGroup.tab   = gameTab

        if not gameData.comingSoon then
            gameTab:addEventListener("tap", function() scene:selectGameMode(gameGroup) end)
        end

        list[#list+1] = gameGroup
        self.view:insert(gameGroup)
        i = i + 1
    end
    return list
end


function scene:loadPlayers()
    local currentPlayer = state.data.playerModel

    self.players = {}

    for i=1, #characterData do
        local player = characterData[i]

        if player.playable then
            local playerGroup = new_group()
            local playerTab   = new_image(playerGroup, "hud/player-indicator-"..player.name, 0, 0)

            playerGroup.playerModel = i
            playerGroup.tab = playerTab
            playerGroup.x   = 1500
            playerGroup.y   = 55

            playerTab:addEventListener("tap", function() scene:selectPlayer(playerGroup, true) end)

            if currentPlayer == i then
                self.selectedPlayer = playerGroup
                playerGroup:scale(1.3, 1.3)
            end

            self.players[#self.players+1] = playerGroup
            self.view:insert(playerGroup)
        end
    end
end


function scene:loadZones()
    self.zones       = {}
    self.numberZones = 26

    -- Create the max number possible for any zone (even though we wont always show them)
    for i=1, self.numberZones do
        local zoneGroup    = new_group()
        local zoneTabRed   = new_image(zoneGroup, "select-game/zone-red", 0, 0)
        local zoneTabGreen = new_image(zoneGroup, "select-game/zone-green", 0, 0)
        local zoneNumber   = newText(zoneGroup,   i, -7, -35, 0.4, "white", "CENTER")
        local zoneLocked   = new_image(zoneGroup, "locking/lock", -10, 0, 0.5)
        local tapHandler   = display.newRect(zoneGroup, -10, -15, 70, 90)

        zoneGroup.zone         = i
        zoneGroup.zoneTabRed   = zoneTabRed
        zoneGroup.zoneTabGreen = zoneTabGreen
        zoneGroup.zoneLocked   = zoneLocked
        zoneGroup.x            = 1500
        zoneGroup.y            = centerY

        tapHandler.alpha = 0.01
        tapHandler:addEventListener("tap", function() scene:selectZone(zoneGroup) end)

        self.zones[#self.zones+1] = zoneGroup
        self.view:insert(zoneGroup)
    end
end


---------- UPDATE CODE CALLED EACH TIME SOMETHING CHANGES ----------


function scene:setGameTypeState()
    local game = state.data.gameSelected

    if infiniteGameType[game] then
        self.gameModes = self.allGameModes["arcade"]
    elseif challengeGameType[game] then
        self.gameModes = self.allGameModes["challenge"]
    end
end


function scene:updateGameProgress()
    local curGame = state.data.gameSelected

    for i,group in pairs(self.planets) do
        self:showPlanetProgress(group, curGame, i)
        self:showPlanetUnlockStatus(group, i)
    end

    for _,group in pairs(self.allGameModes["arcade"]) do
        self:showGameProgress(group, group.game)
        self:showGameUnlockStatus(group, group.game)
    end

    for _,group in pairs(self.allGameModes["challenge"]) do
        self:showGameProgress(group, group.game)
        self:showGameUnlockStatus(group, group.game)
    end
end


function scene:showPlanetProgress(group, curGame, planetSelected)
    if state:planetUnlocked(planetSelected) then
        self:showIconUnlocked(group)

        if curGame == gameTypeStory then
            local data = planetData[planetSelected]
            
            if group.progress then group.progress.alpha = 1 end

            local totalZones = data.normalZones + data.secretZones
            local zoneText   = state:numberZonesCompleted(planetSelected, gameTypeStory).." / "..totalZones
            local starText   = state:planetStarRanking(planetSelected, gameTypeStory).." / "..(totalZones * 5)
            local fuzzyText  = state:numberFuzziesCollected(planetSelected).." / "..data.fuzzies

            if group.progressZone then
                group.progressZone:setText(zoneText)
                group.progressStar:setText(starText)
                group.progressFuzzy:setText(fuzzyText)
            else
                group.progressZone  = newText(group.progress, zoneText,  -135, -85, 0.35, "green",  "CENTER")
                group.progressStar  = newText(group.progress, starText,  -135, 0,   0.35, "yellow", "CENTER")
                group.progressFuzzy = newText(group.progress, fuzzyText, -135, 80,  0.35, "aqua",   "CENTER")
            end
        else
            if group.progress then group.progress.alpha = 0 end
        end
    else
        self:showIconLocked(group, -25, -5)
    end
end


function scene:showGameProgress(group, gameMode, planetSelected)
    local text = ""

    if infiniteGameType[gameMode] then
        local gameState = state:zoneState(1, state.data.planetSelected, gameMode)
        local stage     = gameState.topStage or 0
        local ledge     = gameState.topLedge or 0

        text = "stage: "..stage.." ledge: "..ledge
                
    elseif challengeGameType[gameMode] then
        local numberZones = state:numberZones(state.data.planetSelected, gameMode)
        local completed   = state:numberZonesCompletedAs(state.data.planetSelected, gameMode, state.data.playerModel)

        text = characterData[state.data.playerModel].name..": "..completed.." of "..numberZones
    end

    if group.scoreLabel then
        group.scoreLabel:setText(text)
    else
        if gameMode == gameTypeStory then
            group.scoreLabel = newText(group, text, 0, 80, 0.3, "white", "RIGHT")
        else
            group.scoreLabel = newText(group, text, 130, 20, 0.3, "white", "RIGHT")
        end
    end
end


function scene:showPlanetUnlockStatus(group, planet)
    if state:planetUnlocked(planet) then
        self:showIconUnlocked(group)
    else
        self:showIconLocked(group, -25, -5)
    end
end


function scene:showGameUnlockStatus(group, gameMode)
    local planet = state.data.planetSelected

    if state:gameUnlocked(planet, gameMode) then
        group.scoreLabel.alpha = 1
        self:showIconUnlocked(group)
    else
        self:showIconLocked(group, -110, -5)
    end
end


function scene:setPlayerState()
    if self.players then
        for i=1, #self.players do
            local group  = self.players[i]
            local player = group.playerModel

            if state:characterUnlocked(player) then
                self:showIconUnlocked(group)
            else
                self:showIconLocked(group, 0, 0, 0.7, 0.5)
            end

            -- Show the current selected player
            if player == state.data.playerModel then
                self:selectPlayer(group)
            end
        end
    end
end


function scene:setZoneState()
    -- non challenge modes ignore this:
    if self.zones == nil then return end

    local game   = state.data.gameSelected
    local planet = state.data.planetSelected
    local player = state.data.playerModel
    -- index into the state using the current selected options
    local data   = state.data.levelProgress[planet][game]

    self.numberZones = #data

    -- Loop through tabs and modify then according to the state data
    for i=1, #self.zones do
        local zoneGroup = self.zones[i]

        if i > self.numberZones then
            zoneGroup.alpha = 0
        else
            zoneGroup.alpha = 1
            local zoneState = data[i]

            if state:zoneUnlocked(planet, i) then
                zoneGroup.alpha = 1
                zoneGroup.zoneLocked.alpha = 0

                local completions = zoneState.completedAs

                if completions and table.indexOf(completions, player) then
                    zoneGroup.zoneTabGreen.alpha = 1
                else
                    zoneGroup.zoneTabGreen.alpha = 0
                end
            else
                zoneGroup.alpha              = 0.6
                zoneGroup.zoneLocked.alpha   = 1
                zoneGroup.zoneTabGreen.alpha = 0
            end
        end
    end
end


function scene:showIconLocked(group, xpos, ypos, alpha, scale)
    if group.scoreLabel then
        group.scoreLabel.alpha = 0
    end

    if group.lock == nil then
        group.lock = new_image(group, "locking/lock", xpos, ypos, (scale or 0.75), (alpha or 1))

        if group.tab then
            group.tab:setFillColor(0.4, 0.4, 0.4)
        end

        -- push coming soon over lock icon
        if group.soon then
            group.soon:toFront()
        end
    end
end


function scene:showIconUnlocked(group)
    if group.lock then
        group.lock:removeSelf()
        group.lock = nil
        group.tab:setFillColor(1, 1, 1)
    end
end


---------- EVENTS ----------


function scene:contextBack()
    if scene.context == "selectPlanet" then
        scene.context = "exitScene"
        scene:exitToTitle()

    elseif scene.context == "selectGame" then
        scene.context = "selectPlanet"

        scene:slideGameModesOut("primaryAnims")
        scene:startAnimations("primaryAnims")
        scene:removePlanetBanner("secondaryAnims")
        anim:startQueue("secondaryAnims")

    elseif scene.context == "selectZone" then
        scene.context = "selectGame"

        scene:slideZonesOut("primaryAnims")
        scene:slideGameModesIn("primaryAnims")
        scene:slidePlayersOut("secondaryAnims")
        scene:removeGameModeBackground("tertiaryAnims")

        anim:startQueue("primaryAnims")
        anim:startQueue("secondaryAnims")
        anim:startQueue("tertiaryAnims")
    end

    scene:startSparkles()
end


function scene:finishSequence(animName)
    local seq = anim:chainSeq(animName, nil)
    seq:callback(function() scene.blockInput = false end)
end


function scene:selectPlanet(group)
    local game   = state.data.gameSelected
    local planet = group.planet

    if scene.context == "selectPlanet" and not scene.blockInput then
        if state:planetUnlocked(planet) then
            scene.blockInput = true
            state.data.planetSelected = planet

            if state:planetUnlocked(group.planet) then
                scene.selectedPlanet = group
                scene:bobOption(group)
                scene:updateGameProgress()
                
                after(300, function()
                    if     game == gameTypeStory   then scene:selectStoryPlanet()
                    elseif infiniteGameType[game]  then scene:selectOtherPlanet(planet)
                    elseif challengeGameType[game] then scene:selectOtherPlanet(planet) end
                end)
            end
        else
            newLockedPopup(self.view, planet, "planet", planetData[planet].name, function() scene:startSparkles() end)
        end
    end
end


function scene:selectStoryPlanet()
    local cutsceneStory = "cutscene-planet-intro-"..planetData[state.data.planetSelected].name

    if state:showStory(cutsceneStory) then
        -- Go to the planet intro cutscene
        state.data.zoneSelected  = 1
        state.cutsceneStory      = "cutscene-planet-intro"
        state.sceneAfterCutScene = "scenes.select-zone"
        self.nextScene           = "scenes.mothership"
    else
        -- Go to the zone select scene
        if state.data.zoneSelected == nil or state.data.zoneSelected < 1 then
            state.data.zoneSelected = 1
        end

        self.nextScene = "scenes.select-zone"
    end

    self:changeScene()
end


function scene:selectOtherPlanet(planetIndex)
    scene.context = "selectGame"

    for i=1, #self.planets do
        local planet = self.planets[i]
        local xpos   = 210

        if i ~= planetIndex then
            xpos = -1000
        end

        local seq = anim:chainSeq("planetSlideSelect", planet)
        seq:tran({x=xpos, time=150})
    end

    if self.planetBanner then
        self:removePlanetBanner("planetSlideSelect2", true)
    else
        self:changePlanetBanner("planetSlideSelect2")
    end

    self:slideGameModesIn("planetSlideSelect")
    self:finishSequence("planetSlideSelect")

    anim:startQueue("planetSlideSelect")
    anim:startQueue("planetSlideSelect2")

    scene:startSparkles()
end


function scene:slideGameModesIn(animName)
    for i=1, #self.gameModes do
        local game = self.gameModes[i]
        local seq  = anim:chainSeq(animName, game)

        seq:tran({x=600, y=game.origY, time=250, ease="spring"})
    end
end


function scene:slideGameModesOut(animName)
    for i=1, #self.gameModes do
        local game = self.gameModes[i]
        local seq  = anim:chainSeq(animName, game)

        seq:tran({x=1500, time=150, ease="spring"})
    end
end


function scene:selectGameMode(gameGroup)
    local game   = gameGroup.game
    local planet = state.data.planetSelected

    if state:gameUnlocked(planet, game) then
        if infiniteGameType[game] and scene.context == "selectGame" and not scene.blockInput then
            scene.blockInput = true
            scene.nextScene  = "scenes.play-zone"
            state.data.gameSelected = game

            if     game == gameTypeArcadeRacer then state.data.gameSelected = "-arcade-racer"
            elseif game == gameTypeTimeRunner  then state.data.zoneSelected = "-arcade-timer"
            elseif game == gameTypeClimbChase  then state.data.zoneSelected = "-arcade-climber" end

            state.data.zoneSelected = 1

            self:bobOption(gameGroup)
            scene:changeScene()

        elseif challengeGameType[game] and scene.context == "selectGame" then
            state.data.gameSelected = game
            self:setZoneState()
            self:selectChallengeGame(gameGroup)
        end
    else
        -- Clear out the global package handler to force a reload of modules, Otherwise require wont reload them
        local file = "levels.planet"..planet..".planet"
        package.loaded[file] = nil
        
        local planetSpec  = require(file)
        local description = ""

        if challengeGameType[game] then
            local amount = planetSpec.gameUnlocks[game].fuzzies - state:numberFuzziesCollected(planet)
            description  = "rescue "..amount.." fuzzies"
        elseif infiniteGameType[game] then
            local amount = planetSpec.gameUnlocks[game].stars - state:planetStarRanking(planet, gameTypeStory)
            description  = "earn "..amount.." stars"
        end

        newLockedPopup(self.view, game, "game", gameTypeData[game].name, function() scene:startSparkles() end, description.." to unlock")
        package.loaded[file] = nil
    end
end


function scene:selectChallengeGame(gameGroup)
    scene.context = "selectZone"

    scene:bobOption(gameGroup)

    for i=1, #self.gameModes do
        local game = self.gameModes[i]
        local seq  = anim:chainSeq("zoneSlideSelect", game)

        if game.game == gameGroup.game then
            seq:tran({x=270, y=60, time=250, ease="spring"})
        else
            seq:tran({x=-1000, time=250})
        end
    end

    local seq1 = anim:chainSeq("zoneSlideSelect", self.holobar)
    seq1:tran({alpha=1, time=150})

    self:slidePlayersIn("zoneSlideSelect")

    local seq2 = anim:chainSeq("zoneSlideSelect2", scene.selectedPlanet)
    seq2:tran({x=-1000, time=250})

    self:slideZonesIn("zoneSlideSelect2")

    -- fade in game mode bgr
    if self.gameModeBackground then
        self:removeGameModeBackground("zoneSlideSelect3", true)
    else
        self:changeGameModeBackground("zoneSlideSelect3")
    end

    self:finishSequence("zoneSlideSelect")
    anim:startQueue("zoneSlideSelect")
    anim:startQueue("zoneSlideSelect2")
    anim:startQueue("zoneSlideSelect3")

    scene:startSparkles()
end


function scene:removePlanetBanner(animName, replace)
    local seq = anim:chainSeq(animName, self.planetBanner)
    seq:tran({alpha=0, time=2000})
    seq:callback(function()
        if self.planetBanner then
            self.planetBanner:removeSelf()
            self.planetBanner = nil

            if replace then
                self:changePlanetBanner(animName)
            end
        end
    end)
end


function scene:changePlanetBanner(animName)
    local icon = gameTypeData[state.data.gameSelected].icon
    self.planetBanner = new_image(self.view, "select-game/banner-planet"..state.data.planetSelected, 310, 597, nil, 0)

    self.hudTitle:toFront()

    local seq = anim:chainSeq(animName, self.planetBanner)
    seq:tran({alpha=0.6, time=2000})
end


function scene:removeGameModeBackground(animName, replace)
    local seq = anim:chainSeq(animName, self.gameModeBackground)
    seq:tran({alpha=0, time=2000})
    seq:callback(function()
        self.gameModeBackground:removeSelf()
        self.gameModeBackground = nil

        if replace then
            self:changeGameModeBackground()
        end
    end)
end


function scene:changeGameModeBackground(animName)
    local icon = gameTypeData[state.data.gameSelected].icon
    self.gameModeBackground = new_image(self.view, "select-game/challenge-bg-"..icon, 800, 450, nil, 0)

    self.gameModeBackground:toBack()
    self.background:toBack()

    local seq = anim:chainSeq(animName, self.gameModeBackground)
    seq:tran({alpha=0.4, time=2000})
end


function scene:slidePlayersIn(animName)
    for i=1, #self.players do
        local player = self.players[i]
        local xpos   = 500 + ((i-1) * 100)
        local seq    = anim:chainSeq(animName, player)

        seq:tran({x=xpos, time=150, ease="spring"})
    end
end


function scene:slidePlayersOut(animName)
    for i=1, #self.players do
        local player = self.players[i]
        local seq    = anim:chainSeq(animName, player)
        seq:tran({x=1500, time=150, ease="spring"})
    end

    local seq2 = anim:chainSeq(animName, self.holobar)
    seq2:tran({alpha=0, time=150})
end


function scene:slideZonesIn(animName)
    for i=1, #self.zones do
        local zone = self.zones[i]
        local seq  = anim:chainSeq(animName, zone)
        local xpos = nil
        local ypos = nil

        if i < 12 then
            xpos = 70 + ((i-1) * 85)
            ypos = 200
        elseif i < 22 then
            xpos = 70 + ((i-12) * 85)
            ypos = 320
        elseif i < 30 then
            xpos = 70 + ((i-19) * 85)
            ypos = 440
        end

        seq:tran({y=ypos, x=xpos, time=30})
    end
end


function scene:slideZonesOut(animName)
    for i=1, #self.zones do
        local zone = self.zones[i]
        local seq  = anim:chainSeq(animName, zone)

        seq:tran({y=centerY, x=1500, time=30})
    end

    local seq = anim:chainSeq(animName, scene.selectedPlanet)
    seq:tran({x=210, time=250, ease="spring"})
end


function scene:selectPlayer(playerGroup, playSound)
    local newPlayer = playerGroup.playerModel

    if newPlayer ~= scene.selectedPlayer.playerModel then
        if state:characterUnlocked(newPlayer) then
            sounds:unloadPlayer(state.data.playerModel)
            sounds:loadPlayer(newPlayer)

            if playSound then play(sounds.generalClick) end

            state.data.playerModel = newPlayer

            scene:updateGameProgress()
            scene:setZoneState()
            scene:displayHudPlayer()
            scene.selectedPlayer.xScale, scene.selectedPlayer.yScale = 1, 1
            scene.selectedPlayer = playerGroup
            scene.selectedPlayer:scale(1.3, 1.3)
        else
            newLockedPopup(self.view, newPlayer, "character", characterData[newPlayer].name, function() scene:startSparkles() end)
        end
    end
end


function scene:selectZone(zoneGroup)
    local planet = state.data.planetSelected

    if state:zoneUnlocked(planet, zoneGroup.zone) and not scene.blockInput then
        scene.blockInput = true
        state.data.zoneSelected = zoneGroup.zone

        scene:bobOption(zoneGroup)
        scene.nextScene = "scenes.play-zone"
        scene:changeScene()
    elseif zoneGroup.zone > 21 then
        newLockedPopup(self.view, planet, "zones", "secret zones", function() scene:startSparkles() end)
    end
end


---------- GENERAL ----------


function scene:startSparkles()
    local sparkles = nil

    if     self.context == "selectPlanet" then sparkles = planetSparkles
    elseif self.context == "selectGame"   then sparkles = gameModeSparkles
    elseif self.context == "selectZone"   then sparkles = zoneSparkles end

    if sparkles then
        newRandomSparkle(self.view, 1000, sparkles)
    end

    self:startPulsing()
end


function scene:stopPulsing()
    for i=1, #self.planets do
        anim:destroyQueue("planetPulser"..i)
    end

    if self.gameModes then 
        for i=1, #self.gameModes do
            anim:destroyQueue("gamePulser"..i)
        end
    end

    if self.zones then
        for i=1, #self.zones do
            anim:destroyQueue("zonePulser"..i)
        end
    end
end


function scene:startPulsing()
    local planet = state.data.planetSelected

    if self.context == "selectPlanet" and self.planets then 
        for i=1, #self.planets do
            local planet = self.planets[i]

            if state:planetUnlocked(i) then
                self:pulseItem("planetPulser", planet, i)
            end
        end
    elseif self.context == "selectGame" and self.gameModes then
        for i=1, #self.gameModes do
            local game = self.gameModes[i]

            if state:gameUnlocked(planet, game.game) then
                self:pulseItem("gamePulser", game, i)
            end
        end
    elseif self.context == "selectZone" and self.zones then
        for i=1, #self.zones do
            local zone = self.zones[i]

            if state:zoneUnlocked(planet, i) then
                self:pulseItem("zonePulser", zone, i, 133)
            end
        end
    end
end


function scene:pulseItem(name, item, num, delay)
    local wait = (num-1) * (delay or 500)

    local seq = anim:oustSeq(name..num, item)
    seq:wait(wait)
    seq:add("pulse", {time=1500, scale=0.01})
    seq:start() 
end


function scene:startAnimations(animName)
    for i=1, #self.planets do
        local planet = self.planets[i]
        local xpos   = 210 + ((i-1)*300)
        local seq    = anim:chainSeq(animName, planet)

        seq:tran({x=xpos, time=250, ease="spring"})
    end

    anim:startQueue(animName)
end


function scene:bobOption(option)
    play(sounds.generalClick)

    self:stopPulsing()

    local seq = anim:chainSeq("menuActivate", option)
    seq:tran({time=150, scale=1.2})
    seq:tran({time=150, scale=1})
    seq:start()
end


function scene:changeScene()
    state.musicSceneContinue = false
    play(sounds.gameStart)

    after(500, function()
        loadSceneTransition()
        after(1000, function()
            composer.gotoScene(scene.nextScene, {effect="fade", time=500})
        end)
    end)
end


function scene:exitToTitle()
    if not scene.blockInput then
        scene.blockInput = true

        state.musicSceneContinue = true
        loadSceneTransition()
        after(1000, function() composer.gotoScene(state:backScene(), {effect="fade", time=750}) end)
    end
    return true
end


function scene:exitToShop()
    if not scene.blockInput then
        scene.blockInput = true

        state.musicSceneContinue = false
        play(sounds.sceneEnter)
        composer.gotoScene("scenes.shop")
    end
    return true
end


function scene:exitToPlayerStore()
    if not scene.blockInput then
        scene.blockInput = true

        state.musicSceneContinue = false
        play(sounds.sceneEnter)
        composer.gotoScene("scenes.select-player")
    end
    return true
end


function scene:exitToPlanetProgress()
    if not scene.blockInput then
        scene.blockInput = true

        state.musicSceneContinue = false
        play(sounds.sceneEnter)
        composer.gotoScene("scenes.progress")
    end
    return true
end


function scene:exitToInApStore()
    if not scene.blockInput then
        scene.blockInput = true

        state.musicSceneContinue = false
        play(sounds.sceneEnter)
        composer.gotoScene("scenes.inapp-purchases")
    end
    return true
end


-- Called when scene is about to move offscreen:
function scene:hide(event)
    if event.phase == "will" then
        if not state.musicSceneContinue then
            audio.fadeOut({channel=self.musicChannel, time=1000})
        end

        Runtime:removeEventListener("enterFrame", sceneEnterFrameEvent)
        Runtime:removeEventListener("key", sceneKeyEvent)

        -- NOTE: dont call anim:destroy() as this means exit animations wont always finish and the next time mthe scene items are misplaced
        self:stopPulsing()
        self:removeFruityMachine()

        particles:destroy()
        stopSparkles()
        logAnalyticsEnd()

    elseif event.phase == "did" then
        -- NOTE: we dont purge the scene as this stays in same stat ethrough whole game so we can return to previous options quickly
        --composer.removeScene("scenes.select-game")
        self:stopPulsing()
    end
end


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