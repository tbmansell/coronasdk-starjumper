local storyboard = require("storyboard")


-- Aliases
local math_floor  = math.floor
local math_random = math.random
local play        = globalSoundPlayer


function hud:exitZone()
    self:removeGearFoundInLevel()

    -- Race - mark player as failed if they exit a race early
    if state.data.gameSelected == gameTypeRace then
        if state.data.game == levelOverComplete or state.data.game == levelOverFailed then
            self:saveUpdatedRacePositions()
        else
            self:saveAbortedRacePositions()
        end
    end
    loadSceneTransition()
    after(1000, function() storyboard:gotoScene(state:backScene(), {effect="fade", time=750}) end)
    return true
end


function hud:exitToShop()
    self:removeGearFoundInLevel()
    storyboard:gotoScene("scenes.shop")
    return true
end


function hud:exitToPlayerSelect()
    self:removeGearFoundInLevel()
    storyboard:gotoScene("scenes.select-player")
    return true
end


function hud:replayLevel()
    self:removeGearFoundInLevel(true)

    -- Race - save the updated race positions since plaer landed
    if state.data.gameSelected == gameTypeRace then
        self:saveUpdatedRacePositions()
    end
    loadSceneTransition()
    after(150, function() storyboard:gotoScene("scenes.play-zone", {effect="fade", time=500}) end)
    return true
end


function hud:nextLevel()
    play(sounds.gameStart)
    loadSceneTransition()
    
    -- Race - save the updated race positions since plaer landed
    if state.data.gameSelected == gameTypeRace then
        self:saveUpdatedRacePositions()
    end

    after(1000, function()
        -- check if completed last zone, if so go to the outro scene
        if state.data.zoneSelected == #hud.level.planetDetails.zones then
            state.data.zoneSelected = "-outro"
            storyboard:gotoScene("scenes.cutscene", {effect="fade"})
        else
            state.data.zoneSelected = state.data.zoneSelected + 1
            storyboard:gotoScene("scenes.play-zone", {effect="fade"})
        end
    end)
    return true
end


function hud:setStartZoneStats()
    self.startStats = {
        zones   = state:numberZonesCompleted(),
        stars   = state:planetStarRanking(),
        fuzzies = state:numberFuzziesCollected(),
        awards  = state:numberAwardsCollected(),
    }
end


function hud:saveLevelScore()
    self.finalScore = self.jumpScore + self.timeScore + self.collectScore
    self.ranking    = self:rankPlayerStars()
    self.awards     = self:calculateAwards()
    
    local jumpScores = {}
    local zoneNumber = state.data.zoneSelected
    local ledges     = self.level.ledges.items
    local num        = #ledges

    for i=1,num do
        local ledge = ledges[i]
        if ledge and ledge ~= -1 and ledge.score > 0 then
            jumpScores[ledge.id] = ledge.score
        end
    end

    state:completeZone(
        zoneNumber,
        self.finalScore, 
        self.ranking, 
        self.awards, 
        self.fuzzyKeys,
        jumpScores, 
        self.raceCompletedAs,
        self.infiniteStage,
        self.ledgePosition
    )

    -- If the current game type is STORY mode, then unlock this zone for all other game modes, which player has unlocked
    if state.data.gameSelected == gameTypeStory then
        local planetSpec   = self.level.planetDetails
        self.unlockedItems = state:completeZoneUnlockCheck(zoneNumber, planetSpec.gameUnlocks, planetSpec.unlockFriend)
    end
end


function hud:saveLevelCubes()
    local cubesForRings = 0
    local ringGroup     = self.level.collectables.rings
    local game          = state.data.gameSelected

    for color=1, #ringValues do
        local num = hud:rings(color)
        if num > 0 then
            cubesForRings = cubesForRings + (num * ringValues[color].cubes)
        end
    end

    local zone = state:currentZone()
    if zone then
        self.holocubes = self.holocubes + math_floor(cubesForRings / zone.plays)
    else
        self.holocubes = self.holocubes + cubesForRings
    end

    -- Some extra game modes have a blanket reward
    if challengeGameType[game] then
        -- only award the cubes on the first time the zone is completed for the challenge
        if zone.plays == 1 then
            self.holocubes = self.holocubes + 5
        end
    elseif game == gameTypeTimeRunner then
        -- Time Runner - reward 1 cube for each stage reached beyond 2
        if self.infiniteStage > 2 then
            self.holocubes = self.holocubes + (self.infiniteStage - 2)
        end
    end

    if self.holocubes > 0 then
        state:addHolocubes(self.holocubes)
    end
end


function hud:rankPlayerStars()
    -- Time Runner & Climb Chaser: rank based on the stage they get to
    local game = state.data.gameSelected

    if game == gameTypeTimeRunner then
        return self.infiniteStage - 1
    elseif game == gameTypeClimbChase then
        return self.infiniteStage
    else
        return self:rankPlayerStoryMode()
    end
end


