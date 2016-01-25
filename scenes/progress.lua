local storyboard = require("storyboard")
local anim       = require("core.animations")
local builder    = require("level-objects.builders.builder")
local spineStore = require("level-objects.collections.spine-store")

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
    logAnalytics("progress", "enterScene")

    self.planet = state.data.planetSelected
    self.data   = planetData[self.planet]

    package.loaded["levels.planet"..self.planet..".planet"] = nil
    self.planetSpec = require("levels.planet"..self.planet..".planet")

    state:newScene("progress")
    play(sounds.zoneSummary)

    spineCollection = builder:newSpineCollection()
    spineStore:load(spineCollection)

    newImage(self.view, "select-zone/progress-bgr", centerX, centerY)
    self:displayHud()
    self:summary()

    Runtime:addEventListener("enterFrame", sceneEnterFrameEvent)
end


function scene:displayHud()
    local data = planetData[state.data.planetSelected]

    self.labelCubes, self.labelScore, self.playerIcon = newMenuHud(self.view, spineStore, scene.exitToShop, scene.exitToPlayerStore)

    newText(self.view, data.name.." - progress", centerX, 590, 0.8, data.color, "CENTER")
    newButton(self.view, 55, 50, "back", scene.exitProgress)
end


function scene:summary()
    newText(self.view, "* or buy planet pack to unlock", centerX, 520, 0.45, "red", "CENTER")

    self:summaryProgress()
    self:summaryGameModes()
    self:summarySpecialItems()
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
    newText(self.view, collected, xpos+34, ypos,   0.7, "green", "RIGHT")
    newText(self.view, "/",       xpos+40, ypos+3, 0.5, "white", "LEFT")
    newText(self.view, total,     xpos+55, ypos+3, 0.5, "white", "LEFT")
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
    local data   = gameTypeData[game]
    local player = state.data.playerModel
    local icon   = newImage(self.view, "select-game/tab-"..data.icon, xpos, ypos, 0.5, 0.6)
    
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

        newText(self.view, text, xpos-40, ypos+10, 0.3, "white", "LEFT")
    else
        newImage(self.view, "locking/lock", xpos-65, ypos,    0.6, 0.9)
        newText(self.view,  unlockText,     xpos-45, ypos+15, 0.7, "white", "LEFT")
    end
end


function scene:summarySpecialItems()
    self:summaryCharacter(75,  350, self.planetSpec.unlockFriend, "complete "..planetData[self.planet].normalZones.." zones")
    self:summaryCharacter(760, 340, self.planetSpec.unlockEnemy,  "buy planet pack")
    self:summaryNextPlanet(135,  235)
    self:summarySecretZones(820, 200)
end


function scene:summaryCharacter(xpos, ypos, character, unlockText)
    local data = characterData[character]

    newImage(self.view, "hud/player-indicator-"..data.name, xpos, ypos)
    newText(self.view, data.name, xpos+30, ypos, 0.5, data.color, "LEFT")

    if not state:characterUnlocked(character) then
        newImage(self.view, "locking/lock", xpos,    ypos,    0.6, 0.9)
        newText(self.view,  unlockText,     xpos-35, ypos+30, 0.4, "white", "LEFT")
    end
end


function scene:summaryNextPlanet(xpos, ypos)
    local pid        = self.planet+1
    local nextPlanet = planetData[pid]

    newImage(self.view, "select-game/tab-planet"..pid, xpos-40, ypos, 0.35)

    if not state:planetUnlocked(self.planet+1) then
        newImage(self.view, "locking/lock",    xpos-50, ypos-15, 0.6,  0.9)
        newText(self.view, "complete 5 zones", xpos,    ypos+40, 0.4, "white", "CENTER")
    end

    newText(self.view, nextPlanet.name, xpos, ypos-30, 0.5, nextPlanet.color, "CENTER")
end


function scene:summarySecretZones(xpos, ypos)
    newImage(self.view, "select-game/race-zone-red", xpos-50, ypos+5,  0.8)
    newText(self.view,  "?",                         xpos-65, ypos-10, 0.7, "red", "LEFT")
    newText(self.view,  "secret zones!",             xpos,    ypos-55, 0.5, "red", "CENTER")

    if true then
        newImage(self.view, "locking/lock",   xpos-55, ypos-10,    0.6, 0.9)
        newText(self.view, "buy planet pack", xpos,    ypos+50, 0.45, "white", "CENTER")
    end
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



function scene:exitProgress()
    loadSceneTransition(1)
    after(10, function() storyboard:gotoScene(state:backScene()) end)
    return true
end


-- Called when scene is about to move offscreen:
function scene:exitScene(event)
    Runtime:removeEventListener("enterFrame", sceneEnterFrameEvent)
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