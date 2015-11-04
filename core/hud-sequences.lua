local storyboard   = require("storyboard")
local TextCandy    = require("text_candy.lib_text_candy")
local anim         = require("core.animations")
local soundEngine  = require("core.sound-engine")
local messages     = require("core.messages")
local spineStore   = require("level-objects.collections.spine-store")

-- Aliases:
local math_round = math.round
local math_floor = math.floor
local play       = globalSoundPlayer


-- Called when a level starts to display temparary elements before player acts
function hud:startLevelSequence(level, player)
    self:displayMessageLevelStart(level)
    self:startLevelButtons(level)
    self:showGoMarker(level, player)
end


function hud:countDownSequence(startGameCallback, player, level)
    after(1000, function()
        self:countDownStep(1000, "3",   "red")
        self:countDownStep(2000, "2",   "yellow")
        self:countDownStep(3000, "1",   "green")
        self:countDownStep(4000, "go!", "green")
        after(4100, function() startGameCallback(nil, player) end)
    end)
end


function hud:countDownStep(delay, number, color)
    after(delay, function()
        if number == "go!" then
            play(sounds.countHigh)
        else
            play(sounds.countDown)
        end

        local count = newText(nil, number, centerX, 300, 2, color, "CENTER")
        local seq   = anim:oustSeq("raceCountdown", count, true)
        seq:add("flexout", {time=900, scale=2.5, scaleBack=2})
        seq:start()
    end)
end


function hud:displayMessageLevelStart(level)
    local game = state.data.gameSelected

    if game == gameTypeStory then
        local header1 = newText(nil, "zone "..self.level.zoneNumber, 20, 120, 0.01, "grey",  "LEFT")
        local header2 = newText(nil, self.level.data.name,           20, 180, 0.01, "white", "LEFT")
        header1.alpha, header2.alpha = 0, 0
    
        local seq = anim:oustSeq("levelMessage", header1, true)
        seq.target2 = header2
        seq:tran({time=750, delay=500, scale=0.95, alpha=1})
        seq:add("pulse", {time=1000, scale=0.025, expires=3000})
        seq:tran({time=750, scale=0.01})
        seq:start()
    else
        local description = ""
        if     game == gameTypeSurvival    then description = "complete the zone with one life|to earn a cube reward"
        elseif game == gameTypeTimeAttack  then description = "complete the zone within the time limit|with infinite lives|to earn a cube reward"
        elseif game == gameTypeRace        then description = "race your opponents through the zone|win fairly or with foul play"
        elseif game == gameTypeArcadeRacer then description = "race your opponents to the checkpoints|the last one through falls from the race"
        elseif game == gameTypeTimeRunner  then description = "race against time with one life|to see how far you can go|in a forever changing zone"
        elseif game == gameTypeClimbChase  then description = "climb fast to escape danger|but the higher you go|the higher the rewards - when will you quit?" end

        local group = display.newGroup()
        group.alpha = 0

        newImage(group, "select-game/tab-"..gameTypeData[game].icon, centerX, 70, 0.8)
        newImage(group, "hud/start-bar", centerX, 190)
        newText(group, description, centerX, 190, 0.6, "white", "CENTER")

        local seq = anim:oustSeq("levelMessage", group, true)
        seq:tran({time=250, delay=500, alpha=1})
        seq:wait(4000)
        seq:tran({time=500, alpha=0})
        seq:start()
    end
end


function hud:startLevelButtons()
    hud.startedSequenceRan = false
    self.startLevelGroup   = display.newGroup()
    local group            = self.startLevelGroup
    local seq1             = nil

    --local btnExit, btnExitOverlay = hud:createButtonExit(group, 0, 700)
    local btnPlayerSelect, btnPlayerSelectOverlay = hud:createButtonPlayerSelect(group, 105, 800)
    local btnShop, btnShopOverlay = hud:createButtonShop(group, 305, 800)

    -- Race - dont allow use of shop or character select
    if state.data.gameSelected == gameTypeRace then
        seq1 = anim:chainSeq("startLevelButtons", btnShop)
        seq1.target2 = btnShopOverlay
        seq1:tran({time=250, y=475, ease=easing.inOutCirc})
        seq1:add("pulse", {time=1500, scale=0.05, baseScale=1})
    else
        seq1 = anim:chainSeq("startLevelButtons", btnPlayerSelect)
        seq1.target2 = btnPlayerSelectOverlay
        seq1:wait(500)
        seq1:tran({time=250, y=475, ease=easing.inOutCirc})

        local seq2 = anim:chainSeq("startLevelButtons", btnShop)
        seq2.target2 = btnShopOverlay
        seq2:tran({time=250, y=475, ease=easing.inOutCirc})
        seq2:add("pulse", {time=1500, scale=0.05, baseScale=1})
    end

    seq1:start()
