local composer   = require("composer")
local anim         = require("core.animations")
local messages     = require("core.messages")
local builder      = require("level-objects.builders.builder")
local spineStore   = require("level-objects.collections.spine-store")

-- Local vars for performance:
local scene           = composer.newScene()
local spineCollection = nil
local lastTime        = 0

-- list of random actions and their duration to play for
local actions = {
    {name="Walk",                   duration=nil,  exit=nil},
    {name="Run New",                duration=nil,  exit=nil},
    {name="Jump PREPERATION",       duration=nil,  exit="Jump CANCEL",  exitDuration=1500},
    {name="Landing NEAR EDGE",      duration=2000, exit=nil},
    {name="Landing FAR EDGE",       duration=2000, exit=nil},
    {name="Jump LONG",              duration=1000, exit="Landing LONG", exitDuration=2000},
    {name="Powerup LEDGE GLOVES",   duration=2000},
    {name="Powerup ROCKET",         duration=1500},
    {name="Taunt 1",                duration=2000, exit=nil},
    {name="Taunt 2",                duration=2000, exit=nil},
    {name="Taunt 3",                duration=2000, exit=nil},
    {name="Attack GRAB",            duration=2000},
    {name="Attack PUSH",            duration=2000},
    {name="Attack TRIP",            duration=2000},
    {name="Negable THROW PREP",     duration=2000, exit="Negable THROW", exitDuration=1000},
}


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
        scene:exitPlayerSelect()
        return true
    end
end


-- Called when the scene's view does not exist:
function scene:create(event)
    spineCollection = builder:newSpineCollection()
    spineStore:load(spineCollection)

    self:createItems()
end


-- Called immediately after scene has moved onscreen:
function scene:show(event)
    if event.phase == "did" then
        self:init()

        self.animateLoop = timer.performWithDelay(5000, scene.switchAnimation, 0)
        Runtime:addEventListener("enterFrame", sceneEnterFrameEvent)
        Runtime:addEventListener("key", sceneKeyEvent)
    end
end


function scene:init()
    logAnalyticsStart()
    clearSceneTransition()

    -- Dont append this scene in back history if coming from shop - as it should replace it instead
    if state:currentScene() ~= "scenes.shop" then
        state:newScene("select-player")
    end

    self:displayHud()
end


function scene:createItems()
    newBackground(self.view, "select-player/bgr")
    newButton(self.view, 55,  50,  "back",   scene.exitPlayerSelect)
    newButton(self.view, 700, 410, "select", scene.changeToPlayer, "no")

    -- Delays for a moment to give the scene a chance to display before the heavy player loading is done
    self.characters = {}
    self:createPlayerIcons()
    self:createInAppPurchase()

    newText(self.view, "grade:",   670, 185, 0.35, "grey", "LEFT")
    newText(self.view, "home:",    670, 210, 0.35, "grey", "LEFT")
    newText(self.view, "age:",     670, 235, 0.35, "grey", "LEFT")
    newText(self.view, "likes:",   670, 260, 0.35, "grey", "LEFT")
    newText(self.view, "hates:",   670, 285, 0.35, "grey", "LEFT")
    newText(self.view, "ability:", 670, 310, 0.35, "grey", "LEFT")
    newText(self.view, "throws:",  670, 335, 0.35, "grey", "LEFT")
end


function scene:displayHud()
    self.labelCubes, self.labelScore, self.playerIcon = newMenuHud(self.view, spineStore, scene.exitToShop)

    newImage(self.view, "select-player/logo", 250, 601)
    newText(self.view,  "player select", centerX, 590, 1, "white", "CENTER")
end


function scene:createPlayerIcons()
    local pos  = 1
    local xpos = 108
    local ypos = 180

    self.playerModel = state.data.playerModel
    self.slots = {}

    for player=1, #characterData do
        local info = characterData[player]

        if info.playable then
        	local unselected = newImage(self.view, "select-player/head-"..info.name, xpos, ypos)
            local selected   = newImage(self.view, "select-player/head-"..info.name.."-selected", xpos, ypos, nil, 0)

            self.slots[player] = {
                ["selected"]   = selected,
                ["unselected"] = unselected
            }

            if not state:characterUnlocked(player) then
                newImage(self.view, "locking/lock", xpos+20, ypos-15, 0.8, 0.8)
            end

            unselected.playerModel = player

            unselected.tap = function()
                scene:selectPlayer({target=unselected}, true)
            end

            unselected:addEventListener("tap", unselected)
            selected:addEventListener("tap", function() return true end)

            if player == self.playerModel then
                self:selectPlayer({target=unselected}, false)
            end
        
            if pos%3 == 0 then
                xpos = 108
                ypos = ypos + 145 
            else
                xpos = xpos + 145
            end
            pos = pos + 1
        end
    end
