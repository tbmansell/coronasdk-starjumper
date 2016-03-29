local storyboard   = require("storyboard")
local anim         = require("core.animations")
local stories      = require("core.story")
local tutorials    = require("core.tutorial")
local messages     = require("core.messages")
local particles    = require("core.particles")

-- CORE class
local hud = {}

-- Aliases
local math_floor  = math.floor
local math_random = math.random
local play        = globalSoundPlayer


function hud:create(camera, player, level, pauseGameHandler, resumeGameHandler)
    self.camera            = camera
    self.player            = player
    self.level             = level
    self.pauseGameHandler  = pauseGameHandler
    self.resumeGameHandler = resumeGameHandler
    self.group             = display.newGroup()
    
    self:initVars(level)
    self:createGearSelectors()

    self.iconLives         = newImage(self.group, "hud/player-head-"..characterData[state.data.playerModel].name, 45, 45, 0.5)
    self.textLives         = newText(self.group, player.lives,   80,  25, 0.6, "white")
    self.magnifyIcon       = newImage(self.slotsSwitchGroup, "hud/magnify", 920, 590, 0.7)
    self.textTime          = newText(self.group, "--:--",        centerX,  25, 0.8, "white")
    self.textScore         = newText(self.group, self.jumpScore, 940, 25,  0.7, "green", "RIGHT")
    self.textDebugMode     = newText(self.group, "game mode",    750, 25,  0.4, "green")
    self.textPhysicsMode   = newText(self.group, "hide physics", 750, 65,  0.4, "blue")
    self.textScreenshotMode= newText(self.group, "scr",          -30,   590, 0.6, "white")
    self.tip, self.tipShop = nil, nil

    self.textTime:scale(0.5, 0.5)
    self.textTime.alpha = 0
    --self.textDebugMode.alpha      = 0
    --self.textPhysicsMode.alpha    = 0
    self.textScreenshotMode.alpha = 0

    if player.specialAbility then
        self.specialAbilityIcon = newImage(self.group, "hud/special-ability", 90, 60, 0.3)
    end

    self.iconLives:addEventListener("tap",       hud.showPauseMenu)
    self.iconLives:addEventListener("touch",     function() return true end)
    self.magnifyIcon:addEventListener("tap",     hud.triggerMagnifyZone)
    self.magnifyIcon:addEventListener("touch",   function() return true end)
    self.textDebugMode:addEventListener("tap",   hud.switchDebugMode)
    self.textPhysicsMode:addEventListener("tap", hud.switchPhysicsMode)
    self.textScreenshotMode:addEventListener("tap", hud.switchScreenshotMode)

    self:configureForGame()
    self:configureForDemo()
end


-- Init the internal data the HUD keeps about the current game
function hud:initVars(level)
    self.debugMode          = false
    self.physicsMode        = false
    self.time               = os.date('*t')
    self.jumpScore          = 0
    self.timeScore          = 0
    self.collectScore       = 0
    self.finalScore         = 0
    self.ranking            = 0
    self.holocubes          = 0
    self.infiniteStage      = 1
    self.ledgePosition      = 0
    self.awards             = {}
    self.fuzzyKeys          = {}
    self.racePositions      = {}
    self.arcadeRacePositions= {}
    self.raceCompletedAs    = {}
    self.racerRank          = {}
    self.keyIcons           = {}
    self.notifications      = {}
    self.ringsCollected     = 0
    self.fuzziesCollected   = 0
    self.collectables       = {
        rings   = {},
        fuzzies = {}
    }

    for color=1, #ringValues do
        self.collectables.rings[color] = 0
        self.collectables.fuzzies[color] = 0
    end

    self.time.min, self.time.sec, self.timeCounter = level:getTimeBonus()

    self.slotPositions = {
        [jump]     = {gearTrajectory, gearSpringShoes, gearShield,      gearFreezeTime},
        [air]      = {gearParachute,  gearJetpack,     gearGlider,      gearReverseJump},
        [land]     = {gearGloves,     gearGrappleHook, gearDestroyer,   gearMagnet},
        [negGood]  = {negTrajectory,  negRocket,       negFreezeTarget, negImpactBomb},
        [negEnemy] = {negGravField,   negTimeBomb,     negElectrifier,  negBackPorter},
    }

    self.activeGear = {[jump]=nil, [air]=nil, [land]=nil, [negGood]=nil, [negEnemy]=nil}

    -- We keep track of gear collected in-level: if player doesnt complete the level, they lose it
    -- As gear is used, it's moved from here first, so that gear found in-level gets used up before others
    self.gearFoundInLevel = {}
