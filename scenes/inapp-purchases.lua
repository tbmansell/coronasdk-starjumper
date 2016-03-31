local storyboard = require("storyboard")
local anim       = require("core.animations")
local particles  = require("core.particles")
local scene      = storyboard.newScene()

-- Local vars:
local store       = nil
local storeName   = nil
local googleIAP   = false
local productList = nil
local transactionProduct = nil

local appleProductList = {
    "planet_pack1",
    "planet_pack2",
    "gear_pack_jump_small",
    "gear_pack_air_small",
    "gear_pack_land_small",
    "gear_pack_jump_large",
    "gear_pack_air_large",
    "gear_pack_land_large",
    "gear_pack_everything_small",
    "gear_pack_everything_large",
    "com.weaksaucegames.StarJumper.planet_pack1",
    "com.weaksaucegames.StarJumper.planet_pack2",
    "com.weaksaucegames.StarJumper.gear_pack_jump_small",
    "com.weaksaucegames.StarJumper.gear_pack_air_small",
    "com.weaksaucegames.StarJumper.gear_pack_land_small",
    "com.weaksaucegames.StarJumper.gear_pack_jump_large",
    "com.weaksaucegames.StarJumper.gear_pack_air_large",
    "com.weaksaucegames.StarJumper.gear_pack_land_large",
    "com.weaksaucegames.StarJumper.gear_pack_everything_small",
    "com.weaksaucegames.StarJumper.gear_pack_everything_large",
}

local googleProductList = {
    "planet_pack1",
    "planet_pack2",
    "gear_pack_jump_small",
    "gear_pack_air_small",
    "gear_pack_land_small",
    "gear_pack_jump_large",
    "gear_pack_air_large",
    "gear_pack_land_large",
    "gear_pack_everything_small",
    "gear_pack_everything_large",
    "com.weaksaucegames.StarJumper.planet_pack1",
    "com.weaksaucegames.StarJumper.planet_pack2",
    "com.weaksaucegames.StarJumper.gear_pack_jump_small",
    "com.weaksaucegames.StarJumper.gear_pack_air_small",
    "com.weaksaucegames.StarJumper.gear_pack_land_small",
    "com.weaksaucegames.StarJumper.gear_pack_jump_large",
    "com.weaksaucegames.StarJumper.gear_pack_air_large",
    "com.weaksaucegames.StarJumper.gear_pack_land_large",
    "com.weaksaucegames.StarJumper.gear_pack_everything_small",
    "com.weaksaucegames.StarJumper.gear_pack_everything_large",
    -- these product IDs are for testing and are supported by all Android apps
    "android.test.purchased",
    "android.test.canceled",
    "android.test.refunded",
    "android.test.item_unavailable",
}

