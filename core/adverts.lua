local adverts = {
	-- config settings for the corona ads account
	coronaAds = {
		apiKey = "5223c2c3-cf81-4c43-ae41-2d4ed16552bc"
	},
	-- config settings for the vungle ads account
	vungleAds = {
		appId = "57158296f49eec2152000024"
	},
}


-- Show a full-screen non video advert
function adverts:showStaticAdvert()
    local coronaAds   = require("plugin.coronaAds")
    local adPlacement = "interstitial-1"

    local function adListener(event)
        -- Successful initialization of Corona Ads
        if event.phase == "init" then
            coronaAds.show(adPlacement, true)
        end
    end

    coronaAds.init(self.coronaAds.apiKey, adListener)
end


-- Show a full-screen video advert
function adverts:loadVideoAdvert()
	self:loadVungleAdvert("interstitial")
end


-- Show a full screen video advert which triggers a callback if the video is fully viewed
function adverts:loadRewardVideoAdvert(successCallback)
	self:loadVungleAdvert("incentivized")
end


function adverts:loadVungleAdvert(advertType, successCallback)
	local ads = require("ads")

    local function adListener(event)
    	for property, value in pairs(event) do
            if property == "isCompletedView" and (value == true or value == "true") and successCallback then
            	successCallback()
            end
        end
    end
    
    ads.init("vungle", self.vungleAds.appId, adListener)

    -- Optional table containing targeting parameters
    local targetingParams = { tagForChildDirectedTreatment = true }

    ads.show(advertType, { isBackButtonEnabled=true })
end


return adverts