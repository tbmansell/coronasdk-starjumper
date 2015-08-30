local spine = require("core.spine")
local anim  = require("core.animations")



------------ GLOBAL FUNCTIONS CALLED BY NETWORKING API TO TRIGGER EVENTS FOR REMOTE PLAYER ----------------

function removeRemotePlayer()
    remotePlayer.ingame = false
    camera:remove(remotePlayer.image)
    remotePlayer.image:removeSelf()
    remotePlayer = nil

    hud:displayMessage("sorry, the other player has gone")
end


function positionRemotePlayer(ledgeId, x, y, direction, mode)--, gear)
	remotePlayer:stopMomentum()

    -- detach from any existing items:
    if remotePlayer.attachedLedge ~= nil then
    	remotePlayer.attachedLedge:detach(remotePlayer)
    end

    remotePlayer.attachedLedge = level:getLedge(ledgeId)
    remotePlayer.attachedLedge:attach(remotePlayer)
    remotePlayer:moveTo(x, y)

    if direction == left or direction == right then
    	remotePlayer:changeDirection(direction)
    end
    --remotePlayer:setGear(gear)
end


---------------- ADDITIONS TO PLAYER CLASS TO CREATE NETWORK MESSAGES ON KEY EVENTS --------------------


local playerLoaderNetworking = {}


function playerLoaderNetworking:load(player)

	-- Notify other player if: in multiplayer game, remotePlayer loaded and this object is the main player
	function player:notifyOtherPlayer()
		return state.data.multiplayer and remotePlayer and not self.remote
	end


	function player:moveOnLedgeNotify(moveBy)
	    if self:notifyOtherPlayer() then
	    	print("NOTIFY: WALKING(moveBy="..moveBy..")")
	        hub:privateMessage("player-walk", "ledge="..self.attachedLedge.id.."&x="..moveBy)
	    end
	end


	function player:setGearNotify()
		if self:notifyOtherPlayer() then
			print("NOTIFY: SETGEAR")
			local gear = self.gear
			hub:privateMessage("player-gear", jump.."="..(gear[jump] or 0).."&"..air.."="..(gear[air] or 0).."&"..land.."="..(gear[land] or 0))
		end
	end


	function player:readyJumpNotify()
	    if self:notifyOtherPlayer() then
	    	print("NOTIFY: READY JUMP")
            hub:privateMessage("player-readyJump", "")
        end
	end


	function player:cancelJumpNotify()
	    if self:notifyOtherPlayer() then
	    	print("NOTIFY: CANCEL JUMP")
            hub:privateMessage("player-cancelJump", "")
        end
	end


	function player:changeDirectionNotify()
	    if self:notifyOtherPlayer() then
	    	print("NOTIFY: DIRECTION")
            hub:privateMessage("player-direction", "dir="..self.direction)
        end
	end	


	function player:jumpNotify()
	    if self:notifyOtherPlayer() then
	    	print("NOTIFY: RUNUP")
            hub:privateMessage("player-jump", "ledge="..self.attachedLedge.id.."&x="..self:x().."&y="..self:y().."&xvel="..self.xVelocity.."&yvel="..self.yVelocity)
        end
	end


	function player:positionNotify()
		if self:notifyOtherPlayer() then
			print("NOTIFY: POSITION: ledge="..self.attachedLedge.id.."&x="..self:x())
            hub:privateMessage("player-position", "ledge="..self.attachedLedge.id.."&x="..self:x().."&y="..self:y().."&dir="..self.direction.."&mode="..self.mode)
		end
	end

end


return playerLoaderNetworking