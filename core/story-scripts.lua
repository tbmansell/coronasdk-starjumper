local scripts = {

-- CUTSCENES --

	["cutscene-planet-intro-organia"] = {
		cutscene = true,
		delayEnd = 4000,
		alwaysShow = true,
		sequence = {
			{delay=2000, speaker=characterGygax,  dir=right, text="We have an emergency on our hands, young Newton! Contact has been lost with all Star Jumpers..."},
			{delay=5000, speaker=characterNewton, dir=left,  text="Oh no! Without the energy rings they discover, our homeworld will soon run out of power", 
			                                                 action=function(scene) scene:actionShowHolograms() end},
			{delay=5000, speaker=characterGygax,  dir=right, text="Behold Planet Organia: the last known location of the two Star Jumpers - Skyanna and Kranio", 
															 action=function(scene) scene:actionShowPlanet() end},
			{delay=6000, speaker=characterNewton, dir=left,  text="*gulp* Why is it called Organia boss?"},
			{delay=4000, speaker=characterGygax,  dir=right, text="It is a warm rocky planet populated with giant brains, hearts and shooting stomachs, which dont take kindly to visitors", size="-big"},
			{delay=6000, speaker=characterNewton, dir=left,  text="But how can I help? I'm not a trained Jumper"},
			{delay=4000, speaker=characterGygax,  dir=right, text="I shall train you in the techniques and equipment, as we explore the locations they went missing", size="-big"},
			{delay=4000, speaker=characterGygax,  dir=right, text="There is more. Sightings of the evil Brainiak have been made and I fear he may have something to do with this", size="-big",
											                 action=function(scene) scene:actionShowBrainiak() end}, 
			{delay=6000, speaker=characterNewton, dir=left, text="Oh dear, some day this is turning out to be"},
		},
	},
	["cutscene-character-intro-skyanna"] = {
		cutscene = true,
		delayEnd = 4000,
		alwaysShow = true,
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
		alwaysShow = true,
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

	["cutscene-planet-intro-apocalypsoid"] = {
		cutscene = true,
		delayEnd = 6000,
		alwaysShow = true,
		sequence = {
			{delay=2000, speaker=characterGygax,  dir=right, text="We have a new location to explore Newton, more dangerous than the last. The dying planet known as Apocalypsoid!", size="-big",
															 action=function(scene) scene:actionShowHolograms() end},
			{delay=5000, speaker=characterNewton, dir=left,  text="Yikes - that sounds pretty scary. What is wrong with it?"},
			{delay=4000, speaker=characterGygax,  dir=right, text="The planets inner core has collapsed and we can only get as close as the damaged space stations around its outer atmosphere", size="-big",
															 action=function(scene) scene:actionShowPlanet() end},
			{delay=6000, speaker=characterNewton, dir=left,  text="So, It must be high in energy rings for you to have sent Jumpers there..."},
			{delay=5000, speaker=characterGygax,  dir=right, text="And desperate Fuzzies. We received an emergency broadcast from ReneGrey that evil Greys have arrived to plunder it, before the planet dies", size="-big"},
			{delay=6000, speaker=characterNewton, dir=left,  text="Ok, I'm fitting my spacesuit and getting ready. Anything else?"},
			{delay=4000, speaker=characterGygax,  dir=right, text="Their leader EarlGrey, known for wicked experiments, may have captured Hammer. But our ally ReneGrey is at large and may be able to assist you", size="-big",
															 action=function(scene) scene:actionShowEarlGrey() end},
		},
	},
	["cutscene-character-intro-hammer"] = {
		cutscene = true,
		delayEnd = 6000,
		alwaysShow = true,
		sequence = {
			{delay=2000, speaker=characterGygax,   dir=right, text="Excellent work team - we have rescued Hammer - our toughest Star Jumper!", 
															  action=function(scene) scene:actionShowHolograms() end},
			{delay=5000, speaker=characterHammer,  dir=left,  text="Well not so sure it was a rescue, as I was about to take the Greys down when you showed up. But you guys helped too I suppose", size="-big"},
			{delay=6000, speaker=characterNewton,  dir=left,  text="That was a tough rescue, no doubt about it"},
			{delay=5000, speaker=characterHammer,  dir=left,  text="Well boy, I've got what I like to call the 'Iron Skin'. Where a normal Jumper would die from a single brush with the enemy, I can take two hits and keep on lickin", size="-big",
															  action=function(scene) scene:actionShowNewCharacter() end},
			{delay=6000, speaker=characterNewton,  dir=left,  text="That must have been how you managed to survive the beating from those Greys"},
			{delay=6000, speaker=characterHammer,  dir=left,  text="I see you've come along way Newton with some help, but the big H is here now to really show you the ropes", size="-big"},
		},
	},
	["cutscene-character-intro-renegrey"] = {
		cutscene = true,
		delayEnd = 5000,
		alwaysShow = true,
		sequence = {
			{delay=2000, speaker=characterGygax,    dir=right, text="A welcome addition to the Star Jumpers has escaped the dreaded Apocalypsoid - ReneGrey has returned!",
															   action=function(scene) scene:actionShowHolograms() end},
			{delay=5000, speaker=characterNewton,   dir=left,  text="Thank the stars. What happened to you out there?"},
			{delay=4000, speaker=characterReneGrey, dir=left,  text="Hammer and I were seperated by violent gravity storms and when the evil Greys arrived I went into hiding. I finally found a warp-hole to escape home", size="-big"},
			{delay=6000, speaker=characterGygax,    dir=right, text="ReneGrey turned his back on the evil Grey empire and mastered space exploration. He has the special ability to teleport to a nearby ledge once per zone", size="-big",
															   action=function(scene) scene:actionShowNewCharacter() end},
			{delay=6000, speaker=characterNewton,   dir=left,  text="It's so cool that you dont need to wear a space helmet!"},
			{delay=5000, speaker=characterReneGrey, dir=left,  text="Not only that but I have a stolen UFO we can spraypaint and hit the stars"},
		},
	},


-- IN-GAME STORY SCRIPTS --

	-- PLANET 1
	["intro-brainiak-planet1-zone5"] = {
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
	["race-brainiak-planet1-zone21"] = {
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

	-- PLANET 2
	["intro-planet2-zone7"] = {
		forced   = true,
		delay    = 1500,
		sequence = {
			{delay=1000, speaker=characterGygax, dir=right, text="Danger {player}! You've entered a gravity storm zone. I can't get near to help you. Escape quick before it destroys the whole zone!", size="-big"},			
		},
	},
	["intro-earlgrey-planet2-zone8"] = {
		forced    = true,
		delay     = 0,
		condition = { characterNotIn={characterReneGrey, characterHammer} },
		sequence  = {
			{delay=1000, speaker=characterEarlGrey, dir=right, text="Ahh say there traveler, you must be a brave specimin, to come to this here collapsing planet. Sadly, this here area now belongs to Grey Empire Mining Inc.", size="-big"},
			{delay=3000,                            dir=left,  text="You must be the infamous EarlGrey. I have come to rescue those trapped here and I dont care for your evil doings. Do you have my friend Hammer?", size="-big"},
			{delay=3000, speaker=characterEarlGrey, dir=right, text="Well that is poorly manners ahh must say. It looks like my here guards will have to take care of you. So long varmint", size="-big"},
		},
	},
	["intro-planet2-zone14"] = {
		forced    = true,
		delay     = 1500,
		condition = { characterNotIn={characterReneGrey} },
		sequence  = {
			{delay=1000, speaker=characterGygax,    dir=right, text="Warning {player}, you've entered an asteroid field. My ship has taken a hit and I can't get to you. Hold on there is a transmission coming through...", size="-big"},
			{delay=4000, speaker=characterReneGrey, dir=right, text="Space Jumper - this is ReneGrey. I'm in the zone and will try to guide you through. Zoom out your view to help dodge the falling asteroids. Watch out for me...", size="-big"},
		},
	},
	["rescue-renegrey-planet2-zone17"] = {
		forced    = true,
		delay     = 0,
		condition = { characterNotIn={characterReneGrey} },
		sequence  = {
			{delay=1000, speaker=characterReneGrey, dir=right, text="Fear not {player}, ReneGrey here - I've been tracking you EarlGrey - take this!", size="-big"},
			{delay=3000, speaker=characterEarlGrey, dir=left,  text="What tha! *ouch*", size="-big"},
			{delay=3000, speaker=characterReneGrey, dir=right, text="Get moving {player}, there are evil Greys chasing me!", size="-big"},
			{delay=3000, speaker=characterEarlGrey, dir=left,  text="You will ahh pay for this you here traitor!", size="-big"},
		},
	},
	["race-earlgrey-planet2-zone21"] = {
		forced    = true,
		delay     = 0,
		condition = { characterNotIn={characterHammer, characterReneGrey} },
		sequence  = {
			{delay=1000,                            dir=left,  text="Oh no Hammer what have they done to you!"},
			{delay=3000, speaker=characterEarlGrey, dir=right, text="You have surely impressed me surviving this here planetary disaster. But I think I will be stringing you up next to your friend now", size="-big"},
			{delay=3000,                            dir=left,  text="I have survived this far, you cannot stop me with or without your Grey minions"},
			{delay=3000, speaker=characterEarlGrey, dir=right, text="Ha ha ha. I have some surprises in store for you, for sure"},

		--[[
			{delay=1000, speaker=characterBrainiak, dir=right, text="Aaargh still you survive little alien. Enough toying with your friend. It's feeding time and my trap has done its work bringing more aliens here", size="-big"},
			{delay=3000,                            dir=left,  text="I've not battled this far to give up now. Your evil ways will soon be at an end Brainiak. No-one eats my friends!", size="-big"},
			{delay=3000, speaker=characterBrainiak, dir=right, text="Raaagh you can't stop me..."},
			{delay=3000,                            dir=left,  text="Skyanna I'm coming for you!"},
		]]
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