end


function hud:configureForGame()
    local game = state.data.gameSelected

    if infiniteGameType[game] then
        self:createInfiniteDisplay()
    end

    if game == gameTypeSurvival then
        -- Survival - Dont use timer for these modes
        self.challengeIcon = newImage(self.group, "hud/award-survivor", 120, 40, 0.8)
        self.textLives.alpha = 0
    elseif game == gameTypeTimeAttack then
        -- Time Attack - show symbol for #lives, largen timer
        self.challengeIcon = newImage(self.group, "hud/award-speedpro", centerX+120, 45, 0.8)
        self.textLives:setText("!")
        self.textTime.y = 45
        self.textTime:scale(2, 2)
    elseif game == gameTypeTimeRunner then
        -- Time Runner - show symbol for #lives, largen timer
        self.textLives:setText("!")
        self.textTime.y = 120
        self.textTime:scale(2, 2)
    elseif game == gameTypeClimbChase then
        -- Climb Chase - show symbol for #lives, dont show timer
        self.textLives:setText("!")
    elseif game == gameTypeRace or game == gameTypeArcadeRacer then
        -- Race - show symbol for lives hide jump timer
        self.textLives:setText("!")

        local category = negGood
        if characterData[self.player.model].enemy then category = negEnemy end

        self:createNegableSelectors(category)

        if game == gameTypeArcadeRacer then
            self.textLives.alpha = 0
        end
    end
end


function hud:configureForDemo()
    if state.demoActions then
        self.iconLives.alpha          = 0
        self.textLives.alpha          = 0
        self.textScore.alpha          = 0
        self.textDebugMode.alpha      = 0
        self.textPhysicsMode.alpha    = 0
        self.magnifyIcon.alpha        = 0
        self.textScreenshotMode.alpha = 0
    end
end


function hud:createInfiniteDisplay()
    local game = state.data.gameSelected

    self.irunGroup     = display.newGroup()
    local logo         = newImage(self.irunGroup, "hud/"..gameTypeData[game].icon.."-hud", centerX, 50)
    local label1       = newText(self.irunGroup, "stage", centerX-70, 70, 0.4, "yellow", "CENTER")
    local labal2       = newText(self.irunGroup, "ledge", centerX+70, 70, 0.4, "white",  "CENTER")
    self.stagePosition = newText(self.irunGroup, "1",     centerX-70, 33, 0.6, "yellow", "CENTER")
    self.ledgesCovered = newText(self.irunGroup, "1",     centerX+70, 33, 0.6, "white",  "CENTER")

    if game == gameTypeArcadeRacer then
        label2:setText("pos")
        self.ledgesCovered = "-"
    end

    self.group:insert(self.irunGroup)
    self.irunGroup.alpha = 0
end


