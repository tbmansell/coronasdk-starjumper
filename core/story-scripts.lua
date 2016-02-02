local scripts = {
	["cutscene-planet-intro-organia"] = {
		cutscene = true,
		sequence  = {
			{delay=5000, speaker=characterNewton, dir=right, text="Hey boss, things seem pretty remote down there. I can't imagine it is worth me getting out hey?"},
			{delay=4000, speaker=characterGygax,  dir=right, text="Well well, my sensors are detecting pulse rings ahead. I'll just find a spot to land nearby"},
			{delay=4000, speaker=characterNewton, dir=right, text="Ooh those drops look pretty long, maybe we should just stay here where it is safe..."},
			{delay=4000, speaker=characterGygax,  dir=right, text="Yes, I will indeed be staying here to monitor your training. My it does look cold out there..."},
			{delay=15000, type="finish"},
		},
	},
	["cutscene-planet-outro-organia"] = {
		cutscene = true,
		sequence  = {
			{delay=5000, speaker=characterNewton,  dir=right, text="Woohoo I just rocked! I think I just beat you didn't I? Didn't I?"},
			{delay=6000, speaker=characterSkyanna, dir=left,  text="Hmm... You did good kid, but don't get cocky. It's going to get tougher out there"},
			{delay=6000, speaker=characterNewton,  dir=right, text="So does this mean you are going to help me? I would love to have you along to show me the ropes"},
			{delay=8000, speaker=characterSkyanna, dir=left,  text="You talk a lot kid... but I'm in", y=80},
		}
	},

	["cutscene-planet-intro-apocalypsoid"] = {
		cutscene = true,
		sequence  = {
			{delay=4000, speaker=characterGygax,  dir=right, text="Welcome to the dying planet of Apocalypsoid. We cant set down because the planet is breaking apart"},
			{delay=4000, speaker=characterNewton, dir=right, text="Yikes. What are we doing here then?"},
			{delay=4000, speaker=characterGygax,  dir=right, text="It is a last chance to grab and energy rings and rescue any fuzzies thrown into the space around it"},
			{delay=4000, speaker=characterNewton, dir=right, text="Ok, I'm fitting my spacesuit and getting ready."},
			{delay=15000, type="finish"},
		},
	},
	["cutscene-planet-outro-apocalypsoid"] = {
		cutscene = true,
		sequence  = {
			{delay=5000, speaker=characterNewton,  dir=right, text="I say"},
			{delay=6000, speaker=characterSkyanna, dir=left,  text="You say"},
			{delay=6000, speaker=characterNewton,  dir=right, text="I say"},
			{delay=8000, speaker=characterSkyanna, dir=left,  text="Make some noise", y=80},
		}
	},


	["cutscene-character-intro-skyanna"] = {
		cutscene = true,
		sequence  = {
			{delay=2000, speaker=characterGygax,    dir=right, size="-big", text="Welcome to the club skyanna"},
			{delay=4000, speaker=characterSkyanna,  dir=left,              text="Sup?"},
			{delay=4000, speaker=characterGygax,    dir=right, size="-big", text="We hope you can help us rescue the universe"},
			{delay=4000, speaker=characterSkyanna,  dir=left,              text="Whatevs"},
			{delay=15000, type="finish"},
		},
	},



	--[[
	["explain-zoneSelect"] = {
		sequence = {
			{delay=500,                          dir=left,  text="Boss, I've opened my PlanetNav showing me the zones you have highlighted for exploring..."},
			{delay=3500, speaker=characterGygax, dir=right, text="Very good. The bottom bar shows your progress accross this planet. Tap the icons to discover more"},
			{delay=3500, speaker=characterGygax, dir=right, text="Your Holocubes on the left grant you access to the Cube-n-Carry store, essential for good explorers"},
			{delay=3500, speaker=characterGygax, dir=right, text="Return here to retry zones and rescue all the Fuzzies, gain awards and earn more cubes"},
		},
	},]]
	["explain-fuzzy"] = {
	    sequence = {
			{delay=500,                          dir=left,  text="Hey Boss, I rescued a Fuzzy!"},
			{delay=3000, speaker=characterGygax, dir=right, text="Well done! We need to rescue all our ancient friends from each planet. Keep your eyes open as they may be hiding", size="-big"},
			{delay=3000, speaker=characterGygax, dir=right, text="If you can rescue all Fuzzies on a planet they will reward you with some of their special technology. See the PlanetNav for details", size="-big"},
		}
	},
	["explain-score"] = {
		sequence = {
			{delay=1000, speaker=characterGygax, dir=right, text="Well done you scored a jump by getting close to the marker. Green is perfect then yellow then red"},
			{delay=3000, speaker=characterGygax, dir=right, text="If you can score green on all scorable ledges in a zone you will gain the Jump Pro award"},
			{delay=3000,                    dir=left,  text="Great I've never had an award before..."},
			{delay=3000, speaker=characterGygax, dir=right, text="Check the PlanetNav summary to see what awards will unlock for you. They will also unlock store items"},
		}
	},

	--[[["intro-planet1-zone1"] = {
		forced   = true,
		delay    = 1500,
		sequence = {
			{delay=2000, speaker=characterGygax,   dir=left,  text="To start a jump, pull down and behind your character into the jump grid. Pull further to get a higher or longer jump. Pull up to cancel the jump", size="-big"},
			{delay=3000, speaker=characterHammer, dir=right, text="Get the angle just right to land on the next ledge score marker. Let go to run and jump for it. If you fall it hurts but that's no reason to be a coward newbie", size="-big"},
			{delay=3000, speaker=characterSkyanna,   dir=right, text="Score high on jumps and collect rings to earn Holocubes and a better zone ranking. Good luck kid"},
			{delay=3000,                      dir=right, text="The name is newton by the way... Oh I wished I had stayed in bed..."},
		},
	},]]
	["intro-planet1-zone7"] = {
		forced   = true,
		delay    = 1500,
		sequence = {
			{delay=1000,                    dir=left,  text="So are we going home now?"},
			{delay=3000, speaker=characterGygax, dir=right, text="No, I'm going to make sure you are exploring to the stone we require"},
			{delay=3000, speaker=characterGygax, dir=right, text="I will race you through this zone. If you beat me we can move on. Otherwise, you'll have to try again"},
			{delay=3000,                    dir=left,  text="Great that's fair, shooting along in your spaceship..."},
		},
	},
	["intro-planet1-zone14"] = {
		forced   = true,
		delay    = 1500,
		sequence = {
			{delay=1000, speaker=characterHammer, dir=right, text="Hey! Don't hang about, this zone is unstable. Get to the top before the eruption reaches you!"},
		},
	},
	["intro-planet1-zone21"] = {
		forced   = true,
		delay    = 1500,
		sequence = {
			{delay=1000, 					dir=left,  text="Hey there!"},
			{delay=3000, speaker=characterSkyanna, dir=right, text="Hey kid, you made it. Time to show me what you have learnt. Beat me through this zone and I'll join your expedition!", size="-big"},
			{delay=3000, 					dir=left,  text="Ok, I think I can take you on... erm are you carrying something?"},
			{delay=3000, speaker=characterSkyanna, dir=right, text="Why I don't know what you mean..."},
		},
	},

	["usegear-trajectory"] = {
		sequence = {
			{delay=500,              dir=right, text="Hey boss, I picked up a new peice of equipment, how will this help?"},
			{speaker=characterGygax, dir=left,  text="Let me see... You have picked up the trajectory projection item"},
			{speaker=characterGygax, dir=left,  text="Prepare for a jump and you will see the computer predict your jump as you look around. It will last for one jump per item you own", size="-big"},
			{speaker=characterGygax, dir=left,  text="Items you own can be accessed from the HUD at the top. Select them before each jump. Stock-up before a zone run if you have enough Holocubes", size="-big"},
		}
	},
	["usegear-springshoes"] = {
		sequence = {
			{delay=500,         dir=right, text="Yikes I've got some spring shoes, what do I do?"},
			{speaker=characterGygax, dir=left,  text="These allow you to jump from any point of a ledge, instead of jumping from the end"},
			{speaker=characterGygax, dir=left,  text="This can help you avoid obstacles close to an edge or reach places you otherwise could not get to"},
		}
	},
	["usegear-shield"] = {
		sequence = {
			{delay=500,         dir=right, text="Wahey I have a force shield. How long does it last?"},
			{speaker=characterGygax, dir=left,  text="The force shield will activate when you begin your run and lasts for 10 seconds"},
			{speaker=characterGygax, dir=left,  text="You will be immune to dangerous enemies or obstcles, but not falling from a ledge!"},
		}
	},
	["usegear-freezetime"] = {
		sequence = {
			{delay=500,         dir=right, text="Ooh this device looks impressive!"},
			{speaker=characterGygax, dir=left,  text="Be careful, that is a time freezer! It should only be used in experienced hands, but as you have come across one I will let you have it...", size="-big"},
			{speaker=characterGygax, dir=left,  text="It will activate when you start your jump, so time it to get the best effect. It will stop once you land. You can cancel it with the icon below you", size="-big"},
			{                   dir=right, text="I could have some fun with this"},
		}
	},

	["usegear-jetpack"] = {
		sequence = {
			{delay=500,         dir=right, text="Hey hey I always wanted a jetpack!"},
			{speaker=characterGygax, dir=left,  text="This is not a video game you know! Tap mid-jump to boost your jump and reach higher places or correct yourself", size="-big"},
			{speaker=characterGygax, dir=left,  text="You have enough fuel for three bursts in a single jump"},
		}
	},
	["usegear-glider"] = {
		sequence = {
			{delay=500,         dir=right, text="Hmmm this looks kinda dangerous..."},
			{speaker=characterGygax, dir=left,  text="A glider can be used to travel long distances and skip ledges or reach places you otherwise could not"},
			{speaker=characterGygax, dir=left,  text="Tap mid-air to activate then tap when in use to drop out of the glider and land below"},
		}
	},
	["usegear-parachute"] = {
		sequence = {
			{delay=500,         dir=right, text="Ah I feel safer with a parachute on me"},
			{speaker=characterGygax, dir=left,  text="Tap mid-air to activate the parachute and you will travel directly down from your current position"},
			{speaker=characterGygax, dir=left,  text="This can stop you flying past a ledge or reach difficult places"},
		}
	},
	["usegear-reversejump"] = {
		sequence = {
			{delay=500,         dir=right, text="Hmm what is this odd looking item boss?"},
			{speaker=characterGygax, dir=left,  text="Let me see... Ah yes this is the Jump Reverser. It will allow you to go back in time from a missed jump", size="-big"},
			{speaker=characterGygax, dir=left,  text="Tap mid-jump to reverse time and repeat your jump. This will only work if you do not hit a ledge during your jump. If you fall too far it wont work either", size="-big"},
			{                   dir=right, text="Great! Although I feel maybe you should have given me some of these from the start..."},
		}
	},

	["usegear-gloves"] = {
		sequence = {
			{delay=500,         dir=right, text="What do you think of my nice gloves boss?"},
			{speaker=characterGygax, dir=left,  text="Hmph they are for climbing not showing off. Put them on and they will save your hide"},
			{speaker=characterGygax, dir=left,  text="If you hit the front of a ledge, you will be able to pull yourself onto the ledge and avoid falling"},
			{                   dir=right, text="They do look good though..."},
		}
	},
}


return scripts