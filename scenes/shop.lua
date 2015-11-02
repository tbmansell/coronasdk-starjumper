local storyboard   = require("storyboard")
local anim         = require("core.animations")
local messages     = require("core.messages")
local builder      = require("level-objects.builders.builder")
local spineStore   = require("level-objects.collections.spine-store")

-- Local vars for performance:
local scene           = storyboard.newScene()
local spineCollection = nil
local lastTime        = 0

-- Aliases:
local play       = globalSoundPlayer
local new_image  = newImage
local new_circle = display.newCircle


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
    logAnalytics("shop", "enterScene")

    state:newScene("shop")
    clearSceneTransition()

    spineCollection = builder:newSpineCollection()
    spineStore:load(spineCollection)
   
    self:createEssentials()
    self:createGearIcons()
    self:displayHud()
    self:createInAppPurchase()
    self:createNegables()
    self:startMusic()

    Runtime:addEventListener("enterFrame", sceneEnterFrameEvent)
end


function scene:createEssentials()
    local group    = self.view
    local bgr      = new_image(group, "shop/shop-bgr", centerX, centerY)
    self.bgrInfo   = new_image(group, "shop/info-bgr", 700, 245)
    self.introText = newText(group, "welcome to cubes n carry. select items on the right to view what they do. the number of cubes you have is shown in the bottom left display.", 500, 230, 0.35, "white", "LEFT", 1050)
    self.buy, _    = newButton(group, 810, 340, "buy", scene.buyGear, "no")
    self.buy.alpha = 0

    newButton(group, 55, 50, "back", scene.exitShop)

    self.slotPositions = {
        [jump]     = {gearSpringShoes, gearFreezeTime, gearShield,      gearTrajectory},
        [air]      = {gearGlider,      gearParachute,  gearJetpack,     gearReverseJump},
        [land]     = {gearMagnet,      gearDestroyer,  gearGloves,      gearGrappleHook},
        [negGood]  = {negTrajectory,   negRocket,      negFreezeTarget, negImpactBomb},
        [negEnemy] = {negGravField,    negTimeBomb,    negElectrifier,  negBackPorter},
    }
end


function scene:startMusic()
    if state.data.gameSettings.music then
        self.musicChannel = audio.findFreeChannel()
        audio.setVolume(0.5,    {channel=self.musicChannel})
        audio.setMaxVolume(0.5, {channel=self.musicChannel})
        play(sounds.backgroundSoundShop, {channel=self.musicChannel, fadein=8000, loops=-1})
    end
end


function scene:createGearIcons()
    self.quantities = {}
    self.gearGroups = {}

    for category=jump, land do
        self.gearGroups[category] = display.newGroup()
        self.view:insert(self.gearGroups[category])
    end

    local gstrip = new_image(self.gearGroups[jump], "shop/green-strip", 130, centerY-24, nil, 0.5)
    local bstrip = new_image(self.gearGroups[air],  "shop/blue-strip",  260, centerY-24, nil, 0.5)
    local rstrip = new_image(self.gearGroups[land], "shop/red-strip",   390, centerY-24, nil, 0.5)

    for row=1,4 do
        for category=jump, land do
            local group    = self.gearGroups[category]
            local xpos     = 130+((category - 1)*130)
            local ypos     = 30+(row*105)-5
            local gear     = self.slotPositions[category][row]
            local quantity = state:gear(category, gear)
            local icon     = new_image(group, "collectables/gear-"..gearNames[category].."-"..gear, xpos, ypos, 0.6)
            local circle   = new_circle(group, xpos+36, ypos+35, 13)

            local color = "white"
            if quantity > 0 then color = "yellow" end
            self.quantities[gear] = newText(group, quantity, xpos+35, ypos+35, 0.4, color, "CENTER")

            circle:setFillColor(0.5, 0.5, 0.5)
            circle:setStrokeColor(0.8, 0.8, 0.8)
            circle.strokeWidth = 2
            circle.alpha       = 0.7

            icon.category = category
            icon.gear     = gear
            icon.tap      = scene.selectGear
            icon:addEventListener("tap", icon)

            if not state:gearUnlocked(gear) then
                local lock = new_image(group, "locking/lock", xpos, ypos)
                lock:scale(0.8, 0.8)
                lock.alpha  = 0.8
                icon:setFillColor(150,150,0)
                icon.locked = true
            end
        end
    end
