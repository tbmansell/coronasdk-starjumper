local storyboard = require("storyboard")
local anim       = require("core.animations")
local builder    = require("level-objects.builders.builder")
local spineStore = require("level-objects.collections.spine-store")

-- Local vars:
local scene           = storyboard.newScene()
local spineCollection = nil
local lastTime        = 0

-- Aliases:
local play = realPlayer


-- Things that need to happen as fast as possible (every frame e.g 60 loops per second)
local function sceneEnterFrameEvent(event)
    globalFPS = globalFPS + 1
 
    -- Compute time in seconds since last frame.
    local currentTime = event.time / 1000
    local delta       = currentTime - lastTime
    lastTime = currentTime
    
    spineCollection:animateEach(delta)
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

    self.labelCubes, self.labelScore, self.playerIcon = newMenuHud(self.view, spineStore)

    newText(self.view, data.name.." - progress", centerX, 590, 0.8, data.color, "CENTER")
    newButton(self.view, 55, 50, "back", scene.exitProgress)
end


function scene:summary()
    newText(self.view, "story progress",  165, 105, 0.3, "green", "CENTER")
    newText(self.view, "other games",     440, 20,  0.3, "green", "CENTER")
    newText(self.view, "special unlocks", 785, 20,  0.3, "green", "CENTER")
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

    self:createStatStatus(155, 165, "zones",   zonesDone,  zonesTotal)
    self:createStatStatus(155, 255, "stars",   starsDone,  starsTotal)
    self:createStatStatus(155, 345, "fuzzies", fuzzyDone,  fuzzyTotal)
    self:createStatStatus(155, 440, "awards",  awardsDone, awardsTotal)
end


function scene:createStatStatus(xpos, ypos, title, collected, total)
    newText(self.view, collected, xpos+34, ypos,   0.6, "green", "RIGHT")
    newText(self.view, "/",       xpos+40, ypos+3, 0.4, "white", "LEFT")
    newText(self.view, total,     xpos+55, ypos+3, 0.4, "white", "LEFT")
end


function scene:summaryGameModes()
    local order  = {gameTypeTimeRunner, gameTypeClimbChase, gameTypeArcadeRacer, gameTypeSurvival, gameTypeTimeAttack, gameTypeRace}
    local unlock = self.planetSpec.gameUnlocks
    local ypos   = 75

    for _,game in pairs(order) do
        local  label = ""
        if     infiniteGameType[game]  then label = "get "..unlock[game].stars.." stars*"
        elseif challengeGameType[game] then label = "get "..unlock[game].fuzzies.." fuzzies*" end

        self:createGameModeStatus(430, ypos, game, label)
        ypos = ypos + 75
    end
end


function scene:createGameModeStatus(xpos, ypos, game, unlockText)
    local data   = gameTypeData[game]
    local player = state.data.playerModel
    local icon   = newImage(self.view, "select-game/tab-"..data.icon, xpos, ypos, 0.45, 0.6)
    
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
        newImage(self.view, "locking/lock", xpos-65, ypos, 0.5, 0.7)
        newText(self.view, unlockText, xpos-55, ypos+15, 0.5, "white", "LEFT")
    end
end


function scene:summarySpecialItems()
    self:summaryCharacter(680,   75,  self.planetSpec.unlockFriend, "complete "..planetData[self.planet].normalZones.." zones")
    self:summaryCharacter(680,   175, self.planetSpec.unlockEnemy,  "buy planet pack")
    self:summaryNextPlanet(680,  300)
    self:summarySecretZones(680, 430)
end


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


function scene:summarySecretZones(xpos, ypos)
    newImage(self.view, "select-game/race-zone-red", xpos+5, ypos+5, 0.8)
    newText(self.view, "?",             xpos-15, ypos-10, 0.7, "red",   "LEFT")
    newText(self.view, "secret zones!", xpos+30, ypos-25, 0.5, "red",   "LEFT")

    if false then
        newText(self.view, "unlocked!", xpos+30, ypos+10, 0.4, "green", "LEFT")
    else
        newImage(self.view, "locking/lock",   xpos,    ypos-10, 0.5, 0.7)
        newText(self.view, "buy planet pack", xpos+30, ypos+10, 0.4, "white", "LEFT")
    end
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