function hud:destroy()
    if hud.timerHandle then timer.cancel(hud.timerHandle) end

    hud:removeJetpackFuel()
    hud:removeKeyCollected()

    for i=1,#hud.racerRank do
        hud.racerRank[i]:removeSelf()
        hud.racerRank[i] = nil
    end

    if hud.tip     then hud.tip:removeInOutTransition(); hud.tip:removeSelf(); hud.tip=nil end
    if hud.tipShop then hud.tipShop:removeInOutTransition(); hud.tipShop:removeSelf(); hud.tipShop=nil end

    if hud.pauseMenu          then hud.pauseMenu:removeSelf();          hud.pauseMenu=nil end
    if hud.slotsGroup         then hud.slotsGroup:removeSelf();         hud.slotsGroup=nil end
    if hud.gearPopup          then hud.gearPopup:removeSelf();          hud.gearPopup=nil end
    if hud.endLevelGroup      then hud.endLevelGroup:removeSelf();      hud.endLevelGroup=nil end
    if hud.slotsSelectedGroup then hud.slotsSelectedGroup:removeSelf(); hud.slotsSelectedGroup = nil end
    if hud.slotsSwitchGroup   then hud.slotsSwitchGroup:removeSelf();   hud.slotsSwitchGroup=nil end
    if hud.slotsNegaGroup     then hud.slotsNegaGroup:removeSelf();     hud.slotsNegaGroup=nil end

    if not hud.startedSequenceRan and hud.startLevelGroup then
        hud.startLevelGroup:removeSelf()
        hud.startedSequenceRan = true
    end

    hud.group:removeSelf()
    hud.group               = nil
    hud.pauseGameHandler    = nil
    hud.resumeGameHandler   = nil
    hud.camera              = nil
    hud.player              = nil
    hud.level               = nil
    hud.racePositions       = nil
    hud.raceCompletedAs     = nil
    hud.collectables        = nil
    hud.awards              = nil
    hud.fuzzyKeys           = nil
    hud.racePositions       = nil
    hud.slotPositions       = nil
    hud.gearSelectors       = nil
    hud.gearSelectorsDirect = nil
    hud.gearFoundInLevel    = nil
    self.textLives          = nil
    self.textDebugPlayer    = nil
    self.irunGroup          = nil
    self.stagePosition      = nil
    self.ledgesCovered      = nil
    self.challengeIcon      = nil
end


function hud:pauseGame()
    if hud.timerHandle then timer.pause(hud.timerHandle) end
    hud.pauseGameHandler()
end

function hud:resumeGame(gameState)
    hud.resumeGameHandler(nil, gameState)
    if hud.timerHandle then timer.resume(hud.timerHandle) end
end


function hud:showPauseMenu()
    if state.data.game == levelPlaying then
        hud:pauseGame()

        hud.pauseMenu = display.newGroup()
        newBlocker(hud.pauseMenu, 0.8, 0,0,0, hud.resumeGameFromPauseMenu, "block")
        
        local heading = newText(hud.pauseMenu, "game paused", 480, 100, 0.1, "white")
        local info    = newText(hud.pauseMenu, "(tap background to resume zone "..state.data.zoneSelected..")", 490, 500, 0.5, "green", "CENTER")
        heading.alpha = 0

        local seq = anim:chainSeq("pauseMenu", heading)
        seq:tran({time=150, scale=1.5, alpha=1})
        seq:add("pulse", {time=2000, scale=0.03})
        seq:start()

        if hud.startLevelGroup ~= nil then
            hud.startLevelGroup.alpha = 0
        end

        hud:createButtonExit(hud.pauseMenu,   380, 230)
        hud:createButtonReplay(hud.pauseMenu, 600, 230)
    end
    return true
end


function hud:resumeGameFromPauseMenu()
    if hud.pauseMenu then
        hud.pauseMenu:removeSelf()
        hud.pauseMenu = nil
    end

    hud:resumeGame()

    if hud.startLevelGroup ~= nil then
        hud.startLevelGroup.alpha = 1
    end
    return true
end


function hud:triggerMagnifyZone()
    hud.camera:scale(hud.magnifyZone)
end


function hud:magnifyZone()
    -- if any players are walking or running on a ledge, stop them
    local playerState = hud.player.mode
    if playerState == playerWalk or playerState == playerRun then
        hud.player:stand()
    end

    hud.level:scaleAll(hud.camera)

    if hud.goMarker then
        hud.goMarker:scale(hud.camera)
    end
end


function hud:removeLife(player)
    if state.data.gameSelected == gameTypeStory then
        if player.lives > 0 then
            self.textLives:setText(player.lives)
        else
            self.textLives:setText("")
        end
    end
end


function hud:collect(item)
    if     item.isRing      then self:collectRing(item)
    elseif item.isFuzzy     then self:collectFuzzy(item)
    elseif item.isGear      then self:collectGear(item)
    elseif item.isNegable   then self:collectNegable(item)
    elseif item.isKey       then self:collectKey(item)
    elseif item.isTimeBonus then self:collectTimeBonus(item) end
