local storyboard  = require("storyboard")
local anim        = require("core.animations")
local builder     = require("level-objects.builders.builder")
local spineStore  = require("level-objects.collections.spine-store")

-- Locals:
local scene           = storyboard.newScene()
local spineCollection = nil
local lastTime        = 0

-- Aliases:
local play      = globalSoundPlayer
local new_group = display.newGroup
local new_image = newImage


-- Things that need to happen as fast as possible (every frame e.g 60 loops per second)
local function sceneEnterFrameEvent(event)
    globalFPS = globalFPS + 1
    spineCollection:animateEach(event)
end


-- Called when the scene's view does not exist:
function scene:createScene(event)
    self.creating = true
    self.context  = "selectPlanet"
    
    -- Allow the code from enterScene to run before this
    after(1000, function()
        self:initScene()
        self:displayBackground()
        self:displayHud()
        self:loadPlanetTabs()
        self:loadAllGameModes()
        self:loadPlayers()
        self:loadZones()
        self:setPlayerState()
        self:updateGameProgress()

        newButton(self.view, 55, 50, "back", scene.contextBack)

        self:startAnimations("primaryAnims")
    end)
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene(event)
    logAnalytics("select-game", "enterScene")

    clearTransitionTimer()

    if scene.context == "exitScene" then
        scene.context = "selectPlanet"
    end

    if self.creating then
        self.creating = false
    else
        self:updateScene()
    end

    self:startMusic()
    Runtime:addEventListener("enterFrame", sceneEnterFrameEvent)
end


function scene:initScene()
    state:newScene("select-game")
    globalSceneTransitionGroup:removeSelf()
    globalSceneTransitionGroup = display.newGroup()

    -- Clear initial splash screen if its still here
    if globalSplashScreen then
        globalSplashScreen:removeSelf()
        globalSplashScreen = nil
    end
end


function scene:updateScene()
    self:initScene()
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
    
    self.background = new_image(self.view, "select-game/bgr-"..bgrName, centerX, centerY)
    self.background:toBack()

    if game == gameTypeStory then
        self.hudTitle = newText(self.view, "story mode",  centerX, 590, 1, "green",  "CENTER")
    elseif infiniteGameType[game] then
        self.hudTitle = newText(self.view, "arcade mode", centerX, 590, 1, "yellow", "CENTER")
    elseif challengeGameType[game] then
        self.hudTitle = newText(self.view, "challenges",  centerX, 590, 1, "pink",   "CENTER")
    end
end


function scene:displayHud()
    local game  = state.data.gameSelected
    local group = self.view

    spineCollection = builder:newSpineCollection()
    spineStore:load(spineCollection)

    self.progressGroup = new_group()
    self.progressGroup.alpha = 0
    group:insert(self.progressGroup)

    local progress = newImage(self.progressGroup, "hud/progress-tab", centerX, 508)
    progress:addEventListener("tap", scene.exitToPlanetProgress)

    self.labelCubes, self.labelScore, self.playerIcon = newMenuHud(group, spineStore, scene.exitToShop, scene.exitToPlayerStore)

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

        if planetData[i].comingSoon then
            planetGroup.soon = newText(planetGroup, "coming soon", -20, -80, 0.8, "red", "CENTER")
            planetGroup.soon:rotate(15)
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
        gameTab:addEventListener("tap", function() scene:selectGameMode(gameGroup) end)

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

            playerTab:addEventListener("tap", function() scene:selectPlayer(playerGroup) end)

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
    self.numberZones = 21

    -- Create the max number possible for any zone (even though we wont always show them)
    for i=1, 21 do
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
    local game = state.data.gameSelected

    for i,group in pairs(self.planets) do
        self:showGameProgress(group, gameTypeStory, i)
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
        if state.data.gameSelected == gameTypeStory then
            group.scoreLabel.alpha = 1
        else
            group.scoreLabel.alpha = 0
        end

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

        local seq = anim:chainSeq("progressTab", scene.progressGroup)
        seq:tran({time=1000, alpha=0})
        seq:start()

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
end


function scene:selectPlanet(group)
    local game   = state.data.gameSelected
    local planet = group.planet

    if scene.context == "selectPlanet" then
        if state:planetUnlocked(planet) then
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

            local seq = anim:chainSeq("progressTab", self.progressGroup)
            seq:tran({time=1000, alpha=1})
            seq:start()
        else
            newLockedPopup(self.view, planet, "planet", planetData[planet].name)
        end
    end
end


