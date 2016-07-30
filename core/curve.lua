local curve = {
    Gravity        = 40,
    showTrajectory = false,
    showGrid       = true,
    showGridHandle = nil,
}

local XLimit      = 200
local YLimit      = 200
local timeStep    = 1/display.fps  --seconds per time step at 60fps
local gravityStep = timeStep * curve.Gravity
local trajectory  = nil
local jumpGroup   = nil
--local grid        = nil
local gridSideX   = nil
local gridSideY   = nil
local fingerPoint = nil
local lockPoint   = nil
local xAxis       = nil
local yAxis       = nil
local pullLine    = nil
local animHandle  = nil
--local animateTrajectoryPrev  = nil
--local animateTrajectoryPoint = nil

local math_round     = math.round
local math_abs       = math.abs
local math_floor     = math.floor
local new_circle     = display.newCircle
local new_image      = display.newImage
local new_image_rect = display.newImageRect
local new_mask       = graphics.newMask


function curve:debug(player, px, py, ex, ey)
    local pledge = player.attachedLedge
    local nledge = hud.level:getLedge(pledge.id + 1)

    local diffx, diffy = px-ex, py-ey
    local xvel,  yvel  = curve:calcVelocity(diffx, diffy)
    local distx, disty = 0, nledge:topEdge() - pledge:topEdge()

    if pledge:x() < nledge:x() then
        distx = nledge:leftEdge() - pledge:rightEdge()
    else
        distx = nledge:rightEdge() - pledge:leftEdge()
    end

    data =          "Pull: "..math_round(diffx)..", "..math_round(diffy).." Vel: "..math_round(xvel)..", "..math_round(yvel).."\n"
    data = data ..  "Ledge: distX="..math_round(distx).." distY="..math_round(disty).."\n" 

    if curveDebugText ~= nil then curveDebugText:removeSelf() end
    curveDebugText = display.newText(data, 50,100, 800,100, "arial",22)
    --curveDebugText:setReferencePoint(display.CenterLeftReferencePoint)
    curveDebugText.anchorX = 0
    curveDebugText.x = 50
end


function curve:calcPull(camera, player, event)
    local x, y   = math_round(event.x),    math_round(event.y)
    local px, py = math_round(player:x()), math_round(player:y())

    if y < py then y = py end

    local diffx, diffy = x-px, y-py
    local scale  = camera.scaleVelocity
    local xlimit = (XLimit +7)  * scale  -- these offsets are just to make the visuals sit right
    local ylimit = (YLimit +11) * scale

    if diffx > xlimit  then x = px + xlimit end
    if diffx < -xlimit then x = px - xlimit end
    if diffy > ylimit  then y = py + ylimit end

    -- return player x,y, allowed pull x,y and flag is pull should be cancelled
    local cancelPoint = py - (150 * scale)

    return px, py, x, y, (event.y < cancelPoint)
end


function curve:calcVelocity(diffX, diffY, ignoreLimits)
    if ignoreLimits == nil then
        if diffX > XLimit then diffX = XLimit end
        if diffY > YLimit then diffY = YLimit end
    end

    -- x axis base needs to take into account the direction of the jump
    local basex, basey = 100, -400
    if diffX < 0 then basex = -basex end

    local velx = basex + (diffX * 2.5)
    local vely = basey + (diffY * 2.5)
    
    return math_round(velx), math_round(vely)
end


function curve:calcJumpType(velocityX, velocityY)
    local velx, vely = math_abs(velocityX), math_abs(velocityY)

    if velx > 400 and velx > (vely-100) then
        return "LONG"
    elseif vely > 700 and vely > (velx + 150) then
        return "HIGH"
    else
        return "STANDARD"
    end
end


-- Primary function used to show player jump curve
function curve:drawTrajectory(camera, jumpX, jumpY, pullX, pullY)
    self:removeTrajectory()
    trajectory = display.newGroup()

    local velx, vely = curve:calcVelocity(jumpX-pullX, jumpY-pullY)
    local startVelX, startVelY = velx, vely

    for i=1,40 do
        local pointX, pointY = self:getTrajectoryPoint(jumpX, jumpY, startVelX, startVelY, i)

        local circle = new_circle(trajectory, pointX, pointY, 5)
        circle:setFillColor(1,0.2,0.2)
        circle.alpha = 0.2
    end

    camera:add(trajectory, 2)
    --animateTrajectoryPoint = 1
    --animateTrajectoryPrev  = -10

    --[[curve.animHandleHandle = timer.performWithDelay(100, function()
        --curve.animHandle = timer.performWithDelay(15, curve.animateTrajectory, 0)
        curve.animHandle = timer.performWithDelay(1000, curve.animateTrajectory, 0)
    end)]]
