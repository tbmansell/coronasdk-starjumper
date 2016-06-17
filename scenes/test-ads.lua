local composer = require("composer")
local scene    = composer.newScene()



function scene:create(event)
    local group = self.view
end


function scene:show(event)
	local group = self.view

    if event.phase == "did" then
    	local reload  = newText(group, "reload scene ", 100, 100, 0.5, "white", "LEFT")

    	--local adMob1  = newText(group, "admob: standard ads ", 100, 250, 0.5, "yellow", "LEFT")
    	--local adMob2  = newText(group, "admob: video reward",  100, 350, 0.5, "yellow", "LEFT")

    	local corona1  = newText(group, "corona: banner ads ",   100, 250, 0.5, "yellow", "LEFT")
    	local corona2  = newText(group, "corona: interstitial",  100, 350, 0.5, "yellow", "LEFT")

    	local vungle1 = newText(group, "vungle: standard ads",  450, 250, 0.5, "aqua", "LEFT")
    	local vungle2 = newText(group, "vungle: video reward",  450, 350, 0.5, "aqua", "LEFT")


    	reload:addEventListener("tap", function() composer.gotoScene("scenes.test-ads"); return true end)

    	--adMob1:addEventListener("tap", function() return self:loadAdMobAdvert("ca-app-pub-1657862030086732/6006768804") end)
    	--adMob2:addEventListener("tap", function() return self:loadAdMobAdvert("ca-app-pub-1657862030086732/2588765600") end)

    	corona1:addEventListener("tap", function() return self:loadCoronaAdvert("banner") end)
    	corona2:addEventListener("tap", function() return self:loadCoronaAdvert("interstitial") end)

    	vungle1:addEventListener("tap", function() return self:loadVungleAdvert("interstitial") end)
    	vungle2:addEventListener("tap", function() return self:loadVungleAdvert("incentivized") end)
    end
end



function scene:setupStatus()
    local bgr = display.newRoundedRect(self.view, centerX, centerY, 1000, 700, 15)
    bgr:setFillColor(0.3,    0.3,  0.3,  0.85)
    bgr:setStrokeColor(0.75, 0.75, 0.75, 0.75)
    bgr.strokeWidth = 2

    self.statusText = display.newText({parent=self.view, text="", x=centerX, y=centerY, width=900, height=600, fontSize=22, align="center"})
end


function scene:showStatus(text)
    print(text)
    self.statusText.text = self.statusText.text.."\n"..text
end


-- AdMob: standard ads:
-- App ID:     ca-app-pub-1657862030086732~1112032405
-- Ad unit ID: ca-app-pub-1657862030086732/6006768804

-- AdMob: Video Level Skip:
-- Ad unit ID: ca-app-pub-1657862030086732/2588765600
function scene:loadAdMobAdvert(advertId)
    scene:setupStatus()

    local ads = require("ads")

    local function adListener(event)
        scene:showStatus("phase: ["..tostring(event.phase).."]")

        local s=""
        for k, v in pairs(event) do
            s=s..tostring(k)..": "..tostring(v)..", "
        end
        scene:showStatus(s)
    end
    
    ads.init("admob", "ca-app-pub-1657862030086732~1112032405", adListener)
    --ads.init("admob", advertId, adListener)

    -- Optional table containing targeting parameters
    local targetingParams = { tagForChildDirectedTreatment = true }

    --ads.show("interstitial", { x=0, y=0, targetingOptions=targetingParams, appId=advertId })
    ads.show("interstitial", { x=0, y=0, targetingOptions=targetingParams, appId=advertId })

    return true
end


function scene:loadCoronaAdvert(advertType)
     local coronaAds = require("plugin.coronaAds")

     -- Substitute your own placement IDs when generated
     local bannerPlacement       = "top-banner-320x50"
     local interstitialPlacement = "interstitial-1"

     -- Corona Ads listener function
     local function adListener(event)
         -- Successful initialization of Corona Ads
         if event.phase == "init" then
             -- Show an ad
             if advertType == "banner" then
             	coronaAds.show(bannerPlacement, false)
             else
             	coronaAds.show(interstitialPlacement, true)
             end
         end
     end

     -- Initialize Corona Ads (substitute your own API key when generated)
     coronaAds.init("5223c2c3-cf81-4c43-ae41-2d4ed16552bc", adListener)
end


function scene:loadVungleAdvert(advertType)
	scene:setupStatus()

    local ads = require("ads")

    local function adListener(event)
        scene:showStatus("phase: ["..tostring(event.phase).."]")

        local s=""
        for k, v in pairs(event) do
            s=s..tostring(k)..": "..tostring(v)..", "

            if k == "isCompletedView" and (v == true or v == "true") then
            	s = s.." **woowoo completed**, "
            end
        end
        scene:showStatus(s)
    end
    
    ads.init("vungle", "57158296f49eec2152000024", adListener)

    -- Optional table containing targeting parameters
    local targetingParams = { tagForChildDirectedTreatment = true }

    ads.show(advertType, { isBackButtonEnabled=true, username="guest" })
    
    return true
end


function scene:loadRevMobAdverts()
    scene:setupStatus()

    local appId       = "5715395cee3708361bcdbfba"  -- App User ID
    local placementId = "571539f7b52620eb62377fb2"
    local revmob      = require("plugin.revmob")

    local function adListener(event)
        scene:showStatus("phase: ["..tostring(event.phase).."]")

        local s=""
        for k, v in pairs(event) do
            s=s..tostring(k)..": "..tostring(v)
        end

        --scene:showStatus(s)

        if event.phase == "init" then  -- Successful initialization
            --scene:showStatus("init: "..tostring(event.isError))
            revmob.load("video", placementId)

        elseif event.phase == "loaded" then  -- The ad was successfully loaded
            --scene:showStatus("loaded: "..tostring(event.type))
            revmob.show(placementId, { yAlign="top" })

        elseif event.phase == "failed" then  -- The ad failed to load
            --scene:showStatus("failed: "..tostring(event.type).." "..tostring(event.isError).." "..tostring(event.response))
        end
    end

    revmob.init(adListener, { appId=appId })
    --local loaded = revmob.isLoaded(placementId)
    --scene:showStatus("Loaded: "..tostring(loaded))
end


function scene:hide(event)
    if event.phase == "did" then
        composer.removeScene("scenes.test-ads")
    end
end


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