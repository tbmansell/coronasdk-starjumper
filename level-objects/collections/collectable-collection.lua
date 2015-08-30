-- @class collection for colectables
local collectableCollection = {

	-- lists # of each color of ring loaded
    ringsAvailable = {},

    -- Methods:
    -----------
    -- !add()
    -- tallyRings()
    -- numberRings()
    -- reset()
}


-- @return true if the object passed is a valid gameObject
----
local function validObject(object)
    return object and object ~= -1 and object.image
end


-- Overrides master:add() to tally rings for collection
-- @param object
----
function collectableCollection:add(object)
    self:addToMaster(object)
    self:addToSpineCollection(object)
    self:addToMovementCollection(object)
    self:tallyRings(object)
end


-- Records how many of each color of rings have been loaded into the collection
-- @param object loaded
----
function collectableCollection:tallyRings(object)
    if object.isRing then
        local color = object.color

        if self.ringsAvailable[color] then
            self.ringsAvailable[color] = self.ringsAvailable[color] + 1
        else
            self.ringsAvailable[color] = 1
        end
    end
end


-- Gets number of rings in collection of a certain color
-- @param color to count
-- @return num rings of color
----
function collectableCollection:numberRings(color) 
    return self.ringsAvailable[color] or 0
end


-- Called when player dies, to reset things like regenerating gear, or remove temporarily generated items, so they can play through the level again
----
function collectableCollection:reset()
    local items = self.items
    local num   = #items

    for i=1,num do
        local collectable = items[i]

        if validObject(collectable) then
            if collectable.isTemp then
                collectable:destroy()

            elseif collectable.regenerate then
                -- for regenerating gear, check to see if the player collected it and if they did, remove 1 quantity from their inventory (if they have 1 left)
                -- It's possible that this could remove one of their own if they used more, but tough
                if collectable.isGear and collectable.collected then
                    hud:useUpGear(collectable.name)
                end

                collectable.isStolen  = false
                collectable.collected = false
                collectable:solid()
                collectable:moveTo(collectable.attachedLedge:x() + collectable.originalPos.x, collectable.attachedLedge:y() + collectable.originalPos.y)
                collectable:visible()
            end
        end
    end
end


return collectableCollection