end


-- TEST function just used to show two curves at once for scaling testing
--[[function curve:drawTrajectoryScaled(camera, jumpX, jumpY, pullX, pullY, scale)
    if trajectory2 ~= nil then
        trajectory2:removeSelf()
    end

    trajectory2 = display.newGroup()

    local velx, vely = curve:calcVelocity(camera, jumpX-pullX, jumpY-pullY)
    local startingVelocity = { x=velx, y=vely }

    startingVelocity.x = startingVelocity.x * scale
    startingVelocity.y = startingVelocity.y * scale

    for i=1,90 do
        local s = { x = jumpX, y = jumpY }
        local trajectoryPosition = self:getTrajectoryPoint(s, startingVelocity, i)
        local circle = new_circle(trajectory2, trajectoryPosition.x, trajectoryPosition.y, 5)
        circle:setFillColor(1,0.2,0.2)
        circle.alpha = 0.2
    end

    camera:add(trajectory2, 2)
end]]


-- Used to show an items arc such as for ring paths
function curve:drawItemTrajectory(jumpX, jumpY, distX, distY, arc, numberItems, creator)
    local startVelX, startVelY = curve:calcVelocity(distX, distY, false)
    local drawPoints = nil

    if numberItems == 7 then
        drawPoints = {1, math_round(arc*0.15), math_round(arc*0.3), math_round(arc*0.5), math_round(arc*0.7), math_round(arc*0.85), arc}
    elseif numberItems == 5 then
        drawPoints = {1, math_round(arc*0.25), math_round(arc*0.5), math_round(arc*0.75), arc}
    elseif numberItems == 4 then
        drawPoints = {math_round(arc*0.20), math_round(arc*0.40), math_round(arc*0.60), math_round(arc*0.80)}
    elseif numberItems == 3 then
        drawPoints = {1, math_round(arc/2), arc}
    elseif numberItems == 2 then
        drawPoints = {math_round(arc*0.33), math_round(arc*0.66)}
    else  --default to 1
        drawPoints = {math_round(arc/2)}
    end

    for i=1, arc do
        local pointX, pointY = self:getTrajectoryPoint(jumpX, jumpY, startVelX, startVelY, i)

        if table.indexOf(drawPoints, i) ~= nil then
            creator(i, pointX, pointY)
        end
    end
end


function curve:getTrajectoryPoint(startX, startY, velX, velY, n)
    --velocity and gravity are given per second but we want time step values here
    local stepVelX = timeStep*velX
    local stepVelY = timeStep*velY
    local thing    = (n*n+n)

    -- use 0.5 for 30fps, 0.25 for 60fps
    local pointX = (startX + n * stepVelX + 0.25 * thing * 0)
    local pointY = (startY + n * stepVelY + 0.25 * thing * gravityStep)
    return pointX, pointY
end


--[[function curve:animateTrajectory()
    if trajectory ~= nil then
        if animateTrajectoryPrev > 0 then
            trajectory[animateTrajectoryPrev].alpha = 0.2
        end

        local alpha = 1.00
        for i=animateTrajectoryPoint, animateTrajectoryPrev+1, -1 do
            if i > 1 then
                trajectory[i].alpha = alpha
                alpha = alpha - 0.10
                if alpha < 0.00 then alpha = 0.00 end
            end
        end

        animateTrajectoryPrev  = animateTrajectoryPrev + 1
        animateTrajectoryPoint = animateTrajectoryPoint + 1

        if animateTrajectoryPrev > trajectory.numChildren then
            animateTrajectoryPrev = 1
        end

        if animateTrajectoryPoint > trajectory.numChildren then
            animateTrajectoryPoint = 1
        end
    end
end]]


function curve:removeTrajectory()
    if trajectory then
        trajectory:removeSelf()
        trajectory = nil

        --[[if animHandleHandle ~= nil then
            timer.cancel(animHandleHandle)
            animHandleHandle = nil
        end

        if animHandle then
            timer.cancel(animHandle)
            animHandle = nil
        end]]
    end
end


