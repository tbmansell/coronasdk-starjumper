-- Aliases:
local PI                  = math.pi
local math_abs            = math.abs
local math_cos            = math.cos
local math_sin            = math.sin
local math_round          = math.round
local math_random         = math.random
local math_sqrt           = math.sqrt
local display_new_line    = display.newLine
local display_new_circle  = display.newCircle

-- Local vars:
local movementStyleAmount = 1
local movementAmounts     = {}
local movementModeMoving  = 0
local movementModePaused  = 1
local movementScale       = 1
local delta               = 0


local function modifyItemBySwaying(item, limit)
    local m     = item.movement
    local time  = m.styleTimer or 0
    local image = item.image

    if time > 0 then
        m.styleTimer = m.styleTimer - 1
        return
    end

    m.styleTimer = 1

    local moveBy = movementStyleAmount 
    if m.speed < 1 then moveBy = moveBy * m.speed end

    if m.swayingDirection == left then
        if m.swaying > 0 then
            image.x    = image.x    - moveBy
            m.currentX = m.currentX - moveBy
            m.swaying  = m.swaying  - moveBy
        else
            m.swayingDirection, m.swaying = right, limit
        end
    elseif m.swayingDirection == right then
        if m.swaying > 0 then
            image.x    = image.x    + moveBy
            m.currentX = m.currentX + moveBy
            m.swaying  = m.swaying  - moveBy
        else
            m.swayingDirection, m.swaying = left, limit
        end
    else
        m.swayingDirection, m.swaying = left, limit
    end

    if m.swaying < limit/2 then
        m.currentY = m.currentY - moveBy
        image.y    = image.y    - moveBy
    else
        m.currentY = m.currentY + moveBy
        image.y    = image.y    + moveBy
    end
end


local function modifyItemByWaving(item, limit)
    local m     = item.movement
    local time  = m.styleTimer or 0
    local image = item.image

-- TODO: this has crashed here before - work out why this is nil
--    if m.swaying == nil then return end

    if time > 0 then
        m.styleTimer = m.styleTimer - 1
        return
    end

    m.styleTimer = 1

    local moveBy = movementStyleAmount 
    if m.speed < 1 then moveBy = moveBy * m.speed end

    if m.swayingDirection == left then
        if m.swaying > 0 then
            image.y    = image.y    - moveBy
            m.currentY = m.currentY - moveBy
            m.swaying  = m.swaying  - moveBy
        else
            m.swayingDirection, m.swaying = right, limit
        end
    elseif m.swayingDirection == right then
        if m.swaying > 0 then
            image.y    = image.y    + moveBy
            m.currentY = m.currentY + moveBy
            m.swaying  = m.swaying  - moveBy
        else
            m.swayingDirection, m.swaying = left, limit
        end
    else
        m.swayingDirection, m.swaying = left, limit
    end

    if limit and m.swaying < limit/2 then
        image.x    = image.x    - moveBy
        m.currentX = m.currentX - moveBy
    else
        image.x    = image.x    + moveBy
        m.currentX = m.currentX + moveBy
    end
end


local function modifyItemByRandom(item)
    local r = math_random(100)

    if r < 25 then
        item.image.x = item.image.x - movementStyleAmount
        m.currentX   = m.currentX   - movementStyleAmount
    elseif r < 50 then
        item.image.x = item.image.x + movementStyleAmount
        m.currentX   = m.currentX   + movementStyleAmount
    end
end


local function modifyItemByMovementStyle(item, when)
    local m = item.movement
    local style = m.style

    if when == movementModeMoving and style == nil then
        style = m.moveStyle
    elseif when == movementModePaused and style == nil then
        style = m.pauseStyle
    end

    if style then
        local limit = movementAmounts[style]

        if limit == nil then print("WARNING: style="..tostring(style).." NO LIMIT") end

        if     style == moveStyleRandom    then modifyItemByRandom(item, limit)
        elseif style == moveStyleSway      then modifyItemBySwaying(item, limit)
        elseif style == moveStyleSwaySmall then modifyItemBySwaying(item, limit)
        elseif style == moveStyleSwayBig   then modifyItemBySwaying(item, limit)
        elseif style == moveStyleWave      then modifyItemByWaving(item, limit)
        elseif style == moveStyleWaveTiny  then modifyItemByWaving(item, limit)
        elseif style == moveStyleWaveSmall then modifyItemByWaving(item, limit)
        elseif style == moveStyleWaveBig   then modifyItemByWaving(item, limit) end
    end

    return item.image.x, item.image.y