end


function scene:displayHud()
    self.labelCubes, self.labelScore, self.playerIcon = newMenuHud(self.view, spineStore)
    new_image(self.view, "shop/logo", centerX, 590)
end


function scene:createInAppPurchase()
    local inapp = new_image(self.view, "shop/inapp-purchase", 690, 450)
    inapp:addEventListener("tap", scene.gotoInAppPurchase)

    local seq   = anim:oustSeq("pulseInApp", inapp)
    seq:add("pulse", {time=2000, scale=0.025})
    seq:start()
end


function scene:createNegables()
    local game = state.data.gameSelected

    if game and (game == gameTypeRace or game == gameTypeArcadeRacer) then
        self:createNegableIcons()
    end
end


function scene:createNegableIcons()
    local airStuff  = self.gearGroups[air]
    local landStuff = self.gearGroups[land]

    local seq1 = anim:chainSeq("showNegables", airStuff)
    seq1:tran({x=airStuff.x - 30, time=500})

    local seq2 = anim:chainSeq("showNegables", landStuff)
    seq2:tran({x=landStuff.x - 60, time=500})

    local category = negGood
    local isEnemy  = characterData[state.data.playerModel].enemy
    if isEnemy then category = negEnemy end

    local group = display.newGroup()
    self.gearGroups[category] = group
    self.view:insert(group)

    for row=4, 1, -1 do
        local xpos     = 340
        local ypos     = 73 + (row*105)
        local gear     = self.slotPositions[category][row]
        local quantity = state:gear(category, gear)
        local icon     = new_image(group, "collectables/gear-"..gearNames[category].."-"..gear, xpos, -200, 0.6)

        local color = "white"
        if quantity > 0 then color = "yellow" end
        self.quantities[gear] = newText(group, quantity, xpos+110, -10, 0.4, color, "CENTER")

        icon.category = category
        icon.gear     = gear
--        icon.tap      = scene.selectGear
--        icon:addEventListener("tap", icon)

        local seq = anim:chainSeq("showNegables", icon)
        seq.target2 = self.quantities[gear]
        seq:tran({y=ypos, time=500})
    end

    anim:startQueue("showNegables")
end


function scene:selectGear(event)
    local self       = scene
    local item       = event.target
    local playerOwns = state:gear(item.category, item.gear)
    local gearName   = messages["gear"][item.category][item.gear][1]
    local gearDesc   = messages["gear"][item.category][item.gear][2]
    local gearCost   = messages["gear"][item.category][item.gear][3]

    play(sounds.shopSelect, nil, 0.5)

    -- reset animation on previous selected item
    if self.itemSelected then
        anim:destroyQueue("selectGear")
        self.itemSelected.alpha = 1
    end

    if self.infoGroup then
        self.infoGroup:removeSelf()
        self.infoGroup = nil
    end

    self.buy.alpha = 1

    local  titleColor = "green"
    if     item.category == air  then titleColor = "blue"
    elseif item.category == land then titleColor = "red" end

    local ownColor  = "black"
    if playerOwns > 0 then ownColor = "green" end

    self.infoGroup  = display.newGroup()
    local labelOwn  = newText(self.infoGroup, "own:",     500, 280, 0.4,  "white",    "LEFT")
    local valueOwn  = newText(self.infoGroup, playerOwns, 560, 280, 0.4,  ownColor,   "LEFT")
    local labelCost = newText(self.infoGroup, "cost:",    725, 280, 0.4,  "white",    "LEFT")
    local valueCost = newText(self.infoGroup, gearCost,   788, 280, 0.4,  "red",      "LEFT")
    local labelName = newText(self.infoGroup, gearName,   600, 140, 0.6,  titleColor, "LEFT")
    local labelDesc = newText(self.infoGroup, gearDesc,   600, 210, 0.35, "white",    "LEFT", 800)
    local icon      = new_image(self.infoGroup, "collectables/gear-"..gearNames[item.category].."-"..item.gear, 540, 185, 0.6)
    local holoCubes = spineStore:showHoloCube(845, 295, 0.35)

    self.view:insert(self.infoGroup)
    self.introText.alpha = 0
    self.itemSelected    = item
    self.valueOwn        = valueOwn
    self.gearName        = gearName
    self.gearCost        = gearCost

    if item.locked then
        labelOwn:removeSelf()
        labelCost:removeSelf()
        valueCost:removeSelf()
        valueOwn:setText("item locked")
    end

    local seq = anim:chainSeq("selectGear", item)
    seq:add("glow", {time=2000, alpha=0.5})
    seq:start()

    if not state:gearUnlocked(item.gear) then
        newLockedPopup(self.view, item.gear, "gear", gearName)
    end
