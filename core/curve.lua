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
local line        = nil
local grid        = nil
local fingerPoint = nil
local lockPoint   = nil
local xAxis       = nil
local yAxis       = nil
local pullLine    = nil
local animHandle  = nil
local animateTrajectoryPrev  = nil
local animateTrajectoryPoint = nil

local math_round = math.round
local math_abs   = math.abs
local new_circle = display.newCircle
local new_image  = display.newImage


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


function curve:calcPull(player, event)
    local x, y   = math_round(event.x),  math_round(event.y)
    local px, py = math_round(player:x()), math_round(player:y())

    if y < player:y() then y = py end

    local diffx,  diffy  = x-px, y-py
    local xlimit = XLimit +7  -- these offsets are just to make the visuals sit right
    local ylimit = YLimit +11

    if diffx > xlimit  then x = px + xlimit end
    if diffx < -xlimit then x = px - xlimit end
    if diffy > ylimit  then y = py + ylimit end

    -- return player x,y, allowed pull x,y and flag is pull should be cancelled
    return px, py, x, y, (event.y < (py-150))
end


function curve:calcVelocity(diffX, diffY, ignoreLimits)
    if ignoreLimits == nil then
        if diffX > XLimit then diffX = XLimit end
        if diffY > YLimit then diffY = YLimit end
    end

    -- x axis base needs to take into account the direction of the jump
    local basex, basey = 100, -400
    if diffX < 0 then basex = -100 end

    -- reduce the multiplication factor of the opposing axis the further you increase on the other
    local xscale = 2.5
    local yscale = 2.5
    local velx = basex + (diffX * xscale)
    local vely = basey + (diffY * yscale)
    
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
function curve:drawTrajectory(camera, jumpX, jumpY, pullX, pullY, scale)
    self:removeTrajectory()
    trajectory = display.newGroup()

    local velx, vely = curve:calcVelocity(jumpX-pullX, jumpY-pullY)
    local startVelX, startVelY = velx, vely

    if scale then
        startVelX = startVelX * scale
        startVelY = startVelY * scale
    end

    for i=1,90 do
        local pointX, pointY = self:getTrajectoryPoint(jumpX, jumpY, startVelX, startVelY, i)

        local circle = new_circle(trajectory, pointX, pointY, 5)
        circle:setFillColor(1,0.2,0.2)
        circle.alpha = 0.2
    end

    camera:add(trajectory, 2)
    animateTrajectoryPoint = 1
    animateTrajectoryPrev  = -10

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

    local velx, vely = curve:calcVelocity(jumpX-pullX, jumpY-pullY)
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



function curve:animateTrajectory()
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
end


function curve:removeTrajectory()
    if trajectory ~= nil then
        trajectory:removeSelf()
        trajectory = nil

        if animHandleHandle ~= nil then
            timer.cancel(animHandleHandle)
            animHandleHandle = nil
        end

        if animHandle ~= nil then
            timer.cancel(animHandle)
            animHandle = nil
        end
    end
end


function curve:drawLine(camera, px, py, ex, ey)
    self:removeLine(camera)
    
    if self.showGrid then
        pullLine = display.newLine(px, py, ex, ey)
        pullLine:setStrokeColor(0.5,0.5,0.5)
        pullLine.strokeWidth = 4
        camera:add(pullLine, 2)
    end

    if grid and grid.toFront then 
        grid:toFront() 
    elseif grid ~= nil then
        curve:drawJumpGrid(camera, hud.player)
    end

    if fingerPoint == nil then
        fingerPoint = new_image("images/hud/jump-grid-marker.png", ex-37.5, ey-37.5)
        fingerPoint.alpha = 0.5
        camera:add(fingerPoint, 2)
    else
        fingerPoint.x, fingerPoint.y = ex, ey
        fingerPoint:toFront()
    end

    if self.lock then
        local x, y = px + self.lock[1], py + self.lock[2]

        if lockPoint == nil then
            lockPoint = new_image("images/hud/jump-grid-locked.png", x, y)
            camera:add(lockPoint, 2)
        else
            lockPoint.x, lockPoint.y = x, y
            lockPoint:toFront()
        end
    end

    -- Only display X and Y axis bars if drawing grid
    if self.showGrid then
        if xAxis == nil then
            xAxis = new_image("images/hud/jump-grid-horiz.png", ex, py-45)
            xAxis:scale(0.7,0.7)
            camera:add(xAxis, 2)
        end

        if yAxis == nil then
            yAxis = new_image("images/hud/jump-grid-vert.png", px-115, ey-10)
            yAxis:scale(0.7,0.7)
            if grid and grid.direction == left then yAxis:scale(-1,1) end
            camera:add(yAxis, 2)
        end

        xAxis.x = ex
        yAxis.y = ey

        if ex >= px then
            yAxis.x = px - 50
        else
            yAxis.x = px + 50
        end

        local xColor = math_abs(px-ex) / 200
        local yColor = math_abs(py-ey) / 200
        xAxis:setFillColor(xColor, 1-xColor, 0)
        yAxis:setFillColor(yColor, 1-yColor, 0)
    end