end


local function pauseItemPatternMovement(item)
    local m = item.movement

    if m.style or m.pauseStyle then
        local x, y = modifyItemByMovementStyle(item, movementModePaused)

        if item.isLedge then
            moveAttachedItems(item, x, y)
        end
    end
end


---------- CRITICAL LOCAL FUNCTIONS ----------


local function getDistance(fromX, fromY, toX, toY)
    return math_sqrt( (fromX - toX) * (fromX - toX) + (fromY - toY) * (fromY - toY) )
end


local function getNextPointVelocity(curX, curY, nextX, nextY, speed)
    local distance = getDistance(curX, curY, nextX, nextY)
    return ((nextX - curX) / distance) * speed,
           ((nextY - curY) / distance) * speed
end


local function setupNextPointSpeed(item, nextPoint)
    local m        = item.movement
    local steering = m.steering
    local minSpeed = m.minSpeed
    local maxSpeed = m.maxSpeed
    local speed    = nil

    -- Set direction for easier locating when arriving at or past next point
    m.nextXRight = m.nextX > m.currentX
    m.nextYDown  = m.nextY > m.currentY

    if nextPoint and nextPoint.speed then
        -- pattern point specifically defines a speed:
        speed = nextPoint.speed
    elseif minSpeed and maxSpeed then
        -- object has a variable speed:
        speed = minSpeed + math_random(maxSpeed-minSpeed)
    else
        -- object has a fixed speed:
        speed = m.speed
    end

    if steering then
        -- If element has steering specified, then dont suddenly switch, but activate gradualy steering to the next point
        m.desiredX, m.desiredY = getNextPointVelocity(m.currentX, m.currentY, m.nextX, m.nextY, speed)
        m.pointSpeed = speed
    else
        -- if no steering then switch straight to the next point (jerky)
        m.speedX, m.speedY = getNextPointVelocity(m.currentX, m.currentY, m.nextX, m.nextY, speed)
    end
end


-- m = movement
local function getSteering(m, steering)
    local steeringX = m.desiredX - (m.speedX or 0)
    local steeringY = m.desiredY - (m.speedY or 0)
    local cap       = steering.cap
    local mass      = steering.mass

    steeringX = steeringX / mass
    steeringY = steeringY / mass

    if steeringX > cap then
        steeringX = cap
    elseif steeringX < -cap then
        steeringX = -cap
    end

    if steeringY > cap then
        steeringY = cap
    elseif steeringY < -cap then
        steeringY = -cap
    end

    return steeringX, steeringY
end


local function reachedPatternPoint(item)
    local m = item.movement
    --local steering = m.steering

    --[[
    if steering then
        -- steeirng logic detects if item within a radius of the point
        --if getDistance(m.currentX, m.currentY, m.nextX, m.nextY) <= steering.radius then
        local distance = getDistance(m.currentX, m.currentY, m.nextX, m.nextY)
        if distance <= steering.radius then
            print(item.key.." [reached point] XY="..math_round(m.currentX)..","..math_round(m.currentY).." distance="..math_round(distance).." radius="..steering.radius.." speed="..m.speed)
            return true
        end
    end]]

    -- fallback to axis detection as radius calculations have to be too accurate
    local nextX,    nextY    = m.nextX,    m.nextY
    local curX,     curY     = m.currentX, m.currentY
    local reachedX, reachedY = false, false
    

    if     m.nextX == 0  then reachedX = true
    elseif m.nextXRight  then reachedX = (curX >= nextX)
    elseif curX <= nextX then reachedX = true end

    if     m.nextY == 0  then reachedY = true
    elseif m.nextYDown   then reachedY = (curY >= nextY)
    elseif curY <= nextY then reachedY = true end

    if reachedX and reachedY then
        if not m.steering then
            -- Calculate the overspill here, which gets added onto the items movement
            if nextX == 0 then m.overspillX = -curX else m.overspillX = nextX - curX end
            if nextY == 0 then m.overspillY = -curY else m.overspillY = nextY - curY end
        end
        
        --[[print(item.key.." CUR=" ..string.format("%4d", curX)         ..",".. string.format("%4d", curY)
                      .." TAR=" ..string.format("%4d", nextX)        ..",".. string.format("%4d", nextY)
                      .." OVR=" ..string.format("%4d", m.overspillX) ..",".. string.format("%4d", m.overspillY)
                      .." IMG=" ..string.format("%4d", item.image.x) ..",".. string.format("%4d", item.image.y))]]

        return true
    end

    return false
