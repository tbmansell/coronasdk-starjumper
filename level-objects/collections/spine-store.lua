local anim    = require("core.animations")
local builder = require("level-objects.builders.builder")


-- local constants
local typeCharacter        = 1
local typeBossUfo          = 2
local typeBossChair        = 3
local typeEffectsFlash	   = 4
local typeEffectsExplosion = 5
local typeFuzzy            = 6
local typeGearShield	   = 7 
local typeGearFlame		   = 8 
local typeHolocube		   = 9
local typeJumpMarker	   = 10
local typeLandingDust	   = 11
local typeStartMarker      = 12
local typeRing             = 13
-- max for looping
local maxType              = typeRing


-- @class Definition for Spine store
local spineStore = {

	-- reference to a spine collection to add and remove objects to/from
	spineCollection = nil,
	-- list of dust colors
	dustColors  	= {"grey", "red", "yellow", "green"},
	-- tracks how many of each type of spine object is currently in use
	inUse           = {},
	-- stores how many of each type of object have been created
	created         = {},
	-- stores a list of landing dust spine objects, per color, pre-loaded rath than load on land
	landingDust 	= {},

	-- Methods:
	-----------
	-- load()
	-- destroy()
	-- destroyList()
	-- fetchObject()

	-- newLandingDust()
	-- newJumpMarker()
	-- newStartMarker()
	-- newGearShield()
	-- newGearFlame()
	-- newEffectFlash()
	-- newEffectExplosion()
	-- newHoloCube()
	-- newRing()
	-- newFuzzy()
	-- newCharacter()
	-- newBoss()
	
	-- showLandingDust()
	-- showJumpMarker()
	-- showStartMarker()
	-- showGearShield()
	-- showGearFlame()
	-- showFlash()
	-- showExplosion()
	-- showHoloCube()
	-- showRing()
	-- showFuzzy()
	-- showCharacter()
	-- showBossUfo()
	-- showBossChair()

	-- hideJumpMarkers()
	-- hideStartMarker()
	-- hideGearShield()
	-- hideGearFlame()
}


-- Aliases:
local math_random = math.random


-- Loads up the spine store with spine objects pro-loaded, so they can be fetched quickly in-level
----
function spineStore:load(spineCollection)
	self.spineCollection = spineCollection

	-- creating a landing dust spineObject for each color possible:
	for _,color in pairs(self.dustColors) do
		self.landingDust[color] = self:newLandingDust(color)
	end

	for type=1, maxType do
		self.inUse[type]   = 0
		self.created[type] = {}
	end
end


-- Destroys all spine objects in the store
-- NOTE: we destroy all items in the spineStore even though some may get detroyed belonging to the spineCollection
-- but we have to do this as not all spineStore objects may belong to the spineCollection at deletion time
----
function spineStore:destroy()
	-- remove all landing dust
	for _,color in pairs(self.dustColors) do
		if self.landingDust[color] then
			self.landingDust[color]:destroy()
			self.landingDust[color] = nil
		end
	end

	for type=1, maxType do
		self:destroyList(self.created[type], type)
	end

	self.spineCollection = nil
end


-- Destroy all items for a list
-- @param list to destroy
----
function spineStore:destroyList(list, type)
	for _,item in pairs(list) do
		item:destroy()
		item = nil
	end

	self.inUse[type]   = 0
	self.created[type] = {}
end


