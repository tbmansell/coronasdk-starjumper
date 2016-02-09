local anim             = require("core.animations")
local builder 		   = require("level-objects.builders.builder")
local playerCoreDef    = require("level-objects.player")
local playerActionDef  = require("level-objects.player-actions")
local playerGearDef    = require("level-objects.player-gear")
local playerAiDef      = require("level-objects.player-ai")
local playerCollection = require("level-objects.collections.player-collection")


-- @class Main builder class
local playerBuilder = {
	-- Methods:
	-----------
    -- newPlayerCollection()
	-- newPlayer()
	-- newMainPlayer()
	-- newAiPlayer()
    -- newScriptedPlayer()
}


-- Aliases:
local math_abs  = math.abs
local new_image = display.newImage


-- Creates a new playerCollection
-- @param spineCollection
-- @param movementCollection
-- @return new playerCollection
----
function playerBuilder:newPlayerCollection(spineCollection, movementCollection, particleEmitterCollection)
    local coll = builder:newMasterCollection("players", spineCollection, movementCollection, particleEmitterCollection)

    builder:deepCopy(playerCollection, coll)
    
    return coll
end


-- Base function to create a new player, shared by all types of players
-- @param camera
-- @param spec
-- @param ledge
-- @return new player object
----
function playerBuilder:newPlayer(camera, spec, ledge)
    local skin   = characterData[spec.model].skin
	local player = builder:newSpineObject(spec, {jsonName="player", imagePath="player", scale=(spec.scale or 0.2), skin=skin, animation="Stationary"})

    -- Allow override of destroy()
    player.spineObjectDestroy = player.destroy

	builder:deepCopy(playerCoreDef,   player)
	builder:deepCopy(playerActionDef, player)
	builder:deepCopy(playerGearDef,   player)

	player.name       	= characterData[spec.model].name
	player.startLedge 	= ledge
    player.gear         = {[jump]=nil,   [air]=nil,   [land]=nil}    -- lists name of gear in use
    player.slotInUse    = {[jump]=nil,   [air]=nil,   [land]=nil}    -- true if gear is currently in-use
    player.gearDuration = {[jump]=0,     [air]=0,     [land]=0}      -- true if gear is currently in-use
    player.gearUsed     = {[jump]=false, [air]=false, [land]=false}  -- true if player has successfully used gear in that category
    player.keysUnlocked = {}  -- list of keylock ledges player has unlocked (used by customEvents)

	player:setPhysics(1)
	player:reset()
    player:visible()
	player:changeDirection(right)

    self:applyCharacterAbilities(player)

    if player.xpos then
        player:moveBy(player.xpos, 0)
    end
	
	return player
end


-- Creates the main player
-- @param camera
-- @param spec
-- @param ledge
-- @return new player object
----
function playerBuilder:newMainPlayer(camera, spec, ledge)
	local player = self:newPlayer(camera, spec, ledge)
	player.main  = true

	-- Create a large touch area for the player as the graphic is too small
    local touch  = display.newRect(player.image, 5, -75, 80, 200)
    touch.player = self
    touch.alpha  = 0.01

    -- The touch area is more complex than starting jump on begin: in order to deal with quick taps and moving on ledges
    -- This event handler only handles the part of the jump move thats in the touch area, so it handles the initiation
    -- play-zone:handleJump() carries it on from after this event ends
    touch:addEventListener("touch", function(event)
        if event.phase == "began" and
           player.mode == playerReady and 
           (state.data.game == levelPlaying or state.data.game == levelTutorial) and
           allowPlayerAction("prepare-jump", player.attachedLedge.key)
        then
            player.touchCount = 1
        elseif event.phase == "moved" and player.touchCount > 0 then
            player.touchCount = player.touchCount + 1

            if player.touchCount > 1 and player.mode == playerReady then
                player:readyJump()
            end

        elseif event.phase == "ended" or event.phase == "cancelled" then
            player.touchCount = 0
        end
    end)

    player.touchArea  = touch
    player.touchCount = 0
    camera:add(player.image, 3, true)

	return player