end


function scene:createInAppPurchase()
    local inapp = newImage(self.view, "select-player/inapp-purchase", 270, 460)
    inapp:addEventListener("tap", scene.gotoInAppPurchase)

    local seq   = anim:oustSeq("pulseInApp", inapp)
    seq:add("pulse", {time=2000, scale=0.025})
    seq:start()
end


function scene:selectPlayer(event, playSound)
    local self   = scene
    local icon   = event.target
    local player = icon.playerModel
    local char   = characterData[player]
    local person = char.bio

    if playSound then play(sounds.generalClick) end

    if state:characterUnlocked(player) then
        self.slots[self.playerModel]["selected"].alpha = 0
        self.slots[player]["selected"].alpha = 1

        if self.model then
            self.model:hide()
            self.stats:removeSelf()
            sounds:unloadPlayer(self.playerModel)
        end

        -- These sounds stay loaded (unless player exits) for this character to be used instantly when restarting the level
        sounds:loadPlayer(player)

        -- Check if the player model is already loaded and just show it, otherwise load it up
        if self.characters[player] then
            self.characters[player]:visible()
        else
            local character = spineStore:showCharacter({model=player, x=600, y=360, size=0.35})
            self.characters[player] = character
        end
        
        self.playerModel = player
        self.model       = self.characters[player]
        self.stats       = display.newGroup()

        newText(self.stats, char.name,      690, 120, 0.7,  char.color, "CENTER")
        newText(self.stats, person.grade,   755, 185, 0.35, char.color, "LEFT")
        newText(self.stats, person.home,    755, 210, 0.35, char.color, "LEFT")
        newText(self.stats, person.age,     755, 235, 0.35, char.color, "LEFT")
        newText(self.stats, person.likes,   755, 260, 0.35, char.color, "LEFT")
        newText(self.stats, person.hates,   755, 285, 0.35, char.color, "LEFT")
        newText(self.stats, person.ability, 755, 310, 0.35, "red",      "LEFT")
        newText(self.stats, person.throws,  755, 335, 0.35, char.color, "LEFT")
        self.view:insert(self.stats)
    else
        newLockedPopup(self.view, player, "character", char.name)
    end
end


function scene:changeToPlayer()
    play(sounds.sceneEnter)

    state.data.playerModel = scene.playerModel
    state.data.playerSkin  = characterData[scene.playerModel].skin

    loadSceneTransition(1)
    after(10, function() composer.gotoScene(state:backScene()) end)
    return true
end


function scene:switchAnimation()
    local self  = scene
    local model = self.characters[self.playerModel]

    if self.action then
        if self.action.duration == nil then
            if self.action.exit then
                model:animate(self.action.exit)
            end

            after(self.action.exitDuration or 0, function() model:loop("Stationary") end)
            self.action = nil
        end
    else
        self.action = actions[math.random(#actions)]

        if self.action.duration then
            model:animate(self.action.name)

            if self.action.duration then
                after(self.action.duration, function()
                    if self.action.exit then
                        model:animate(self.action.exit)
                        after(self.action.exitDuration or 0, function() 
                            model:loop("Stationary")
                            self.action = nil
                        end)
                    else
                        model:loop("Stationary")
                        self.action = nil
                    end
                end)
            end
        else
            model:loop(self.action.name)
        end
    end
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


function scene:exitPlayerSelect()
    -- restore the original players sounds
    sounds:unloadPlayer(scene.playerModel)
    sounds:loadPlayer(state.data.playerModel)

    loadSceneTransition(1)
    after(10, function() composer.gotoScene(state:backScene()) end)
    return true
end


-- Called when scene is about to move offscreen:
function scene:hide(event)
    if event.phase == "will" then
        audio.fadeOut({channel=self.musicChannel, time=1000})

        Runtime:removeEventListener("enterFrame", sceneEnterFrameEvent)
        Runtime:removeEventListener("key", sceneKeyEvent)
        track:cancelEventHandles()
        timer.cancel(self.animateLoop)

        anim:destroy()
        spineStore:destroy()

        self.stats:removeSelf()
        self.labelCubes:removeSelf()
        self.labelScore:removeSelf()
        self.playerIcon:removeSelf()

        self.model      = nil
        self.labelCubes = nil
        self.labelScore = nil
        self.playerIcon = nil

        if self.infoGroup then
            self.infoGroup:removeSelf()
            self.infoGroup = nil
        end

        -- Save game regardless of how we left the level
        state:saveGame()
        logAnalyticsEnd()

    elseif event.phase == "did" then
        composer.removeScene("scenes.select-player")
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
