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
    -- Guard to stop this being triggerd twice and added to movementCollection
    if self.used then return end

    self.used   = true
    self.player = player

    -- Stop momentum, hold  then activate the slide movement
    player:soundLand()
    
    player:stopMomentum()
    player:grabObstacle(self)
    player:loop("DeathSlide HOLD")
    player.mode = playerHang

    self:moveToGrabPoint(player, 0, (60 * self:getCamera().scaleImage))
    
    after(self.delay or 0, function()
        -- loop until turned off
        self:sound("deathslideActivated", {duration=10000,  loops=-1})
        self:loop("Deathslide-"..self.animSpeed)
        self.started = true
        self:move()
    end)
end


function deathslide:movementCompleted()
    soundEngine:stopSound(self.key)
    
    self:stop()
    self:animate("Standard")

    if self.player then
        self.player:letGoAction()
        self.player = nil
    end
end


function deathslide:reset(camera)
    if self.used then
        self.used   = false
        self.player = nil
    end

    if self.started then
        local scale = camera.scaleImage  -- not scalePosition as when scaled out this is > 1
        local m     = self.movement

        self:movementCompleted()
        self:moveBy(-m.currentX, -m.currentY)
        self.started = false

        m.currentX   = 0
        m.currentY   = 0
        m.nextX      = self.length[1] * scale
        m.nextY      = self.length[2] * scale
        m.patternPos = 1
    end
end


return deathslide