function scene:selectStoryPlanet()
    -- If the first zone of the planet selected has not been completed we always show the intro cutscene before the zone select
    local zone = state:zoneState(1)
    
    if zone.completed then
        -- Go to the zone select scene
        if state.data.zoneSelected == nil or state.data.zoneSelected < 1 then
            state.data.zoneSelected = 1
        end

        self.nextScene = "scenes.select-zone"
    else
        -- Go to the planet intro cutscene
        state.data.zoneSelected  = 1
        state.cutsceneStory      = "cutscene-planet-intro"
        state.sceneAfterCutScene = "scenes.select-zone"
        self.nextScene           = "scenes.mothership"
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
    anim:startQueue("planetSlideSelect")
    anim:startQueue("planetSlideSelect2")
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
        if infiniteGameType[game] and scene.context == "selectGame" then
            state.data.gameSelected = game
            scene.nextScene = "scenes.play-zone"

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

        newLockedPopup(self.view, game, "game", gameTypeData[game].name, description.." to unlock")
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

    anim:startQueue("zoneSlideSelect")
    anim:startQueue("zoneSlideSelect2")
    anim:startQueue("zoneSlideSelect3")
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

        if i < 12 then
            local xpos = 70 + ((i-1) * 85)
            seq:tran({y=250, x=xpos, time=50, ease="spring"})
        elseif i < 23 then
            local xpos = 70 + ((i-12) * 85)
            seq:tran({y=370, x=xpos, time=50, ease="spring"})
        end
    end
end


function scene:slideZonesOut(animName)
    for i=1, #self.zones do
        local zone = self.zones[i]
        local seq  = anim:chainSeq(animName, zone)

        seq:tran({y=centerY, x=1500, time=50})
    end

    local seq = anim:chainSeq(animName, scene.selectedPlanet)
    seq:tran({x=210, time=250, ease="spring"})
end


function scene:selectPlayer(playerGroup)
    local newPlayer = playerGroup.playerModel

    if newPlayer ~= scene.selectedPlayer.playerModel then
        if state:characterUnlocked(newPlayer) then
            sounds:unloadPlayer(state.data.playerModel)
            sounds:loadPlayer(newPlayer)
            play(sounds.generalClick)

            state.data.playerModel = newPlayer

            scene:updateGameProgress()
            scene:setZoneState()
            scene:displayHudPlayer()
            scene.selectedPlayer.xScale, scene.selectedPlayer.yScale = 1, 1
            scene.selectedPlayer = playerGroup
            scene.selectedPlayer:scale(1.3, 1.3)
        else
            newLockedPopup(self.view, newPlayer, "character", characterData[newPlayer].name)
        end
    end
end


function scene:selectZone(zoneGroup)
    if state:zoneUnlocked(state.data.planetSelected, zoneGroup.zone) then
        state.data.zoneSelected = zoneGroup.zone

        scene:bobOption(zoneGroup)
        scene.nextScene = "scenes.play-zone"
        scene:changeScene()
    end
end


---------- GENERAL ----------


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

    local seq = anim:chainSeq("menuActivate", option)
    seq:tran({time=150, scale=1.2})
    seq:tran({time=150, scale=1})
    seq:start()
end


function scene:activateOption(option)
    play(sounds.generalClick)

    local seq = anim:chainSeq("menuActivate", option)
    seq:tran({time=250, scale=1.5})
    seq:tran({time=500, scale=0.01})
    seq:start()
end


function scene:changeScene()
    state.musicSceneContinue = false
    play(sounds.gameStart)

    after(500, function()
        loadSceneTransition()
        after(1000, function()
            storyboard:gotoScene(scene.nextScene, {effect="fade", time=500})
        end)
    end)
end


function scene:exitToTitle()
    state.musicSceneContinue = true
    loadSceneTransition()
    after(1000, function() storyboard:gotoScene(state:backScene(), {effect="fade", time=750}) end)
    return true
end


function scene:exitToShop()
    state.musicSceneContinue = false
    play(sounds.sceneEnter)
    storyboard:gotoScene("scenes.shop")
    return true
end


function scene:exitToPlayerStore()
    state.musicSceneContinue = false
    play(sounds.sceneEnter)
    storyboard:gotoScene("scenes.select-player")
    return true
end


function scene:exitToPlanetProgress()
    state.musicSceneContinue = false
    play(sounds.sceneEnter)
    storyboard:gotoScene("scenes.progress")
    return true
end


-- Called when scene is about to move offscreen:
function scene:exitScene(event)
    if not state.musicSceneContinue then
        audio.fadeOut({channel=self.musicChannel, time=1000})
    end

    Runtime:removeEventListener("enterFrame", sceneEnterFrameEvent)
end


-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
    --storyboard.purgeScene("scenes.select-game")
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