end


function hud:showGoMarker(level, player)
    local flip      = false
    local nextLedge = level:getLedge(2)

    if nextLedge:x() < 0 then 
        flip = true
        player:changeDirection()
    end

    spineStore:showStartMarker(self.camera, player:x()+25, player:y()-75, flip)
end


-- Called when player first starts to remove temporary elements from startLevelSequence()
function hud:levelStartedSequence()
    if not hud.startedSequenceRan then
        hud.startedSequenceRan = true

        local seq = anim:chainSeq("startLevelButtons", hud.startLevelGroup, true)
        seq:tran({time=250, y=900, ease=easing.inOutCirc})

        -- get rid of the start message:
        anim:destroyQueue("levelMessage")
        seq:start()
        
        spineStore:hideStartMarker(self.camera)
    end
end


-- Called when end of level FAILED as run out of lives
function hud:levelFailedSequence(skipProgressBar, passGuard)
    if not passGuard and (state.data.game == levelOverFailed or state.data.game == levelOverComplete) then
        print("WARNING: double fail sequence attmpted")
        return
    end

    local self = hud
    local game = state.data.gameSelected

    -- Time Runner - always goes to failed, but switch to success if they got to 2nd stage:
    if game == gameTypeTimeRunner then
        if self.infiniteStage > 1 then
            return self:levelCompleteSequence(true)
        end
    end

    state.data.game = levelOverFailed

    self.level:stopSpecialFeatures()
    soundEngine:stopBackgroundSounds()

    if self.timerHandle then timer.cancel(self.timerHandle) end
	-- ensure weve got rid of the start sequence in-case they die without doing anything
	self:levelStartedSequence()

    -- Race - show failed sequence
    if game == gameTypeRace then
        state:saveZoneFailedRace(state.data.zoneSelected, self.raceCompletedAs)
    end
    
    state:saveGame()
    
    self:hideGameHud()
    self:endLevelBasics(false)
    self:endLevelTip()
    self:endLevelCollectables(false)
    self:endLevelButtons(false)

    if not infiniteGameType[game] then 
        self:endLevelProgress() 
    end

    self:endLevelSequenceStart()
end


-- Called when end of level COMPLETED as reached finish ledge
function hud:levelCompleteSequence(passGuard)
    if not passGuard and (state.data.game == levelOverFailed or state.data.game == levelOverComplete) then
        print("WARNING: double success sequence attmpted")
        return
    end

    state.data.game = levelOverComplete

    local game = state.data.gameSelected

    -- Race Games - Check if they lost the race and then make them fail
    if raceGameType[game] or hud.level.data.aiRace then
        hud:racerCompletedZone(hud.player)

        if not hud:playerIsWinner() then
            hud:raceWinnerSequence()
            return hud:levelFailedSequence(true, true)
        end
    end

    hud.level:stopSpecialFeatures()
    soundEngine:stopBackgroundSounds()
    
    if hud.timerHandle then timer.cancel(hud.timerHandle) end
    play(sounds.levelComplete)

    hud:setStartZoneStats()
    hud:saveLevelScore()
    hud:saveLevelCubes()
    state:saveGame()
    
    -- Kick off level end sequence    
    after(1000,function()
        hud:hideGameHud()
        hud:endLevelBasics(true)

        if game == gameTypeStory then
            hud:endLevelProgressSummary()
        end

        hud:endLevelCollectables(true)

        if game == gameTypeStory then
            hud:endLevelUpdateProgress()
            hud:endLevelShowUnlocks()
        end

        hud:endLevelButtons(true)
        hud:endLevelSequenceStart()
    end)
