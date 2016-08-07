local composer  = require("composer")
local anim      = require("core.animations")
local particles = require("core.particles")
local messages  = require("core.messages")
local scene     = composer.newScene()

-- Local vars:
local store              = nil
local storeName          = nil
local transactionProduct = nil
local googleIAP          = false
local restoreChecked     = false

local productIds = {
    planetPack1       = "planet_pack1",
    planetPack2       = "planet_pack2",
    gearPackJumpSmall = "iap_gear_pack_jump_small",
    gearPackJumpLarge = "iap_gear_pack_jump_large",
    gearPackAirSmall  = "iap_gear_pack_air_small",
    gearPackAirLarge  = "iap_gear_pack_air_large",
    gearPackLandSmall = "iap_gear_pack_land_small",
    gearPackLandLarge = "iap_gear_pack_land_large",
    gearPackAllSmall  = "iap_gear_pack_everything_small",
    gearPackAllLarge  = "iap_gear_pack_everything_large",
}

local productData = {
    -- how many of each gear is purchased for pack sizes
    quantitySmall = 5,
    quantityLarge = 10,

    -- costs listed here are static costs for when we cannot connect to the store - but they may not reflect the real prices
    iap = {
        [productIds.planetPack1]       = { cost=0.99, planet=1 },
        [productIds.planetPack2]       = { cost=0.99, planet=2 },
        [productIds.gearPackJumpSmall] = { cost=0.50, gear=jump,  size="small" },
        [productIds.gearPackAirSmall]  = { cost=0.50, gear=air,   size="small" },
        [productIds.gearPackLandSmall] = { cost=0.50, gear=land,  size="small" },
        [productIds.gearPackJumpLarge] = { cost=0.85, gear=jump,  size="large" },
        [productIds.gearPackAirLarge]  = { cost=0.85, gear=air,   size="large" },
        [productIds.gearPackLandLarge] = { cost=0.85, gear=land,  size="large" },
        [productIds.gearPackAllSmall]  = { cost=1.00, gear="all", size="small" },
        [productIds.gearPackAllLarge]  = { cost=1.79, gear="all", size="large" },
    }
}


local planetSparkles = {
    {x=100, y=130}, {x=400, y=130}, {x=850, y=120}, {x=470, y=500}, {x=210, y=520}, {x=600, y=610},
}

local gearSparkles = {
    {x=70, y=100}, {x=370, y=100}, {x=900, y=100}, 
    {x=70, y=470}, {x=900, y=480},
}

-- Aliases:
local play = globalSoundPlayer


-- Treat phone back button same as back game button
local function sceneKeyEvent(event)
    if event.keyName == "back" and event.phase == "up" then
        scene:exitInApPurchases()
        return true
    end
end


-- Called when the scene's view does not exist:
function scene:create(event)
    self:setupProducts()
    self:loadProductFromStore()
    self:buildPages()
    self:buildMenu()
end


-- Called immediately after scene has moved onscreen:
function scene:show(event)
    if event.phase == "did" then
        self:init()

        Runtime:addEventListener("key", sceneKeyEvent)

        if state.inappPurchaseType == "planet" then
            self:showPage("planet")
        elseif state.inappPurchaseType == "special" then
            self:showPage("special")
        else
            self:showPage("gear")
        end

        if self.statusGroup then
            self.statusGroup:toFront()
        end

        -- check for restored purchases on very first scene load
        self:restorePurchases()
    end
end


function scene:init()
    logAnalyticsStart()
    state:newScene("inapp-purchases")
    clearSceneTransition()
    self.dontPlaySound = true
end


-- Setup base product data-set (to avoid repetition defining)
-- As we (try) and get the raw prics from the remote store for dynamic pricing, we have to convert these into user-friendly labels
function scene:setupProducts()
    for id, product in pairs(productData.iap) do
        product.id = id

        if product.labelPrice then
            product.labelPrice.text = self:createCostLabel(product.cost)
        end
    end
end


function scene:createCostLabel(cost)
    if cost == "coming soon" then
        return "n/a"
    elseif type(cost) == "number" then
        if cost < 1 then
            return string.format("%2.2f", cost)
        else
            return string.format("%4.2f", cost)
        end
    else
        return cost
    end
end


