local coronaAds = require("plugin.coronaAds")
local vungleAds = require("ads")


local adverts = {
	-- a counter which shows how many adverts we have forced the player to see
	forcedAdsShown     = 0,
	-- a counter which tracks checks to see if we should force an add on a player
	forcedAdsChecks    = 0,
	-- the number of times that a check to see if we should force an ad on a player, before we show one
	forcedAdsFrequency = 3,

	-- config settings for the corona ads account
	corona = {
		initialised = false,
		apiKey      = "5223c2c3-cf81-4c43-ae41-2d4ed16552bc"
		--apiKey      = "a69eadfe-d8e2-424f-8c2f-41a6ac3b9e79"
	},
	-- config settings for the vungle ads account
	vungle = {
		["Android"]   = "57158296f49eec2152000024",
		["iPhone OS"] = "57644672a6d78e284600006f",
	},
}


-- Force user to view an advert and track that we've shown them one
function adverts:forceAdvert()
	self.forcedAdsShown = self.forcedAdsShown + 1

	self:showStaticAdvert()
end


-- Checks if we should show and advert and tracks checks, so every N calsl will trigger an advert
function adverts:checkShowAdvert()
	self.forcedAdsChecks = self.forcedAdsChecks + 1

	if self.forcedAdsChecks >= self.forcedAdsFrequency then
		self:forceAdvert()
	end
end


-- Show a full-screen non video advert
function adverts:showStaticAdvert()
	local advertId = "interstitial-1"

    local function adListener(event)
    	self:debugAdvertEvent(event)
    	
        if event.phase == "init" then
        	-- Only show the first time this is called (after init)
        	if self.corona.initialised == false then
        	    self.corona.initialised = true
        	    self.forcedAdsChecks    = 0

            	coronaAds.show(advertId, true)
            end
        end
    end

    displayDebugPanel("show static advert: "..advertId.." api-key: "..self.corona.apiKey)

    if self.corona.initialised then
    	coronaAds.show(advertId, true)
    	self.forcedAdsChecks = 0
    else
    	coronaAds.init(self.corona.apiKey, adListener)
    end
    
end


-- Show a full-screen video advert
function adverts:loadVideoAdvert()
	self:loadVungleAdvert("interstitial")
end


-- Show a full screen video advert which triggers a callback if the video is fully viewed
function adverts:loadRewardVideoAdvert(successCallback)
	self:loadVungleAdvert("incentivized", successCallback)
end


function adverts:loadVungleAdvert(advertType, successCallback)
	local appId = self.vungle[system.getInfo("platformName")]

	-- listener triggered by ad provider
    local function adListener(event)
    	for property, value in pairs(event) do
    		self:debugAdvertEvent(event)

            if property == "isCompletedView" and (value == true or value == "true") and successCallback then
            	successCallback()
            end
        end
    end

    displayDebugPanel("init video advert: "..appId)

    vungleAds.init("vungle", appId, adListener)
	
	self.attempts = 0
	self:checkVungleAdvert(advertType)
end


-- As it takes a while to load, we check every 250ms for up to 5 seconds for response of video ad
function adverts:checkVungleAdvert(advertType)
	if vungleAds.isAdAvailable() then
		vungleAds.show(advertType, { isBackButtonEnabled=true })
    else
    	self.attempts = self.attempts + 1

    	if self.attempts >= 20 then
    		updateDebugPanel("video advert not available")
    	else
    		updateDebugPanel(", "..self.attempts, true)
    		after(250, function() self:checkVungleAdvert(advertType) end)
    	end
    end
end


function adverts:debugAdvertEvent(event)
	if globalDebugStatus then
		local text = "[event: "
		for k,v in pairs(event) do
			if k then
				text = text..tostring(k).."="..tostring(v).." "
			end
		end
		text = text.."]"
		updateDebugPanel(text)
	end
end


return adverts