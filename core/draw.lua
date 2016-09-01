local composer = require("composer")
local TextCandy  = require("text_candy.lib_text_candy")
local anim       = require("core.animations")
local particles  = require("core.particles")

-- local vars:
local sparklSeq  = nil
local goSparkle  = false
local debugPanel = nil
local debugText  = nil


local lockedSparkles = {
    {x=580, y=135}, {x=780, y=135}, {x=660, y=450}, {x=740, y=450}
}

-- Aliases:
local math_round    = math.round
local math_random   = math.random
local play          = globalSoundPlayer
local new_image     = display.newImage
local new_image_rect = display.newImageRect


TextCandy.AddCharsetFromBMF("gamefont_aqua",   "text_candy/ingamefont_aqua.fnt",   32)
TextCandy.AddCharsetFromBMF("gamefont_blue",   "text_candy/ingamefont_blue.fnt",   32)
TextCandy.AddCharsetFromBMF("gamefont_green",  "text_candy/ingamefont_green.fnt",  32)
TextCandy.AddCharsetFromBMF("gamefont_pink",   "text_candy/ingamefont_pink.fnt",   32)
TextCandy.AddCharsetFromBMF("gamefont_purple", "text_candy/ingamefont_purple.fnt", 32)
TextCandy.AddCharsetFromBMF("gamefont_red",    "text_candy/ingamefont_red.fnt",    32)
TextCandy.AddCharsetFromBMF("gamefont_white",  "text_candy/ingamefont_white.fnt",  32)
TextCandy.AddCharsetFromBMF("gamefont_grey",   "text_candy/ingamefont_grey.fnt",   32)
TextCandy.AddCharsetFromBMF("gamefont_yellow", "text_candy/ingamefont_yellow.fnt", 32)
TextCandy.AddCharsetFromBMF("gamefont_black",  "text_candy/ingamefont_black.fnt",  32)


--------------- GLOBAL FUNCTIONS ------------------

function printDate(text)
    print(os.date("%H:%M:%S ")..text)
end


-- handles text generation using text candy
function newText(group, text, x, y, scale, color, align, wrapWidth)
    local font = TextCandy.CreateText({
        fontName    = "gamefont_"..color,
        x           = x,
        y           = y,
        text        = text,
        textFlow    = align,
        fontSize    = size,
        originX     = align,
        originY     = "CENTER",
        wrapWidth   = wrapWidth or nil,
        lineSpacing = 0,
        showOrigin  = false,
        parentGroup = group,
    })

    if scale ~= 1 then
        font:scale(scale,scale)
    end

    return font
end


function animateText(label, onComplete)
    local effect = {
        startNow            = true,
        loop                = true,
        restartOnChange     = true,
        restoreOnComplete   = false,

        inDelay             = 0,
        inCharDelay         = 40,
        inMode              = "LEFT_RIGHT",
        AnimateFrom         = { alpha=0, xScale=0.5, yScale=0.5, time=2000 },

        outDelay            = 0,
        outCharDelay        = 40,
        outMode             = "RIGHT_LEFT",
        AnimateTo           = { alpha=0, xScale=0.5, yScale=0.5, time=2000 },

        CompleteListener    = onComplete
    }

    label:applyInOutTransition(effect)
end


-- handles image generation, using base folder and optional scaling and alpha
function newImage(group, image, x, y, scale, alpha)
    local image = new_image(group, "images/"..image..".png", x, y)

    if scale then image:scale(scale, scale) end
    if alpha then image.alpha = alpha end

    return image
end


-- handles image generation, using base folder and optional scaling and alpha
function newImageRect(group, image, x, y, width, height, scale, alpha)
    local image = new_image_rect(group, "images/"..image..".png", width, height)
    image.x = x
    image.y = y

    if scale then image:scale(scale, scale) end
    if alpha then image.alpha = alpha end

    return image
end


function newBackground(group, image)
    return newImageRect(group, image, centerX, centerY, backgroundWidth, backgroundHeight)
end


-- Creates an area that size of the screen that captures touch/tap events
function newBlocker(group, alpha, r,g,b, onclick, touchEvent)
    -- default to blocking all tap and touch events
    if onclick == nil then 
        onclick = function() return true end
    end

    local rect = display.newRect(group, centerX, centerY, 1400, 1000)
    rect.alpha = alpha or 0.5
    rect:setFillColor(r or 0, g or 0, b or 0)
    rect:addEventListener("tap", onclick)

    if touchEvent == "block" then
        rect:addEventListener("touch", function() return true end)
    elseif touchEvent ~= "ignore" then
        rect:addEventListener("touch", onclick)
    end

    return rect
