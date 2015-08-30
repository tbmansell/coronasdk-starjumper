local soundEngine = require("core.sound-engine")


-- @class Deathslide class
local deathslide = {
	
	isDeathSlide = true,

	-- Methods:
	-----------
	-- jumpTop()
	-- setPhysics()
	-- canGrab()
	-- grab()
	-- movementCompleted()
	-- reset()
}


function deathslide:jumpTop() 
    return self:y() + (35 * self:getCamera().scaleImage)
end


function deathslide:setPhysics(s)
    local shape = {-15*s,35*s, 15*s,35*s, 15*s,60*s, -15*s,60*s}
    if not globalIgnorePhysicsEngine then
        physics.addBody(self.image, "static", {density=0, friction=0, bounce=0, isSensor=true, shape=shape})
    end
end


function deathslide:canGrab(player)
    local playerTop = player:topEdge() + (player.intHeight/3)
    local slideTop  = self:y() + (35 * self:getCamera().scaleImage)
    return playerTop >= slideTop
end


function deathslide:grab(player)
    if self.used then return end
    -- Stop momentum, hold  then activate the slide movement
    soundEngine:playLand(player.model)
    
    player:stopMomentum()
    player:grabObstacle(self)
    player:loop("DeathSlide HOLD")
    player.mode = playerHang
    self.player = player

    self:moveToGrabPoint(player, 0, (60 * self:getCamera().scaleImage))
    
    after(self.delay or 0, function()
        soundEngine:playManaged(sounds.deathslideActivated, self, 10000, -1, 1, 0, 250)  -- loop until turned off, max volume
        self:loop("Deathslide-"..self.animSpeed)
        self.started = true
        self:moveNow()
    end)
end


function deathslide:movementCompleted()
    soundEngine:stopSound(self.key)
    
    self:stop()
    self:animate("Standard")
    self.started = false
    self.used    = true

    if self.player then
        self.player:letGoAction()
        self.player = nil
    end
end


function deathslide:reset(camera)
    if self.started or self.used then
        local scale = camera.scaleImage
        self:movementCompleted()
        self.used = false
        self:moveBy(-self.movement.currentX, -self.movement.currentY)
        self.movement.pattern = {{self.length[1]*scale, self.length[2]*scale}}
        self:setMovement(camera, self.movement)
    end
end


return deathslide