function scene:loadProductFromStore()
    displayDebugPanel("loadProductsFromStore")

    if self:initStore() then
        store.init(storeName, function(event) scene:storeTransaction(event) end)

        if store.canLoadProducts then
            -- attempt to read product lists from the inapp store
            updateDebugPanel("Reading product list from store: "..tostring(storeName))

            -- build product list to load
            local list = {}
            for key,_ in pairs(productData.iap) do list[#list+1] = key end

            -- consume IAPs for testing purposes in debug mode
            if globalDebugGame then
                if store.consumePurchase then
                    store.consumePurchase(list, function(event) updateDebugPanel("consumed products") end)
                end
            end

            store.loadProducts(list, function(event) self:storeProductsLoaded(event) end)
        else
            updateDebugPanel("Store does not allow loading of products: "..tostring(storeName))
        end
    end
end


function scene:initStore()
    if system.getInfo("platformName") == "Android" then
        store       = require("plugin.google.iap.v3")
        storeName   = "google"
        googleIAP   = true
        return true
    elseif (system.getInfo("platformName") == "iPhone OS") then
        store       = require("store")
        storeName   = "apple"
        return true
    else
        storeName   = "unknown"
        updateDebugPanel("In-app purchases are not supported in the Corona Simulator")
        return false
    end
end


-- Called when store.loadProducts completes
function scene:storeProductsLoaded(event)
    updateDebugPanel("Product list loaded. products: "..#event.products.." invalidProducts: "..#event.invalidProducts)

    for i=1, #event.products do
        local product = event.products[i]
        local pid     = product.productIdentifier
        local price   = product.localizedPrice
        
        --[[local s = tostring(i)..". valid: "
        for k,v in pairs(product) do
            s = s..tostring(k).."="..tostring(v)..", "
        end--]]
        --updateDebugPanel(tostring(i)..". valid: "..pid.." £"..price)

        if price and pid and productData.iap[pid] then
            productData.iap[pid].cost = price 
        end
    end

    self:setupProducts()
end


function scene:buildPages()
    local planetGroup  = display.newGroup()
    local gearGroup    = display.newGroup()
    local specialGroup = display.newGroup()

    planetGroup.alpha, gearGroup.alpha, specialGroup.alpha = 0, 0, 0
    self.view:insert(planetGroup)
    self.view:insert(gearGroup)
    self.view:insert(specialGroup)

    self.pages = {
        ["planet"]  = planetGroup,
        ["gear"]    = gearGroup,
        ["special"] = specialGroup
    }

    newBackground(planetGroup,  "inapp-purchases/bgr")
    newBackground(gearGroup,    "inapp-purchases/bgr")
    newBackground(specialGroup, "inapp-purchases/bgr")

    self:buildPlanetPage(planetGroup)
    self:buildGearPage(gearGroup)
end


function scene:buildPlanetPage(planetGroup)
    newImage(planetGroup, "inapp-purchases/planet-text", centerX, 560)

    self:newPlanetBuyer(planetGroup, 1, true,  190)
    self:newPlanetBuyer(planetGroup, 2, true,  centerX)
    self:newPlanetBuyer(planetGroup, 3, false, 770)
end


function scene:buildGearPage(gearGroup)
    newImage(gearGroup, "inapp-purchases/iap-gear-jump", 190,     280)
    newImage(gearGroup, "inapp-purchases/iap-gear-air",  centerX, 280)
    newImage(gearGroup, "inapp-purchases/iap-gear-land", 800,     280)
    newImage(gearGroup, "inapp-purchases/iap-gear-all",  centerX, 540)

    self:newGearBuyers(gearGroup, 130, 335, productIds.gearPackJumpSmall, productIds.gearPackJumpLarge)
    self:newGearBuyers(gearGroup, 425, 335, productIds.gearPackAirSmall,  productIds.gearPackAirLarge)
    self:newGearBuyers(gearGroup, 740, 335, productIds.gearPackLandSmall, productIds.gearPackLandLarge)
    self:newGearBuyers(gearGroup, 750, 535, productIds.gearPackAllSmall,  productIds.gearPackAllLarge)
end


function scene:newPlanetBuyer(planetGroup, planet, available, xpos)
    local productId = "planet_pack"..planet
    local product   = productData.iap[productId]

    newImage(planetGroup, "inapp-purchases/iap-planet"..planet, xpos, 280)

    if available then
        self:newBand(planetGroup, xpos, 400, 230, 70)

        local purchasedText = newText(planetGroup, "purchased!", xpos, 400, 0.8, "green", "CENTER")

        if not state:hasPurchased(productId) then
            purchasedText.alpha = 0

            local b1, b2 = newButton(planetGroup, xpos-40, 400, "buy", function() scene:purchase(product) end, 1000)
            self:animate(b1, b2)

            product.labelPrice     = display.newText(planetGroup, " ", xpos+65, 400, "arial", 22)
            product.labelPurchased = purchasedText
            product.buyButton1     = b1
            product.buyButton2     = b2
        end
    else
        local soon = newText(planetGroup, "coming soon", xpos-20, 400, 0.8, "red", "CENTER")
        soon:rotate(15)
    end
end


function scene:newGearBuyers(group, x, y, nameSmall, nameLarge)
    local iapSmall = productData.iap[nameSmall]
    local iapLarge = productData.iap[nameLarge]

    local b1, b1o = newButton(group, x, y,    "buy", function() scene:purchase(iapSmall) end, 1000, nil, 0.7)
    local b2, b2o = newButton(group, x, y+60, "buy", function() scene:purchase(iapLarge) end, 1000, nil, 0.7)

    self:animate(b1, b1o, {baseScale=0.7})
    self:animate(b2, b2o, {baseScale=0.7})

    iapSmall.labelPrice = display.newText(group, " ", x+100, y+5,  "arial", 22)
    iapLarge.labelPrice = display.newText(group, " ", x+100, y+65, "arial", 22)

    local l1 = display.newText(group, productData.quantitySmall.." of each", x+100, y-15, "arial", 20)
    local l2 = display.newText(group, productData.quantityLarge.." of each", x+100, y+45, "arial", 20)
    l1:setTextColor(0,0,0)
    l2:setTextColor(0,0,0)
end


function scene:newBand(group, x, y, width, height)
    local band1 = display.newRect(group, x, y, width, height)
    band1:setFillColor(0.4, 0.4, 0.4, 0.7)
    band1:setStrokeColor(0.8, 0.8, 0.8)
end


function scene:buildMenu()
    newButton(self.view, 50, 40, "back", scene.exitInApPurchases)

    local planetMenu  = newImage(self.view, "inapp-purchases/menu-planet",  270, 27)
    local gearMenu    = newImage(self.view, "inapp-purchases/menu-gear",    535, 27)
    local specialMenu = newImage(self.view, "inapp-purchases/menu-special", 800, 27)

    planetMenu:addEventListener("tap",  function() scene:showPage("planet")  end)
    gearMenu:addEventListener("tap",    function() scene:showPage("gear")    end)
    specialMenu:addEventListener("tap", function() scene:showPage("special") end)

    self.menu = {
        ["planet"]  = planetMenu,
        ["gear"]    = gearMenu,
        ["special"] = specialMenu,
    }
end


function scene:showPage(page)
    self.page = page

    if self.dontPlaySound then
        self.dontPlaySound = false
    else
        play(sounds.generalClick)
    end

    local sparkles = nil
    if     page == "planet" then sparkles = planetSparkles
    elseif page == "gear" then sparkles = gearSparkles end

    if sparkles then
        newRandomSparkle(self.view, 1000, sparkles)
    end

    for name, group in pairs(self.pages) do
        if name == page then
            group.alpha = 1
            self.menu[name].alpha = 1
        else
            group.alpha = 0
            self.menu[name].alpha = 0.5
        end
    end
end


-------------- PURCHASE A PRODUCT -----------------

--[[
-- Use for TESTING on simulator
function scene:purchase(product)
    transactionProduct = product
    self:storeTransaction({transaction={state="purchased"}})
end
]]

-- Use for Real Transactions
function scene:purchase(product)
    displayDebugPanel("purchase: "..product.id)
    
    if store == nil then
        updateDebugPanel("Purchase "..product.id.." failed: purchases not available as no store loaded")
        return
    end

    if store.canMakePurchases then
        transactionProduct = product

        if googleIAP then
            -- calls storeTransaction() 
            store.purchase(product.id)
        else
            -- calls storeTransaction() 
            store.purchase({product.id})
        end
    else
        updateDebugPanel("Store purchases have been disabled in phone settings")
    end
end


function scene:restorePurchases()
    -- calls storeTransaction() for each previous purchase to restore
    if store and not restoreChecked then
        updateDebugPanel("checking store restore")
        transactionProduct = nil
        store.restore()
        restoreChecked = true
    end
end


function scene:storeTransaction(event)
    local self        = scene
    local transaction = event.transaction

    if transaction.state == "purchased" or transaction.state == "restored" then
        self.unlockedItems = {}
        local restore      = false

        -- handle restorePurchases: as this will not be nil if a purchase event occured
        if transactionProduct == nil then
            transactionProduct = productData.iap[transaction.productIdentifier]
            updateDebugPanel("restoring "..tostring(transactionProduct.id))
            restore = true
        else
            play(sounds.shopPurchase)
        end
        
        if transactionProduct and not state:hasPurchased(transactionProduct.id) then
            local planet = transactionProduct.planet
            local gear   = transactionProduct.gear
            local size   = transactionProduct.size

            if planet then
                if     planet == 1 then self:purchasedPlanetPack1(restore)
                elseif planet == 2 then self:purchasedPlanetPack2(restore) end
            elseif gear then
                if     gear == jump  and size == "small" then self:purchasedSmallJumpGearPack()
                elseif gear == jump  and size == "large" then self:purchasedLargeJumpGearPack()
                elseif gear == air   and size == "small" then self:purchasedSmallAirGearPack()
                elseif gear == air   and size == "large" then self:purchasedLargeAirGearPack()
                elseif gear == land  and size == "small" then self:purchasedSmallLandGearPack()
                elseif gear == land  and size == "large" then self:purchasedLargeLandGearPack()
                elseif gear == "all" and size == "small" then self:purchasedSmallAllGearPack()
                elseif gear == "all" and size == "large" then self:purchasedLargeAllGearPack() end
            end

            state:saveGame()
            transactionProduct = nil
        end

    elseif transaction.state == "refunded" then
        -- Google Play allows for IAP refunds - so disable the functionality ... pretty tough to work out though
        transactionProduct = productData.iap[transaction.productIdentifier]

        if transactionProduct then
            local planet = transactionProduct.planet

            -- Currently: can only refund planet packs not consumables such as gear
            if planet then
                if     planet == 1 then self:refundPlanetPack1()
                elseif planet == 2 then self:refundPlanetPack2() end
            end

            state:saveGame()
        end

    elseif transaction.state == "cancelled" then
        play(sounds.shopCantBuy)
        updateDebugPanel("Purchase cancelled: "..tostring(transaction.productIdentifier))

    elseif transaction.state == "failed" then
        play(sounds.shopCantBuy)
        updateDebugPanel("Purchase failed: "..tostring(transaction.productIdentifier).." => "..tostring(event.errorType).." "..tostring(event.errorString))
    else
        play(sounds.shopCantBuy)
        updateDebugPanel("Purchase other status: "..tostring(transaction.state).." "..tostring(transaction.productIdentifier))
    end

    if store then
        store.finishTransaction(transaction)
    end
end


--------------------- SUCCESSFULL PURCHASE HANDLERS - ACTIVATE PURCHASES ---------------------


function scene:purchasedPlanetPack1(restore)
    self:unlockPlanetPack(1, characterKranio)
    self:displayPlanetUnlocked(1, restore)
end


function scene:purchasedPlanetPack2(restore)
    self:unlockPlanetPack(2, characterReneGrey)
    self:displayPlanetUnlocked(2, restore)
end


function scene:purchasedSmallJumpGearPack()
    self:addJumpGear(productData.quantitySmall)
    self:consumeProduct()
    self:displayGearPurchased()
end


function scene:purchasedLargeJumpGearPack()
    self:addJumpGear(productData.quantityLarge)
    self:consumeProduct()
    self:displayGearPurchased()
end


function scene:purchasedSmallAirGearPack()
    self:addAirGear(productData.quantitySmall)
    self:consumeProduct()
    self:displayGearPurchased()
end


function scene:purchasedLargeAirGearPack()
    self:addAirGear(productData.quantityLarge)
    self:consumeProduct()
    self:displayGearPurchased()
end


function scene:purchasedSmallLandGearPack()
    self:addLandGear(productData.quantitySmall)
    self:consumeProduct()
    self:displayGearPurchased()
end


function scene:purchasedLargeLandGearPack()
    self:addLandGear(productData.quantityLarge)
    self:consumeProduct()
    self:displayGearPurchased()
end


function scene:purchasedSmallAllGearPack()
    local num = productData.quantitySmall

    self:addJumpGear(num)
    self:addAirGear(num)
    self:addLandGear(num)
    self:consumeProduct()
    self:displayGearPurchased()
end


function scene:purchasedLargeAllGearPack()
    local num = productData.quantityLarge

    self:addJumpGear(num)
    self:addAirGear(num)
    self:addLandGear(num)
    self:consumeProduct()
    self:displayGearPurchased()
end


function scene:unlockPlanetPack(planet, specialCharacter)
    state:unlockPlanet(planet)
    state:unlockZone(planet, 22)
    state:unlockZone(planet, 23)
    state:unlockZone(planet, 24)
    state:unlockZone(planet, 25)
    state:unlockGame(planet, gameTypeTimeAttack)
    state:unlockGame(planet, gameTypeSurvival)
    state:unlockGame(planet, gameTypeRace)
    state:unlockGame(planet, gameTypeTimeRunner)
    state:unlockGame(planet, gameTypeClimbChase)
    state:unlockGame(planet, gameTypeArcadeRacer)
    state:unlockCharacter(specialCharacter)
    state:addPurchase(transactionProduct.id)

    state.cutsceneCharacter = specialCharacter

    table.insert(self.unlockedItems, {"planet",    planet})
    table.insert(self.unlockedItems, {"game",      gameTypeTimeAttack})
    table.insert(self.unlockedItems, {"game",      gameTypeSurvival})
    table.insert(self.unlockedItems, {"game",      gameTypeTimeRunner})
    table.insert(self.unlockedItems, {"game",      gameTypeClimbChase})
    table.insert(self.unlockedItems, {"character", specialCharacter})
end


function scene:addJumpGear(quantity)
    state:unlockGear(gearSpringShoes)
    state:unlockGear(gearShield)
    state:unlockGear(gearFreezeTime)
    state:unlockGear(gearTrajectory)

    for i=1, quantity do
        state:addGear(jump, gearSpringShoes)
        state:addGear(jump, gearShield)
        state:addGear(jump, gearFreezeTime)
        state:addGear(jump, gearTrajectory)
    end

    table.insert(self.unlockedItems, {"gear",gearFreezeTime})
    table.insert(self.unlockedItems, {"gear",gearSpringShoes})
    table.insert(self.unlockedItems, {"gear",gearShield})
    table.insert(self.unlockedItems, {"gear",gearTrajectory})
end


function scene:addAirGear(quantity)
    state:unlockGear(gearGlider)
    state:unlockGear(gearParachute)
    state:unlockGear(gearJetpack)
    state:unlockGear(gearReverseJump)

    for i=1, quantity do
        state:addGear(air, gearGlider)
        state:addGear(air, gearParachute)
        state:addGear(air, gearJetpack)
        state:addGear(air, gearReverseJump)
    end

    table.insert(self.unlockedItems, {"gear",gearJetpack})
    table.insert(self.unlockedItems, {"gear",gearGlider})
    table.insert(self.unlockedItems, {"gear",gearParachute})
    table.insert(self.unlockedItems, {"gear",gearReverseJump})
end


function scene:addLandGear(quantity)
    state:unlockGear(gearGrappleHook)
    state:unlockGear(gearGloves)

    for i=1, quantity do
        state:addGear(land, gearGrappleHook)
        state:addGear(land, gearGloves)
    end

    table.insert(self.unlockedItems, {"gear",gearGrappleHook})
    table.insert(self.unlockedItems, {"gear",gearGloves})
end


-- Googles requires some items to be consumed to buy again
function scene:consumeProduct()
    if googleIAP then
        store.consumePurchase({transactionProduct.id}, function(event) 
            updateDebugPanel("consumed product: "..transactionProduct.id)
        end)
    end
end


function scene:displayPlanetUnlocked(planet, restore)
    local productId = transactionProduct.id
    local product   = productData.iap[productId]

    if product and product.labelPurchased then
        product.labelPurchased.alpha = 1
        product.labelPrice.alpha     = 0

        product.buyButton1:removeSelf()
        product.buyButton2:removeSelf()
        product.buyButton1 = nil
        product.buyButton2 = nil
    end

    -- dont change scenes if restoring
    if not restore then
        newBlocker(self.view)
        self:animatePurchases(500, 1000, 500)

        local seq = anim:chainSeq("showUnlocks", self.view)
        seq:callback(function() 
            state.data.planetSelected = planet
            state.cutsceneStory       = "cutscene-character-intro"
            state.sceneAfterCutScene  = "scenes.inapp-purchases"
            composer.gotoScene("scenes.mothership", {effect="fade", time=500})
        end)
        anim:startQueue("showUnlocks")
    end
end


function scene:displayGearPurchased()
    self:animatePurchases()
    anim:startQueue("showUnlocks")
end


function scene:animatePurchases(speedIn, delay, speedOut)
    for _,unlock in pairs(self.unlockedItems) do
        local type  = unlock[1]
        local value = unlock[2]
        local group = display.newGroup()

        self.view:insert(group)
        group.alpha, group.x, group.y = 0, centerX, centerY

        if type == "gear" then
            local category = gearSlots[value]
            local name     = messages["gear"][category][value][1]
            newImage(group, "collectables/gear-"..gearNames[category].."-"..value, 0, 0)
            newText(group, "purchased equipment!", 0, -20, 0.5, "green",  "CENTER")
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

        local seq = anim:chainSeq("showUnlocks", group)
        seq:add("flexout", {time=(speedIn or 250), scale=1.3, scaleBack=1, playSound=sounds.unlock})
        seq:wait(delay or 500)
        seq:tran({time=(speedOut or 250), scale=0.01, alpha=0})
    end
end


----- REFUNDS -----


function scene:refundPlanetPack1()
    self:refundPlanetPack(1, characterKranio)
    updateDebugPanel("Purchase refunded: Organia Planet Pack")
end


function scene:refundPlanetPack2()
    self:refundPlanetPack(2, characterReneGrey)
    updateDebugPanel("Purchase refunded: Apocalypsoid Planet Pack")
end


function scene:refundPlanetPack(planet, specialCharacter)
    state:lockZone(planet, 22)
    state:lockZone(planet, 23)
    state:lockZone(planet, 24)
    state:lockZone(planet, 25)
    state:lockCharacter(specialCharacter)
    state:removePurchase(transactionProduct.id)
end


----- GENERAL -----


function scene:animate(item, item2, params)
    local params = params or {}
    self.pulseId = (self.pulseId or 0) + 1

    local seq   = anim:oustSeq("pulse-"..self.pulseId, item)
    seq.target2 = item2
    seq:add("pulse", {time=1500, scale=0.035, baseScale=params.baseScale})
    seq:start()
end


function scene:displayMessage(message, color)
    local text = newText(self.group, message, 480, 310, 0.8, color, "CENTER")
    local seq  = anim:oustSeq("purchase", text, true)
    seq:add("pulse", {time=1000, scale=0.025, expires=3000})
    seq:tran({time=750, scale=0.1, alpha=0})
    seq:start()
end


function scene:exitInApPurchases()
    loadSceneTransition(1)
    after(10, function() composer.gotoScene(state:backScene()) end)
    return true
end


-- Called when scene is about to move offscreen:
function scene:hide(event)
    if event.phase == "will" then
        Runtime:removeEventListener("key", sceneKeyEvent)
        track:cancelEventHandles()
        anim:destroy()

        for _,product in pairs(productData.iap) do
            if product.labelPrice then
                product.labelPrice:removeSelf()
                product.labelPrice = nil
            end

            if product.labelPurchased then
                product.labelPurchased:removeSelf()
                product.labelPurchased = nil
            end

            if product.buyButton1 then
                product.buyButton1:removeSelf()
                product.buyButton1 = nil
            end

            if product.buyButton2 then
                product.buyButton2:removeSelf()
                product.buyButton2 = nil
            end
        end

        self.pages = nil
        self.menu  = nil
        logAnalyticsEnd()

    elseif event.phase == "did" then
        composer.removeScene("scenes.inapp-purchases")
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