-- Looks to fetch an existing item from a list, or creates one if they are all currently used up
-- @return spineObject
----
function spineStore:fetchObject(creator, type, params)
	local index   = self.inUse[type] + 1
	local created = self.created[type]

	self.inUse[type] = index

	if created[index] == nil then
		if type == typeGearFlame then print("Creating new flame at index "..index) end

		local newObject = creator(self, params)
		
		newObject:pose()

		newObject.inPhysics 		   = false
		newObject.belongsToSpineStore  = true
    	newObject:generateKey(#created + 1)
    	
    	created[index] = newObject
    else
    	if type == typeGearFlame then print("Returning existing flame at index "..index) end
	end

	return created[index]
end


-- Adds an item to the spine collection and handles spineDelays
-- @param object
----
function spineStore:addSpine(object)
	if object.spineDelay and object.spineDelay > 0 then
    	after(object.spineDelay, function()
    		self.spineCollection:add(object)
    	end)
    else
    	self.spineCollection:add(object)
    end
end


-- Creates a new landing dust spineObject
-- @param color of the dust
-- @return spineObject
----
function spineStore:newLandingDust(color)
	local dust = builder:newSpineObject({type=color.."dust"}, {jsonName="land-dust", imagePath="land-dust", scale=0.5, skin=color, animation="land-1"})
	dust.id    = 1
	dust.inPhysics = false
	return dust
end


-- Creates a new jump marker spineObject
-- @return spineObject
----
function spineStore:newJumpMarker()
	return builder:newSpineObject({type="jumpmarker"}, {jsonName="ledge-score", imagePath="hud", scale=0.5,  animation="animation"})
end


-- Creates a green go arrow spine image
-- @return spineObject
----
function spineStore:newStartMarker()
	return builder:newSpineObject({type="startMarker"}, {jsonName="start-arrow", imagePath="ledges", scale=0.7, animation="Pulse"})
end


-- Creates a new player gear shield bubble spineObject
-- @return spineObject
----
function spineStore:newGearShield()
	return builder:newSpineObject({type="gearshield"}, {jsonName="shield", imagePath="collectables", animation="Rotate"})
end


-- Creates a new player gear flame spineObject
-- @return spineObject
----
function spineStore:newGearFlame(params)
	return builder:newSpineObject({type="gearflame"}, {jsonName="effect-jetpack-flame", imagePath="collectables", scale=(params.size or 0.4), animation="Standard"})
end


-- Creates a new flash effect (used for player death)
-- @return spineObject
----
function spineStore:newEffectFlash(size)
	return builder:newSpineObject({type="effectflash"}, {jsonName="effect-flash", imagePath="effects", scale=(size or 0.4), animation="stone"})
end


-- Creates a new explosion effect (used for ledges etc)
-- @return spineObject
----
function spineStore:newEffectExplosion(size)
	return builder:newSpineObject({type="effectexplosion"}, {jsonName="effect-explosion", imagePath="effects", scale=(size or 1), animation="Standard"})
end


-- Creates a holocube spine image
-- @return spineObject
----
function spineStore:newHoloCube(size)
    return builder:newSpineObject({type="holocube"}, {jsonName="holo-cube", imagePath="hud", scale=size, animation="Standard 1"})
end


-- Creates a new ring object that is visual only and not part of the physics or game engine
-- @return spineObject
----
function spineStore:newRing(color)
    return builder:newSpineObject({type="ring"}, {jsonName="rings", imagePath="collectables", scale=0.7, skin=colorNames[color], animation="Pulse"})
end


-- Creates a new fuzzy object that is visual only and not part of the physics or game engine
-- @return spineObject
----
function spineStore:newFuzzy(params)
	local skin = colorNames[params.color].." Ball"
    return builder:newSpineObject({type="fuzzy"}, {jsonName="friend-fuzzy", imagePath="friends", scale=params.size, skin=skin, animation="Standard"})
end


-- Creates a new player character that is visual only and not part of the physics or game engine
-- @return spineObject
----
function spineStore:newCharacter(params)
	local skin  = characterData[params.model].skin
	local frame = params.animation or "Stationary"
	local scale = params.size or 0.5

    return builder:newSpineObject({type="player"}, {jsonName="player", imagePath="player", scale=scale, skin=skin, animation=frame, loop=params.loop, spineDelay=params.spineDelay})
end


-- Creates a new boss character that is visual only and not part of the physics or game engine
-- @return spineObject
----
function spineStore:newBoss(params)
	return builder:newSpineObject({type="boss"}, {jsonName="gygax-"..params.type, imagePath="gygax/"..params.type, scale=params.size, animation=params.animation, loop=params.loop, spineDelay=params.spineDelay})
end


-- Requests a landing dust object be displayed at a ledge location
-- @param camera
-- @param x
-- @param y
-- @param color
----
function spineStore:showLandingDust(camera, x, y, color)
	local dust = self.landingDust[color]

	if dust then
		dust:animate("land-"..math_random(3))
		dust:moveTo(x, y)
		dust:visible(0.4)

		camera:add(dust.image, 3)
		self.spineCollection:add(dust)

		-- shelve the effect after its time is up
		after(1000, function()
			dust:hide()
			self.spineCollection:remove(dust)
			camera:remove(dust.image)
		end)
	end
end


-- Requests that a score marker be shown on a ledge
-- @param camera
-- @param ledge - the ledge to display on
----
function spineStore:showJumpMarker(camera, ledge)
	local marker = self:fetchObject(self.newJumpMarker, typeJumpMarker)

	if marker and marker.inGame and ledge.inGame then
		marker.alpha = 0
		marker:moveTo(ledge:scorePosition(), ledge:topEdge())

		-- NOTE: can do a bind as spineStore is responsible for creating the marker.id - doesnt need adding to a sceneryCollection
		ledge:bind(marker)
		self.spineCollection:add(marker)
		camera:add(marker.image, 3)

		local seq = anim:chainSeq("ledgeScoreAppear", marker.image)
        seq:tran({time=500, alpha=1})
        seq:start()
	end
end


-- Shows the go start marker arrow
-- @param camera
-- @param x
-- @param y
-- @param flip - true if arrow should flip to show first jump is to the left
----
function spineStore:showStartMarker(camera, x, y, flip)
	local marker = self:fetchObject(self.newStartMarker, typeStartMarker)

	if marker then
	    if flip then 
	    	marker.image:scale(-1,1)
	    	marker.flipped = true
	    end

	    marker:hide()
	    marker:moveTo(x, y)
	    self.spineCollection:add(marker)
	    camera:add(marker.image, 4)
	    
	    local seq = anim:oustSeq("startMarker", marker.image)
	    seq:wait(500)
	    seq:tran({time=1000, alpha=1})
	    seq:start()
	end
end


-- Requests that a player gear shield be shown and attached to them
-- @param camera
-- @param player   - to attach
----
function spineStore:showGearShield(camera, player, params)
	local xpos   = params.x or 0
	local ypos   = params.y or 0
	local shield = self:fetchObject(self.newGearShield, typeGearShield, params)

	if shield then
		shield:moveTo(xpos, ypos)
		shield.image:scale(0.01, 0.01)
		shield:loop("Rotate")
		shield:visible(0.6)

		self.spineCollection:add(shield)
		player.shieldImage = shield

        local seq = anim:oustSeq("playerShield", shield.image)
        --seq:tran({time=500, scale=1, playSound=sounds.gearShield})
        seq:tran({time=500, scale=1, playSound=sounds.gearShield})
        seq:callback(function() player:sound("gearShield") end)
        seq:callbackAfter(8000, function() shield:loop("Pulse") end)
        --seq:tran({time=1000, delay=2000, scale=0.1, playSound=sounds.gearShield, playDelay=2000})
        seq:tran({time=1000, delay=2000, scale=0.1})
        seq:callbackAfter(2000, function() player:sound("gearShield") end)
        seq.onComplete = function() player:shieldExpired() end
        seq:start()
        
        -- assign the sequence to the shield so we can tell the shield to stop it at any time
        shield.seq = seq
        -- Insert into image so corona moves the shield with the object for us
		player.image:insert(shield.image)
	end
end


-- Requests that a flame be shown and attached to an object (to re-use just show the attachment)
-- @param camera
-- @param object - to attach flame to
-- @param
----
function spineStore:showGearFlame(camera, object, params)
	local xpos     = params.x        or 0
	local ypos     = params.y        or 0
	local rotation = params.rotation or 0
	local flame    = self:fetchObject(self.newGearFlame, typeGearFlame, params)

	if flame and flame.image then
		print("showGearFlame:     player="..tostring(object.key).." flame="..tostring(flame.key).." flame.image="..tostring(flame.image).." tally="..tostring(self.inUse[typeGearFlame]).." playerFlame="..tostring(object.jetPackFlame))

		flame:moveTo(xpos, ypos)

		if object.direction == left then
			flame.image:scale(-1,1)
			flame.flipped = true
		end

		flame:rotate(rotation)
		flame:animate("Standard")
		flame:visible()

		self.spineCollection:add(flame)
		object.jetPackFlame = flame

		-- Insert into image so corona moves the flames with the object for us
		print("showGearFlame: ADD player="..tostring(object.key).." flame="..tostring(flame.key).." flame.image="..tostring(flame.image).." tally="..tostring(self.inUse[typeGearFlame]).." playerFlame="..tostring(object.jetPackFlame))

		for i=1,5 do
			local object = self.created[typeGearFlame][i]
			local image  = nil
			local rem    = nil

			if object then image = object.image end
			if image  then rem   = object.image.removeSelf end

			print(i.." object="..tostring(object).." object.image="..tostring(image).." object.image.removeSelf="..tostring(rem))
		end

		object.image:insert(flame.image)
	end
end


-- Requests to show a flash effect on he player
-- @param camera
-- @param player
----
function spineStore:showFlash(camera, player, size)
	local effect = self:fetchObject(self.newEffectFlash, typeEffectsFlash, size)

	if effect then
		effect:moveTo(player:pos())
		effect:visible()
		effect:animate("stone")

		camera:add(effect.image, 2)
		self.spineCollection:add(effect)

		after(1000, function() 
			effect:hide()
			camera:remove(effect.image)
			self.spineCollection:remove(effect)
			self.inUse[typeEffectsFlash] = self.inUse[typeEffectsFlash] - 1
		end)
	end
end


-- Requests to show a explosion effect on he player
-- @param camera
-- @param player
----
function spineStore:showExplosion(camera, target, size)
	local effect = self:fetchObject(self.newEffectExplosion, typeEffectsExplosion, size)

	if effect then
		effect:moveTo(target:pos())
		effect:visible()
		effect:animate("Standard")

		camera:add(effect.image, 2)
		self.spineCollection:add(effect)

		after(1500, function()
			effect:hide()
			camera:remove(effect.image)
			self.spineCollection:remove(effect)
			self.inUse[typeEffectsExplosion] = self.inUse[typeEffectsExplosion] - 1
		end)
	end
end


-- Requests to show a holocube
-- @param x
-- @param y
-- @param size
-- @return cube object
----
function spineStore:showHoloCube(x, y, size)
    local cube = self:fetchObject(self.newHoloCube, typeHolocube, size)

    if cube then
    	--NOTE: since the new holocube th ey offset is off, so correct it automatically here to avoid changing all the code
    	y = y - 40

    	cube:moveTo(x, y)
    	cube:visible()
    	self.spineCollection:add(cube)

	    local seq = anim:oustSeq("holocubes-"..cube.id, cube)

	    seq:add("callbackLoop", {delay=2000, callback=function()
	        if cube.image then
	            cube:animate("Standard "..math_random(3))
	        end
	    end})
	    seq:start()
    end

    return cube
end


-- Requests to show a ring outside of the game itself (end of level sequence)
-- @param x
-- @param y
-- @param color
-- @return a ring object
----
function spineStore:showRing(x, y, color)
	local ring = self:fetchObject(self.newRing, typeRing, color)

	if ring then
		ring:moveTo(x, y)
		ring:visible()
		self.spineCollection:add(ring)
	end

	return ring
end


-- Requests to show a fuzzy that snot part of the game engine
-- @param spec
----
function spineStore:showFuzzy(spec)
	local char = self:fetchObject(self.newFuzzy, typeFuzzy, spec)

	if char then
		char:moveTo(spec.x, spec.y)
		char:visible()
		self.spineCollection:add(char)
	end

	return char
end


-- Requests to show a new character which is not an AI object: there is no hide as we dont re-use them
-- @param spec - character spec including the model, skin, type, x and y
----
function spineStore:showCharacter(spec)
	local char = self:fetchObject(self.newCharacter, typeCharacter, spec)

	if char then
		char.skeleton:setAttachment("attachment-handfront-ledgegloves", nil)
    	char.skeleton:setAttachment("attachment-handback-ledgegloves",  nil)
    	char.skeleton:setAttachment("Back Attachment", nil)

		char:moveTo(spec.x, spec.y)
		char:visible()
		char.spineDelay = spec.spineDelay
		self:addSpine(char)
	end

	return char
end


-- Requests to show a ne Boss in a UFO: there is no hide as we dont re-use them
-- @param spec - spine spec including the model, skin, type, x and y
----
function spineStore:showBossUfo(spec)
	spec.type      = "ufo"
	spec.animation = "Stationary"

	local boss = self:fetchObject(self.newBoss, typeBossUfo, spec)

	if boss then
		boss:moveTo(spec.x, spec.y)
		boss:visible()
		boss.spineDelay = spec.spineDelay
		boss:addSpine(char)
	end

	return boss
end


-- Requests to show a ne Boss in a UFO: there is no hide as we dont re-use them
-- @param spec - spine spec including the model, skin, type, x and y
----
function spineStore:showBossChair(spec)
	spec.type      = "chair"
	spec.animation = "Standard"

	local boss = self:fetchObject(self.newBoss, typeBossChair, spec)

	if boss then
		boss:moveTo(spec.x, spec.y)
		boss:visible()
		boss.spineDelay = spec.spineDelay
		self:addSpine(boss)
	end

	return boss
end


-- Hides all currently shown jump markers
-- @param camera
----
function spineStore:hideJumpMarkers(camera)
	local objects = self.created[typeJumpMarker]
	local num 	  = #objects

	self.inUse[typeJumpMarker] = 0
	
	for i=1,num do
		local marker = objects[i]
		
		if marker then
			local seq = anim:chainSeq("ledgeScoreDisappear", marker.image)
	        seq:tran({time=500, alpha=0})
	        seq.onComplete = function()
	        	-- Detach the marker from the ledge, animator and camera
	        	camera:remove(marker.image)
	        	self.spineCollection:remove(marker)
				marker:detachFromLedge()
			end
			seq:start()
		end
    end
end


-- Hide start marker
-- @param camera
----
function spineStore:hideStartMarker(camera)
	local objects = self.created[typeStartMarker]
	local num 	  = #objects

	self.inUse[typeStartMarker] = 0
	
	for i=1,num do
		local marker = objects[i]
		
		if marker then
			local seq = anim:oustSeq("startMarker", marker.image)
	        seq:tran({time=1000, alpha=0})
	        seq.onComplete = function()
	        	-- Detach the marker from the ledge, animator and camera
	        	camera:remove(marker.image)
	        	self.spineCollection:remove(marker)
			end
			seq:start()
		end
    end
end


-- Hides a player gear shield
-- @param camera
-- @param player   - to release
----
function spineStore:hideGearShield(camera, player)
	local shield = player.shieldImage

	if shield then
		anim:removeSeq(shield.seq)
		shield.seq = nil

		camera:remove(shield.image)
		self.spineCollection:remove(shield)
		shield:hide()

		self.inUse[typeGearShield] = self.inUse[typeGearShield] - 1
		player.shieldImage = nil
	end
end


-- Hides a player gear flame
-- @param camera
-- @param player to release
----
function spineStore:hideGearFlame(camera, player)
	local flame = player.jetPackFlame

	if flame then
		camera:remove(flame.image)
		self.spineCollection:remove(flame)
		flame:hide()
		flame.rotation = 0

		if flame.flipped then
			flame.flipped = false
			flame.image:scale(-1,1)
		end

		self.inUse[typeGearFlame] = self.inUse[typeGearFlame] - 1
		player.jetPackFlame = nil

		print("hideGearFlame: player="..tostring(player.key).." flame="..tostring(flame.key).." flame.image="..tostring(flame.image).." tally="..tostring(self.inUse[typeGearFlame]).." playerFlame="..tostring(player.jetPackFlame))
	end
end


return spineStore