end


function hud:playerIsWinner()
    return self.racePositions[1].key == self.player.key
end


function hud:raceWinnerSequence()
    local winner = self.racePositions[1]
    
    if winner.isBossShip then
        if winner.loseAction == "fliesOff" then
            winner:loop("Standard")
            winner:moveNow({pattern={{2000,-2000}}, speed=2, pause=0, oneWay=true})
            winner.racer = false  -- do this so we dont re-trigger the end of level sequence
        end
    elseif winner.isPlayer and winner.ai then
        local player = hud.player

        if player:x() < winner:x() then
            winner:changeDirection()
        else
            player:changeDirection()
        end

        after(2000, function()
            self:characterEndSequence(player, 1)
            self:characterEndSequence(winner, 3)
        end)
    end
end


function hud:playerCompletedSequence()
    local player = hud.player
    local rank   = hud.ranking

    if self.level.data.aiRace then
        self:characterEndSequence(player, 4)

        for i=2, #self.racePositions do
            local ai = self.racePositions[i]
            self:characterEndSequence(ai, 1)
        end
    else
        self:characterEndSequence(player, rank)
    end
end


function hud:characterEndSequence(character, sequenceNumber)
    if sequenceNumber == 1 then
        character:animate("1 2 Stars")
    elseif sequenceNumber == 2 then
        character:crouch()
    elseif sequenceNumber == 3 then
        character:animate("3 4 Stars")
    elseif sequenceNumber == 4 then
        character:animate("3 4 Stars")
        after(1500, function()
            character:changeDirection()
            character:animate("3 4 Stars")
        end)
    elseif sequenceNumber == 5 then
        character:changeDirection()
        character:loop("5 Stars")

        local curX = character:x()
        transition.to(character.image, {x=curX+150, time=3000})
        after(3000, function() character:stand() end)
    end
end


function hud:endLevelSequenceStart()
    anim:startQueue("endLevel")
    anim:startQueue("endLevelTitle")
end


function hud:endLevelBasics(success)
    anim:destroyQueue("levelMessage")
    
    hud.endLevelGroup = display.newGroup()
    local gameType    = state.data.gameSelected
    local group       = hud.endLevelGroup
    local bgr         = newBlocker(hud.endLevelGroup)
    local sidebar     = newImage(group, "hud/sidebar", -500, centerY, nil, 0.9)
    local rightCenter = 640
    local titleYpos   = 60
    local retryText   = nil
    local titleText   = nil

    if gameType ~= gameTypeStory then
        newImage(group, "select-game/tab-"..gameTypeData[gameType].icon, rightCenter, 60, 0.8)
        titleYpos = 140
    end

    if success then
        local text = "zone "..state.data.zoneSelected.." completed"
        -- Time Runner & Climb Chase - show stage reached
        if     gameType == gameTypeTimeRunner then text = "reached stage "..hud.infiniteStage
        elseif gameType == gameTypeClimbChase then text = "escaped at stage "..hud.infiniteStage end

        titleText = newText(group, text, rightCenter, titleYpos, 1, "yellow", "CENTER")

        local zone = state:currentZone()
        if zone and zone.plays > 1 then
            retryText = newText(group, "retry: "..zone.plays-1, rightCenter, titleYpos+160, 0.7, "purple", "CENTER")
        end
    else
        local text = "zone "..state.data.zoneSelected.." failed"
        if gameType == gameTypeTimeRunner then text = "failed" end

        titleText = newText(group, text, rightCenter, titleYpos, 1, "red", "CENTER")
    end

    titleText:scale(0.1, 0.1)
    titleText.alpha = 0

    local seqTitle = anim:chainSeq("endLevelTitle", titleText)
    seqTitle:tran({time=300, scale=1.3, alpha=1})
    seqTitle:add("pulse", {time=2000, scale=0.03, baseScale=1.15})

    local seq1 = anim:chainSeq("endLevel", sidebar)
    seq1:tran({time=300, x=155, ease=easing.inOutCirc})
end


