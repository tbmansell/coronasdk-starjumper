-- @class collection for enemies
local enemyCollection = {
    -- Methods:
    -----------
    -- +add()
    -- reset()
    -- stopAnimations()
    -- checkBehaviourChange()
    -- checkShouldShoot()
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
function enemyCollection:add(enemy, zoneState)
    -- increment fuzzy-napper ID before adding so we can check if its already been collected
    if enemy.type == "greynapper" and enemy.skin == "fuzzy-napper" then
        enemy:generateKey(#self.items + 1)

        -- Check if this fuzzy-napper has already been collected on the current level and exit if so (but still allow incrementing self.amount for the next one)
        if self:collectedItem(enemy, zoneState, "fuzzies") then
            return false
        end
    end

    self:baseAdd(enemy)
    return true
end


-- Stops any animating enemies
----
function enemyCollection:stopAnimations()
    local items = self.items
    local num   = #items

    for i=1,num do
        local enemy = items[i]

        if validObject(enemy) and enemy.movement then
            enemy:pauseMovementFinished()
        end
    end
end


-- Resets all enemies when player dies
----
function enemyCollection:reset()
    local items = self.items
    local num   = #items

    for i=1,num do
        local enemy = items[i]

        if validObject(enemy) then
            if enemy.mode ~= stateSleeping then
                enemy:pose()
                enemy:loop("Standard")
                enemy:lostContact(nil)
            end

            if enemy.deadly then
                enemy:solid()
            end
        end
    end
    -- NOTE: no need for shooters to cleanup the negables, cos they delete themselves as marked isTemp
end


-- Loops through all enemies and calls the behaviour chekers on them in turn (faster than looping many times)
-- @param mainPlayer - reference to the player
-- @param playerCollection
-- @param floor - an integer for the Y value
----
function enemyCollection:checkBehaviours(mainPlayer, playerCollection, floorY)
    local items = self.items
    local num   = #items

    for i=1,num do
        local enemy = items[i]

        if validObject(enemy) then
            if mainPlayer and not enemy.fixDirection then
                enemy:checkDirection(mainPlayer:x())
            end

            self:checkBehaviourChange(enemy, playerCollection)

            enemy:checkShouldShoot()
            enemy:checkFiredItemsOutOfPlay(floorY)

            if hud.debugMode then
                hud:debugEnemyMode(enemy)
            end
        end
    end
end


-- Checks if any enemies need to update their behaviour for moving, shooting, taunting, etc
-- @param enemy
-- @param players - playerCollection
----
function enemyCollection:checkBehaviourChange(enemy, players)
    local playerItems = players.items
    local numPlayers  = #playerItems

    if enemy.mode == stateActive then
        enemy:checkShouldTaunt()

        if enemy.player and enemy.behaviour.range then
            enemy:reachedRange()
        end
    elseif enemy.mode == stateWaiting or enemy.mode == stateSleeping then
        -- Loop through all players and see if a player has woken an enemy
        for p=1, numPlayers do
            local player = playerItems[p]

            if player ~= -1 then
                local playerLedge = player.attachedLedge

                if playerLedge then
                    -- NOTE: find a better way to do this such as when landing on a ledge get the ledge to see if it wakes someone up
                    --if enemy:shouldAwaken(playerLedge.id, player) then
                    -- WARNING: cheated here for zone21 so chasing enemy follows the player and not the AI: not sure of better way to do this yet
                    if enemy:shouldAwaken(playerLedge.id, hud.player) then
                        break
                    end
                end
            end
        end
    end
end


return enemyCollection