end


local function moveAttachedItems(item, x, y)
    for key,object in pairs(item.boundItems) do
        local image = object.image
        if image then
            local ox, oy = image.x, image.y
            
            if ox and x then object.image.x = ox + x end
            if oy and y then object.image.y = oy + y end
        end

        if object.isPlayer then
            -- If player is throwing a negable: move this
            local heldItem = object.negableShot
            if heldItem then
                heldItem.x, heldItem.y = heldItem.x + x, heldItem.y + y
            end

            if object.main and (object.mode == playerDrag or object.mode == playerThrowing) then
                -- If player preparing jump on moving ledge, have to redraw grid and curve items
                curve:moveJumpGridBy(x, y)

                -- If player on a moving ledge and has trajectory gear activated, a global will be created to reposition
                if curve.showTrajectory and redrawTrajectory then
                    redrawTrajectory()
                end
            end
        end
    end
end


local function selectPositionOf(item, target, offsetX, offsetY)
    local m = item.movement
    local px, py = target.image.x + (offsetX or 0), target:topEdge() + (offsetY or 0)

    -- We have the option of specifying a move which only follows one of the players axis not both (ignore these restrictions if resetting position)
    if not m.followYOnly or item.mode == stateResetting then
        local ix = item.image.x
        if px < ix then
            m.nextX = math_round(-(ix-px))
        else
            m.nextX = math_round(px-ix)
        end

        local waste = m.nextX % (m.speed or m.maxSpeed-m.minSpeed)
        if waste > 0 then m.nextX = m.nextX - waste end
    end

    if not m.followXOnly or item.mode == stateResetting then
        local iy = item.image.y
        -- sanity check: dont go past the player
        local levelFloor = hud.level.floor.y

        if py > levelFloor then py = levelFloor end

        if py < iy then
            m.nextY = math_round(-(iy-py))
        else
            m.nextY = math_round(py-iy)
        end

        local waste = m.nextY % (m.speed or m.maxSpeed-m.minSpeed)
        if waste > 0 then m.nextY = m.nextY - waste end
    end

    -- apply any follow offsets
    m.nextX = m.nextX + (m.offsetX or 0)
    m.nextY = m.nextY + (m.offsetY or 0)
    
    m.currentX, m.currentY = 0, 0
    setupNextPointSpeed(item, nil)
end


local function moveItemPatternXY(item, delta)
    local m        = item.movement
    local steering = m.steering
    local image    = item.image
    local moveX    = (m.speedX or 0) --* delta
    local moveY    = (m.speedY or 0) --* delta

    if image == nil then return end

    if steering then
        local steeringX, steeringY = getSteering(m, steering)
        
        moveX = (moveX + steeringX)
        moveY = (moveY + steeringY)
        m.speedX, m.speedY = moveX, moveY
    end

    -- Log movement here
    m.currentX = m.currentX + moveX
    m.currentY = m.currentY + moveY

    if m.style or m.moveStyle then
        modifyItemByMovementStyle(item, movementModeMoving)
    end
    
    -- Apply initial overspill to movement if it exists:
    --if m.overspillX ~= 0 or m.overspillY ~= 0 then
    --    print("Added overspill ("..m.overspillX..", "..m.overspillY..") X: "..moveX.."+"..m.overspillX.."="..(moveX + m.overspillX).." Y: "..moveY.."+"..m.overspillY.."="..(moveY + m.overspillY))
    --end

    -- Apply overspill movement here which is untracked (so as not to disrupt the nextXY pos)
    if m.overspillX ~= 0 then
        moveX = moveX + m.overspillX
        m.overspillX = 0
    end

    if m.overspillY ~= 0 then
        moveY = moveY + m.overspillY
        m.overspillY = 0
    end

    -- Move the actual image with any overspill applied
    image.x = image.x + moveX
    image.y = image.y + moveY

    if item.isLedge or item.isObstacle then
        moveAttachedItems(item, moveX, moveY)
    end
end