-- Draws all items per frame for the jump curve, plus sets up items not created
function curve:draw(camera, px, py, ex, ey)
    if jumpGroup == nil then
        jumpGroup = display.newGroup()
        camera:add(jumpGroup, 2) 

        if self.showGrid then    
            self:drawGrid(camera, hud.player)
            self:drawAxis(px, py, ex, ey)
        end
    else
        self:removePullLine(camera)
    end

    -- modify the coords for the group coords
    px = px - jumpGroup.x
    ex = ex - jumpGroup.x
    
    if self.showGrid then
        self:drawGridPosition(camera, px, py, ex, ey)
    end

    if fingerPoint == nil then
        self:drawFingerPoint(ex, ey)
    else
        fingerPoint.x, fingerPoint.y = ex, ey
    end

    if self.lock then
        self:drawLockPoint(px, py)
    end
end


function curve:drawFingerPoint(ex, ey)
    fingerPoint = new_image("images/hud/jump-grid-marker.png", ex-37.5, ey-37.5)
    fingerPoint.alpha = 0.5
    jumpGroup:insert(fingerPoint)
end


function curve:drawLockPoint(px, py)
    local x, y = px + self.lock[1], py + self.lock[2]

    if lockPoint == nil then
        lockPoint = new_image("images/hud/jump-grid-locked.png", x, y)
        jumpGroup:insert(lockPoint)
    else
        lockPoint.x, lockPoint.y = x, y
    end
end


function curve:drawGrid(camera, player)
    local scale     = camera.scaleVelocity
    local playerX   = player:x()
    local playerY   = player:y()
    local xSideHalf = 106 * scale
    local ySideHalf = 35  * scale
    local xSideFull = 212 * scale
    --local xoffset = 192 * scale
    --local yoffset = 61  * scale
    --local adjust  = 135 * scale

    --grid = new_image("images/hud/jump-grid.png", playerX+xoffset, playerY+yoffset)
    --grid.alpha = 0

    gridSideX = new_image_rect("images/hud/accelerator-lines-horizontal.png", 212, 70)
    gridSideY = new_image_rect("images/hud/accelerator-lines-vertical.png",   70,  212)

    gridSideX.alpha, gridSideY.alpha = 0.7, 0.7
    gridSideX.x, gridSideX.y = playerX-xSideHalf, playerY-ySideHalf
    gridSideY.x, gridSideY.y = playerX+ySideHalf, playerY+xSideHalf

    gridSideX:setMask(new_mask("images/hud/accelerator-horizontal-mask.png"))
    gridSideY:setMask(new_mask("images/hud/accelerator-vertical-mask.png"))
    --gridSideY.maskY = -xSideFull

    if camera.scaleMode then
        --grid:scale(scale, scale)
        gridSideX:scale(scale, scale)
        gridSideY:scale(scale, scale)
    end

    if player.direction == right then
        --grid.direction = right
        --grid.x = grid.x - (grid.width * scale) + adjust

        --gridSideX.maskX = xSideFull
    else
        --grid.direction = left
        --grid:scale(-1,1)
        --grid.x = grid.x - adjust

        gridSideX:scale(-1,1)
        gridSideY:scale(-1,1)
        self:adjustGridLeft(scale)
    end

    jumpGroup.direction = player.direction
    jumpGroup:insert(gridSideX)
    jumpGroup:insert(gridSideY)

    --self.showGridHandle = transition.to(grid, {alpha=0.7, time=300, onComplete=function() curve.showGridHandle=nil end})
    --self.showGridHandle = transition.to(grid, {alpha=0.4, time=300, onComplete=function() curve.showGridHandle=nil end})
    --gridAnimationHandle = timer.performWithDelay(50, curve.animateGrid, 0)

    --camera:add(grid, 2)
    --camera:add(gridSideY, 2)
    --camera:add(gridSideX, 2)

    -- instead of doing it every time event triggered
    -- grid:toFront()
end


function curve:drawAxis(px, py, ex, ey)
    xAxis = new_image("images/hud/jump-grid-horiz.png", ex, py-45)
    yAxis = new_image("images/hud/jump-grid-vert.png", px-115, ey-10)

    xAxis.posColor = 0
    yAxis.posColor = 0
    xAxis:scale(0.7,0.7)
    yAxis:scale(0.7,0.7)

    if grid and grid.direction == left then 
        yAxis:scale(-1,1)
    end
    
    jumpGroup:insert(xAxis)
    jumpGroup:insert(yAxis)
end


