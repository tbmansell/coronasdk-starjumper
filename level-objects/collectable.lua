-- @class main class
local collectable = {
	-- Methods:
	-----------
	-- eventCollideRing()
	-- eventCollideTimeBonus()
	-- eventCollideGear()
    -- eventCollideKey()
	-- eventCollideRandomizer()
	-- eventCollideWarpField()
}


function collectable.eventCollideRing(self, event)
    local other = event.other.object
    local ring  = self.object

    if other ~= nil and other.isPlayer and event.phase == "began" and not ring.isStolen then
        ring:stop()
        ring:animate("Collected")
        other:collected(ring)
        return true
    end
end


function collectable.eventCollideGear(self, event)
    local other = event.other.object
    local gear  = self.object

    if other == nil then return end

    if event.phase == "began" and not gear.isStolen then
        if other.isPlayer then
            if gear.ignoreObject and gear.ignoreObject == other.key then
                return false
            end
            gear:intangible()
            other:collected(gear)
            return true
        elseif other.isLedge then
            gear.attachedLedge = other
            other:bind(gear)
            gear.image:setLinearVelocity(0,0)
            return true
        end
    end
end


function collectable.eventCollideTimeBonus(self, event)
    local other = event.other.object
    local bonus = self.object

    if other ~= nil and other.isPlayer and event.phase == "began" and not bonus.isStolen then
        bonus:stop()
        bonus:animate("Foward")
        other:collected(bonus)
        return true
    end
end


function collectable.eventCollideKey(self, event)
    local other = event.other.object
    local key   = self.object

    if other == nil then return end

    if event.phase == "began" and other.isLedge then
        other:bind(key)
    end

    if event.phase == "began" and not key.isStolen then
        if other.isPlayer then
            key:intangible()
            other:collected(key)
            return true
        end
    end
end


function collectable.eventCollideRandomizer(self, event)
    local other      = event.other.object
    local randomizer = self.object

    if other ~= nil and other.isPlayer and event.phase == "began" and not randomizer.collected then
        -- Have to delay calling the method as physics engine cries like baby if created object during a collision event
        after(50, function() randomizer:activate() end)
        return true
    end
end


function collectable.eventCollideWarpField(self, event)
    local other = event.other.object
    local warp  = self.object

    if other == nil then return end

    if event.phase == "began" then
        if not other.touchJoint and not other.immuneWarpFields then
            after(10, function()
                if other.image and other.image ~= -1 then
                    other.touchJoint = physics.newJoint("rope", warp.image, other.image)
                    warp:sound("hit"..tostring(other.key), warp.hitSound)

                    after(1000, function()
                        if other.touchJoint then
                            other.immuneWarpFields = true
                            if other.touchJoint.removeSelf then other.touchJoint:removeSelf() end
                            other.touchJoint = nil
                            after(1500, function() other.immuneWarpFields=false end)
                        end
                    end)
                end
            end)
        end
    elseif event.phase == "ended" then 
        if other.isPlayer and other.hasJoint then
            other.touchJoint:removeSelf()
            other.touchJoint = nil
        end
    end
end


return collectable