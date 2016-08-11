local composer = require("composer")
local adverts  = require("core.adverts")


-- Items the scenes can dynamically load in, where they are used in multiple scenes
local sharedScene = {}


-- Loads in function to show popup triggering reward video and firing fruit machine afterward
function sharedScene:loadFruityMachine(scene)

	-- Triggers reward video and handles callback reward
	function scene:exitToFruityMachine()
	    if not scene.blockInput and not scene.tappedRewardVideo then
	        scene.tappedRewardVideo = true

	        local group  = display.newGroup()
	        local prompt = newImage(group, "message-tabs/tutorial-leftbox",   700, 450)
	        local text   = newText(group,  "watch a video to earn a reward?", 700, 380, 0.37, "white")

	        local handler = function()
	            if not scene.blockInput then
	                scene.blockInput         = true
	                state.musicSceneContinue = false

	                audio.fadeOut({channel=scene.musicChannel, time=1000})

	                after(4000, function() scene.blockInput = false end)

	                --adverts:loadRewardVideoAdvert(function() composer.gotoScene("scenes.fruit-machine") end)
	                composer.gotoScene("scenes.fruit-machine")
	            end
	        end

	        newButton(group, 700, 440, "playvideo", handler, nil, nil, 0.9)

	        scene.rewardVideoPrompt = group
	        scene.view:insert(group)
	    else
	        scene:removeFruityMachine()
	    end
	    return true
	end

	-- Cleans up the fruity machine scene members
	function scene:removeFruityMachine()
	    if scene.rewardVideoPrompt then
	        scene.rewardVideoPrompt:removeSelf()
	        scene.rewardVideoPrompt = nil
	        scene.tappedRewardVideo = false
	    end
	end

end


return sharedScene