local function moveItemCircular(camera, item)
    local m       = item.movement
    local radius  = item.length
    local speed   = m.speed
    local centerX = m.center.x
    local centerY = m.center.y

    if item.direction == left and m.degree <= m.arcEnd then
        item.direction = right
        item:changeDirection()
    elseif item.direction == right and m.degree >= m.arcStart then
        item.direction = left
        item:changeDirection()
    end

    if item.direction == right then
        m.degree = m.degree + speed
    else
        m.degree = m.degree - speed
    end

    local radian = (m.degree/180) * PI
    local x = centerX + math_cos(radian) * radius
    local y = centerY - math_sin(radian) * radius

    local diffX = x - item.image.x
    local diffY = y - item.image.y
    
    -- move item and tell it to redraw itself if needed (rope swings)
    item:moveBy(diffX, diffY)
    item:redraw(camera)
    moveAttachedItems(item, diffX, diffY)
end


local function selectNextFollowPosition(item)
    local m = item.movement

    if item.isResetting then
        item:hasReset()
    elseif item.mode == stateResetting then
        item.isResetting = true
        selectPositionOf(item, item.startLedge, m.originalX, m.originalY, delta)
    else
        selectPositionOf(item, item.player, nil, nil, delta)
    end
    return true
end


local function selectNextPatternPosition(item)
    local m = item.movement
    local pattern = m.pattern
    local repeatPattern = false

    if m.patternName == movePatternFollow then
        return selectNextFollowPosition(item)
    elseif m.oneWay and m.patternPos == #pattern then
        return false
    end

    if m.inReverse then
        if m.patternPos == 1 then
            m.inReverse = false
            repeatPattern = true
        else
            m.patternPos = m.patternPos - 1
        end
    elseif m.patternPos == #pattern then
        if m.reverse then
            m.inReverse = true
        else
            m.patternPos = 1
            repeatPattern = true
        end
    else
        m.patternPos = m.patternPos + 1
    end

    local nextPoint = pattern[m.patternPos]

    if m.inReverse then
        m.nextX, m.nextY = -nextPoint[1], -nextPoint[2]
    else
        m.nextX, m.nextY = nextPoint[1], nextPoint[2]
    end

    m.currentX, m.currentY = 0, 0
    setupNextPointSpeed(item, nextPoint)
    return true
end


---------- GLOBAL FUNCTIONS ----------


-- Creates the movement 
function setupMovingItem(item)
    local m = item.movement
    -- default these params if not supplied
    m.currentX    = 0
    m.currentY    = 0
    m.overspillX  = 0
    m.overspillY  = 0
    m.patternPos  = m.patternStart or 1
    m.pause       = m.pause or 0
    m.patternName = m.pattern

    if m.pattern == movePatternHorizontal then
        m.reverse = true
        m.pattern = {{-m.distance, 0, m.pause or 0}}

    elseif m.pattern == movePatternVertical then
        m.reverse = true
        m.pattern = {{0, m.distance, m.pause or 0}}

    elseif m.pattern == movePatternFollow then
        m.startX, m.startY = item.x, item.y
        m.pattern     = {{0, 0, m.pause or 0}}
        m.followXOnly = m.followXOnly or false
        m.followYOnly = m.followYOnly or false

    elseif m.pattern == movePatternCircular then
        item.direction = item.direction or right

        if item.direction == left then
            m.arcEnd = m.arcStart - m.arc - 10
            m.degree = m.arcStart
        else
            m.arcEnd   = m.arcStart - 10
            m.arcStart = m.arcEnd + m.arc + 10
            m.degree   = m.arcEnd
        end
        -- dont look for next point in the pattern
        return

    elseif m.isTemplate then
        m.isTemplate = false
        m.pattern = parseMovementPattern(m.pattern, m.distance)

    elseif m.isBobbing then
        m.isBobbing = false  -- used to signal a pattern parse first time only
        m.bobbing   = true   -- used by external code to detect if this is bobbing movement
        m.reverse   = true
        m.dontDraw  = true
        m.pattern   = parseMovementPattern(m.pattern, m.distance)
    end

    -- setup the movement to the first point
    m.nextX = m.pattern[m.patternPos][1]
    m.nextY = m.pattern[m.patternPos][2]
    setupNextPointSpeed(item, m.pattern)
end


