local storyboard = require("storyboard")
local anim       = require("core.animations")
local scene      = storyboard.newScene()

-- Aliases:
local play = globalSoundPlayer

-- Local vars:
local IAPData = {
    planets = {
        ["planet-pack-1"] = { cost = 0.99,  label = "99p" },
        ["planet-pack-2"] = { cost = 0.99,  label = "99p" },
        ["planet-pack-3"] = { cost = "n/a", label = "coming soon" },
    },
    gear = {
        ["small-jump-gear"] = { cost = 0.49, label="49p",   quantity = 5 },
        ["small-air-gear"]  = { cost = 0.49, label="49p",   quantity = 5 },
        ["small-land-gear"] = { cost = 0.29, label="29p",   quantity = 5 },
        ["large-jump-gear"] = { cost = 0.79, label="79p",   quantity = 10 },
        ["large-air-gear"]  = { cost = 0.79, label="79p",   quantity = 10 },
        ["large-land-gear"] = { cost = 0.49, label="49p",   quantity = 10 },
        ["small-all-gear"]  = { cost = 1.00, label="99p",   quantity = 5  },
        ["large-all-gear"]  = { cost = 1.79, label="£1.79", quantity = 10 },
    },
    special = {
        -- NONE
    }
}


-- Called when the scene's view does not exist:
function scene:createScene(event)
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene(event)
    logAnalytics("inapp-purchases", "enterScene")
    state:newScene("inapp-purchases")

    self.dontPlaySound = true
    self:buildPages()
    self:buildMenu()

    if state.inappPurchaseType == "planet" then
        self:showPage("planet")
    elseif state.inappPurchaseType == "special" then
        self:showPage("special")
    else
        self:showPage("gear")
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

    newImage(planetGroup,  "inapp-purchases/bgr-planet",  centerX, centerY)
    newImage(gearGroup,    "inapp-purchases/bgr-gear",    centerX, centerY)
    newImage(specialGroup, "inapp-purchases/bgr-special", centerX, centerY)

    -- Gear pack purchase info
    newImage(gearGroup, "inapp-purchases/iap-gear-jump", 190,     280)
    newImage(gearGroup, "inapp-purchases/iap-gear-air",  centerX, 280)
    newImage(gearGroup, "inapp-purchases/iap-gear-land", 800,     280)
    newImage(gearGroup, "inapp-purchases/iap-gear-all",  centerX, 540)

    self:newGearBuyers(gearGroup, 130, 335, "small-jump-gear", "large-jump-gear")
    self:newGearBuyers(gearGroup, 425, 335, "small-air-gear",  "large-air-gear")
    self:newGearBuyers(gearGroup, 740, 335, "small-land-gear", "large-land-gear")
    self:newGearBuyers(gearGroup, 750, 535, "small-all-gear",  "large-all-gear")

    -- Planet pack purchase info
    newImage(planetGroup, "inapp-purchases/iap-planet1", 190,     280)
    newImage(planetGroup, "inapp-purchases/iap-planet2", centerX, 280)
    newImage(planetGroup, "inapp-purchases/iap-planet3", 800,     280)
    newImage(planetGroup, "inapp-purchases/planet-text", centerX, 560)

    scene:newBand(planetGroup, 190,     400, 230, 70)
    scene:newBand(planetGroup, centerX, 400, 230, 70)

    newButton(planetGroup, 160, 400, "buy", function() scene:purchase(IAPData.planets["planet-pack-1"]) end)
    newButton(planetGroup, 450, 400, "buy", function() scene:purchase(IAPData.planets["planet-pack-2"]) end)
    
    newText(planetGroup, IAPData.planets["planet-pack-1"].label, 255, 400, 0.6, "white")
    newText(planetGroup, IAPData.planets["planet-pack-2"].label, 545, 400, 0.6, "white")

    local soon = newText(planetGroup, "coming soon", 780, 400, 0.8, "red", "CENTER")
    soon:rotate(15)

    self.pages = {
        ["planet"]  = planetGroup,
        ["gear"]    = gearGroup,
        ["special"] = specialGroup
    }
end


function scene:newGearBuyers(group, x, y, nameSmall, nameLarge)
    local iapSmall = IAPData.gear[nameSmall]
    local iapLarge = IAPData.gear[nameLarge]

    newButton(group, x, y,    "buy", function() scene:purchase(iapSmall) end, nil, 0.7)
    newButton(group, x, y+60, "buy", function() scene:purchase(iapLarge) end, nil, 0.7)

    newText(group, iapSmall.label, x+50, y+5,  0.4, "white", "LEFT")
    newText(group, iapLarge.label, x+50, y+65, 0.4, "white", "LEFT")

    local l1 = display.newText(group, iapSmall.quantity.." of each", x+90, y-15, "arial", 18)
    local l2 = display.newText(group, iapLarge.quantity.." of each", x+90, y+45, "arial", 18)
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
    if self.dontPlaySound then
        self.dontPlaySound = false
    else
        play(sounds.hudClick)
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


function scene:purchase(product)

end


function scene:activateOption(option)
    local seq = anim:oustSeq("menuActivate", option)
    seq:tran({time=250, scale=1.5})
    seq:tran({time=500, scale=0.01})
    seq:start()
end


function scene:exitInApPurchases()
    loadSceneTransition(1)
    after(10, function() storyboard:gotoScene(state:backScene()) end)
    return true
end


-- Called when scene is about to move offscreen:
function scene:exitScene(event)
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