end


-- Creates an image button that shows it's depression, makes a sound and triggers an function
function newButton(group, x, y, image, callback, multiClick, clickSound, size)
    local btn        = newImage(group, "buttons/button-"..image.."-up",   x, y)
    local btnOverlay = newImage(group, "buttons/button-"..image.."-down", x, y, nil, 0)

    if size then
        btn:scale(size, size)
        btnOverlay:scale(size, size)
    end

    btn.activated = false

    btn:addEventListener("tap", function(event)
        if not btn.activated then
            btn.activated = true

            if multiClick then
                after(multiClick, function() if btn then btn.activated = false end end)
            end

            if not clickSound or clicksound ~= "no" then
                play(clickSound or sounds.sceneEnter)
            end

            btn.alpha, btnOverlay.alpha = 0, 1
            after(150, function()
                callback()
                btn.alpha, btnOverlay.alpha = 1, 0
            end)
        end
        return true
    end)

    return btn, btnOverlay
end


-- Displays the common menu hud
function newMenuHud(group, spineStore, toStore, toPlayerSelect, toInAppStore, toProgress)
    local game       = state.data.gameSelected
    local playerName = characterData[state.data.playerModel].name
    local bgr        = newImageRect(group, "hud/menu-hud", centerX, 562, backgroundWidth, 157)
    local cube       = spineStore:showHoloCube(70, 615, 0.65)
    local playerIcon = newImage(group, "hud/player-head-"..playerName, 885, 580, 0.85, 0.30)
    local labelCubes = newText(group, state.data.holocubes, 70,  590, 0.7, "white",  "CENTER")
    local labelScore = newText(group, state.data.score,     880, 590, 0.7, "yellow", "CENTER")

    -- block touch events
    bgr:addEventListener("touch", function() return true end)

    if toStore then
        cube.tap = toStore
        cube.image:addEventListener("tap", cube)
    end

    if toPlayerSelect then
        playerIcon.tap = toPlayerSelect
        playerIcon:addEventListener("tap", playerIcon)
    end

    group:insert(cube.image)
    labelCubes:toFront()
    labelScore:toFront()

    -- return items that need to be referenced and removed afterward
    return labelCubes, labelScore, playerIcon
end


function newMenuHudIcons(group, toInAppStore, toProgress, toFruity)
    local iconProgress = newImage(group, "hud/hud-tab-progress", 520, 545)
    local iconFruity   = newImage(group, "hud/hud-tab-random",   625, 545)
    local iconStore    = newImage(group, "hud/hud-tab-shop",     730, 545)

    local handler = function(object, callback)
        if not object.activated then
            object.activated = true
            after(400, function() if object then object.activated = false end end)

            local seq  = anim:chainSeq("iconTap", object)
            seq:tran({time=150, scale=1.1, transition = easing.outBack})
            seq:tran({time=150, scale=1,   transition = easing.outBack})
            seq.onComplete = callback
            seq:start()
        end
    end

    iconProgress:addEventListener("tap", function() handler(iconProgress, toProgress)   end)
    iconFruity:addEventListener("tap",   function() handler(iconFruity,   toFruity)     end)
    iconStore:addEventListener("tap",    function() handler(iconStore,    toInAppStore) end)

    return iconProgress
end


-- Loads the mid-sceen scene
function loadSceneTransition(time)
    globalSceneTransitionGroup.alpha = 0

    local bgr = display.newRect(globalSceneTransitionGroup, centerX, centerY, contentWidth+200, contentHeight+200)
    bgr:setFillColor(0,0,0)

    newBackground(globalSceneTransitionGroup, "scene-transition")

    local text = newText(globalSceneTransitionGroup, "loading...", centerX, 500, 0.5, "yellow")
    text.alpha = 0

    globalSceneTransitionGroup:toFront(globalSceneTransitionGroup)
    transition.to(globalSceneTransitionGroup, {alpha=1, time=time or 1000})

    globalTransitionTimer = timer.performWithDelay(100, function()
        if text and text.alpha then
            if text.alpha >= 1 then
                text.backward = true
            elseif text.alpha <= 0 then
                text.backward = false
            end

            if text.backward then 
                text.alpha = text.alpha - 0.1
            else
                text.alpha = text.alpha + 0.1
            end
        end
    end, 0)
end