function hud:endLevelProgressSummary()
    local group = display.newGroup()
    newImage(group, "hud/progress-summary", 0, 0)

    self.progressSummaryZones   = newText(group, hud.startStats.zones,   -185, -10, 0.7, "white", "LEFT")
    self.progressSummaryStars   = newText(group, hud.startStats.stars,   -65,  -10, 0.7, "white", "LEFT")
    self.progressSummaryFuzzies = newText(group, hud.startStats.fuzzies, 50,   -10, 0.7, "white", "LEFT")
    self.progressSummaryAwards  = newText(group, hud.startStats.awards,  175,  -10, 0.7, "white", "LEFT")

    group.x, group.y = 650, 800
    hud.endLevelGroup:insert(group)

    local seq = anim:chainSeq("endLevel", group)
    seq:tran({time=300, y=450, ease=easing.inOutCirc})
end


function hud:endLevelButtons(success)
    local group = hud.endLevelGroup
    local game  = state.data.gameSelected

    local btnExit,   btnExitOverlay   = self:createButtonExit(group,   450, 800)
    local btnReplay, btnReplayOverlay = self:createButtonReplay(group, 650, 800)

    local seq2 = anim:chainSeq("endLevel", btnExit)
    seq2.target2 = btnExitOverlay
    seq2:tran({time=150, y=575, ease=easing.inOutCirc})

    local seq3 = anim:chainSeq("endLevel", btnReplay)
    seq3.target2 = btnReplayOverlay
    seq3:tran({time=150, y=575, ease=easing.inOutCirc})

    -- Infinite Games - dont show next levelbutton
    if success and not infiniteGameType[game] then
        -- only show next button if next zone is playable OR we are in story mode (as this takes us to outro sequence)
        local zoneState = state:zoneState(state.data.zoneSelected + 1)

        if game == gameTypeStory or (zoneState ~= nil and zoneState.playable) then
            local btnNext, btnNextOverlay = self:createButtonNext(group, 850, 800)
            local seq4   = anim:chainSeq("endLevel", btnNext)
            seq4.target2 = btnNextOverlay
            seq4:tran({time=150, y=575, ease=easing.inOutCirc})

            local seq5   = anim:chainSeq("buttonPulse", btnNext)
            seq5.target2 = btnNextOverlay
            seq5:add("pulse", {time=1500, scale=0.05})
            seq5:start()
        end
    else
        local btnShop, btnShopOverlay = self:createButtonShop(group, 850, 800)
        local seq4   = anim:chainSeq("endLevel", btnShop)
        seq4.target2 = btnShopOverlay
        seq4:tran({time=150, y=575, ease=easing.inOutCirc})

        local seq5   = anim:chainSeq("buttonPulse", btnShop)
        seq5.target2 = btnShopOverlay
        seq5:add("pulse", {time=1500, scale=0.05})
        seq5:start()
    end
end


function hud:endLevelTip()
    hud.tipShop = newText(hud.endLevelGroup, "access the shop to buy helpful equipment", 650, 460, 0.5, "pink", "CENTER", 2000)

    local effect = {
        startNow = true,
        loop = true,
        restartOnChange = true,
        restoreOnComplete = false,

        inDelay = 0,
        inCharDelay = 40,
        inMode = "LEFT_RIGHT",
        AnimateFrom = { alpha=0, xScale=0.5, yScale=0.5, time=2000 },

        outDelay = 0,
        outCharDelay = 40,
        outMode = "RIGHT_LEFT",
        AnimateTo = { alpha=0, xScale=0.5, yScale=0.5, time=2000 },
    }

    hud.tipShop:applyInOutTransition(effect)
end


function hud:endLevelProgress()
    local group = display.newGroup()
    hud.endLevelGroup:insert(group)
    group.alpha = 0
    
    local labelProgress = newText(group, "completed:", 560, 220, 1, "white")
    local textProgress  = newText(group, "0%",         770, 220, 1, "red")
    
    local completed = math_round(((self.player.highestLedgeId-1) / (self.level:lastLedgeId()-1)) * 100)
    
    local seq1 = anim:chainSeq("endLevel", group)
    seq1:tran({alpha=1, time=250})

    if completed > 0 then
        local seq2 = anim:chainSeq("endLevel", textProgress)
        seq2:add("countnum", {countFrom=0, countTo=completed, appendText="%"})
    end
