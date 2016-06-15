local scripts = {
	["intro-planet1-zone1"] = {
		sequence = {
			[1] = {
				actions     = { {name="select-gear", target=gearTrajectory} },
				showNote    = { delay=3000, image="leftbox", x=181, y=500, size=0.6, text="select trajectory jump equipment", color="white", textY=-20, inCamera=false },
				showSpeech  = { delay=0, speaker=characterGygax, dir=right, y=50, text="Ok {player}, I will help you through this zone to get you started. I'll be supplying you some precious jump trajectory equipment to learn jumping"
				},
			},
			[2] = {
				actions     = { {name="prepare-jump", target=nil} },
				showNote    = { image="reverseleftbox", x=284, y=440, size=0.6, text="drag from feet to prepare a jump", color="white", textY=0, inCamera=true },
			},
			[3] = {
				actions     = { {name="jump", target=nil, params={pullx=-100, pully=150}} },
				showSpeech  = { delay=0, speaker=characterGygax, dir=right, y=50, text="Use your jump grid to work out how far and high you should jump. I've highlighted where you should aim for this jump"},
				customCode  = function()
					curve:lockJump(-100, 150)
				end,
			},
			[4] = {
				actions     = { {name="tap-ledge", target="ledge_stone_2", params={to=-100, accuracy=50}} },
				showNote    = { delay=2500, image="reverseleftbox", x=160, y=450, size=0.6, text="tap ledge to collect equipment", color="white", textY=0, inCamera=true },
				showSpeech  = { delay=2500, speaker=characterGygax, dir=right, y=50, text="You can move around a ledge by tapping a point on it. Go collect that trajectory I placed for you"},
			},
			[5] = {
				actions     = { {name="select-gear", target=gearTrajectory} },
				showNote    = { delay=1500, image="leftbox", x=179, y=500, size=0.6, text="select trajectory jump equipment", color="white", textY=-20, inCamera=false },
			},
			[6] = {
				actions     = { {name="prepare-jump", target=nil} },
				showNote    = { image="reverseleftbox", x=285, y=440, size=0.6, text="drag from feet to prepare a jump", color="white", textY=0, inCamera=true },
			},
			[7] = {
				actions     = { {name="jump", target=nil, params={pullx=-130, pully=170}} },
				showSpeech  = { speaker=characterGygax, dir=right, y=50, text="For the next jump, notice how the trajectory shows the predicted jump from your current position. But, you always jump from the end of a ledge..."},
				customCode  = function()
					curve:lockJump(-130, 170)
				end,
			},
			[8] = {
				actions     = { {name="prepare-jump", target=nil} },
				showNote    = { delay=2000, image="reverseleftbox", x=290, y=440, size=0.6, text="drag from feet to prepare a jump", color="white", textY=0, inCamera=true },
				showSpeech  = { delay=2000, speaker=characterGygax, dir=right, y=50, text="I will help show you where to jump once more. This time without a jump trajectory. Remember to select your jump gear before each jump if you need it"},
			},
			[9] = {
				actions     = { {name="jump", target=nil, params={pullx=-85, pully=85}} },
				customCode  = function()
					curve:lockJump(-85, 85)
				end,
			},
			[10] = {
				actions     = { {name="any"} },
				showSpeech  = { delay=2000, speaker=characterGygax, dir=right, y=50, text="Well done. The closer you land to the jump marker the ledge will change color. Green is a perfect jump. Now go complete the zone!"},
			},
		}
	},
}


return scripts