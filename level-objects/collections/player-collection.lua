local soundEngine = require("core.sound-engine")


-- @class Main class for collection
local playerCollection = {
	-- Methods:
	-----------
	-- checkMovement()
	-- checkIfOutOfPlay()
	-- checkJumpToFall()
	-- checkDeadlyLedge()
	-- checkOffScreenIndicator()
	-- playerOnLedge()
}


-- Aliases:
local atan = math.atan


-- Checks the players movement: walking, running or landing correction
-- @param delta
----
function playerCollection:checkMovement(delta)
	local items = self.items
    local num   = #items

    for i=1,num do
        local player = items[i]

        if player ~= -1 then
    	    local ledge  = player.attachedLedge
    	    local mode   = player.mode

    	    if mode == playerRun and ledge and ledge.inGame then
    	    	self:checkRunMovement(player, ledge, delta)
    	        
    	    elseif mode == playerWalk then
    	    	self:checkWalkMovement(player, delta)

            elseif mode == playerGrappling then
                self:drawGrappleHook(player)

            elseif mode == playerOnVehicle then
                if player.vehicleImage then
                    player.vehicleImage.x = player.image.x      --* delta
                    player.vehicleImage.y = (player.image.y-25) --* delta
                end
    	    else
        	    local correctBy = player.correctBy
        		if correctBy ~= 0 then
    	    		self:checkCorrectionMovement(player, correctBy)
    	    	end

    	        if player.boundEmitter then
    	        	self:checkTrailMovement(player, player.boundEmitter)
    	        end
    	    end
        end
	end
end


function playerCollection:checkRunMovement(player, ledge, delta)
	local x      = player.image.x + (player.runSpeed * delta)
    local lx     = ledge.image.x 
    local length = ledge:width()/2

    player.image.x = x

    if x > (lx + length) or x < (lx - length) then
        player:jump()
    end
end


function playerCollection:checkWalkMovement(player, delta)
    local x         = player.image.x
    local walkSpeed = player.walkSpeed
    local walked    = player.walked
    local walkUntil = player.walkUntil

    if player:onStartLedge() and walkSpeed <= 0 and x < player:startPosition() then
        player:pose()
        player:stand()
    end

    if (walked > 0 and walked < walkUntil) or (walked < 0 and walked > walkUntil) then
        player.walked  = walked + (walkSpeed * delta)
        player.image.x = x      + (walkSpeed * delta)
    else
        -- Were forced to do this and the load gear cos otherwise when walking backward his head stays backward
        player:pose()
        player:stand()
    end
end


function playerCollection:checkCorrectionMovement(player, correctBy)
	local x = player.image.x

    if correctBy < 0 then
        correctBy    = correctBy + 5
        player.image.x = x - 5
        if correctBy > 0 then player.correctBy = 0 else player.correctBy = correctBy end
    else
        correctBy    = correctBy - 5
        player.image.x = x + 5
        if correctBy < 0 then player.correctBy = 0 else player.correctBy = correctBy end
    end
end


function playerCollection:checkTrailMovement(player, trail)
	local adj, opp = player:getForce()

	if player.direction == left then
		adj = -adj
	end

	local angle = atan(opp/adj) * 57.29
	
	trail.angle = angle - 180
end


-- Loops through all players and calls the behaviour chekers on them in turn (faster than looping many times)
-- @param camera
-- @param floor - an integer for the Y value
----
function playerCollection:checkBehaviours(camera, floor)
	local items = self.items
    local num   = #items

    for i=1,num do
        local player = items[i]

        if player ~= -1 then
    	   self:checkIfOutOfPlay(player, camera, floor)
    	   self:checkJumpBehaviour(player)
    	   self:checkDeadlyLedge(player)
        end
    end
end


-- Checks if the player has fallen passed the level floor
-- @param player
-- @param camera
-- @param floor - an integer for the Y value
----
function playerCollection:checkIfOutOfPlay(player, camera, floor)
    -- NOTE: Check for debug status here:
    hud:debugPlayerMode(player)

    if player ~= -1 and player.image.y > floor and player.markedOutOfPlay == nil then
        local main = player.main
        local mode = player.mode

        player:sound("randomFall")
        player.markedOutOfPlay = true

        if main then camera:cancel() end

        if mode ~= playerMissedDeath and mode ~= playerKilled then
        	player:destroyEmitter()
            player:animate("Death JUMP "..player.jumpType)

            -- Calculate closest ledge to determine if the jump was a near or far miss
            if main and player.jumpedFrom then
                local ledge, diff = hud.level:getClosestLedge(player.jumpedFrom.id, player.image.x, player.xVelocity)

                if diff and diff < 250 then
                    hud:displayMessageDied("jump-missed-close")
                else
                    hud:displayMessageDied("jump-missed-wide")
                end
            end
        end

        -- Only reset player if they have not already been killed otherwise it will conflict with player:murder()
        if mode ~= playerKilled then
            after(2000, function()
                if mode ~= playerKilled then 
                	player:loseLife() 
                end
            end)
        end
    end
end


-- Checks different behaviour changes possible while jumping in the air
-- @param player
----
function playerCollection:checkJumpBehaviour(player)
    local mode       = player.mode
    local jumpedFrom = player.jumpedFrom

    if (mode == playerJump or mode == playerMissedDeath) and jumpedFrom and jumpedFrom.inGame then
        self:checkJumpToFall(player, jumpedFrom)

        if (mode == playerJump or mode == playerFall) and player.gear[land] == gearGrappleHook then 
            self:checkUseGrappleHook(player, jumpedFrom)
        end
    end