end


function hud:endLevelCollectables(success)
    local zone = state:currentZone()
    local gameType = state.data.gameSelected

    self.scoreGroup = display.newGroup()
    self.scoreGroup.alpha = 0

    hud.endLevelGroup:insert(self.scoreGroup)
    hud.endLevelScoreYpos = 300
    
    local valCubes  = newText(self.scoreGroup, "0", 285, 520, 0.8, "white",  "RIGHT")
    local valPoints = newText(self.scoreGroup, "0", 285, 587, 0.8, "yellow", "RIGHT")
    local holoCubes = spineStore:showHoloCube(55, 540, 0.35)

    self.scoreGroup:insert(holoCubes.image)
    
    local seq1 = anim:chainSeq("endLevel", self.scoreGroup)
    seq1:tran({time=250, alpha=1})
    
    -- Jump score
    if hud.jumpScore > 0 then
        local jumpPointRatio, jumpCubeRatio, score = hud.jumpScore, 0, hud.jumpScore
        if zone and zone.plays > 0 then 
            jumpPointRatio = math_floor(jumpPointRatio / zone.plays)
            score = math_floor(score / zone.plays)
        end

        hud:createScoreText(valPoints, valCubes, success, score, "jump bonus", jumpPointRatio, jumpCubeRatio, score)
    end

    -- Rings
    for color=1, #ringValues do
        local num = hud:rings(color)
        if num > 0 then
            hud:createScoreRing(valPoints, valCubes, success, color, num)
        end
    end
    -- Fuzzies
    for color=1, #ringValues do
        local num = hud:fuzzies(color)
        if num > 0 then
            hud:createScoreFuzzy(valPoints, valCubes, success, color, num)
        end
    end

    if success then
        -- Some extra game modes have a blanket reward
        if challengeGameType[gameType] then
            -- only award the cubes on the first time the zone is completed for the challenge
            if zone and zone.plays == 1 then 
                hud:createScoreText(valPoints, valCubes, true, 5, "champion", 0, 1, 1)
            end
        elseif gameType == gameTypeTimeRunner then
            if self.holocubes > 0 then
                hud:createScoreText(valPoints, valCubes, true, self.holocubes*100, "stage bonus", 0, 0.01, 100)
            end
        end

        -- Awards
        local i = 1
        for key,award in pairs(self.awards) do
            hud:createScoreAward(award, i)
            i=i+1
        end

        -- Ranking
        if gameType == gameTypeStory then
            for i=1, self.ranking do
                hud:createScoreStar(i, i==self.ranking)
            end
        end
    end
end


function hud:createScoreText(labelPoints, labelCubes, doScore, quantity, name, pointRatio, cubeRatio, countStep)
    local zone  = state:currentZone()
    local group = self.scoreGroup
    local ypos  = hud.endLevelScoreYpos
    local color = "yellow"

    if name == "jump bonus" then color = "green" end

    local holder       = display.newGroup()
    local itemName     = newText(holder, name,     260, 0, 0.5, color, "RIGHT")
    local itemQuantity = newText(holder, quantity, 0,   0, 0.5, "white", "RIGHT")
    
    itemQuantity.x = 315
    group:insert(holder)
    holder.x, holder.y = -40, -200
    
    local seq1 = anim:chainSeq("endLevel", holder)
    seq1:tran({time=750, y=ypos, playSound=sounds.bounce, playDelay=150, ease="bounce"})
    
    if doScore and quantity > 0 then
        hud:createCountingAnimation(labelPoints, labelCubes, itemQuantity, 265, pointRatio, cubeRatio, 1, countStep)
    end

    hud.endLevelScoreYpos = hud.endLevelScoreYpos - 38
end


