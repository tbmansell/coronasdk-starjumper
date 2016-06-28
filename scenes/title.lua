local composer = require("composer")
local anim     = require("core.animations")
local recorder = require("core.recorder")
local scene    = composer.newScene()

-- Aliases:
local play = globalSoundPlayer


-- Stop the phone back button from exiting the game
local function sceneKeyEvent(event)
    if event.keyName == "back" and event.phase == "up" then
        return true
    end
end


-- Called when the scene's view does not exist:
function scene:create(event)
    local group  = self.view
    local planet = math.random(1,3)
    
    newBackground(group, "title/title-screen"..planet)

    if globalDebugGame then
        newText(group, "debug version "..globalBuildVersion, 50, 600, 0.5, "red", "LEFT")
    else
        newText(group, "version "..globalBuildVersion, 50, 600, 0.35, "white", "LEFT")
    end

    local options = newImage(group, "title/settings2", 25, 610)
    options:addEventListener("tap", scene.showSettings)

    self.menuX   = 665
    self.menuY   = 370
    self.options = {}
    self.optionSelected = false
    self.userLeaving    = false
    self:newOption("story",     scene.initStoryGame)
    self:newOption("arcade",    scene.initArcadeGame)
    self:newOption("challenge", scene.initChallengeGame)
end


-- Called immediately after scene has moved onscreen:
function scene:show(event)
    if event.phase == "did" then
        self:init()
        self:startMusic()
        self:startAnimations()
        self:startDemoTimer()

        Runtime:addEventListener("key", sceneKeyEvent)
    end
end


function scene:init()
    logAnalyticsStart()
    state:newScene("title")

    globalSceneTransitionGroup:removeSelf()
    globalSceneTransitionGroup = display.newGroup()

    -- Clear initial splash screen if its still here
    if globalSplashScreen then
        globalSplashScreen:removeSelf()
        globalSplashScreen = nil
    end

    state.demoActions = nil
end


function scene:showSettings()
    scene.status        = {}
    scene.optionChanged = false
    scene.userLeaving   = true
    scene.settingsGroup = display.newGroup()

    local settings       = state.data.gameSettings
    local group          = scene.settingsGroup
    local background     = newBackground(group, "title/options-background")
    local bgrImageOption = display.newRect(group, 220, 125, 360, 80)
    local bgrSoundOption = display.newRect(group, 220, 255, 360, 80)
    local musicOption    = display.newRect(group, 740, 125, 360, 80)
    local storyOption    = display.newRect(group, 740, 255, 360, 80)
    local creditOption   = display.newRect(group, 480, 355, 200, 65)

    scene:createSettingStatus("bgrImage", settings.backgroundImages, 360, 120)
    scene:createSettingStatus("bgrSound", settings.backgroundSounds, 360, 255)
    scene:createSettingStatus("music",    settings.music,            880, 120)
    newButton(group, 55, 45, "back", scene.closeSettings)

    bgrImageOption.alpha, bgrSoundOption.alpha, storyOption.alpha, musicOption.alpha, creditOption.alpha = 0.01, 0.01, 0.01, 0.01, 0.01

    background:addEventListener("tap", function() return true end)

    bgrImageOption:addEventListener("tap", function()
        play(sounds.generalClick)
        scene.optionChanged  = true
        settings.backgroundImages = not settings.backgroundImages
        scene:createSettingStatus("bgrImage", settings.backgroundImages, 360, 120)
    end)

    bgrSoundOption:addEventListener("tap", function()
        play(sounds.generalClick)
        scene.optionChanged  = true
        settings.backgroundSounds = not settings.backgroundSounds
        scene:createSettingStatus("bgrSound", settings.backgroundSounds, 360, 255)
    end)

    musicOption:addEventListener("tap", function() 
        play(sounds.generalClick)
        scene.optionChanged = true
        settings.music      = not settings.music
        scene:createSettingStatus("music", settings.music, 880, 120)

        if settings.music then
            state.musicSceneContinue = false
            scene:startMusic()
        else
            audio.fadeOut(0)
        end
    end)

    storyOption:addEventListener("tap", function()
        play(sounds.generalClick)
        state.data.storiesAcknowledged = {}
        state:saveGame()

        play(sounds.shopPurchase)
        scene:displaySettingMessage("all stories and hints will show again", "green")
    end)

    creditOption:addEventListener("tap", function() 
        play(sounds.generalClick)
        scene:rollCredits()
    end)
end


function scene:createSettingStatus(name, status, xpos, ypos)
    if self.status[name] then
        self.status[name]:removeSelf()
    end

    if status then
        self.status[name] = newText(scene.settingsGroup, "on",  xpos, ypos, 0.9, "green")
    else
        self.status[name] = newText(scene.settingsGroup, "off", xpos, ypos, 0.9, "red")
    end
end


function scene:displaySettingMessage(message, color)
    local text = newText(self.settingsGroup, message, 480, 310, 0.8, color, "CENTER")
    local seq  = anim:oustSeq("settingMessage", text, true)
    seq:add("pulse", {time=1000, scale=0.025, expires=3000})
    seq:tran({time=750, scale=0.1, alpha=0})
    seq:start()
end