function curve:drawGridPosition(camera, px, py, ex, ey)
    -- Draw line
    pullLine = display.newLine(px, py, ex, ey)
    pullLine:setStrokeColor(0.8,0.8,0.8)
    pullLine.strokeWidth = 2
    jumpGroup:insert(pullLine)

    -- Position axis
    xAxis.x = ex
    yAxis.y = ey

    local scale = camera.scaleVelocity

    -- Position side axis masks
    gridSideY.maskY = ((ey - gridSideY.y) / scale) - 106

    if ex >= px then
        yAxis.x = px - (50 * scale)
        gridSideX.maskX = 106 + ((gridSideX.x - ex) / scale)
    else
        yAxis.x = px + 50
        gridSideX.maskX = -((gridSideX.x - ex) / scale) + 106
    end

    -- fix for calc bodge where maskX ends up nearly 0 (and grid sides flicker in full - when X at flip point)
    if gridSideX.maskX < 1 then gridSideX.maskX = 212 end

    -- Color Axis: Round to 1DP to reduce the number of times we call set fill color
    local boundary = 200 * scale
    local xColor   = math_floor( (math_abs(px-ex) / boundary) * 10 + 0.5) / 10
    local yColor   = math_floor( (math_abs(py-ey) / boundary) * 10 + 0.5) / 10

    if xColor ~= xAxis.posColor then
        xAxis:setFillColor(xColor, 1-xColor, 0)
        xAxis.posColor = xColor
    end

    if yColor ~= yAxis.posColor then
        yAxis:setFillColor(yColor, 1-yColor, 0)
        yAxis.posColor = yColor
    end
end


function curve:removePullLine(camera)
    if pullLine and pullLine.removeSelf then
        pullLine:removeSelf()
        pullLine = nil
    end
end


function curve:moveJumpGridBy(x, y)
    if jumpGroup then
        if x then jumpGroup.x = jumpGroup.x + x end
        if y then jumpGroup.y = jumpGroup.y + y end
    end
end


function curve:flipGrid(player)
    if self.showGrid and jumpGroup then
        local scale = player:getCamera().scaleVelocity

        --grid:scale(-1,1)
        gridSideX:scale(-1,1)
        gridSideY:scale(-1,1)
        yAxis:scale(-1,1)

        if jumpGroup.direction == left then
            jumpGroup.direction = right
            self:adjustGridRight(scale)
        else
            jumpGroup.direction = left
            self:adjustGridLeft(scale)
        end
    end
end


function curve:adjustGridRight(scale)
    --grid.x      = player:x() - (55 * scale)
    gridSideX.x = gridSideX.x - (212 * scale)
    gridSideY.x = gridSideY.x + (70  * scale)
end


function curve:adjustGridLeft(scale)
    --grid.x      = player:x() + (55 * scale)    
    gridSideX.x = gridSideX.x + (212 * scale)
    gridSideY.x = gridSideY.x - (70  * scale)
end


function curve:lockJump(x, y)
    self.lock = {x, y}
end


function curve:playerAtLockPoint(camera, player, event)
    local px, py, ex, ey, cancelJump = curve:calcPull(camera, player, event)
    local loX, loY = self.lock[1], self.lock[2]
    local atX      = ex-px
    local atY      = ey-py
    local accuracy = 25

    if atX > loX-accuracy and atX < loX+accuracy and atY > loY-accuracy and atY < loY+accuracy then
        return true
    end
    return false
end


function curve:freeJump(camera)
    self.lock = nil
    self:clearLockJump(camera)
end


function curve:hideJumpGrid(camera)
    if jumpGroup then
        jumpGroup:removeSelf()
        jumpGroup   = nil
        fingerPoint = nil
        xAxis       = nil
        yAxis       = nil
        gridSideX   = nil
        gridSideY   = nil
        lockPoint   = nil
    end
end


--[[function curve:animateGrid()
    local self = curve

    if grid == nil or grid.alpha == nil then
        return
    end

    if grid.pause then
        if grid.pauseFor then
            grid.pauseFor = grid.pauseFor - 1

            if grid.pauseFor <= 0 then
                grid.pause, grid.pauseFor = false, nil
            end
        else
            grid.pauseFor = 8
        end
    elseif grid.fadingOut then
        if grid.alpha <= 0.5 then
            grid.fadingOut = false
            grid.pause = true
        else
            grid.alpha = grid.alpha - 0.025
        end
    else
        if grid.alpha >= 0.7 then
            grid.fadingOut = true
            grid.pause = true
        else
            grid.alpha = grid.alpha + 0.025
        end
    end
end]]


function curve:clearUp(camera)
    curve:hideJumpGrid(camera)
    curve:removePullLine(camera)
    curve:removeTrajectory(c)
end


return curve