function hud:createScoreRing(labelPoints, labelCubes, doScore, color, quantity)
    local group    = self.scoreGroup
    local ypos     = hud.endLevelScoreYpos
    local name     = colorNames[color]
    local numRings = self.level:numRings(color)
    
    local holder       = display.newGroup()
    local ring         = spineStore:showRing(125, 0, color)
    local itemQuantity = newText(holder, quantity,       220, 0, 0.5, "white", "RIGHT")
    local itemTotal    = newText(holder, "/ "..numRings, 245, 0, 0.5, "white", "RIGHT")

    holder:insert(ring.image)
    group:insert(holder)

    holder.x, holder.y = 30, -200
    itemQuantity.x = 185
    
    local seq1 = anim:chainSeq("endLevel", holder)
    seq1:tran({time=750, y=ypos, playSound=sounds.bounce, playDelay=150, ease="bounce"})
    
    if doScore and quantity > 0 then
        local zone    = state:currentZone()
        local divider = 1

        if zone then divider = zone.plays end

        local pointRatio = ringValues[color].points / divider
        local cubeRatio  = ringValues[color].cubes  / divider

        hud:createCountingAnimation(labelPoints, labelCubes, itemQuantity, 95, pointRatio, cubeRatio, 100)
    end

    hud.endLevelScoreYpos = hud.endLevelScoreYpos - 38
end


function hud:createScoreFuzzy(labelPoints, labelCubes, doScore, color, quantity)
    local group        = self.scoreGroup
    local ypos         = hud.endLevelScoreYpos
    local name         = colorNames[color]
    local numFuzzies   = self.level:numFuzzies(color)

    local holder       = display.newGroup()
    local friend       = spineStore:showFuzzy({color=color, x=75, y=15, size=0.2})
    local itemQuantity = newText(holder, quantity,         175, 0,  0.5, "white", "RIGHT")
    local itemTotal    = newText(holder, "/ "..numFuzzies, 195, 0,  0.5, "white", "RIGHT")
    
    holder:insert(friend.image)
    group:insert(holder)

    itemQuantity.x = 135
    holder.x, holder.y = 80, -200
    
    local seq1 = anim:chainSeq("endLevel", holder)
    seq1:tran({time=750, y=ypos, playSound=sounds.bounce, playDelay=150, ease="bounce"})

    hud.endLevelScoreYpos = hud.endLevelScoreYpos - 38
end


function hud:createCountingAnimation(labelPoints, labelCubes, labelQuantity, labelPos, pointRatio, cubeRatio, countDelay, countStep)
    local quantity = tonumber(labelQuantity.text)
    labelQuantity:setText("0")

    local seq1 = anim:chainSeq("endLevel", labelQuantity)
    seq1.target2 = labelPoints
    seq1.target3 = labelCubes
    seq1:wait(200)
    seq1:add("countnum", {
        countFrom=0, countTo=quantity, countStep=countStep or 1, countDelay=countDelay,
        align     = "right",
        align2    = "right",
        align3    = "right",
        ratio2    = pointRatio, 
        ratio3    = cubeRatio,
        xpos      = labelPos, 
        xpos2     = 200,
        xpos3     = 200,
        playSound = soundEngine:getRandomRing()
    })
end


function hud:createScoreAward(award, awardNumber)
    local group    = self.scoreGroup
    local ypos     = hud.endLevelScoreYpos
    local iconName = newText(group, award.name, 210, -100, 0.4, "yellow", "RIGHT")
    local icon     = newImage(group, "hud/award-"..award.icon, 250, -100, 0.6)

    local seq1 = anim:chainSeq("endLevel", iconName)
    seq1.target2 = icon
    seq1:tran({time=750, y=ypos, playSound=sounds.bounce, playDelay=250, ease="bounce"})

    local movey = 385
    local movex = (270-((awardNumber-1)*60))

    if awardNumber > 3 then 
        movey = 440
        movex = (270-((awardNumber-4)*60))
    end

    local seq2 = anim:chainSeq("endLevel", icon)
    seq2:add("flexout", {time=300, scale=1.3, scaleBack=0.6, playSound=sounds.gainAward})
    seq2.onComplete = function()
        -- Move award icon down at same time as name slides away
        local seq = anim:chainSeq("endLevelMoveAward", icon)
        seq:tran({time=400, x=movex, y=movey, ease="spring", playSound=sounds.whoosh})
        seq:start()
    end

    local seq3 = anim:chainSeq("endLevel", iconName, true)
    seq3:tran({time=250, x=-300, ease="bounce", playSound=sounds.whoosh, playDelay=250})
