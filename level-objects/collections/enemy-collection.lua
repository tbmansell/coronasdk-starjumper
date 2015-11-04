-- @class collection for enemies
local enemyCollection = {
    -- Methods:
    -----------
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
            if mainPlayer then
                enemy:checkDirection(mainPlayer:x())
            end

            self:checkBehaviourChange(enemy, playerCollection)

            enemy:checkShouldShoot()
            enemy:checkFiredItemsOutOfPlay(floorY)

             -- check if enemy should play active sound
            if enemy.activeSound then
                enemy:sound("active", enemy.activeSound)
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
    elseif enemy.mode == stateWaiting or enemy.mode == stateSleeping or (enemy.mode ~= stateResetting and enemy.behaviour.range) then
        -- Loop through all players and see if a player has woken an enemy
        for p=1, numPlayers do
            local player      = playerItems[p]
            local playerLedge = player.attachedLedge

            if playerLedge then
                -- NOTE: find a better way to do this such as when landing on a ledge get the ledge to see if it wakes someone up
                if enemy.mode == stateWaiting or enemy.mode == stateSleeping then
                    if enemy:shouldAwaken(playerLedge.id, player) then
                        break
                    end
                elseif enemy.mode ~= stateResetting and enemy.behaviour.range then
                    enemy:reachedRange(playerLedge.id)
                    break
                end
            end
        end
    end
end


return enemyCollection