end


function scene:buyGear()
    local self = scene

    if self.itemSelected and self.valueOwn then
        local maxItems   = 10
        local item       = self.itemSelected
        local playerOwns = state:gear(item.category, item.gear)

        if not state:gearUnlocked(item.gear) then
            local gearName = messages["gear"][item.category][item.gear][1]
            newLockedPopup(self.view, item.gear, "gear", gearName)
            
        elseif playerOwns >= maxItems then
            -- they already have max items
            play(sounds.shopCantBuy)
            self:displayMessage("max-owned")
        elseif self.gearCost > state.data.holocubes then
            -- they cant afford it
            play(sounds.shopCantBuy)
            self:displayMessage("need-cubes")
        else
            -- buy it
            play(sounds.shopPurchase)
            state:addGear(item.category, item.gear)
            state.data.holocubes = state.data.holocubes - self.gearCost

            local newQuantity = state:gear(item.category, item.gear)
            
            self.valueOwn:removeSelf()
            self.valueOwn = newText(self.infoGroup, newQuantity, 560, 280, 0.4, "green", "LEFT")

            self.labelCubes:setText(state.data.holocubes)
            self.quantities[item.gear]:setText(newQuantity)
            self.quantities[item.gear]:setColor(1,1,0)

            self:displayMessage("purchased")
        end
    end
end


--[[
function scene:displayMessage(message, color)
    local text = newText(self.group, message, 480, 310, 0.8, color, "CENTER")
    local seq  = anim:oustSeq("purchase", text, true)
    seq:add("pulse", {time=1000, scale=0.025, expires=3000})
    seq:tran({time=750, scale=0, alpha=0})
    seq:start()
end
]]

function scene:displayMessage(message)
    local image = new_image(self.view, "shop/notice-"..message, 615, 330)
    local seq   = anim:oustSeq("purchase", image, true)
    seq:add("pulse", {time=1000, scale=0.025, expires=3000})
    seq:tran({time=500, alpha=0})
    seq:start()
end


function scene:gotoInAppPurchase()
    play(sounds.hudClick)

    state.inappPurchaseType = "gear"
    storyboard:gotoScene("scenes.inapp-purchases")
    return true
end


function scene:exitShop()
    loadSceneTransition(1)
    after(10, function() storyboard:gotoScene(state:backScene()) end)
    return true
end


-- Called when scene is about to move offscreen:
function scene:exitScene(event)
    audio.fadeOut({channel=self.musicChannel, time=1000})

    Runtime:removeEventListener("enterFrame", sceneEnterFrameEvent)
    anim:destroy()
    spineCollection:destroy()
    spineStore:destroy()

    self.labelCubes:removeSelf()
    self.labelScore:removeSelf()
    self.playerIcon:removeSelf()
    self.labelCubes = nil
    self.labelScore = nil
    self.playerIcon = nil
    self.buy        = nil

    if self.infoGroup then
        self.infoGroup:removeSelf()
        self.infoGroup = nil
    end

    -- Save game regardless of how we left the level
    state:saveGame()

    spineCollection = nil
end


-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene(event)
    storyboard.purgeScene("scenes.shop")
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene(event)
    local group = self.view
end


-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
    local overlay_name = event.sceneName  -- name of the overlay scene
end


-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded(event)
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
