-- @class collection for ledges
local ledgeCollection = {

    -- Movement pattern for when a player lands on a ledge: to shake the ledge
	ledgeShakeMovement = nil,

    -- Methods:
    -----------
    -- !add()
    -- setShakeMovement()
    -- reset()
    -- resetPulley()
}


-- @return true if the object passed is a valid gameObject
----
local function validObject(object)
    return object and object ~= -1 and object.image
end


-- Replaces mastercollection.add() to add a ledge as it assigns previous saved scores to the ledge from zone state
-- @param ledge     - to add
-- @param zoneState - optional state data for previous run on a zone (so we assign prev score)
----
function ledgeCollection:add(ledge, zoneState)
	self:addToMaster(ledge)
    self:addToSpineCollection(ledge)
    self:addToMovementCollection(ledge)

	-- load in previous scores and colour ledge from previous zone plays
	if zoneState and zoneState.jumpScores and zoneState.jumpScores[ledge.id] and state.demoActions == nil then
        ledge.score = zoneState.jumpScores[ledge.id]

        if     ledge.score == ledge.points   then ledge.scoreCategory = scoreCategoryFirst
        elseif ledge.score == ledge.points/2 then ledge.scoreCategory = scoreCategorySecond
        elseif ledge.score == ledge.points/4 then ledge.scoreCategory = scoreCategoryThird end

        ledge:colorLedge()
    end
end


-- Sets the ledge shake movement
-- @param movement
----
function ledgeCollection:setShakeMovement(movement)
    self.ledgeShakeMovement = movement
end


-- Called when player dies, to reset things like bomb ledges, so they can play through the level again
-- @param player - main player
-- @param camera
----
function ledgeCollection:reset(player, camera)
   	local items = self.items
	local num   = #items

	for i=1,num do
		local ledge = items[i]

		if validObject(ledge) then
            if ledge.surface == pulley and ledge.triggeredPulley and not ledge.dontReset then
                self:resetPulley(ledge, camera)

            elseif ledge.surface == exploding then
                ledge:visible(1)
            end

			if ledge.isSpine and not ledge.dontReset then
                ledge:pose()
                ledge:loop("Standard")
                ledge:solid()
                ledge.deadly    = false
                ledge.triggered = false
            end

            -- restore invisible ledges that player is not standing on
            if ledge.invisible and not player:onLedge(ledge) then
                timer.resume(ledge.timerAnimationHandle)
                ledge:hide()
                ledge:cancelFade()
            end

            -- Restore destroyed ledges UNLESS they are marked as dontReset
            if ledge.destroyed and not ledge.dontReset then
                ledge.destroyed = false
                ledge:solid()
            end
		end
	end
end


function ledgeCollection:resetPulley(ledge, camera)
    local scale    = 1
    local camScale = camera.scalePosition
    local movScale = ledge.movement.scaled

    if camScale < 1 then
        if movScale == nil or movScale >= 1 then
            scale = camScale
        end
    else
        if movScale < 1 then
            scale = camScale
        end
    end

    ledge.triggeredPulley = false
    ledge:stop()
    ledge:moveBy(-ledge.movement.currentX * scale, -ledge.movement.currentY * scale)
end


return ledgeCollection