-- Calculate how many stars to award the player: return number of stars to award. Zone ranking:
-- 1 for completing the level with at least 1 point
-- extra 1 for getting >= 50% rings
-- extra 1 for getting >= 90% rings
-- extra 1 for getting >= 25% jump score
-- extra 1 for getting >= 50% jump score
function hud:rankPlayerStoryMode()
    local jumpScore = self.jumpScore
    local ringScore = self.collectScore

    -- give them no scores for no score at all (possible cheat with gear or bodge)
    if jumpScore <= 0 and ringScore <= 0 then
        return 0
    end

    local stars        = 1
    local maxJumpScore = 0
    local maxRingScore = 0
    
    -- calculate total score player could get from ledges
    self.level.ledges:forEach(function(ledge)
        if ledge.points and ledge.type ~= "start" and ledge.type ~= "finish" then
            maxJumpScore = maxJumpScore + ledge.points
        end
    end)

    -- calculate total score player could get from rings
    for color=1, #ringValues do
        local num = hud:rings(color)
        if num > 0 then
            maxRingScore = maxRingScore + (num * ringValues[color].points)
        end
    end

    local jumpPercent = math.ceil((jumpScore / maxJumpScore)*100)
    local ringPercent = math.ceil((ringScore / maxRingScore)*100)

    if jumpPercent >= 50 then
        stars = stars + 2
    elseif jumpPercent >= 25 then
        stars = stars + 1
    end

    if ringPercent >= 90 then
        stars = stars + 2
    elseif ringPercent >= 50 then
        stars = stars + 1
    end

    return stars
end


-- Calculates if the player should reeive any awards and returns an array of them
function hud:calculateAwards()
    local awards    = {}
    local player    = self.player
    local gameType  = state.data.gameSelected
    local allLedges = self.level.ledges.items

    -- 1. Did they get the time bonus
    -- Survival & Inifnite Game - dont allow this award
    if hud.timeCounter > 0 and gameType ~= gameTypeSurvival and not infiniteGameType[gameType] then
        table.insert(awards, awardDefinitions[awardSpeedPro])
    end

    -- 2. Did they get gold digger award: collected everything on the level?
    if hud.ringsCollected == self.collectables.totalCollectables then
        table.insert(awards, awardDefinitions[awardGoldDigger])
    end

    -- 3. Did they get the survivor award: didnt die on the level?
    if not player.hasDied then
        table.insert(awards, awardDefinitions[awardSurvivor])
    end

    -- 4. Did they get pro jumper award: got top jump thrice in a row (first time jump on a ledge only, no repeat jumps)
    if player.maxJumpsInaRow > 2 then
        table.insert(awards, awardDefinitions[awardJumpPro])
    end

    -- 5. Did they get top score on every scorable ledge
    local topScore = true
    for i,ledge in pairs(allLedges) do
        if ledge and ledge ~= -1 and ledge.points and ledge.score < ledge.points then
            topScore = false
            break
        end
    end

    if topScore then
        table.insert(awards, awardDefinitions[awardLedgeMaster])
    end

    -- 6. Did they use a piece of gear from each category successfully
    if player.gearUsed[jump] and player.gearUsed[air] and player.gearUsed[land] then
        table.insert(awards, awardDefinitions[awardGearMonster])
    end

    return awards
end


function hud:racerCompletedZone(racer)
    local model = racer.model
    
    if model then
        self.racePositions[#self.racePositions+1]     = racer
        self.raceCompletedAs[#self.raceCompletedAs+1] = model

        local pos   = #self.raceCompletedAs
        local info  = characterData[model]
        local text  = info.name
        local ledge = self.level.finishLedge
        local x, y  = ledge:x()-200, ledge:topEdge() - 150

        if     pos == 1 then text = "1st "..text
        elseif pos == 2 then text = "2nd "..text
        elseif pos == 3 then text = "3rd "..text end

        local label = newText(nil, text, x, y+(pos*40), 0.6, info.color, "LEFT")
        self.camera:add(label, 2)
        hud.racerRank[#hud.racerRank] = label

        return pos
    end
end


-- As soon as the player lands on the finish ledge we save the state and positions.
-- But, if other AI are yet to finish then we need to save when player exits the scene the most up-to-date positions
function hud:saveUpdatedRacePositions()
    for i=1,3 do
        if self.raceCompletedAs[i] == nil then
            local char = self:getRacerPosition(self.raceCompletedAs)
            if char then
                self.raceCompletedAs[i] = char.model
            end
        end
    end
        
    state:updateZoneRacePositions(state.data.zoneSelected, self.raceCompletedAs)
    state:saveGame()
end


-- if player exits a race level early, we update the zone as if they had failed the race and have to work out where the AI players came
function hud:saveAbortedRacePositions()
    for i=1,2 do
        if self.raceCompletedAs[i] == nil then
            local char = self:getRacerPosition(self.raceCompletedAs)
            if char then
                self.raceCompletedAs[i] = char.model
            end
        end
    end
    -- player is forced to be 3rd
    self.raceCompletedAs[3] = self.player.model
        
    state:saveZoneFailedRace(state.data.zoneSelected, self.raceCompletedAs)
    state:saveGame()
end


-- determines a racers position mid-race, by what ledge they are on
function hud:getRacerPosition(ignoreList)
    local player  = nil
    local ledgeId = 0
    local num     = #self.aiPlayers

    for i=1,num do
        local ai = self.aiPlayers[i]
        if table.indexOf(ignoreList, ai.model) == nil then
            local ledge = ai.attachedLedge
            if ledge == nil then ledge = ai.jumpedFrom end

            if ledge.id > ledgeId then
                ledgeId = ledge.id
                player  = ai
            end
        end
    end

    return player
end
