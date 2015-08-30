local storyboard = require("storyboard")
local anim       = require("core.animations")
local scene      = storyboard.newScene()

-- Aliases:
local play = realPlayer


-- Called when the scene's view does not exist:
function scene:createScene(event)
    sounds:loadPlayer(state.data.playerModel)
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene(event)
    logAnalytics("title", "enterScene")
    self:initScene()

    local group   = self.view
    local planet  = math.random(1,2)
    
    newImage(group, "title/title-screen"..planet, centerX, centerY)
    newText(group, "version: "..globalBuildVersion, 50, 600, 0.35, "white", "LEFT")

    local options = newImage(group, "title/settings2", 25, 610)
    options:addEventListener("tap", scene.showSettings)

    self.menuX   = 665
    self.menuY   = 370
    self.options = {}
    self.optionSelected = false
    self:newOption("story",     scene.initStoryGame)
    self:newOption("arcade",    scene.initArcadeGame)
    self:newOption("challenge", scene.initChallengeGame)

    self:startMusic()
    self:startAnimations()
end


function scene:initScene()
    state:newScene("title")
    globalSceneTransitionGroup:removeSelf()
    globalSceneTransitionGroup = display.newGroup()

    -- Clear initial splash screen if its still here
    if globalSplashScreen then
        globalSplashScreen:removeSelf()
        globalSplashScreen = nil
    end
end


function scene:showSettings()
    scene.status        = {}
    scene.optionChanged = false
    scene.settingsGroup = display.newGroup()

    local settings      = state.data.gameSettings
    local group         = scene.settingsGroup
    local background    = newImage(group, "title/options-background", centerX, centerY)
    local bgrOption     = display.newRect(group, 220, 125, 360, 80)
    local resetOption   = display.newRect(group, 740, 125, 360, 80)
    local musicOption   = display.newRect(group, 220, 260, 360, 80)
    local advertOption  = display.newRect(group, 740, 260, 360, 80)
    local creditOption  = display.newRect(group, 480, 360, 200, 50)

    scene:createSettingStatus("background", settings.backgrounds, 340, 120)
    scene:createSettingStatus("music",      settings.music,       340, 255)
    scene:createSettingStatus("adverts",    settings.adverts,     855, 255)
    newButton(group, 55, 45, "back", scene.closeSettings)

    bgrOption.alpha, resetOption.alpha, musicOption.alpha, advertOption.alpha, creditOption.alpha = 0.01, 0.01, 0.01, 0.01, 0.01

    background:addEventListener("tap", function() return true end)

    bgrOption:addEventListener("tap", function()
        play(sounds.hudClick)
        scene.optionChanged  = true
        settings.backgrounds = not settings.backgrounds
        scene:createSettingStatus("background", settings.backgrounds, 340, 120)
    end)

    musicOption:addEventListener("tap", function() 
        play(sounds.hudClick)
        scene.optionChanged = true
        settings.music      = not settings.music
        scene:createSettingStatus("music", settings.music, 340, 255)

        if settings.music then
            state.musicSceneContinue = false
            scene:startMusic()
        else
            audio.fadeOut(0)
        end
    end)

    resetOption:addEventListener("tap", function()
        play(sounds.hudClick)
        -- reset levelProgress but keep everything unlocked thats unlocked
        state:resetSavedGame()
        play(sounds.shopPurchase)
        scene:displaySettingMessage("game progress has been reset", "green")
    end)

    advertOption:addEventListener("tap", function() 
        play(sounds.hudClick)
        -- take em to the store
    end)

    creditOption:addEventListener("tap", function() 
        play(sounds.hudClick)
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
    seq:tran({time=750, scale=0, alpha=0})
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
        self:addCredit("toby mansell jnr")

        self:addCredit("graphics, animations & sound", true)
        self:addCredit("ian jay esquire")

        self:addCredit("game design and concept", true)
        self:addCredit("ian jay & toby mansell")
        self:addCredit("brothers in battle")

        self:addCredit("testers and ear lenders", true)
        self:addCredit("gerry costello - vm tester")
        self:addCredit("rhys mansell - game breaker")
        self:addCredit("kevin ray - morale booster")
        self:addCredit("laura nash - opinionator")

        self:addCredit("special thanks to", true)
        self:addCredit("corona labs - technology platform")
        self:addCredit("esoteric software - spine animation tech")
        self:addCredit("x-pressive games - text candy")
        self:addCredit("caleb p - project perspective")
        self:addCredit("dudes who gave us free sound effects")

        self:addCredit("game bugs", true)
        self:addCredit("toby mansell")

        scene:addCreditImage("hud/player-head-newton", 150)

        self:addCredit("star jumpr",           true,  "white", 100)
        self:addCredit("weak sauce games ltd", false, "aqua")
        self:addCredit("2015",                 false, "aqua")

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
end


function scene:newOption(name, callback)
    local group  = self.view
    local option = newImage(group, "title/option-"..name, 1200, self.menuY)

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
        play(sounds.backgroundSoundTitle, {channel=self.musicChannel, fadein=8000, loops=-1})
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


function scene:selectGame(event)
    local option = self

    if not scene.optionSelected then
        scene.optionSelected = true

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
            storyboard:gotoScene(scene.nextScene, {effect="fade", time=500})
        end)
    end)
end


-- Called when scene is about to move offscreen:
function scene:exitScene(event)
    anim:destroy()
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