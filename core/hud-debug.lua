local playerStates = {
    [playerReady]         = "ready",
    [playerWalk]          = "walk",
    [playerDrag]          = "drag",
    [playerRun]           = "run",
    [playerJumpStart]     = "jump-start",
    [playerJump]          = "jump",
    [playerFallStart]     = "fall-start",
    [playerFall]          = "fall",
    [playerSwing]         = "swing",
    [playerHang]          = "hang",
    [playerClimb]         = "climb",
    [playerKilled]        = "killed",
    [playerMissedDeath]   = "missed-death",
    [playerCompletedZone] = "completed",
    [playerAnalysingJump] = "analysing",
    [playerThrowing]      = "throwing",
    [playerTeleporting]   = "teleporting",
    [playerOnVehicle]     = "on-vehicle",
    [playerGrappling]     = "grappling",
}


-- Aliases:
local round = math.round


function hud:switchDebugMode()
    local self=hud
    self.debugMode = not self.debugMode
    
    if self.debugMode then
        self.textDebugMode:setText("debug mode")
        self.debugGroup = display.newGroup()
        
        -- loop through all ledges and show jump position plus score
        local ledges = self.level.ledges.items
        local num    = #ledges
        
        for i=1,num do
            local ledge = ledges[i]
            if ledge and ledge ~= -1 and ledge.image then
                local x, y, length = ledge:scorePosition(), ledge:y(), 100

                local ledgeId = display.newText(self.debugGroup, ledge.id.."/"..ledge.zoneRouteIndex.." ["..tostring(ledge.infinitePosition).."]", ledge:x()-30, ledge:topEdge()-120, "Arial", 20)
                ledgeId:setFillColor(1,0,0)

                if ledge.route then
                    local route = display.newText(self.debugGroup, "route "..ledge.route, ledge:x()-50, ledge:topEdge()-90, "Arial", 20)
                    route:setFillColor(0,0,1)
                end
                
                for z = 1,4 do
                    local jumpLine = display.newLine(self.debugGroup, x, y-length, x, y+length)
                    jumpLine:setStrokeColor(0,255,0)
                    jumpLine.strokeWidth = 2
                    x = x - 25
                    length = 50
                end
                
                local x, y, length = ledge:scorePosition(), ledge:y(), 100
                for z = 1,4 do
                    local jumpLine = display.newLine(self.debugGroup, x, y-length, x, y+length)
                    jumpLine:setStrokeColor(0,255,0)
                    jumpLine.strokeWidth = 2
                    x = x + 25
                    length = 50
                end
                
                local points = ledge.points or ""
                local jumpScore = display.newText(self.debugGroup, ledge.score.."/"..points, ledge:x()-30, ledge:y()+110, "Arial", 18)
                jumpScore:setFillColor(0,1,0)
            end
        end

        self.camera:add(self.debugGroup, 2, false)
    else
        self.textDebugMode:setText("game mode")
        self.camera:remove(self.debugGroup)
        
        if self.debugPoint ~= nil then
            self.debugPoint:removeSelf()
            self.debugPointInfo:removeSelf()
            self.debugPoint = nil
            self.debugPointInfo = nil
        end
        
        if self.debugGroup ~= nil then
            self.debugGroup:removeSelf()
            self.debugGroup = nil
        end

        local players = self.level.players.items
        local num     = #players

        for i=1,num do
            local player = players[i]
            player.debugStatusText:removeSelf()
            player.debugStatusText = nil
        end
    end
end


function hud:displayDebugOffsetPoint(event)
    local ledge, x, y, sideX, sideY = self.level:getClosestLedgeAtPoint(event.x, event.y)

    if self.debugPoint ~= nil then
        self.debugPoint:removeSelf()
        self.debugPointInfo:removeSelf()
        self.debugPoint = nil
        self.debugPointInfo = nil
    end

    self.debugPoint     = display.newCircle(self.debugGroup, event.x, event.y, 5)
    self.debugPointInfo = display.newText(self.debugGroup, "...", event.x, event.y-30, "Arial", 20)
    
    self.debugPoint:setFillColor(0,1,0)
    self.debugPointInfo:setFillColor(0,1,0)

    if ledge == nil then
        self.debugPointInfo.text = "Unable to find closest ledge"
    else
        self.debugPointInfo.text = "#"..ledge.id.." distance: "..x..", "..y
    end
end


function hud:switchPhysicsMode()
    hud.physicsMode = not hud.physicsMode

    if hud.physicsMode then
        physics.setDrawMode("hybrid")
        hud.textPhysicsMode:setText("show physics")
    else
        physics.setDrawMode("normal")
        hud.textPhysicsMode:setText("hide physics")
    end
end


function hud:switchScreenshotMode()
    hud.screenshotMode = not hud.screenshotMode

    if hud.screenshotMode then
        hud:pauseGame()
        hud.textPhysicsMode.alpha    = 0
        hud.textDebugMode.alpha      = 0
        hud.textScreenshotMode.alpha = 0

        Runtime:addEventListener("tap", hud.switchScreenshotMode)
    else
        Runtime:removeEventListener("tap", hud.switchScreenshotMode)

        hud:resumeGame()
        hud.textPhysicsMode.alpha    = 1
        hud.textDebugMode.alpha      = 1
        hud.textScreenshotMode.alpha = 1
    end
    return true
end


function hud:scriptMode(on)
    if on then
        if self.selectorSwitch then
            self:hideGear()
        end

        if self.startLevelGroup then self.startLevelGroup.alpha = 0 end
    else
        if self.selectorSwitch then
            self:showGearFull()
        end

        if self.startLevelGroup then self.startLevelGroup.alpha = 1 end
    end
end


function hud:debugPlayerMode(player)
    if self.debugMode then
        local xvel, yvel = player:getForce()

        local text = playerStates[player.mode].."|"..round(player:x())..", "..round(player:y()).."|alive="..tostring(player.inGame).." key="..tostring(player.key)
        text = text.."|vel="..round(xvel)..","..round(yvel)

        if player.debugStatusText == nil then
            player.debugStatusText = newText(player.image, text, 0, -140, 0.3, "white")
        else
            player.debugStatusText:setText(text)
        end
    end
end
