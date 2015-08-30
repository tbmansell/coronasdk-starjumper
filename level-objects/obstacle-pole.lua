local soundEngine = require("core.sound-engine")


-- @class Pole class
local pole = {
	
	isPole = true,

	-- Methods:
	-----------
	-- jumpTop()
	-- setPhysics()
	-- canGrab()
	-- grab()
}


function pole:jumpTop() 
    return self:y()
end


function pole:setPhysics(s)
    if not globalIgnorePhysicsEngine then
        -- divide default image size by length to get scale
        local w, h  = (28/2)*s, (self.length/2)*s
        local shape = {-w,-h, w,-h, w,h, -w,h}
        physics.addBody(self.image, "static", {density=0, friction=0, bounce=0, isSensor=true, shape=shape})
    end
end


function pole:canGrab(player)
    local playerTop = player:topEdge() + (player.intHeight/3)
    local poleTop   = self:topEdge()
    return playerTop >= poleTop and player.mode ~= playerKilled
end


function pole:grab(player)
    -- Stop momentum, hold for half a second then slide down with gravity
    soundEngine:playLand(player.model)
    player:stopMomentum(true)
    player:grabObstacle(self)
    player:animate("Pole HOLD")

    -- grab point works slightly differently from slide and swing
    after(25, function()
        local dist  = 10 * player:getCamera().scaleImage
        local moveX = self:x() - player:x()
        local moveY = self:topEdge() + dist - player:topEdge()

        if player.direction == right then dist = -dist end
        moveX = moveX + dist

        if moveY < 0 then moveY = 0 end

        player:moveBy(moveX, moveY)
    end)

    -- ice poles automatically slide off, normal you hang till pressing tap
    if self.sticky then
        player.mode = playerHang
    else
        after(500, function()
            soundEngine:playManaged(sounds.poleSlide, self, 2000)
            player:letGoAction(true)
            player:animate("Pole SLIDE")
        end)
    end
end


return pole