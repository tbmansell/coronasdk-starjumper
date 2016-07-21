local scripts = {
	["intro-planet1-zone1"] = {
		sequence = {
			[1] = {
				actions     = { {name="prepare-jump", target=nil} },
				showNote    = { image="reverseleftbox", x=284, y=440, size=0.6, text="drag from feet to prepare a jump", color="white", textY=0, inCamera=true },
				showSpeech  = { delay=0, speaker=characterGygax, dir=right, y=50, text="Your training begins {player}. I will teach you how to jump ledges and use precious jump trajectory equipment to make it easier"}
			},
			[2] = {
				actions     = { {name="jump", target=nil, params={pullx=-100, pully=150}} },
				showSpeech  = { delay=0, speaker=characterGygax, dir=right, y=50, text="Use your jump grid to work out how far and high you should jump. I've highlighted where you should aim for this jump"},
				customCode  = function()
					curve:lockJump(-100, 150)
				end,
			},
			[3] = {
				actions     = { {name="prepare-jump", target=nil} },
				showNote    = { delay=2500, image="reverseleftbox", x=285, y=440, size=0.6, text="drag from feet to prepare a jump", color="white", textY=0, inCamera=true },
				showSpeech  = { delay=2500, speaker=characterGygax, dir=right, y=50, text="Try another jump and notice how you will always run and jump from the edge of a ledge, unless you wear spring shoes"},
			},
			[4] = {
				actions     = { {name="jump", target=nil, params={pullx=-130, pully=170}} },
				showSpeech  = { speaker=characterGygax, dir=right, y=50, text="As this ledge is higher, you need to pull down further to reach it"},
				customCode  = function()
					curve:lockJump(-130, 170)
				end,
			},
			[5] = {
				actions     = { {name="tap-ledge", target="ledge_stone_3", params={to=100, accuracy=50}} },
				showNote    = { delay=2000, image="reverseleftbox", x=400, y=450, size=0.6, text="tap ledge to collect equipment", color="white", textY=0, inCamera=true },
				showSpeech  = { delay=2000, speaker=characterGygax, dir=right, y=50, text="You can move around a ledge by tapping a point on it. Go collect that trajectory I placed for you"},
			},
			[6] = {
				actions     = { {name="select-gear", target=gearTrajectory} },
				showNote    = { delay=1500, image="leftbox", x=179, y=500, size=0.6, text="select trajectory jump equipment", color="white", textY=-20, inCamera=false },
				showSpeech  = { delay=1500, speaker=characterGygax, dir=right, y=50, text="Your gear slots appear at the bottom. You can select one of each category at any time. Select your jump trajectory"},
			},
			[7] = {
				actions     = { {name="prepare-jump", target=nil} },
				showNote    = { image="reverseleftbox", x=284, y=440, size=0.6, text="drag from feet to prepare a jump", color="white", textY=0, inCamera=true },
			},
			[8] = {
				actions     = { {name="jump", target=nil, params={pullx=-85, pully=85}} },
				showSpeech  = { speaker=characterGygax, dir=right, y=50, text="Notice how your jump is predicted from your current ledge position. Be aware if using away from the edge, you must take that distance into account"},
				customCode  = function()
					curve:lockJump(-85, 85)
				end,
			},
			[9] = {
				actions     = { {name="any"} },
				showSpeech  = { delay=2000, speaker=characterGygax, dir=right, y=50, text="Well done. The closer you land to the jump marker, the better your score. Green is a perfect jump. Now go complete this zone and get all the energy rings!"},
			},
		}
	},
}


return scripts