function clearTransitionTimer()
    if globalTransitionTimer then
        timer.cancel(globalTransitionTimer)
    end
end


-- Clear the mid-screen scene
function clearSceneTransition(time)
    if time then
        transition.to(globalSceneTransitionGroup, {alpha=0, time=time, onComplete=function()
            clearTransitionTimer()
            globalSceneTransitionGroup:removeSelf()
            globalSceneTransitionGroup = display.newGroup()
        end})
    else
        clearTransitionTimer()
        globalSceneTransitionGroup:removeSelf()
        globalSceneTransitionGroup = display.newGroup()
    end
end


--- Code for random sparkle effects

function newRandomSparkle(group, delay, sparkles, previousNum)
    stopSparkles()
    goSparkle = true

    after(delay, function()
        if goSparkle then
            local num = math_random(#sparkles)

            if previousNum then
                while num == previousNum do
                    num = math_random(#sparkles)
                end
            end

            newSparkle(group, delay, sparkles, num)
        end
    end)
end


function newSparkle(group, delay, sparkles, num)
    local camera   = { add = function(self, item) if group.insert then group:insert(item) end end }
    local point    = sparkles[num]
    local type     = point.type     or 1
    local alpha    = point.alpha    or 1
    local duration = point.duration or 2500

    local sparkle  = particles:showEmitter(camera, "menu-flare"..type, point.x, point.y, "forever")
    sparkle.alpha  = 0
    sparkle:scale(0.5, 0.5)

    sparkleSeq = anim:oustSeq("sparkle", sparkle, true)
    sparkleSeq:tran({time=500, alpha=alpha})
    sparkleSeq:tran({time=500, alpha=0, delay=duration})
    sparkleSeq.onComplete = function() newRandomSparkle(group, delay, sparkles, num) end
    sparkleSeq:start()
end


function stopSparkles()
    goSparkle = false

    if sparkleSeq then
        sparkleSeq:destroy()
        sparkleSeq = nil
    end
end


--- Code for locked popups ---

local function newLockedPopupSpecifics(group, id, type, description)
    local buymode = "both"

    if type == "planet" then
        newImage(group, "select-game/race-zone-green", 170, 265)

        local other = id - 1
        local zones = 5  - state:numberZonesCompleted(other, gameTypeStory)
        description = "complete "..zones.." zones in "..planetData[other].name.." to unlock"

    elseif type == "zones" then
        newImage(group, "select-game/race-zone-green", 170, 265)
        description = "buy "..planetData[id].name.." planet pack to unlock"
        buymode     = "storeOnly"

    elseif type == "game" then
        newImage(group, "select-game/tab-"..gameTypeData[id].icon, 170, 265, 0.35)

    elseif type == "character" then
        newImage(group, "select-player/head-"..characterData[id].name.."-selected", 170, 265, 0.8)
        
        buymode = characterData[id].buyMode
        local charPlanet = characterData[id].planet
        local planetName = planetData[charPlanet].name

        if buymode == "storeOnly" then
            description = characterData[id].lockText
        elseif not state:planetUnlocked(charPlanet) then
            description = "unlock and complete "..planetName.." to unlock"
        else
            local zones = planetData[charPlanet].normalZones - state:numberZonesCompleted(charPlanet, gameTypeStory)
            description = "complete "..zones.." zones in "..planetName.." to unlock"
        end
    elseif type == "gear" then
        newImage(group, "collectables/gear-"..gearNames[gearSlots[id]].."-"..id, 170, 265, 0.5)

        local zones = gearUnlocks[id].unlockAfter - state:totalStoryZonesCompleted()
        buymode     = gearUnlocks[id].buyMode
        description = "complete "..zones.." zones to unlock"
    end

    return buymode, description
end


local function newLockedPopupGeneral(group, title, description, buymode, planet, buyHandler)
    newText(group, title,       370, 160, 0.8, "red",   "CENTER")
    newText(group, description, 370, 260, 0.5, "white", "CENTER", 550)

    if buymode == "storeOnly" or buymode == "both" then
        local icon  = newImage(group, "locking/buy-to-unlock", 170, 410)
        local instr = newText(group,  "purchase in store",     370, 400, 0.5, "white", "CENTER")

        icon:addEventListener("tap", buyHandler)
        instr:addEventListener("tap", buyHandler)

        if buymode == "both" then
            local label = newText(group, "or", 170, 400, 0.8, "red")
            label:addEventListener("tap", buyHandler)
        end
    end

    state.inappPurchaseType = "planet"
    if type == "gear" then state.inappPurchaseType = "gear" end

    newImage(group, "locking/popup-advert"..planet, 700, 295)
end


-- Displays the locked popup with info relelvent to the item that was locked
function newLockedPopup(sceneGroup, id, type, title, callback, description)
    local group = display.newGroup()
    local seq1, seq2, seq3 = nil, nil, nil
    local action = false

    local exitHandler = function()
        if not action then
            action = true
            seq:destroy()
            stopSparkles()
            group:removeSelf()

            if callback then callback() end
        end
        return true
    end

    local buyHandler = function()
        if not action then
            action = true
            seq:destroy()
            stopSparkles()
            group:removeSelf()
            composer.gotoScene("scenes.inapp-purchases")
        end
        return true
    end

    local planet  = state.data.planetSelected or 1
    local blocker = newBlocker(group, 0.8, 0,0,0, exitHandler, "block")
    local popup   = newImage(group, "locking/popup", centerX, centerY)

    if type == "planet" then planet = id end

    popup:addEventListener("tap", function() return true end)

    local buymode, description = newLockedPopupSpecifics(group, id, type, description)
    newLockedPopupGeneral(group, title, description, buymode, planet, buyHandler)

    newButton(group, 370, 455, "close", exitHandler)
    local b1, b1o = newButton(group, 700, 455, "buy", buyHandler)

    seq = anim:oustSeq("buyButton", b1, true)
    seq.target2 = b1o
    seq:add("pulse", {time=1500, scale=0.035})
    seq:start()

    newRandomSparkle(group, 1000, lockedSparkles)
end


-- Saves an objects fillcolor to a property it can be restored from, for temporary colouring
function recordImageColor(image)
    if image.setFillColor and not image.preColor then
        image.preColor = {r=image.fill.r, g=image.fill.g, b=image.fill.b, alpha=image.alpha}
    end
end


-- Randomly modifies an images RGB and alpha values
function randomizeImage(image, doAlpha, alphaMin)
    local r, g, b = math_random(), math_random(), math_random()

    if image.setFillColor then
        image:setFillColor(r,g,b)
    end

    if doAlpha then
        local alpha = math_random()
        local min   = alphaMin or 0

        if alpha < min then alpha = min end
        image.alpha = alpha
    end
end


-- Resets and images RGB values
function restoreImage(image)
    if image.setFillColor then
        local pre = image.preColor

        if pre then
            image:setFillColor(pre.r, pre.g, pre.b)
            image.alpha = pre.alpha
            image.preColor = nil
        else
            image:setFillColor(1,1,1)
            image.alpha = 1
        end
    end
end


-- Used for debugging performance stats over all over display objects
-- requires globalFPS be incremented in enterFrame handler
function displayPerformance()
    local data = "mem usage: "..math_round(collectgarbage("count")/1024).." mb|texture mem: "..math_round(system.getInfo("textureMemoryUsed") / 1024/1024).." mb|fps: "..globalFPS
    globalFPS = 0

    if globalPerformanceLabel == nil then
        globalPerformanceLabel = newText(nil, data, 50, 110, 0.4, "white", "LEFT", 1000)
    else
        globalPerformanceLabel:setText(data)
    end
    globalPerformanceLabel:toFront()
end


function displayDebugPanel(text, x, y, width, height)
    if globalDebugStatus then
        x      = x      or centerX
        y      = y      or centerY
        width  = width  or 1000
        height = height or 600

        debugPanel = display.newRoundedRect(x, y, width, height, 15)
        debugPanel:setFillColor(0.3,    0.3,  0.3,  0.85)
        debugPanel:setStrokeColor(0.75, 0.75, 0.75, 0.75)
        debugPanel.strokeWidth = 2

        debugText = display.newText({text=text, x=x, y=y, width=width, height=height, fontSize=22, align="center"})

        debugPanel:addEventListener("tap", closeDebugPanel)
        debugText:addEventListener("tap", closeDebugPanel)
    end
end


function updateDebugPanel(text, skipNewLine)
    if globalDebugStatus then
        if debugText == nil then
            displayDebugPanel(text)
        else
            if skipNewLine then
                debugText.text = debugText.text..text
            else
                debugText.text = debugText.text.."\n"..text
            end
        end
    end
end


function closeDebugPanel()
    if debugPanel then
        debugPanel:removeSelf()
        debugText:removeSelf()
        debugPanel = nil
        debugText  = nil
    end
    return true
end

