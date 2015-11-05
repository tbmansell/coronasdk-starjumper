local builder          = require("level-objects.builders.builder")
local fuzzyDef         = require("level-objects.friend-fuzzy")
local ufoBossDef       = require("level-objects.friend-ufoboss")
local friendCollection = require("level-objects.collections.friend-collection")


-- @class special builder for friends
local friendBuilder = {
	-- Methods:
	-----------
	-- newFriendCollection()
	-- newFriend()
	-- newFuzzy()
	-- newBossUfo()
}


-- Creates a new friendCollection
-- @param spineCollection    - ref to an existing spine collection, to add friends to it
-- @param movementCollection - ref to an existing move  collection, to add friends to it
-- @return new friendCollection
----
function friendBuilder:newFriendCollection(spineCollection, movementCollection, particleEmitterCollection)
    local coll = builder:newMasterCollection("friends", spineCollection, movementCollection, particleEmitterCollection)

    builder:deepCopy(friendCollection, coll)

    coll.fuzziesAvailable = {}
    
    return coll
end


-- Creates a new friend
-- @param camera
-- @param spec
-- @param x 	- level X adjustment
-- @param y 	- level Y adjustment
-- @param ledge - previous ledge which friend may be attached too
-- @return friendObject
---- 
function friendBuilder:newFriend(camera, spec, x, y, ledge)
    -- fuzzies only appear in story mode
	if spec.type == "fuzzy" and state.data.gameSelected == gameTypeStory then 
		return self:newFuzzy(camera, spec, x, y, ledge)
	elseif spec.type == "ufoboss" then
        return self:newBossUfo(camera, spec, x, y)
	end
end


-- Creates a new fuzzy
-- @param camera
-- @param spec
-- @param x 	- level X adjustment
-- @param y 	- level Y adjustment
-- @param ledge - previous ledge which friend may be attached too
-- @return fuzzyObject
----
function friendBuilder:newFuzzy(camera, spec, x, y, ledge)
    local  animation = "Standard"

    if     spec.kinetic == "bounce"     then animation = "Jump"
    elseif spec.kinetic == "hang"       then animation = "Hang Left Arm Standard"
    elseif spec.kinetic == "hangDouble" then animation = "Hang Double" end

    local size   = spec.size or 0.5
	local friend = builder:newSpineObject(spec, {jsonName="friend-"..spec.type, imagePath="friends", scale=size, skin=spec.color.." Ball", animation=animation})

	builder:deepCopy(fuzzyDef, friend)

	friend.direction     = friend.direction or left
    friend.color 	     = friend.color     or ""
    friend.colorCode     = colorCodes[friend.color]
    friend.originalScale = size

    local scale = friend.originalScale * camera.scaleImage
    if scale ~= 1 then
        friend.image:scale(scale, scale)
    end

    friend:setPhysics(camera.scaleImage)
    friend:moveTo((spec.x or 0) + x, (spec.y or 0) + y)
    friend:setDelayTillNextChange()

    if friend.direction == right then
        friend:changeDirection(right)
    end

    friend.image.collision = friend.eventCollide
    friend.image:addEventListener("collision", friend.image)
    camera:add(friend.image, 2)

    return friend
end


-- Creates a new ufoboss
-- @param camera
-- @param spec
-- @param x 	- level X adjustment
-- @param y 	- level Y adjustment
-- @return spineObject
----
function friendBuilder:newBossUfo(camera, spec, x, y)
	local skin 		= spec.skin
	local animation = spec.animation or "Stationary"

    if spec.hasPassenger then
        skin = "Passenger-"..characterData[spec.playerModel].shipSkin.."-alien"
    end

    local friend = builder:newSpineObject(spec, {jsonName="ufoboss", imagePath="ufoboss", scale=spec.size, skin=skin, animation=animation})

    -- Allow override of destroy()
    builder:deepCopy(ufoBossDef, friend)

    -- This property allows the ufo boss to assist player with dropping gear
    if not friend.gearDropper then
        -- settings to true means it will never drop anything
        friend.waitingForNextDrop = true
    end

    friend:moveTo(spec.x + x, spec.y + y)

    if not friend.noSound then
        friend.constantSound = {sound=sounds.friendBossActive, duration=16000}
    end

    if friend.direction == right then
        friend:changeDirection(right)
    end

    if friend.movement then
    	friend:moveNow()
    end

    -- Allow items to be optionally excluded from the camera or made the camera focus
    if not friend.dontAddCamera then
        camera:add(friend.image, 2, friend.isCameraFocus or false)
    end

    return friend
end


return friendBuilder