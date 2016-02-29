local scripts = {

-- CUTSCENES --

	["cutscene-planet-intro-organia"] = {
		cutscene = true,
		delayEnd = 4000,
		sequence = {
			{delay=2000, speaker=characterGygax,  dir=right, text="We have an emergency on our hands, young Newton! Contact has been lost with all Star Jumpers..."},
			{delay=5000, speaker=characterNewton, dir=left,  text="Oh no! Without the energy rings they discover, our homeworld will soon run out of power", 
			                                                 action=function(scene) scene:actionShowHolograms() end},
			{delay=5000, speaker=characterGygax,  dir=right, text="Behold Planet Organia: the last known location of the two Star Jumpers - Skyanna and Kranio", 
															 action=function(scene) scene:actionShowPlanet1() end},
			{delay=6000, speaker=characterNewton, dir=left,  text="*gulp* Why is it called Organia boss?"},
			{delay=4000, speaker=characterGygax,  dir=right, text="It is a warm rocky planet populated with giant brains, hearts and shooting stomachs, which dont take kindly to visitors", size="-big"},
			{delay=6000, speaker=characterNewton, dir=left,  text="But how can I help? I'm not a trained Jumper"},
			{delay=4000, speaker=characterGygax,  dir=right, text="I shall train you in the techniques and equipment, as we explore the locations they went missing", size="-big"},
			{delay=4000, speaker=characterGygax,  dir=right, text="There is more. Sightings of the evil Brainiak have been made and I fear he may have something to do with this", size="-big",
											                 action=function(scene) scene:actionShowBrainiak() end}, 
			{delay=6000, speaker=characterNewton, dir=left, text="Oh dear, worst day ever"},
		},
	},
	["cutscene-character-intro-skyanna"] = {
		cutscene = true,
		delayEnd = 4000,
		sequence = {
			{delay=2000, speaker=characterGygax,   dir=right, text="Congratulations we have rescued a captured Star Jumper - welcome back Skyanna!",
												              action=function(scene) scene:actionShowHolograms() end},
			{delay=5000, speaker=characterSkyanna, dir=left,  text="Hey! Thanks for the rescue. It's good to be away from that barren planet and the evil Brainiak"},
			{delay=6000, speaker=characterGygax,   dir=right, text="Skyanna is our fastest Star Jumper. I think the last recorded test showed you were 50% faster than the rest", size="-big",
															  action=function(scene) scene:actionShowNewCharacter() end},
			{delay=6000, speaker=characterSkyanna, dir=left,  text="I get in and out fast without a doubt. I'm Ready for action once more thanks to you guys"},
			{delay=6000, speaker=characterNewton,  dir=right, text="I look forward to working with you. I've heard the story of how you raced through the fog pits of *Poisened Earth*", size="-big"},
			{delay=6000, speaker=characterSkyanna, dir=left,  text="Oh yes, I've got some tales to tell you on our travels. You did good kid"},
		},
	},
	["cutscene-character-intro-kranio"] = {
		cutscene = true,
		delayEnd = 4000,
		sequence = {
			{delay=2000, speaker=characterGygax,   dir=right, text="Good news everyone, a missing Star Jumper has returned from planet Organia - welcome back Kranio!",
												              action=function(scene) scene:actionShowHolograms() end},
			{delay=5000, speaker=characterKranio,  dir=left,  text="I was banished to the Grey Matter Zone by my father Brainiak, so that I could not spoil his plans. I vow to stop his evil ways", size="-big"},
			{delay=6000, speaker=characterGygax,   dir=right, text="Kranio has a unique Mind Matter ability to convert any dangerous ledge into a safe one, once per zone",
															  action=function(scene) scene:actionShowNewCharacter() end},
			{delay=6000, speaker=characterKranio,  dir=left,  text="It is how I escaped Brainiak's minions and has really helped me out of some tricky situations"},
			{delay=6000, speaker=characterNewton,  dir=right, text="I look forward to working with you. It must be hard having an evil Brain Master for a father", size="-big"},
			{delay=6000, speaker=characterKranio,  dir=left,  text="I turned my back on his legacy and brain empire to free all minds everywhere"},
		},
	},

	-- TODO:
	["cutscene-planet-intro-apocalypsoid"] = {
		cutscene = true,
		delayEnd = 10000,
		sequence = {
			{delay=4000, speaker=characterGygax,  dir=right, text="Welcome to the dying planet of Apocalypsoid. We cant set down because the planet is breaking apart"},
			{delay=4000, speaker=characterNewton, dir=right, text="Yikes. What are we doing here then?"},
			{delay=4000, speaker=characterGygax,  dir=right, text="It is a last chance to grab and energy rings and rescue any fuzzies thrown into the space around it"},
			{delay=4000, speaker=characterNewton, dir=right, text="Ok, I'm fitting my spacesuit and getting ready."},
		},
	},
	-- TODO:
	["cutscene-character-intro-hammer"] = {
		cutscene = true,
		delayEnd = 10000,
		sequence = {
			{delay=2000, speaker=characterGygax,    dir=right, size="-big", text="Welcome to the club skyanna", action=function(mothership) mothership:showTvPlanet1() end},
			{delay=4000, speaker=characterSkyanna,  dir=left,               text="Sup?"},
			{delay=4000, speaker=characterGygax,    dir=right, size="-big", text="We hope you can help us rescue the universe"},
			{delay=4000, speaker=characterSkyanna,  dir=left,               text="Whatevs"},
		},
	},
	-- TODO:
	["cutscene-character-intro-greyson"] = {
		cutscene = true,
		delayEnd = 10000,
		sequence = {
			{delay=2000, speaker=characterGygax,    dir=right, size="-big", text="Welcome to the club skyanna", action=function(mothership) mothership:showTvPlanet1() end},
			{delay=4000, speaker=characterSkyanna,  dir=left,               text="Sup?"},
			{delay=4000, speaker=characterGygax,    dir=right, size="-big", text="We hope you can help us rescue the universe"},
			{delay=4000, speaker=characterSkyanna,  dir=left,               text="Whatevs"},
		},
	},


-- IN-GAME STORY SCRIPTS --

	["intro-brainiak-zone5"] = {
		forced    = true,
		delay     = 0,
		condition = { characterNotIn={characterSkyanna, characterKranio} },
		sequence  = {
			{delay=1000, speaker=characterBrainiak, dir=right, text="Foolish trespasser you have entered the domain of Brainiak, where all must tremble! Ha ha perhaps you are searching for your friend...", size="-big"},
			{delay=3000,  							dir=left,  text="Skyanna! What have you done with her you fiend?"},
			{delay=3000, speaker=characterBrainiak, dir=right, text="She is my prisoner little alien, one I am savouring for later. Mmm I think you will make a nice starter. My super smart brainoids will deal with you...", size="-big"},
			{delay=3000,                            dir=left,  text="Wait - come back here!"},
		},
	},
	["intro-planet1-zone7"] = {
		forced   = true,
		delay    = 1500,
		sequence = {
			{delay=1000, speaker=characterGygax, dir=right, text="Right {player}, you have been doing well so far, but things are going to get harder so we must work on your speed training", size="-big"},
			{delay=3000,                         dir=left,  text="Oh it's pretty cold down here and it was so safe and warm in the zone navigator"},
			{delay=3000, speaker=characterGygax, dir=right, text="I will race you through this zone. If you beat me we can move on. Otherwise, you'll have to try again. Oh you might want to stock up on jetpacks too", size="-big"},
			{delay=3000,                         dir=left,  text="I'm not sure this race is entirely fair..."},
		},
	},
	["intro-planet1-zone14"] = {
		forced   = true,
		delay    = 1500,
		sequence = {
			{delay=1000, speaker=characterGygax, dir=right, size="-big", text="Quick don't hang about, this zone is unstable! Get to the top before the eruption reaches you. But look out for Fuzzies who need rescuing!"},
		},
	},
	["race-brainiak-zone21"] = {
		forced    = true,
		delay     = 0,
		condition = { characterNotIn={characterSkyanna, characterKranio} },
		sequence  = {
			{delay=1000, speaker=characterBrainiak, dir=right, text="Aaargh still you survive little alien. Enough toying with your friend. It's feeding time and my trap has done its work bringing more aliens here", size="-big"},
			{delay=3000,                            dir=left,  text="I've not battled this far to give up now. Your evil ways will soon be at an end Brainiak. No-one eats my friends!", size="-big"},
			{delay=3000, speaker=characterBrainiak, dir=right, text="Raaagh you can't stop me..."},
			{delay=3000,                            dir=left,  text="Skyanna I'm coming for you!"},
		},
	},


-- INGAME HELP --

	["explain-score"] = {
		sequence = {
			{delay=500,  speaker=characterGygax, dir=right, text="Well done you scored points by getting close to the jump marker. Green is perfect then yellow and red last"},
			{delay=3000, speaker=characterGygax, dir=right, text="If you can score green on all standard ledges in a zone you will gain the Jump Pro award"},
			{delay=3000,                         dir=left,  text="Great I've never won an award before!"},
			{delay=3000, speaker=characterGygax, dir=right, text="Be sure to check the PlanetNav summary to see how many awards you have won in each planet"},
		}
	},
	["explain-fuzzy"] = {
	    sequence = {
			{delay=500,                          dir=left,  text="Hey Boss, I rescued a Fuzzy!"},
			{delay=3000, speaker=characterGygax, dir=right, text="Well done! We need to rescue all our ancient friends from each planet. Keep your eyes open as they may be hiding or in danger", size="-big"},
			{delay=3000, speaker=characterGygax, dir=right, text="Rescuing Fuzzies unlocks challenge game modes in each planet. See the PlanetNav for details", size="-big"},
		}
	},

	["usegear-trajectory"] = {
		sequence = {
			{delay=500,              dir=right, text="Hey boss, how do these Trajectory Projection items help again?"},
			{speaker=characterGygax, dir=left,  text="They are helpful for a particularly hard jump, when you have enough time. Select them from your hud before you jump", size="-big"},
			{speaker=characterGygax, dir=left,  text="When you are readying your jump, your projected path is shown - if you jumped from where you are CURRENTLY standing", size="-big"},
			{speaker=characterGygax, dir=left,  text="Remember - when you sprint you run from the edge of the ledge, so adjust the path accordingly. Re-visit zone one to practise them", size="-big"},
		}
	},
	["usegear-springshoes"] = {
		sequence = {
			{delay=500,              dir=right, text="Cool, I've got some spring shoes, what do I do?"},
			{speaker=characterGygax, dir=left,  text="They allow you to jump from any point of a ledge, instead of jumping from the end"},
			{speaker=characterGygax, dir=left,  text="This can help you avoid danger close to an edge or reach places you otherwise could not get to"},
		}
	},
	["usegear-shield"] = {
		sequence = {
			{delay=500,              dir=right, text="Wahey, I have a force shield, how long does it last?"},
			{speaker=characterGygax, dir=left,  text="The force shield will activate when you begin your run and lasts for 10 seconds"},
			{speaker=characterGygax, dir=left,  text="You will be immune to dangerous enemies or lethal obstcles, but not from obstructions or falling from a ledge!", size="-big"},
		}
	},
	["usegear-freezetime"] = {
		sequence = {
			{delay=500,              dir=right, text="Ooh this device looks impressive..."},
			{speaker=characterGygax, dir=left,  text="Be careful, that is a time freezer! It should only be used by experienced hands, but as you have come across one I will let you have it...", size="-big"},
			{speaker=characterGygax, dir=left,  text="It will activate when you start your jump, so time it to get the best effect. It will stop once you land. You can cancel it with the icon below you", size="-big"},
			{                        dir=right, text="I could have some fun with this"},
		}
	},

	["usegear-jetpack"] = {
		sequence = {
			{delay=500,              dir=right, text="Woohoo! I always wanted a jetpack!"},
			{speaker=characterGygax, dir=left,  text="This is not a video game you know. Tap mid-jump to boost your jump and reach higher places or correct yourself", size="-big"},
			{speaker=characterGygax, dir=left,  text="You have enough fuel for three bursts in a single jump"},
		}
	},
	["usegear-glider"] = {
		sequence = {
			{delay=500,              dir=right, text="Hmmm this looks kinda dangerous..."},
			{speaker=characterGygax, dir=left,  text="A glider can be used to travel long distances and skip ledges or reach places you otherwise could not"},
			{speaker=characterGygax, dir=left,  text="Tap mid-air to activate then tap when in use to drop out of the glider and land below"},
		}
	},
	["usegear-parachute"] = {
		sequence = {
			{delay=500,              dir=right, text="Ah I feel safer with a parachute on me"},
			{speaker=characterGygax, dir=left,  text="Tap mid-air to activate the parachute and you will travel directly down from your current position. This can stop you flying past a ledge or reach difficult places", size="-big"},
			{speaker=characterGygax, dir=left,  text="Tap again when parachuting to close the chute and fall fast"},
		}
	},
	["usegear-reversejump"] = {
		sequence = {
			{delay=500,              dir=right, text="Hmm what is this odd looking item boss?"},
			{speaker=characterGygax, dir=left,  text="Let me see... Ah yes, this is the TimeJump Reverser. It will allow you to travel back in time from a bad jump", size="-big"},
			{speaker=characterGygax, dir=left,  text="Tap mid-jump to reverse time and repeat your jump. It will not work if you hit something during your jump, or if you fall too far", size="-big"},
			{                        dir=right, text="Great! Although, I feel maybe we should have stocked up on them before we started this..."},
		}
	},

	["usegear-gloves"] = {
		sequence = {
			{delay=500,              dir=right, text="What do you think of my nice new gloves boss?"},
			{speaker=characterGygax, dir=left,  text="Hmph they are for climbing not showing off. Put them on and they will save your hide"},
			{speaker=characterGygax, dir=left,  text="If you hit a ledge from the front, you will be able to pull yourself up and avoid falling"},
			{                        dir=right, text="They do look good though..."},
		}
	},
	["usegear-grapplehook"] = {
		sequence = {
			{delay=500,              dir=right, text="Now this grappling hook looks handy"},
			{speaker=characterGygax, dir=left,  text="They can be used instead of climbing gloves, to reach out and pull yourself onto a ledge you have just jumped past", size="-big"},
			{speaker=characterGygax, dir=left,  text="The rope range is limited, so they will only save you if you fall close past a ledge. Stock these and climbing gloves to be a versatile Jumper", size="-big"},
			{                        dir=right, text="Hmm gloves or hook, what should I wear, decisions, decisions..."},
		}
	},

	["intro-character-kranio"] = {
		sequence = {
			{speaker=characterKranio, dir=left, text="I have the unique special ability to transform the material of a deadly ledge into a safe one with my mind, once per zone", size="-big"},
			{speaker=characterKranio, dir=left, text="Tap a nearby dangerous ledge and I will change it. If a ledge cannot be changed or my power is used up, you will hear a warning sound", size="-big"},
		}
	},
	["intro-character-greyson"] = {
		sequence = {
			{speaker=characterReneGrey, dir=left, text="I have the unique special ability to teleport to the ledge next to me, with my alien technology, once per zone", size="-big"},
			{speaker=characterReneGrey, dir=left, text="Tap the ledge immediately before or after the one I am on to teleport. If a ledge cannot be teleported to or my power up, is used you will hear a warning sound", size="-big"},
		}
	},
}


return scripts