local IAPData = {
    -- how many of each gear is purchased for pack sizes
    quantitySmall = 5,
    quantityLarge = 10,

    planets = {
        ["planet_pack1"]                = { id="planet_pack1",                  cost=0.99 },
        ["planet_pack2"]                = { id="planet_pack2",                  cost=0.99 },
        ["planet_pack3"]                = { id="planet_pack3",                  cost="n/a" },
    },
    gear = {
        ["gear_pack_jump_small"]        = { id="gear_pack_jump_small",          cost=0.50, },
        ["gear_pack_air_small"]         = { id="gear_pack_air_small",           cost=0.50, },
        ["gear_pack_land_small"]        = { id="gear_pack_land_small",          cost=0.50, },
        ["gear_pack_jump_large"]        = { id="gear_pack_jump_large",          cost=0.85, },
        ["gear_pack_air_large"]         = { id="gear_pack_air_large",           cost=0.85, },
        ["gear_pack_land_large"]        = { id="gear_pack_land_large",          cost=0.85, },
        ["gear_pack_everything_small"]  = { id="gear_pack_everything_small",    cost=1.00, },
        ["gear_pack_everything_large"]  = { id="gear_pack_everything_large",    cost=1.79, },
    },
    special = {
        -- NONE
    }
--[[
    planets = {
        ["planet_pack1"]                = { id="planet_pack1",                  cost=0.99,  label="99p" },
        ["planet_pack2"]                = { id="planet_pack2",                  cost=0.99,  label="99p" },
        ["planet_pack3"]                = { id="planet_pack3",                  cost="n/a", label="coming soon" },
    },
    gear = {
        ["gear_pack_jump_small"]        = { id="gear_pack_jump_small",          cost=0.50,  label="50p",   quantity = 5 },
        ["gear_pack_air_small"]         = { id="gear_pack_air_small",           cost=0.50,  label="50p",   quantity = 5 },
        ["gear_pack_land_small"]        = { id="gear_pack_land_small",          cost=0.50,  label="50p",   quantity = 5 },
        ["gear_pack_jump_large"]        = { id="gear_pack_jump_large",          cost=0.85,  label="85p",   quantity = 10 },
        ["gear_pack_air_large"]         = { id="gear_pack_air_large",           cost=0.85,  label="85p",   quantity = 10 },
        ["gear_pack_land_large"]        = { id="gear_pack_land_large",          cost=0.85,  label="85p",   quantity = 10 },
        ["gear_pack_everything_small"]  = { id="gear_pack_everything_small",    cost=1.00,  label="£1.00", quantity = 5  },
        ["gear_pack_everything_large"]  = { id="gear_pack_everything_large",    cost=1.79,  label="£1.79", quantity = 10 },
    },
    special = {
        -- NONE
    }
]]
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
    Runtime:addEventListener("key", sceneKeyEvent)

    if self:initStore() then
        store.init(storeName, scene.storeTransaction)

        if store.canLoadProducts then
            -- attempt to read product lists from the inapp store
            self:showStatus("Reading product list from store: "..tostring(storeName))

            store.loadProducts(productList, function(event) 
                self:showStatus("Product list loaded. #Products: "..#event.products)

                for i=1, #event.products do
                    after(i*5000, function() 
                        local p = event.products[i]

                        self:showStatus(i..". "..tostring(p.productIdentifier)..", "..tostring(p.title)..", "..tostring(p.price))
                    end)
                end
            end)
        else
            self:showStatus("Store does not allow loading of products: "..storeName)
        end
    end

    self:setupProducts()
end


function scene:initStore()
    if (system.getInfo("platformName") == "Android") then
        store       = require("plugin.google.iap.v3")
        storeName   = "google"
        productList = googleProductList
        googleIAP   = true
        return true
    elseif (system.getInfo("platformName") == "iPhone OS") then
        store       = require("store")
        storeName   = "apple"
        productList = appleProductList
        return true
    else
        storeName   = "unknown"
        self:showStatus("In-app purchases are not supported in the Corona Simulator")
        return false
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
    for id, product in pairs(IAPData[category]) do
        product.id    = id
        product.label = self:createCostLabel(product.cost)
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


-- Called immediately after scene has moved onscreen:
function scene:enterScene(event)
    Runtime:addEventListener("key", sceneKeyEvent)
    
    logAnalytics("inapp-purchases", "enterScene")
    state:newScene("inapp-purchases")
    clearSceneTransition()

    self.dontPlaySound = true
    self.page = state.inappPurchaseType

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
    newImage(planetGroup, "inapp-purchases/iap-planet1", 190,     280)
    newImage(planetGroup, "inapp-purchases/iap-planet2", centerX, 280)
    newImage(planetGroup, "inapp-purchases/iap-planet3", 800,     280)
    newImage(planetGroup, "inapp-purchases/planet-text", centerX, 560)

    self:newBand(planetGroup, 190,     400, 230, 70)
    self:newBand(planetGroup, centerX, 400, 230, 70)

    local b1, b1o = newButton(planetGroup, 160, 400, "buy", function() scene:purchase(IAPData.planets["planet_pack1"]) end)
    local b2, b2o = newButton(planetGroup, 450, 400, "buy", function() scene:purchase(IAPData.planets["planet_pack2"]) end)

    self:animate(b1, b1o)
    self:animate(b2, b2o)
    
    newText(planetGroup, IAPData.planets["planet_pack1"].label, 255, 400, 0.6, "white")
    newText(planetGroup, IAPData.planets["planet_pack2"].label, 545, 400, 0.6, "white")

    local soon = newText(planetGroup, "coming soon", 780, 400, 0.8, "red", "CENTER")
    soon:rotate(15)
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


function scene:newGearBuyers(group, x, y, nameSmall, nameLarge)
    local iapSmall = IAPData.gear[nameSmall]
    local iapLarge = IAPData.gear[nameLarge]

    local b1, b1o = newButton(group, x, y,    "buy", function() scene:purchase(iapSmall) end, nil, 0.7)
    local b2, b2o = newButton(group, x, y+60, "buy", function() scene:purchase(iapLarge) end, nil, 0.7)

    self:animate(b1, b1o, {baseScale=0.7})
    self:animate(b2, b2o, {baseScale=0.7})

    newText(group, iapSmall.label, x+50, y+5,  0.4, "white", "LEFT")
    newText(group, iapLarge.label, x+50, y+65, 0.4, "white", "LEFT")

    local l1 = display.newText(group, IAPData.quantitySmall.." of each", x+90, y-15, "arial", 18)
    local l2 = display.newText(group, IAPData.quantityLarge.." of each", x+90, y+45, "arial", 18)
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


function scene:showStatus(text)
    self:hideStatus()
    print(text)

    self.statusGroup = display.newGroup()
    self.view:insert(self.statusGroup)

    local bgr = display.newRoundedRect(self.statusGroup, centerX, 150, 880, 100, 15)
    bgr:setFillColor(0.3,    0.3,  0.3,  0.85)
    bgr:setStrokeColor(0.75, 0.75, 0.75, 0.75)
    bgr.strokeWidth = 2

    --display.newText(self.statusGroup, text, centerX, 180, 900, 100, "arial", 22)
    display.newText({parent=self.statusGroup, text=text, x=centerX, y=180, width=900, height=100, fontSize=22, align="center"})
end


function scene:hideStatus()
    if self.statusGroup then
        self.statusGroup:removeSelf()
        self.statusGroup = nil
    end
end


function scene:purchase(product)
    self:hideStatus()

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


function scene:storeTransaction(event)
    local self        = scene
    local transaction = event.transaction

    if transaction.state == "purchased" then
        self:showStatus("Purchase successful: "..tostring(transaction.productIdentifier))
        transactionProduct.purchaseSuccess()

    elseif transaction.state == "cancelled" then
        self:showStatus("Purchase cancelled: "..tostring(transaction.productIdentifier))

    else
        self:showStatus("Purchase other status: "..tostring(transaction.state).." "..tostring(transaction.productIdentifier))

    end

    store.finishTransaction(transaction)
end


--------------------- SUCCESSFULL PURCHASE HANDLERS - ACTIVATE PURCHASES ---------------------


function scene:purchasedPlanetPack1()
    local self = scene
end


function scene:purchasedPlanetPack2()
    local self = scene
end





function scene:animate(item, item2, params)
    local params = params or {}
    self.pulseId = (self.pulseId or 0) + 1

    local seq   = anim:oustSeq("pulse-"..self.pulseId, item)
    seq.target2 = item2
    seq:add("pulse", {time=1500, scale=0.035, baseScale=params.baseScale})
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