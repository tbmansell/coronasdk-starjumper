-- @class Base obstacle class
local obstacle = {
	
	isObstacle 		 = true,
    class      		 = "obstacle",
    immuneWarpFields = true,

    -- Methods:
    -----------
    -- eventCollide()
    -- position()
    -- moveToGrabPoint()
}


-- Aliases:
table_indexof = table.indexOf


-- Event handler for the physics collision
-- @param self - obstacle image
-- @param event
----
function obstacle.eventCollide(self, event)
    local obstacle = self.object
    local object   = event.other.object

    if obstacle.isElectricGate then
        if object and obstacle.deadly then
            obstacle:killWithElectricity(object)
        end
        return false
    end

    if object and object.isPlayer and
       table_indexof(playerNonLandModes, object.mode) == nil and
       obstacle:canGrab(object) and
       not obstacle:isBound(object) and
       object.lastObstacleId ~= obstacle.id
    then
        -- delay to allow players physics to be remade to dodge any ledges in the way
        after(1, function()
            object.lastObstacleId = obstacle.id
            obstacle:bind(object)
            obstacle:grab(object)
        end)
    end
end


-- Position this obstacle based on the previous ledge
-- @param prev - ledge
----
function obstacle:position(prev)
	if prev then
	    -- position obstacle from left or right edge depending on if position was negative or positive
	    if self.moveX >= 0 then
	        self:x(prev:rightEdge() + self.moveX + self:width()/2)
	    else
	        self:x(prev:leftEdge() + self.moveX - self:width()/2)
	    end

	    -- position self always from top of last
	    self:y(prev:topEdge() + self.moveY + self:height()/2)
    else
        -- used for when only passing in an X and Y (zone select)
        self:moveTo(self.moveX, self.moveY)
	end
end


-- Moves objects passed to the specified grab point for this object
-- @param object - to move
-- @param x      - xpos
-- @param y      - ypos
----
function obstacle:moveToGrabPoint(object, x, y)
    object.image.gravityScale = 0

    after(25, function()
        local xAdjust, yAdjust = x or 0, y or 0
        local moveX = self:x() + xAdjust - object:x()
        local moveY = self:y() + yAdjust - object:topEdge()
        object:moveBy(moveX, moveY)
    end)
end


return obstacle