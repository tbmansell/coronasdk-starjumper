local soundEngine = require("core.sound-engine")


-- @class Ropeswing class
local ropeswing = {
	
	isRopeSwing = true,

	-- Methods:
	-----------
	-- jumpTop()
	-- changeDirection()
	-- setPhysics()
	-- canGrab()
	-- grab()
	-- redraw()
	-- *scaleMovement()
	-- getVelocity()
}


function ropeswing:jumpTop()   
    return self:y() - (30 * hud.camera.scaleImage)  
end


function ropeswing:changeDirection()
    soundEngine:playManaged(sounds.ropeswingAmbient, self, 1000)
end


function ropeswing:setPhysics(s)
    if not globalIgnorePhysicsEngine then
        physics.addBody(self.image, "static", {density=0, friction=0, bounce=0, isSensor=true, radius=10*s})
    end
end


function ropeswing:canGrab(player)
    local playerTop = player:topEdge() + (player.intHeight/3)
    local slideTop  = self:y() - (30 * player:getCamera().scaleImage)
    return playerTop >= slideTop
end


function ropeswing:grab(player)
    soundEngine:playLand(player.model)
    
    player:stopMomentum()
    player:grabObstacle(self)
    player:loop("DeathSlide HOLD")
    player.mode = playerSwing
    self:moveToGrabPoint(player, 0, 20 * player:getCamera().scaleImage)
end


function ropeswing:redraw(camera)
    if self.line ~= nil then
        camera:remove(self.line)
        self.line:removeSelf()
    end

    local center = self.movement.center
    local line   = display.newLine(center.x, center.y, self:x(), self:y()-10)
    line:setStrokeColor(0.25, 0.25, 0.25)
    line.strokeWidth = 4
    camera:add(line, 3)
    self.line = line
end


-- Override base as not doesnt work with ciruclar movement
function ropeswing:scaleMovement(camera)
    local move   = camera.scalePosition
    local center = self.movement.center
    local centerX, centerY = center.x, center.y

    camera:remove(center)
    center:removeSelf()

    center = display.newCircle(centerX*move, centerY*move, 7*camera.scaleImage)
    center:setFillColor(0.25, 0.25, 0.25)
    camera:add(center, 3)

    self.movement.center = center
    self.length = self.length * move
end


function ropeswing:getVelocity()
    local s = hud.camera.scaleVelocity
    if self.direction == right then
        return 400*s, -400*s
    else
        return -400*s, -400*s
    end
end


return ropeswing