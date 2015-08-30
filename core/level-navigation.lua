local spineStore = require("level-objects.collections.spine-store")

-- The main class: just a loader class
local newObjectsLoader = {}

-- Local vars for faster access
local allLedges         = nil
local allObstacles      = nil
local jumpObjectRoute   = nil
local numberLedges      = 0
local numberObstacles   = 0
local numberJumpObjects = 0

-- Aliases
local math_abs    = math.abs
local math_floor  = math.floor
local math_random = math.random

-- Wrapper for loading new functions into level:
function newObjectsLoader:load(level)

    -- Called by main setLocalAssignments() to allow this file to have its own copy of locals
    function level:setNavigationLocalAssignments(_jumpObjectRoute)
        allLedges         = self.ledges.items
        allObstacles      = self.obstacles.items
        jumpObjectRoute   = _jumpObjectRoute
        numberLedges      = #allLedges
        numberObstacles   = #allObstacles
        numberJumpObjects = #jumpObjectRoute
    end


    -- Called when level destroyed to remove all refs
    function level:destroyNavigation()
        allLedges, allObstacles, jumpObjectRoute = nil, nil, nil
    end


    -- Displays the surrounding ledge score markers for the main player
    function level:showLedgeScoreMarkers(currentLedgeId, playerX)
        -- Loop backward until ledges are not on screen or we reach start ledge:
        local i = currentLedgeId - 1
        while i > self.startLedge.id do
            local ledge = allLedges[i]
            if ledge and ledge ~= -1 and ledge.image then
                if ledge:rightEdge() > playerX - contentWidth then
                    if ledge:showScoreMarker() then
                        spineStore:showJumpMarker(self.camera, ledge)
                    end
                else
                    break
                end
            end
            i = i - 1
        end

        -- Loop forward until ledges are not on screen or we reach finish ledge:
        local lastId = self:lastLedgeId()
        i = currentLedgeId + 1

        while i < lastId do
            local ledge = allLedges[i]
            if ledge and ledge ~= -1 and ledge.image then
                if ledge:leftEdge() < playerX + contentWidth then
                    if ledge:showScoreMarker() then
                        spineStore:showJumpMarker(self.camera, ledge)
                    end
                else
                    break
                end
            end
            i = i + 1
        end
    end


    function level:hideLedgeScoreMarkers()
        spineStore:hideJumpMarkers(self.camera)
    end


    -- simple index by ID # to all level ledges
    function level:getLedge(ledgeId)
        if ledgeId > numberLedges then
            return nil
        else
            return allLedges[ledgeId]
        end
    end


    -- gets the ID of the levels last ledge
    function level:lastLedgeId()
        return allLedges[#allLedges].id
    end


    -- gets the last ledge
    function level:getLastLedge()
        return self:getLedge(self:lastLedgeId())
    end


    -- sinple index by ID # to all level obstacles
    function level:getObstacle(id)
        if id > numberObstacles then
            return nil
        else
            return allObstacles[id]
        end
    end


    -- finds next item to jump to, without AI rules
    function level:nextJumpObject(fromIndex)
        local fromIndex = fromIndex or 1
        local nextIndex = fromIndex + 1

        if nextIndex > numberJumpObjects then
            return nil
        else
            return jumpObjectRoute[nextIndex]
        end
    end


    -- finds the next eligable ledge or obstacle to jump to for AI, from current position, going forward
    function level:nextAiJumpObject(fromIndex)
        local fromIndex = fromIndex or 1
        local nextIndex = fromIndex + 1

        -- check if current item has command to tell you the next location
        local from = jumpObjectRoute[fromIndex]
        if from.ai then
            local ai = from.ai
            if ai.nextJump then
                local nextJump = ai.nextJump
                -- if nextJump set, then loop through possibilities and if % meets up, go to that jumpObject
                local decision = math_random(100)
                for chance,zoneRouteIndex in pairs(nextJump) do
                    if decision <= chance then
                        return jumpObjectRoute[zoneRouteIndex]
                    end
                end
            end
        end

        -- loop through next objects and see which are eligable
        local num = numberJumpObjects
        for i=nextIndex, num do
            local object = jumpObjectRoute[i]
            local ai     = object.ai

            if ai then
                local ignore = ai.ignore
                -- check if ai.ignore is a number, which means its a % chance AI will ignore jumpObject
                -- if ai.ignore is bool (true) then always ignore it
                if not ignore or (type(ignore) == "number" and math_random(100) > ignore) then
                    return object
                end
            else
                return object
            end
        end
        return nil
    end


    -- Gets the closest ledge to a position and direction, returning the ledge and the distance to it
    function level:getClosestLedge(jumpedLedgeId, x, xVelocity)
        local left        = xVelocity < 0
        local foundJumped = false
        local curDiff     = nil
        local ledge, loopStart, loopEnd, step = nil, 1, numberLedges, 1

        if left then
            local temp = loopStart
            loopStart, loopEnd, step = loopEnd, temp, -1
        end

        for i=loopStart, loopEnd, step do
            local iter = allLedges[i]

            if iter ~= -1 and iter.image then 
                if iter.id == jumpedLedgeId then
                    foundJumped = true
                elseif foundJumped then
                    local ledgeX, finalX = iter:x(), 0

                    if x > ledgeX or (left and x < ledgeX) then
                        finalX = ledgeX + iter:width()/2
                    else
                        finalX = ledgeX - iter:width()/2
                    end

                    local diff = math_abs(finalX - x)

                    if curDiff == nil then
                        ledge, curDiff = iter, diff
                    elseif diff < curDiff then
                        ledge, curDiff = iter, diff
                    else
                        -- We've already found the closest
                        break
                    end
                end
            end
        end

        return ledge,curDiff
    end


    -- Gets the closest ledge to a position, returning the ledge and the x/y distance to its left/right/top/bototm edge
    function level:getClosestLedgeAtPoint(x, y)
        local found    = false
        local curLedge = nil
        local curX     = 1000000
        local curY     = 1000000
        local curSideX = "left"
        local curSideY = "top"

        for i=1,numberLedges do
            local ledge = allLedges[i]
            local diffLeft, diffRight = math_abs(x - ledge:leftEdge()), math_abs(x - ledge:rightEdge())
            local diffTop,  diffBot   = math_abs(y - ledge:topEdge()),  math_abs(y - ledge:bottomEdge())
            local distX, distY        = 0, 0
            local sideX, sideY        = "left", "top"
            
            if diffRight < diffLeft then
                distX = diffRight
                if diffRight < curX then sideX = "right" end
            else
                distX = diffLeft
                if diffLeft  < curX then sideX = "left" end
            end

            if diffBot < diffTop then
                distY = diffBot
                if diffBot < curY then sideY = "bottom" end
            else
                distY = diffTop
                if diffTop < curY then sideY = "top" end
            end
            
            if (distX + distY) < (curX + curY) then
                curLedge = ledge
                curX     = distX
                curY     = distY
                curSideX = sideX
                curSideY = sideY
            end
        end

        return curLedge, curX, curY, curSideX, curSideY
    end
    
    
    -- Get number of start of type
    function level:numRings(type)
        return self.collectables:numberRings(type)
    end


    -- Get number of start of type
    function level:numFuzzies(type)
        return self.friends:numberFuzzies(type)
    end
    
    
    -- Returns the #mins and #seconds, plus total seconds to complete the level in bonus time
    function level:getTimeBonus()
        local timeBonusSeconds = self.data.timeBonusSeconds or 60
        return math_floor(timeBonusSeconds/60), math_floor(timeBonusSeconds % 60), timeBonusSeconds
    end

end


return newObjectsLoader