function scene:rollCredits()
    if not self.creditsRolling then
        self.creditsRolling = true
        self.creditYpos      = 0
        self.creditsGroup    = display.newGroup()
        self.creditsGroup.x  = 0
        self.creditsGroup.y  = contentHeight

        self:addCredit("game programming", true)
        self:addCredit("toby mansell")

        self:addCredit("graphics, animations & sound", true)
        self:addCredit("ian jay")

        self:addCredit("game design and concept", true)
        self:addCredit("ian jay & toby mansell")

        self:addCredit("special thanks to", true)
        self:addCredit("corona labs")
        self:addCredit("esoteric software")
        self:addCredit("x-pressive games")
        self:addCredit("www.freesfx.co.uk")
        self:addCredit("www.shapes4free.com")
        self:addCredit("thesuper.deviantart.com")
        self:addCredit("suziq creations")

        self:addCredit("game bugs", true)
        self:addCredit("toby mansell")

        scene:addCreditImage("hud/player-head-newton", 150)

        self:addCredit("star jumper",          true,  "white", 100)
        self:addCredit("weak sauce games ltd", false, "aqua")
        self:addCredit("2016",                 false, "aqua")

        local seq = anim:oustSeq("credits", self.creditsGroup, true)
        seq:tran({time=60000, y=-2000})
        seq.onComplete = function() scene.creditsRolling = false end
        seq:start()
    end
end


function scene:addCredit(text, title, color, ypos)
    if title then
        self.creditYpos = self.creditYpos + (ypos or 60)
        newText(self.creditsGroup, text, centerX, self.creditYpos, 0.5, color or "yellow", "CENTER")
    else
        self.creditYpos = self.creditYpos + (ypos or 30)
        newText(self.creditsGroup, text, centerX, self.creditYpos, 0.6, color or "white", "CENTER")
    end
end


function scene:addCreditImage(image, ypos)
    self.creditYpos = self.creditYpos + (ypos or 60)
    newImage(self.creditsGroup, "hud/player-head-newton", centerX, self.creditYpos)
end


function scene:closeSettings()
    if scene.optionChanged then
        state:saveGame()
    end

    if scene.creditsGroup then
        anim:destroyQueue("credits")
        scene.creditsGroup:removeSelf()
        scene.creditsGroup = nil
    end

    scene.creditsRolling = false
    scene.settingsGroup:removeSelf()
    scene.settingsGroup = nil
    scene.userLeaving   = false
end


function scene:newOption(name, callback)
    local group  = self.view
    local option = newImage(group, "title/option-"..name, 1400, self.menuY)

    option.initGame = callback
    option.tap      = scene.selectGame
    option:addEventListener("tap", option)

    self.options[#self.options+1] = option
    self.menuY = self.menuY + 80
end


function scene:startMusic()
    -- If music not playing then start it
    if not state.musicSceneContinue and state.data.gameSettings.music then
        state.musicSceneContinue = true
        self.musicChannel = audio.findFreeChannel()
        audio.setVolume(0.5, {channel=self.musicChannel})
        audio.setMaxVolume(0.5, {channel=self.musicChannel})
        play(sounds.tuneTitle, {channel=self.musicChannel, fadein=8000, loops=-1})
    end
end


function scene:startAnimations()
    for i=1, #self.options do
        local option = self.options[i]
        local seq    = anim:chainSeq("menuSlide", option)
        seq:tran({x=scene.menuX, time=250, ease="spring"})

        scene.menuX = scene.menuX + 50
    end

    local logo = newImage(self.view, "title/logo", 670, 130, nil, 0)
    local seq  = anim:oustSeq("logoAppear", logo)
    seq:tran({alpha=1, time=750})
    seq.onComplete = function()
        anim:startQueue("menuSlide")
        scene:displayMenu()
    end

    after(500, function()
        seq:start()
    end)
end


function scene:startDemoTimer()
    after(20000, function()
        if not scene.userLeaving then
            if recorder:loadRandomDemo() then
                loadSceneTransition()
                after(1000, function()
                    if not scene.userLeaving then
                        audio.fadeOut({channel=self.musicChannel, time=1000})
                        composer.gotoScene("scenes.play-zone", {effect="fade", time=500})
                    else
                        recorder:restoreFromDemo()
                    end
                end)
            end
        end
    end)
end


function scene:selectGame(event)
    local option = self

    if not scene.optionSelected then
        scene.optionSelected = true
        scene.userLeaving    = true

        option:initGame()
        scene:activateOption(option)
        scene:changeScene()
    end
end


function scene:initStoryGame()
    state.data.gameSelected = gameTypeStory
    state.data.multiplayer  = false
    scene.nextScene         = "scenes.select-game"
end


function scene:initArcadeGame()
    state.data.gameSelected = gameTypeTimeRunner
    state.data.multiplayer  = false
    scene.nextScene         = "scenes.select-game"
end


function scene:initChallengeGame()
    state.data.gameSelected = gameTypeTimeAttack
    state.data.multiplayer  = false
    scene.nextScene         = "scenes.select-game"
end


function scene:displayMenu()
    local delay = 1000

    for i,option in pairs(scene.options) do
        option.index = i
        after(delay, function()
            if not scene.optionSelected then
                local seq = anim:oustSeq("menuPulse"..i, option)
                seq:add("pulse", {time=1500, scale=0.025})
                seq:start()
            end
        end)

        delay = delay + 1700
    end
end


function scene:activateOption(option)
    anim:destroyQueue("menuPulse"..option.index)

    local seq = anim:oustSeq("menuActivate", option)
    seq:tran({time=250, scale=1.5})
    seq:tran({time=500, scale=0.01})
    seq:start()
end


function scene:changeScene()
    play(sounds.gameStart)

    after(500, function()
        loadSceneTransition()
        after(1000, function()
            composer.gotoScene(scene.nextScene, {effect="fade", time=500})
        end)
    end)
end


-- Called when scene is about to move offscreen:
function scene:hide(event)
    if event.phase == "will" then
        Runtime:removeEventListener("key", sceneKeyEvent)
        anim:destroy()
        track:cancelEventHandles()
        logAnalyticsEnd()

    elseif event.phase == "did" then
        composer.removeScene("scenes.title")
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