end


-- Creates an AI player
-- @param camera
-- @param spec
-- @param ledge
-- @return new player object
----
function playerBuilder:newAiPlayer(camera, spec, ledge)
	local player = self:newPlayer(camera, spec, ledge)
    
	builder:deepCopy(playerAiDef, player)
	player.ai = true

	-- Create a large touch area for the player as the graphic is too small
    --[[
    local touch  = display.newRect(player.image, player.image.x+5, player.image.y-75, player.image.x+80, player.image.y+150)
    touch.player = self
    touch.alpha  = 0.01
    touch:addEventListener("tap", function(event)
        --player.mainPlayerRef:targetOtherPlayer(player)
        return true
    end)

    player.touchArea = touch
    ]]

    if spec.direction == left then
    	player:changeDirection()
    end

    camera:add(player.image, 3)

	return player
end


-- Creates a player with no intelligence that is used for story scripts
-- @param camera
-- @param spec
-- @param ledge
-- @return new player object
----
function playerBuilder:newScriptedPlayer(camera, spec, ledge)
    local player = self:newPlayer(camera, spec, ledge)
    player.scripted = true
    
    if spec.direction == left then
        player:changeDirection()
    end

    player:moveBy((spec.x or 0), (spec.y or 0))
    camera:add(player.image, 3)

    return player
end


-- Creates character specifc stats / abilities
-- @param player
----
function playerBuilder:applyCharacterAbilities(player)
    if player.model == characterSkyanna then
        -- Skyanna: runs 50% faster (permanent)
        player.constRunSpeed = 12

    elseif player.model == characterHammer then
        -- Hammer: can take two hits from a deadly enemy before he is killed (once per zone)
        player.ironSkin = 2

    elseif player.model == characterBrainiak then
        -- Brainiak: can convert one spine ledge into a normal ledge of the same size, per zone
        --player.transformLedge = 1
        player.transformLedge = 100

        function player:tapOtherLedge(ledge)
            if self.transformLedge > 0 then
                hud.level:transformLedge(self.attachedLedge, ledge, function(success)
                    if success then
                        self.transformLedge = self.transformLedge - 1
                        self:sound("playerTeleport")
                    else
                        self:sound("shopCantBuy")
                    end
                end)
            else
                self:sound("shopCantBuy")
            end
        end

    elseif player.model == characterGrey then
        -- Grey: can teleport to the next / previous ledge once per zone
        --player.teleportLedge = 1
        player.teleportLedge = 100
        
        function player:tapOtherLedge(ledge)
            local id = self.attachedLedge.id
            -- check if they have teleport power left and ledge is next or previous only
            if self.teleportLedge > 0 and ledge.type ~= "start" and ledge.type ~= "finish" and (ledge.id == id-1 or ledge.id == id+1) then
                self.mode          = playerTeleporting
                self.teleportLedge = self.teleportLedge - 1
                self.goingBackward = (ledge:x() < self.attachedLedge:x())

                local warp = hud.level:createWarpField(self:getCamera(), self:y()+100)
                warp:hide()

                local seq = anim:oustSeq("greyTeleporter", warp.image)
                seq:tran({time=1000, alpha=1, playSound=sounds.playerTeleport})
                seq:wait(500)
                seq:callback(function()
                    local xpos = ledge:leftEdge()
                    if self.goingBackward then xpos = ledge:rightEdge()-30 end
                    if ledge:isRotated()  then xpos = ledge:x() end

                    self.attachedLedge:release(self)
                    self.mode = playerFall
                    self:moveTo(xpos, ledge:topEdge()-50)
                end)
                seq:tran({time=500, alpha=0})
                seq.onComplete = function() warp:destroy() end
                seq:start()
            else
                self:sound("shopCantBuy")
            end
        end
    end
end


return playerBuilder