end


-- Checks if a player in the air should switch to the falling state if they have fallen too far passed where they jumped from
-- @param player
----
function playerCollection:checkJumpToFall(player, jumpedFrom)
    local distanceY = jumpedFrom:y() - player:y()

    -- Check if a player has jumped too far below initial ledge and turn their jump into a fall...
    if distanceY < -200 and not player.gliding and not player.parachuting then
        player.mode = playerFall
        player:sound("randomWorry")

        player:destroyEmitter()
        player:animate("Death JUMP "..(player.jumpType or "HIGH"))
    end
end


-- Check if player has GrappleHook and has fallen passed a ledge to hook at the right distance to hook onto
-- @param player
----
function playerCollection:checkUseGrappleHook(player, jumpedFrom)
    --local grappleRange = 300
    local grappleRange = 1300
    local px, py       = player:pos()
    local ledge, curX, curY, curSideX, curSideY = hud.level:getClosestLedgeAtPoint(px, py)

    -- Record player y positions at key points
    player.jumpSnapshots[#player.jumpSnapshots+1] = { x=px, y=py }

    if ledge and ledge.key ~= jumpedFrom.key then
        local xvel, yvel = player:getForce()
        local leftEdge, rightEdge, topEdge = ledge:leftEdge(), ledge:rightEdge(), ledge:topEdge()

        print("ledge "..ledge.key.." topEdge="..topEdge)

        -- Under ledge and within grapple range:
        if py > topEdge and ((py - topEdge) <= grappleRange) then
            -- Check that player has been over the ledge at some point
            local snaps = player.jumpSnapshots
            local num   = #snaps
            local valid = false

            for i=1, num do
                local pos = snaps[i]
                print("player="..tostring(pos["y"]))
                if pos.y < topEdge then
                    print("VALID: "..pos.y.." < "..topEdge)
                    valid = true
                    break
                end
            end

            if valid then
                if xvel > 0 and px > rightEdge and (px - rightEdge) <= grappleRange then
                    player:useGrappleHook(ledge, right)
                elseif xvel < 0 and px < leftEdge and (leftEdge - px) <= grappleRange then
                    player:useGrappleHook(ledge, left)
                end
            end
        end
    end
end


function playerCollection:drawGrappleHook(player)
    if player.grappleLine then
        hud.camera:remove(player.grappleLine)
        player.grappleLine:removeSelf()
    end

    local ledge   = player.grappleTarget
    local playerY = player:y() - 80

    if ledge and ledge.inGame then
        if player.grappleSide == right then
            player.grappleLine = display.newLine(ledge:rightEdge(), ledge:topEdge(), player:x(), playerY)
        else
            player.grappleLine = display.newLine(ledge:leftEdge(), ledge:topEdge(), player:x(), playerY)
        end

        player.grappleLine.strokeWidth = 3
        player.grappleLine:setStrokeColor(0.7, 0.6, 0.5)
        hud.camera:add(player.grappleLine, 3)
    end
end


-- Checks if the player passed is on a deadly ledge
-- @param player
----
function playerCollection:checkDeadlyLedge(player)
    local ledge  = player.attachedLedge

    if ledge and ledge.inGame and ledge.deadly and player.mode ~= playerKilled then
    	-- The following ledge surfaces are deadly:
        if     ledge.surface == electric then ledge:killWithElectricity(player)
        elseif ledge.surface == lava     then ledge:killWithLava(player)
        elseif ledge.surface == spiked   then ledge:killWithSpikes(player) end
    end
end



-- Updates the off-screen indicators for AI characters
----
function playerCollection:checkOffScreenIndicator()
	local items = self.items
    local num   = #items

    for i=1,num do
        local player = items[i]
	    local marker = player.raceIndicator
	    local x, y   = player:pos()

        -- TODO: use constants for scaling
        if x < -100 or x > 1000 or y < 0 or y > 700 then
            local rank = player.arcadeRaceRank

            if rank then
                if not marker then
                    -- create the indicator icon for the first time only
                    local char   = characterData[player.model]
                    marker       = display.newGroup()
                    marker.icon  = display.newImage(marker, "images/hud/player-indicator-"..char.name..".png", 0, 0)
                    marker.text  = newText(marker, rank, -10, 10, 0.6, char.color, "CENTER")
                    marker.icon.alpha  = 0.8
                    player.raceIndicator = marker
                elseif tostring(rank) ~= marker.text:getText() then
                    -- update the indicator with the new rank
                    marker.text:setText(rank)
                end

                local adjust = player.indicatorAdjustment

                -- position the indicator
                if     x > 930 then marker.x = 930 - adjust
                elseif x < 30  then marker.x = 30  + adjust
                else   marker.x = x  end

                if     y < 30  then marker.y = 30  + adjust
                elseif y > 600 then marker.y = 600 - adjust
                else   marker.y = y - 40 end

                if marker.alpha == 0 then marker.alpha = 1 end
            end
            
        elseif marker and marker.alpha ~= 0 then
            -- on screen from off screen
            marker.alpha = 0
        end
	end
end


function playerCollection:checkAIBehaviour(level)
	local items = self.items
    local num   = #items

    for i=1,num do
        local player = items[i]

        if player ~= -1 and player.ai then
        	player:checkAIBehaviour(level)
        end
   end
end


function playerCollection:playerOnLedge(ledge)
    local items = self.items
    local num   = #items

    for i=1,num do
        local player = items[i]

        if player.attachedLedge and player.attachedLedge.id == ledge.id then
            return true
        end
    end

    return false
end


return playerCollection