local storyboard = require("storyboard")
local anim       = require("core.animations")
local particles  = require("core.particles")
local scene      = storyboard.newScene()

-- Local vars:
local store       = nil
local storeName   = nil
local googleIAP   = false
local transactionProduct = nil

local productData = {
    -- how many of each gear is purchased for pack sizes
    quantitySmall = 5,
    quantityLarge = 10,

    -- costs listed here are static costs for when we cannot connect to the store - but they may not reflect the real prices
    planets = {
        ["planet_pack1"]                = { cost=0.99, planet=1 },
        ["planet_pack2"]                = { cost=0.99, planet=2 },
    },
    gear = {
        ["gear_pack_jump_small"]        = { cost=0.50, gear=jump,  size="small" },
        ["gear_pack_air_small"]         = { cost=0.50, gear=air,   size="small" },
        ["gear_pack_land_small"]        = { cost=0.50, gear=land,  size="small" },
        ["gear_pack_jump_large"]        = { cost=0.85, gear=jump,  size="large" },
        ["gear_pack_air_large"]         = { cost=0.85, gear=air,   size="large" },
        ["gear_pack_land_large"]        = { cost=0.85, gear=land,  size="large" },
        ["gear_pack_everything_small"]  = { cost=1.00, gear="all", size="small" },
        ["gear_pack_everything_large"]  = { cost=1.79, gear="all", size="large" },
    },
    special = {
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
function scene:createScene(event)
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene(event)
    Runtime:addEventListener("key", sceneKeyEvent)

    logAnalytics("inapp-purchases", "enterScene")
    state:newScene("inapp-purchases")
    clearSceneTransition()

    self.dontPlaySound = true
    self.page = state.inappPurchaseType

    self:setupProducts()
    self:loadProductFromStore()
    self:buildPages()
    self:buildMenu()

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
end


-- Setup base product data-set (to avoid repetition defining)
-- As we (try) and get the raw prics from the remote store for dynamic pricing, we have to convert these into user-friendly labels
function scene:setupProducts()
    self:setupProductCategory("planets")
    self:setupProductCategory("gear")
    self:setupProductCategory("special")
end


function scene:setupProductCategory(category)
    for id, product in pairs(productData[category]) do
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
    if self:initStore() then
        store.init(storeName, function(event) scene:storeTransaction(event) end)

        if store.canLoadProducts then
            -- attempt to read product lists from the inapp store
            --self:showStatus("Reading product list from store: "..tostring(storeName))

            -- build product list to load
            local list = {}
            for key,_ in pairs(productData.planets) do list[#list+1] = key end
            for key,_ in pairs(productData.gear)    do list[#list+1] = key end
            for key,_ in pairs(productData.special) do list[#list+1] = key end

            store.consumePurchase(list, function(event) self:showStatus("consumed products") end)
            store.loadProducts(list, function(event) self:storeProductsLoaded(event) end)
        else
            --self:showStatus("Store does not allow loading of products: "..tostring(storeName))
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
        --self:showStatus("In-app purchases are not supported in the Corona Simulator")
        return false
    end
end


-- Called when store.loadProducts completes
function scene:storeProductsLoaded(event)
    --self:showStatus("Product list loaded. products: "..#event.products.." invalidProducts: "..#event.invalidProducts)

    for i=1, #event.products do
        local product = event.products[i]
        local pid     = product.productIdentifier
        local price   = product.localizedPrice
        
        --[[local s = tostring(i)..". valid: "
        for k,v in pairs(product) do
            s = s..tostring(k).."="..tostring(v)..", "
        end
        self:showStatus(s)]]

        if price then
            if productData.planets[pid] then productData.planets[pid].cost = price end
            if productData.gear[pid]    then productData.gear[pid].cost    = price end
            if productData.special[pid] then productData.special[pid].cost = price end
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

    newImage(planetGroup,  "inapp-purchases/bgr", centerX, centerY)
    newImage(gearGroup,    "inapp-purchases/bgr", centerX, centerY)
    newImage(specialGroup, "inapp-purchases/bgr", centerX, centerY)

    self:buildPlanetPage(planetGroup)
    self:buildGearPage(gearGroup)
end


function scene:buildPlanetPage(planetGroup)
    newImage(planetGroup, "inapp-purchases/planet-text", centerX, 560)

    self:newPlanetBuyer(planetGroup, 1, true,  190)
    self:newPlanetBuyer(planetGroup, 2, true,  centerX)
    self:newPlanetBuyer(planetGroup, 3, false, 800)
end


function scene:buildGearPage(gearGroup)
    newImage(gearGroup, "inapp-purchases/iap-gear-jump", 190,     280)
    newImage(gearGroup, "inapp-purchases/iap-gear-air",  centerX, 280)
    newImage(gearGroup, "inapp-purchases/iap-gear-land", 800,     280)
    newImage(gearGroup, "inapp-purchases/iap-gear-all",  centerX, 540)

    self:newGearBuyers(gearGroup, 130, 335, "gear_pack_jump_small",       "gear_pack_jump_large")
    self:newGearBuyers(gearGroup, 425, 335, "gear_pack_air_small",        "gear_pack_air_large")
    self:newGearBuyers(gearGroup, 740, 335, "gear_pack_land_small",       "gear_pack_land_large")
    self:newGearBuyers(gearGroup, 750, 535, "gear_pack_everything_small", "gear_pack_everything_large")
end


function scene:newPlanetBuyer(planetGroup, planet, available, xpos)
    local productId = "planet_pack"..planet
    local product   = productData.planets[productId]

    newImage(planetGroup, "inapp-purchases/iap-planet"..planet, xpos, 280)

    if available then
        self:newBand(planetGroup, xpos, 400, 230, 70)

        local purchasedText = newText(planetGroup, "purchased!", xpos, 400, 0.8, "green", "CENTER")

        if not state:hasPurchased(productId) then
            purchasedText.alpha = 0

            local b1, b2 = newButton(planetGroup, xpos-40, 400, "buy", function() scene:purchase(product) end)
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
    local iapSmall = productData.gear[nameSmall]
    local iapLarge = productData.gear[nameLarge]

    local b1, b1o = newButton(group, x, y,    "buy", function() scene:purchase(iapSmall) end, nil, 0.7)
    local b2, b2o = newButton(group, x, y+60, "buy", function() scene:purchase(iapLarge) end, nil, 0.7)

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

    planetMenu:addEventListener("tap",  function() scene:showPage("planet",  true) end)
    gearMenu:addEventListener("tap",    function() scene:showPage("gear",    true) end)
    specialMenu:addEventListener("tap", function() scene:showPage("special", true) end)

    self.menu = {
        ["planet"]  = planetMenu,
        ["gear"]    = gearMenu,
        ["special"] = specialMenu,
    }
end


function scene:showPage(page, hideStatus)
    if hideStatus then self:hideStatus() end

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


-- Use for TESTING on simulator
function scene:purchase(product)
    transactionProduct = product
    self:hideStatus()
    self:storeTransaction({transaction={state="purchased"}})
end

--[[
-- Use for Real Transactions
function scene:purchase(product)
    self:hideStatus()

    self:storeTransaction({transaction={state="purchased"}})
    
    if store == nil then
        self:showStatus("Purchase "..product.id.." failed: purchases not available as no store loaded")
        return
    end

    if store.canMakePurchases then
        transactionProduct = product

        if googleIAP then
            self:showStatus("Purchasing "..product.id.." from Google Play Store")
            store.purchase(product.id)
        else
            self:showStatus("Purchasing "..product.id.." from Apple App Store")
            store.purchase({product.id})
        end
    else
        self:showStatus("Store purchases have been disabled in phone settings")
    end
end
]]

function scene:storeTransaction(event)
    local self        = scene
    local transaction = event.transaction

    if transaction.state == "purchased" then
        play(sounds.shopPurchase)
        
        local planet = transactionProduct.planet
        local gear   = transactionProduct.gear
        local size   = transactionProduct.size

        if planet then
            if     planet == 1 then self:purchasedPlanetPack1()
            elseif planet == 2 then self:purchasedPlanetPack2() end
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

    elseif transaction.state == "cancelled" then
        play(sounds.shopCantBuy)
        self:showStatus("Purchase cancelled: "..tostring(transaction.productIdentifier))
    else
        play(sounds.shopCantBuy)
        self:showStatus("Purchase other status: "..tostring(transaction.state).." "..tostring(transaction.productIdentifier))
    end

    if store then
        store.finishTransaction(transaction)
    end
end


--------------------- SUCCESSFULL PURCHASE HANDLERS - ACTIVATE PURCHASES ---------------------


function scene:purchasedPlanetPack1()
    self:unlockPlanetPack(1, characterKranio)
    self:displayPlanetUnlocked(1)
end


function scene:purchasedPlanetPack2()
    self:unlockPlanetPack(2, characterReneGrey)
    self:displayPlanetUnlocked(2)
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
end


function scene:addJumpGear(quantity)
    for i=1, quantity do
        state:addGear(jump, gearSpringShoes)
        state:addGear(jump, gearShield)
        state:addGear(jump, gearFreezeTime)
        state:addGear(jump, gearTrajectory)
    end
end


function scene:addAirGear(quantity)
    for i=1, quantity do
        state:addGear(air, gearGlider)
        state:addGear(air, gearParachute)
        state:addGear(air, gearJetpack)
        state:addGear(air, gearReverseJump)
    end
end


function scene:addLandGear(quantity)
    for i=1, quantity do
        state:addGear(land, gearGrappleHook)
        state:addGear(land, gearGloves)
    end
end


-- Googles requires some items to be consumed to buy again
function scene:consumeProduct()
    if googleIAP then
        store.consumePurchase({transactionProduct.id}, function(event) 
            show:setStatus("consumed product: "..transactionProduct.id)
        end)
    end
end


function scene:displayPlanetUnlocked(planet)
    local productId = transactionProduct.id
    local product   = productData.planets[productId]

    product.labelPurchased.alpha = 1
    product.labelPrice.alpha     = 0

    product.buyButton1:removeSelf()
    product.buyButton2:removeSelf()
    product.buyButton1 = nil
    product.buyButton2 = nil
end


function scene:displayGearPurchased()
    --self:displayMessage(message, color)
end


----- GENERAL -----


function scene:showStatus(text)
    self:hideStatus()
    print(text)

    self.statusGroup = display.newGroup()
    self.view:insert(self.statusGroup)

    local bgr = display.newRoundedRect(self.statusGroup, centerX, 150, 880, 100, 15)
    bgr:setFillColor(0.3,    0.3,  0.3,  0.85)
    bgr:setStrokeColor(0.75, 0.75, 0.75, 0.75)
    bgr.strokeWidth = 2

    display.newText({parent=self.statusGroup, text=text, x=centerX, y=330, width=900, height=400, fontSize=22, align="center"})
end


function scene:hideStatus()
    if self.statusGroup then
        self.statusGroup:removeSelf()
        self.statusGroup = nil
    end
end


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
    seq:tran({time=750, scale=0, alpha=0})
    seq:start()
end


function scene:exitInApPurchases()
    loadSceneTransition(1)
    after(10, function() storyboard:gotoScene(state:backScene()) end)
    return true
end


-- Called when scene is about to move offscreen:
function scene:exitScene(event)
    Runtime:removeEventListener("key", sceneKeyEvent)
    track:cancelEventHandles()
    anim:destroy()

    for _,planet in pairs(productData.planets) do
        if planet.labelPrice then
            planet.labelPrice:removeSelf();  planet.labelPrice = nil
        end

        if planet.labelPurchased then
            planet.labelPurchased:removeSelf();  planet.labelPurchased = nil
        end

        if planet.buyButton1 then
            planet.buyButton1:removeSelf();  planet.buyButton1 = nil
        end

        if planet.buyButton2 then
            planet.buyButton2:removeSelf();  planet.buyButton2 = nil
        end
    end

    self.pages = nil
    self.menu  = nil
end


-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
    storyboard.purgeScene("scenes.inapp-puchases")
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