-- draws the movement path
function drawMovingPathPoint(fromX, fromY, pattern, index, camera)
    local toX = fromX + pattern[index][1]
    local toY = fromY + pattern[index][2]
    local fromCircle = nil

    if index == 1 then
        fromCircle   = display_new_circle(fromX, fromY, 5)
        fromCircle.alpha = 0.5
        fromCircle:setFillColor(0.2, 0.4, 0.5)
        camera:add(fromCircle, 3)
        fromCircle:toBack()
    end

    local line = display_new_line(fromX, fromY, toX, toY)
    line.alpha = 0.5
    line.strokeWidth = 5
    line:setStrokeColor(0.2, 0.4, 0.6)

    local circle = display_new_circle(toX, toY, 5)
    circle.alpha = 0.5
    circle:setFillColor(0.2, 0.4, 0.6)

    camera:add(line, 3)
    camera:add(circle, 3)
    line:toBack()
    circle:toBack()

    return toX, toY, line, circle, fromCircle
end


-- This is the main function called from the game loop to update movement
function moveItemPattern(camera, item, delta)
    local m = item.movement

    if m.pattern == movePatternCircular then
        return moveItemCircular(camera, item)
    end

    if item.pauseMovementHandle ~= nil or item.mode == stateWaiting then
        return pauseItemPatternMovement(item)
    end

    if reachedPatternPoint(item) then
        if item.reachedPatternPoint then
            item:reachedPatternPoint()
        end

        -- look for the next position to move to (or reverse or loop if at end of pattern)
        if selectNextPatternPosition(item) then
            -- check if we should delay before moving to the next position
            local pause = m.pattern[m.patternPos].pause or m.pause
            item:pauseMovement(pause)

            if item.nextPositionStarted then
                item:nextPositionStarted()
            end

            -- If not pausing then still perform movement pattern this loop - otherwise you get a jerkying motion if an item is the camera focus
            if pause == nil or pause == 0 then
                moveItemPatternXY(item, delta)
            end
        else
            -- If returns false we are done moving
            return item:movementCompleted()
        end
    else
		moveItemPatternXY(item, delta)
    end
end


---------- UTILITY FUNCTIONS -----------


function setMovementStyleSpeeds()
    movementStyleAmount = 1
    movementAmounts = {
        [moveStyleRandom]    = 1,
        [moveStyleSway]      = 20,
        [moveStyleSwaySmall] = 5,
        [moveStyleSwayBig]   = 35,
        [moveStyleWave]      = 20,
        [moveStyleWaveTiny]  = 1,
        [moveStyleWaveSmall] = 5,
        [moveStyleWaveBig]   = 35
    }
end


function scaleMovement(scale)
    movementStyleAmount = scale

    for index,speed in pairs(movementAmounts) do
        movementAmounts[index] = speed * scale
    end
end


function cloneMovement(m)
    local movement = {
        pattern    = m.pattern,
        speed      = m.speed, 
        pause      = m.pause,
        reverse    = m.reverse,
        oneWay     = m.oneWay,
        distance   = m.distance, 
        moveStyle  = m.moveStyle,
        pauseStyle = m.pauseStyle,
        arcStart   = m.arcStart,
        arc        = m.arc,
        steering   = m.steering
    }
    return movement
end


-- Takes one of the globally defined movement patterns and a distance and multiplies the distance into the pattern to get a pattern with real movement
-- NOTE: enemies do reverse X logic from ledges due to their direction attribute: use flipX for ledges if using global constants
function parseMovementPattern(pattern, distance, flipX)
    local real = {}
    local num  = #pattern

    for i=1,num do
        local position = pattern[i]
        local index    = #real+1

        local x, y  = position[1] * distance, position[2] * distance
        real[index] = {x, y, speed=position.speed, pause=position.pause}

        if flipX then
            real[index][1] = -real[index][1]
        end
    end

    return real
end


function getMovementDistance(pattern, distance)
    if pattern == movePatternHorizontal then
        return distance, 0
    elseif pattern == movePatternVertical then
        return 0, distance
    end

    local maxX, maxY = 0, 0
    local num = #pattern

    for i=1,num do
        local position = pattern[i]

        local x = math_abs(position[1] * distance)
        local y = math_abs(position[2] * distance)

        if x > maxX then maxX = x end
        if y > maxY then maxY = y end
    end

    return maxX, maxY
end


function reverseShape(shape)
    local rev = {}
    local num = #shape
    for i=1,num do
        rev[i] = -shape[i]
    end
    return rev
end
