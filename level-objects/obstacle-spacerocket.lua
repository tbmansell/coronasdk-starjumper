local soundEngine = require("core.sound-engine")
local anim        = require("core.animations")


-- @class Deathslide class
local rocket = {
	
	isSpaceRocket = true,

	-- Methods:
	-----------
	-- jumpTop()
    -- *scale()
	-- setPhysics()
	-- canGrab()
	-- grab()
	-- reset()
}


-- Aliases:
local play     = realPlayer
local math_abs = math.abs


function rocket:jumpTop() 
    return self:y() + (35 * self:getCamera().scaleImage)
end


-- Overrides base scale() in order to handle the attached images for this element.
-- The base image is this element itself and will be scaled by baseScale(), so the rocket and cradle must be scaled here
function rocket:scale(camera)
    -- scale base
    self:baseScale(camera)

    local cradleScale = camera.scaleImage * 0.6
    local shipScale   = camera.scaleImage
    local move        = camera.scalePosition

    -- scale cradle
    self.cradle.xScale = cradleScale
    self.cradle.yScale = cradleScale
    self.cradle.x      = self.cradle.x * move
    self.cradle.y      = self.cradle.y * move

    -- scale ship
    physics.removeBody(self.ship)
    self.ship.xScale = shipScale
    self.ship.yScale = shipScale

    if self.angle > 0 then
        self.ship:scale(-1,1)
    end

    self.ship.x = self.ship.x * move
    self.ship.y = self.ship.y * move
    self:setPhysics(shipScale)
end


function rocket:setPhysics(s)
    if not globalIgnorePhysicsEngine then
        local w, h  = (self.ship.width/2)*s, (self.ship.height/2)*s
        local shape = {-w, -h, w, -h, w, h, -w, h}
        physics.addBody(self.ship, "static", {shape=shape, density=0, friction=0, bounce=0, isSensor=true})
    end
end


function rocket:canGrab(player)
    return (self.used ~= true)
end


function rocket:grab(player)
    if self.used then return end

    -- Stop momentum, hold  then activate the slide movement
    soundEngine:playLand(player.model)

    player:stopMomentum()
    player:destroyEmitter()
    player:animate("Rocket-SIT-1")
    player:rotate(self.angle)
    player.mode = playerOnVehicle
    self.used   = true

    if (self.angle > 0 and player.direction == right) or (self.angle < 0 and player.direction == left) then
        player:changeDirection()
    end

    local scale = self:getCamera().scaleImage
    self:moveToGrabPoint(player, 0, -230*scale)
    self:animate("Activated-"..self.takeoff)

    after(1000,       function() self:zoomOut(player) end)
    after(self.delay, function() self:launch(player)  end)
end


-- auto zoom out if not zoomed out
function rocket:zoomOut(player)
    if not self:getCamera().scaleMode then
        hud:triggerMagnifyZone()
        player:stopMomentum(true)
    end
end


function rocket:launch(player)
    soundEngine:playManaged(sounds.rocketActivated, self, 10000, -1, 1, 0, 250)  -- loop until turned off, max volume

    local camera  = self:getCamera()
    local scale   = camera.scaleImage
    local vscale  = camera.scaleVelocity
    local degrees = self.rotation.degrees
    local capsule = display.newImage("images/obstacles/space-rocket/rocket.png", 0, 0)

    capsule.rotation     = self.angle
    capsule.x, capsule.y = player:x(), (player:y()-25)
    capsule:scale(scale, scale)
    camera:add(capsule, 2)

    if self.angle > 0 then  -- left
        capsule:scale(-1,1)
    end

    self.ship.alpha = 0
    self:release(player)
    
    player.vehicleImage = capsule
    player:animate("Rocket-SIT-2")
    player:setGravity(0.5)
    player:applyForce(self.force[1]*vscale, self.force[2]*vscale)

    -- Timer function to rotate player & ship as they move
    self.capsuleSeq = anim:oustSeq("vehicleFlight", self.image)
    self.capsuleSeq:add("callbackLoop", {delay=self.rotation.time, callback=function()
        if player.mode ~= playerOnVehicle then
            anim:destroyQueue("vehicleFlight")
        elseif capsule then
            capsule.rotation      = capsule.rotation      + degrees
            player.image.rotation = player.image.rotation + degrees
        end
    end})
    self.capsuleSeq:start()
end


function rocket:reset(camera)
    self.used = false
    self.ship.alpha = 1
    self:pose()
    self:loop("Standard")
end


return rocket