end


function curve:removeLine(camera)
    if pullLine ~= nil then
        camera:remove(pullLine)
        pullLine:removeSelf()
        pullLine = nil
    end
end


function curve:drawJumpGrid(camera, player)
    if state.demoActions then return end

    local scale   = 1 -- camera.scaleImage
    local xoffset = 192 * scale
    local yoffset = 61  * scale
    local adjust  = 135 * scale

    grid = new_image("images/hud/jump-grid.png", player:x()+xoffset, player:y()+yoffset)
    grid.alpha = 0

    --[[if camera.scaleMode then
        grid:scale(camera.scaleImage, camera.scaleImage)
    end]]

    if player.direction == right then
        grid.direction = right
        grid.x = grid.x - (grid.width * scale) + adjust
    else
        grid.direction = left
        grid:scale(-1,1)
        grid.x = grid.x - adjust
    end

    self.showGridHandle = transition.to(grid, {alpha=0.7, time=300, onComplete=function() curve.showGridHandle=nil end})

    gridAnimationHandle = timer.performWithDelay(50, curve.animateGrid, 0)
    camera:add(grid, 2)
end


function curve:moveJumpGridBy(x, y)
    if grid == nil then return end

	if x then
		grid.x = (grid.x or 0) + x
		if pullLine then
			pullLine.x    = pullLine.x + x
			xAxis.x       = xAxis.x + x
			yAxis.x       = yAxis.x + x
            fingerPoint.x = fingerPoint.x + x
		end
	end

	if y then
		grid.y = (grid.y or 0) + y
		if pullLine then
			pullLine.y    = pullLine.y + y
			xAxis.y       = xAxis.y + y
			yAxis.y       = yAxis.y + y
            fingerPoint.y = fingerPoint.y + y
		end
	end
end


function curve:flipGrid(player)
    if self.showGrid and grid then
        grid:scale(-1,1)
        yAxis:scale(-1,1)

        if grid.direction == left then
            grid.direction = right
            grid.x = player:x() - 55
        else
            grid.direction = left
            grid.x = player:x() + 55
        end
    end
end


function curve:lockJump(x, y)
    self.lock = {x, y}
end


function curve:playerAtLockPoint(player, event)
    local px, py, ex, ey, cancelJump = curve:calcPull(player, event)
    local loX, loY = self.lock[1], self.lock[2]
    local atX      = ex-px
    local atY      = ey-py
    local accuracy = 25

    print(atX..","..atY.." => "..loX..","..loY)

    if atX > loX-accuracy and atX < loX+accuracy and atY > loY-accuracy and atY < loY+accuracy then
        print("yay")
        return true
    end
    return false
end


function curve:freeJump(camera)
    self.lock = nil
    self:clearLockJump(camera)
end


function curve:clearLockJump(camera)
    if lockPoint then
        camera:remove(lockPoint)
        lockPoint:removeSelf()
        lockPoint = nil
    end
end


function curve:hideJumpGrid(camera)
    if fingerPoint ~= nil then
        camera:remove(fingerPoint)
        if fingerPoint.removeSelf then fingerPoint:removeSelf() end
        fingerPoint = nil
    end

    self:clearLockJump(camera)

    if xAxis ~= nil then
        camera:remove(xAxis)
        if xAxis.removeSelf then xAxis:removeSelf() end
        xAxis = nil
    end
    
    if yAxis ~= nil then
        camera:remove(yAxis)
        if yAxis.removeSelf then yAxis:removeSelf() end
        yAxis = nil
    end

    if self.showGridHandle then
        transition.cancel(self.showGridHandle)
        self.showGridHandle = nil
    end

    if gridAnimationHandle ~= nil then
        timer.cancel(gridAnimationHandle)
        gridAnimationHandle = nil
    end

    transition.to(grid, {alpha=0, time=100, onComplete=function()
        if grid ~= nil then
            camera:remove(grid)
            if grid.removeSelf then grid:removeSelf() end
            grid = nil
        end
    end})
end


function curve:animateGrid()
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
end


function curve:clearUp(camera)
    curve:hideJumpGrid(camera)
    curve:removeLine(camera)
    curve:removeTrajectory(c)
end


return curve