end


function hud:collectRing(item)
    self.collectables.rings[item.type] = self.collectables.rings[item.type] + 1
    self.ringsCollected = self.ringsCollected + 1
    self.collectScore   = self.collectScore   + ringValues[item.color].points
    
    item:emit("collect-ring")
    item:collect(self.camera)
end


function hud:collectFuzzy(item)
    self.collectables.fuzzies[item.colorCode] = self.collectables.fuzzies[item.colorCode] + 1
    self.fuzziesCollected    = self.fuzziesCollected + 1
    self.fuzzyKeys[item.key] = {color=item.color, kinetic=item.kinetic, direction=item.direction}

    item:collect(self.camera)

    self:showStory("explain-fuzzy")
end


function hud:collectGear(item)
    item:emit("collect-item")

    if state.demoActions then
        return hud:collectCompleted(item)
    end

    local gotGear = function(item)
        state:addGear(item.slot, item.name)
        hud.gearFoundInLevel[#hud.gearFoundInLevel+1] = item.name
        hud:assignGear(item.name)
        hud:showStory("usegear-"..item.name)
        hud:collectCompleted(item)
    end

    if item.regenerate then
        -- Regenerating gear: dont move it as it gets reset
        gotGear(item)
    else
        -- Normal gear: move it to the HUD
        local xpos = self.gearSelectorsDirect[item.name].x
        local seq  = anim:chainSeq("gearCollected", item.image)
        seq:tran({time=500, x=xpos, y=515})
        seq:callback(function() gotGear(item) end)
        seq:start()
    end
end


function hud:collectNegable(item)
    local seq = anim:chainSeq("negCollected", item.image)
    seq:tran({time=500, x=450, y=515})
    seq:callback(function()
        state:addNegable(item.slot, item.name)

        if state.demoActions == nil then
            hud:assignNegable(item.name)
        end
        
        hud:collectCompleted(item) 
    end)
    seq:start()
end


function hud:collectKey(item)
    item:emit("collect-item")

    -- determine if we need to swap keys and where to put the replaced one BEFORE the sequence in-case player leaves ledge
    local swapKey = hud:getKeySwap(item)

    local seq = anim:chainSeq("keyCollected", item.image)
    seq:tran({time=500, x=140, y=50})
    seq:callback(function()
        local newKey = hud.player:getKey()

        if hud.keyIcon then
            hud.keyIcon:removeSelf()
            swapKey()
        end

        hud.keyIcon = display.newImage(hud.group, "images/collectables/"..item.color.."-key.png", 140, 50)
        hud.keyIcon:scale(0.35, 0.35)
        hud.keyCollected = newKey

        hud:collectCompleted(item)
    end)
    seq:start()
end


function hud:getKeySwap(item)
    if hud.keyCollected then
        local ledge  = item.attachedLedge or hud.player.attachedLedge
        
        return function()
            local player = hud.player

            if ledge == nil then 
                ledge = player.jumpedFrom 
            end
            
            local xpos = ledge:x()
            
            -- Place swapped key just behind the player
            if player.direction == right then
                if player:x() - ledge:leftEdge() > 80 then
                    xpos = ledge:leftEdge() + 50
                else
                    xpos = ledge:rightEdge() - 50
                end
            else
                if ledge:rightEdge() - player:x() > 80 then
                    xpos = ledge:rightEdge() - 50
                else
                    xpos = ledge:rightEdge() + 50
                end
            end

            hud.level:generateKey(xpos, ledge:topEdge()-50, hud.keyCollected)
        end
    end
    return nil
end


function hud:removeKeyCollected()
    if hud.keyIcon then
        hud.keyIcon:removeSelf()
        hud.keyIcon = nil
    end
end


function hud:collectTimeBonus(item)
    item:emit("collect-item")
    
    local seq = anim:chainSeq("timeCollected", item.image)
    seq:tran({time=500, x=450, y=0, xScale=2, yScale=2})
    seq:callback(function() 
        hud:addTime(item.bonus)
        hud:collectCompleted(item) 
    end)
    seq:start()
end


function hud:collectCompleted(item)
    if item.regenerate then
        item:hide()
    else
        item:destroy()
    end
end


function hud:removeKey(color)
    local image = self.keyIcons[color]
    if image then
        image:removeSelf()
        self.keyIcons[color] = nil
    end
end


function hud:lost(item)
    if item.isRing and self.collectables.rings[item.type] > 0 then
        self.player:sound("randomRing")
        self.collectables.rings[item.type] = self.collectables.rings[item.type] - 1
        self.collectScore = self.collectScore - ringValues[item.color].points
    end
end


function hud:rings(color)
    return self.collectables.rings[color]
end


function hud:fuzzies(color)
    return self.collectables.fuzzies[color]
end


function hud:selectCollectedRing()
    for color,quantity in pairs(self.collectables.rings) do
        if quantity > 0 then
            return color
        end
    end
    return nil
end


function hud:addJumpScore(scoreadd)
    hud.jumpScore = hud.jumpScore + scoreadd

    local seq = anim:chainSeq("levelPointsChange", hud.textScore)
    seq:add("countnum", {countTo=hud.jumpScore, countDelay=10, align="right", xpos=940 })
    seq:start()
end


function hud:subJumpScore(scoreadd)
    hud.jumpScore = hud.jumpScore - scoreadd
end


-- Kicks off the timer
function hud:startTimer()
    local game = state.data.gameSelected

    if infiniteGameType[game] then
        self.irunGroup.alpha = 1
    end

    if game == gameTypeStory or game == gameTypeTimeAttack or game == gameTypeTimeRunner then
        local counter = self.timeCounter 

        if     counter < 6  then self.textTime:setColor(100,0,0)
        elseif counter < 16 then self.textTime:setColor(255,0,0)
        elseif counter < 31 then self.textTime:setColor(255,255,0) end

        self.textTime.alpha = 1
        self.timerHandle = timer.performWithDelay(1000, hud.displayTime, 0)
    end
end


-- used for normal game operation
function hud:displayTime()
    local self = hud
    local game = state.data.gameSelected

    if self.timeCounter <= 0 then
        timer.cancel(self.timerHandle)
        self.timerHandle = nil
        self.timeCounter = 0
        self.textTime:setText("00:00")

        -- Time Attack, Timer Runner - fail the game and restart automatically
        if game == gameTypeTimeAttack or game == gameTypeTimeRunner then
            self.player:failedCallback()
        end
    else
        self.time.sec    = self.time.sec    - 1
        self.timeCounter = self.timeCounter - 1
        self.textTime:setText(os.date("%M:%S", os.time(self.time)))

        -- Time Attack, Time Runner - animate and color timer
        if game == gameTypeTimeAttack or game == gameTypeTimeRunner then
            local counter = self.timeCounter 
            if     counter == 5  then self.textTime:setColor(100,0,0)
            elseif counter == 15 then self.textTime:setColor(255,0,0)
            elseif counter == 30 then self.textTime:setColor(255,255,0) end

            if counter == 0 then
                play(sounds.countDown)
            elseif counter <= 5 then
                play(sounds.countHigh)
            end

            local seq = anim:oustSeq("pulseTimer", self.textTime)
            seq:tran({time=100, scale=1.1})
            seq:tran({time=100, scale=1})
            seq:start()
        end
    end
end


function hud:addTime(bonus)
    self.time.sec    = self.time.sec    + bonus
    self.timeCounter = self.timeCounter + bonus
    self.textTime:setText(os.date("%M:%S", os.time(self.time)))
    -- update colors
    local counter = self.timeCounter 
    if     counter > 15 then self.textTime:setColor(255,255,0)
    elseif counter > 5  then self.textTime:setColor(255,0,0)
    else  self.textTime:setColor(100,0,0) end
end


function hud:updateInfiniteStats(ledge, player)
    if self.ledgePosition < ledge.id then
        self.ledgePosition = ledge.id
        self.ledgesCovered:setText(ledge.id)
    end

    if not self.infiniteStage or not ledge.stage then
        return
    end
    
    if self.infiniteStage < ledge.stage then
        play(sounds.awardStar)
        
        self.infiniteStage = ledge.stage
        self.stagePosition:setText(self.infiniteStage)

        local seq = anim:oustSeq("pulseStage", self.stagePosition)
        seq:tran({time=100, scale=0.8})
        seq:tran({time=100, scale=0.6})
        seq:start()
    end
end


-- {[1]={player}, [2]={player}, ...}
function hud:updateInfiniteRace(ledge, player)
    local pos      = (ledge.infinitePosition or 0) * ledge.stage
    local rankings = self.arcadeRacePositions
    local newRank  = {}
    local rank     = 0
    local replaced = false

    player.arcadeRacePosition = pos
    
    for _,racer in pairs(rankings) do
        if racer and racer.model ~= player.model then
            rank = rank + 1
            if not replaced and pos > racer.arcadeRacePosition then
                -- we have a position higher than this existing one
                player.arcadeRaceRank = rank
                newRank[rank] = player
                replaced = true
                rank = rank + 1
            end
            
            racer.arcadeRaceRank = rank
            newRank[rank] = racer
        end
    end

    if not replaced then
        rank = rank + 1
        player.arcadeRaceRank = rank
        newRank[rank] = player
    end

    -- update the players rank in the hud & put the winners indicators on top
    for i=#newRank, 1, -1 do
        local racer = newRank[i]
        if racer.raceIndicator then
            racer.raceIndicator:toFront()
        end

        if racer.model == self.player.model then
            self.ledgesCovered:setText(racePositions[i])
        end
    end

    self.arcadeRacePositions = newRank
end


-- used for when testing zone timebonus
function hud:displayTimeUp()
    local self = hud

    self.time.sec    = self.time.sec    + 1
    self.timeCounter = self.timeCounter + 1
    self.textTime:setText(os.date("%M:%S", os.time(self.time)))
end


function hud:displayMessageJump(what)
    local set = messages["jump"][what]
    self:displayMessage(set[math_random(#set)], good)
end


function hud:displayMessageDied(how)
    local set = messages["died"][how]
    self:displayMessage(set[math_random(#set)], bad)
end


function hud:displayMessage(message, type)
    local game  = state.data.gameSelected
    local color = "purple"
    local ypos  = 110

    if type == good then color="green" elseif type == average then color="yellow" end

    if infiniteGameType[game] then 
        ypos = 140
        if game == gameTypeTimeRunner then ypos = 170 end 
    end

    local text = newText(self.group, message, 480, ypos, 0.8, color, "CENTER")
    local seq  = anim:oustSeq("levelMessage", text, true)
    seq:add("pulse", {time=1000, scale=0.025, expires=3000})
    seq:tran({time=750, scale=0, alpha=0})
    seq:start()
end


function hud:showStory(storyId, postStoryCallback)
    local resumeCallback = postStoryCallback or self.resumeGameHandler

    -- Used for when an ingame script runs a story and then needs to execute more action after
    if postStoryCallback then
        resumeCallback = function(gameState)
            hud:resumeGame(gameState)
            postStoryCallback()
        end
    end

    -- if story not played then make the callback: for this to work accurately the story script needs a 0 delay
    if stories:start(storyId, hud.pauseGame, resumeCallback, hud.notifyStory) == false and postStoryCallback then
        postStoryCallback()
    end
end


function hud:showTutorial(tutorialId)
    if tutorials:start(tutorialId) then
        -- dont allow scaling in tutorial to save placement problems
        self.magnifyIcon.alpha = 0
    end
end


function hud:notifyStory(storyId)
    local self = hud

    -- check to see if this notification already exists and if so dont add the same one
    for i=1, #self.notifications do
        if self.notifications[i].storyId == storyId then
            return false
        end
    end

    local number = #self.notifications+1
    local note   = newImage(self.group, "hud/notification", number*60, 150, 0.5, 0)
    note.number  = number
    note.storyId = storyId

    note:addEventListener("tap", function()
        stories:startNow(note.storyId, hud.pauseGame, function()
            hud.resumeGame()
            hud:removeNotification(note)
        end)
        return true
    end)

    self.notifications[#self.notifications+1] = note
    
    local seq = anim:chainSeq("hudNotification-"..number, note)
    seq:add("flexout", {time=1000, scale=1.3, scaleBack=0.5, playSound=sounds.storyNotification})
    seq:start()
end


function hud:removeNotification(note)
    local seq = anim:chainSeq("hudNotificationBye", note, true)
    seq:tran({time=250, scale=0.01})
    seq:callback(function() table.remove(hud.notifications, note.number) end)

    for i=note.number, #hud.notifications do
        local nextNote = hud.notifications[i]
        if nextNote and nextNote.x then
            local xpos = nextNote.x - 60
            local seq  = anim:chainSeq("hudNotificationBye", nextNote)
            seq:tran({time=150, x=xpos, ease=easing.inOutCirc})
        end
    end

    anim:startQueue("hudNotificationBye")
end


function hud:animateScoreText(scoreadd, scoreCategory, textX, textY)
    local color = "white"
    if     scoreCategory == scoreCategoryFirst  then color = "green"
    elseif scoreCategory == scoreCategorySecond then color = "yellow"
    elseif scoreCategory == scoreCategoryThird  then color = "red" end

    local textScore = newText(nil, scoreadd, textX, textY+15, 1, color, "CENTER")
    
    textScore.alpha = 0
    self.camera:add(textScore, 2)
    
    local seq = anim:chainSeq("jumpScore", textScore, true)
    seq:tran({time=250, alpha=1,  xScale=1.25, yScale=1.25})
    seq:tran({time=750, delay=500, x=hud.textScore.x, y=hud.textScore.y, xScale=0.5, yScale=0.5, transition=easing.inQuad})
    seq:callback(function() hud:addJumpScore(scoreadd) end)
    seq:start()
end


function hud:createButtonExit(group, x, y)
    return newButton(group, x, y, "menu", function() hud:exitZone(); end)
end


function hud:createButtonReplay(group, x, y)
    return newButton(group, x, y, "replay", function() hud:replayLevel() end)
end


function hud:createButtonShop(group, x, y)
    return newButton(group, x, y, "shop", function() hud:exitToShop() end)
end


function hud:createButtonPlayerSelect(group, x, y)
    return newButton(group, x, y, "charselect", function() hud:exitToPlayerSelect() end)
end


function hud:createButtonNext(group, x, y)
    return newButton(group, x, y, "next", function() hud:nextLevel() end)
end


---------- USED AS PROXY FOR PLAYER ----------

function hud:showScoreMarkers(ledge, x)
    self.level:showLedgeScoreMarkers(ledge, x)
end


function hud:hideScoreMarkers()
    self.level:hideLedgeScoreMarkers()
end


function hud:hideSpecialAbility()
    if self.specialAbilityIcon then
        self.specialAbilityIcon.alpha = 0
    end
end


function hud:reset(player)
    if player.main then
        self.level:reset(player)
    elseif player.ai then
        self.level:resetForAi(player)
    end
end


function hud:firstLedge()
    return self.level:getLedge(1)
end


---------- USED FOR INGAME SCRIPTS ----------

function hud:triggerEvent(eventName, player)
    self.level:triggerCustomEvent(eventName, player or self.player, nil)
end


function hud:getTarget(type, name)
    return self.level:getTarget(type, name)
end


function hud:exitScript()
    state.data.game = levelPlaying
    self:scriptMode(false)
end


function hud:showEffect(effect, target, params)
    local spineStore = require("level-objects.collections.spine-store")

    if effect == "explosion" then
        spineStore:showExplosion(hud.camera, target, params)
    end
end


function hud:sequence(type, name, target1, target2, target3)
    local seq = nil
    if type == "oust" then 
        seq = anim:oustSeq(name, target1)
    else
        seq = anim:chainSeq(name, target1)
    end

    if target2 then seq.target2 = target2 end
    if target3 then seq.target3 = target3 end

    return seq
end


return hud