end


function hud:createScoreStar(number, last)
    local game  = state.data.gameSelected
    local group = self.scoreGroup
    local ypos  = 140
    local from  = 590 - (self.ranking * 50)
    local star  = newImage(group, "hud/star-ranking", from + (number*100), ypos, nil, 0)

    local seq = anim:chainSeq("endLevel", star)
    seq:tran({time=400, alpha=1, playSound=sounds.awardStar})

    -- Play player end of level animation after stars displayed
    if last then
        seq.onComplete = function()
            hud:playerCompletedSequence()
        end
    end

    local seqStar = anim:oustSeq("endLevelStar"..number, star, true)
    seqStar:add("pulse", {time=2000, scale=0.03, baseScale=1, delay=number*100})
    seqStar:start()
end


function hud:endLevelUpdateProgress()
    local startZones   = self.startStats.zones
    local startStars   = self.startStats.stars
    local startFuzzies = self.startStats.fuzzies
    local startAwards  = self.startStats.awards
    local newZones     = state:numberZonesCompleted()
    local newStars     = state:planetStarRanking()
    local newFuzzies   = state:numberFuzziesCollected()
    local newAwards    = state:numberAwardsCollected()

    if startZones < newZones then
        self:endLevelUpdateStat(startZones, newZones, self.progressSummaryZones, sounds.progress)
    end
    
    if startStars < newStars then
        self:endLevelUpdateStat(startStars, newStars, self.progressSummaryStars, sounds.progress)
    end

    if startFuzzies < newFuzzies then
        self:endLevelUpdateStat(startFuzzies, newFuzzies, self.progressSummaryFuzzies, sounds.progress)
    end
    
    if startAwards < newAwards then
        self:endLevelUpdateStat(startAwards, newAwards, self.progressSummaryAwards, sounds.progress)
    end
end


function hud:endLevelUpdateStat(start, new, label, sound)
    local seq = anim:chainSeq("endLevel", label)

    for i=start+1, new do
        seq:callback(function() label:setText(i) end)
        seq:add("flexout", {time=150, scale=1.3, scaleBack=0.6, playSound=sound})
    end
end


function hud:endLevelShowUnlocks()
    for _,unlock in pairs(self.unlockedItems) do
        local type  = unlock[1]
        local value = unlock[2]

        if type ~= "zone" then
            local group = display.newGroup()
            group.alpha = 0
            group.x, group.y = 650, 350

            if type == "gear" then
                local category = gearSlots[value]
                local name     = messages["gear"][category][value][1]
                newImage(group, "collectables/gear-"..gearNames[category].."-"..value, 0, 0)
                newText(group, "unlocked equipment!", 0, -20, 0.5, "green",  "CENTER")
                newText(group, name,                  0, 20,  0.5, "yellow", "CENTER")

            elseif type == "game" then
                newImage(group, "select-game/tab-"..gameTypeData[value].icon, 0, 0)
                newText(group, "unlocked game mode!", 0, -80, 0.5, "green",  "CENTER")

            elseif type == "planet" then
                newImage(group, "select-game/tab-planet"..value, 0, 0)
                newText(group, "unlocked planet!",     -45, -20, 0.5, "green",  "CENTER")
                newText(group, planetData[value].name, -45, 20,  0.5, "yellow", "CENTER")

            elseif type == "character" then
                local name = characterData[value].name
                newImage(group, "hud/player-head-"..name, 0, 0)
                newText(group, "unlocked character!", 0, -80, 0.5, "green",  "CENTER")
                newText(group, name,                  0, 80,  0.5, "yellow", "CENTER")
            end

            group:scale(0.1, 0.1)
            hud.endLevelGroup:insert(group)

            local seq = anim:chainSeq("endLevel", group)
            seq:add("flexout", {time=1000, scale=1.3, scaleBack=1, playSound=sounds.unlock})
            seq:wait(2000)
            seq:tran({time=250, scale=0.01, alpha=0})
        end
    end
end
