-- @class collection for friends
local friendCollection = {

    -- lists # of each color of fuzzy loaded
    fuzziesAvailable = {},

    -- Methods:
    -----------
    -- +add()
    -- tallyFuzzies()
    -- numberFuzzies()
    -- reset()
    -- checkBehaviourChange()
}


-- @return true if the object passed is a valid gameObject
----
local function validObject(object)
    return object and object ~= -1 and object.image
end


-- Replaces masterCollection.add() to add a friend optionally based on if they have collected a friend before
-- @param friend    - to add
-- @param zoneState - optional state data for previous run on a zone (so we assign prev score)
----
function friendCollection:add(friend, zoneState)
    -- increment fuzzy ID before adding so we can check if its already been collected
    if friend.isFuzzy then
        friend:generateKey(#self.items + 1)

        -- Check if this fuzzy has already been collected on the current level and exit if so (but still allow incrementing self.amount for the next one)
        if self:collectedItem(friend, zoneState, "fuzzies") then
            return false
        end
    end

    self:baseAdd(friend)
    self:tallyFuzzies(friend)
    return true
end


-- Records how many of each color of fuzzies have been loaded into the collection
-- @param object loaded
----
function friendCollection:tallyFuzzies(object)
    if object.isFuzzy then
        local color = object.color

        if self.fuzziesAvailable[color] then
            self.fuzziesAvailable[color] = self.fuzziesAvailable[color] + 1
        else
            self.fuzziesAvailable[color] = 1
        end
    end
end


-- Gets number of fuzzies in collection of a certain color
-- @param color to count
-- @return num fuzzies of color
----
function friendCollection:numberFuzzies(color)
    return self.fuzziesAvailable[colorNames[color]] or 0
end


-- Reset friends when player dies
----
function friendCollection:reset()
    local items = self.items
    local num   = #items

    for i=1,num do
        local friend = items[i]

        if validObject(friend) and friend.isFuzzy then
            friend:pose()
            friend:loop("Standard")
            friend:solid()
        end
    end
end


-- Loop through friends to see if any should change their behaviour
----
function friendCollection:checkBehaviourChange()
    local items = self.items
    local num   = #items

    for i=1,num do
        local friend = items[i]

        if validObject(friend) then
            -- get fuzzies to wave
            if friend.isFuzzy and friend.kinetic ~= "hangDouble" and not friend.cantChangeYet and not friend.collected then
                friend:wave()
            end
        end
    end
end


return friendCollection