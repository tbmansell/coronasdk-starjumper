local anim         = require("core.animations")
local particles    = require("core.particles")
local spineStore   = require("level-objects.collections.spine-store")


-- @class main player class
local player = {
	-- Methods:
	-----------
	-- changeDirection()
	-- stand()
	-- taunt()
	-- readyJump()
	-- cancelJump()
	-- runup()
	-- jump()
	-- createJumpActionTriggers()
    -- createJumpTrail()
	-- land()
	-- landUpdateState()
	-- landEffects()
	-- landCorrection()
	-- grabObstacle()
	-- missLedge()
	-- miss()
	-- addKey()
	-- hasKey()
	-- moveOnLedge()
	-- swingOffAction()
	-- letGoAction()
    -- ironSkinCollision()
	-- targetOtherPlayer()
	-- attackOtherPlayer()
	-- shove()
	-- yank()
	-- trip()
	-- prepareThrow()
	-- cancelThrow()
	-- throwNegable()
}


-- Aliases:
local math_random = math.random


function player:changeDirection(direction)
    if self.direction ~= direction then
        if self.direction == right then
            self.skeleton.flipX = true
            self.direction = left

            if self.negableShot then
                local distance     = player.width * self.camera.scaleImage
                self.negableShot.x = self.negableShot.x + distance*5
            end
        else
            self.skeleton.flipX = false
            self.direction = right

            if self.negableShot then
                local distance     = player.width * self.camera.scaleImage
                self.negableShot.x = self.negableShot.x - distance*5
            end
        end
    end
end


function player:stand()
    self.mode = playerReady
    self:stopMomentum()
    self:loop("Stationary")

    -- check if we have targeted 
    if self.attackTarget then
        self:attackOtherPlayer(self.attackTarget)
    end
end


function player:taunt(sequence, delay)
    self.mode = playerReady
    self.taunting = true
    self:stopMomentum()
    local anim = sequence or math_random(3)

    -- This to get around a problem where AI wont taunt on level start if not looping
    if delay then
        after(delay, function() self:animate("Taunt "..anim) end)
    else
        self:animate("Taunt "..anim)
    end

    after(2000, function()
        self.taunting = false
        if player.mode == playerReady then self:loop("Stationary") end
    end)
end


function player:readyJump()
    local gameMode = state.data.game

    self.mode = playerDrag
    self:crouch()
    self:dragGearUsage()

    if self.main then
        if gameMode == levelPlaying or gameMode == levelTutorial then
            hud:showScoreMarkers(self.attachedLedge.id, self:x())
            hud:showGearSummary()
        end

        hud:levelStartedSequence()

        if curve.showGrid then
            curve:drawJumpGrid(self:getCamera(), self)
        end
    end
end


function player:crouch()
    self:pose()
    self:animate("Jump PREPERATION")
end


function player:cancelJump()
    self.mode = playerReady
    self:animate("Jump CANCEL")
    
    if self.main then
        hud:hideScoreMarkers()
        hud:showGearFull()
    end

    after(1500, function()
        if player.mode == playerReady then
            player:stand()
        end
    end)
end


function player:runup(xVelocity, yVelocity)
    if self.main then 
        hud:hideScoreMarkers()
    end
    
    if self:onStartLedge() and xVelocity < 1 then
        -- cant run backwards on start ledge
        return self:cancelJump()
    elseif yVelocity > -50 or (xVelocity >= 0 and xVelocity < 50) or (xVelocity < 0 and xVelocity > -50) then
        -- safety check as jump simply fails under a certain velocity
        return self:cancelJump()
    end

    -- scale velocity by players scaled amount: dont do for AI yet
    if self.main then
        local scale = self:getCamera().scaleVelocity
        xVelocity = xVelocity * scale
        yVelocity = yVelocity * scale
    end

    --self:sound("playerRun")
    self.mode      = playerRun
    self.xVelocity = xVelocity
    self.yVelocity = yVelocity

    if self.gear[air] == negRocket then
        self.yVelocity = self.yVelocity * 1.5
    elseif self.gear[air] == negBooster then
        self.xVelocity = self.xVelocity * 1.5
    end

    self.runSpeed = self.constRunSpeed * self.scaled
    if xVelocity < 0 then 
        self.runSpeed = -self.runSpeed 
    end

    if self:runupGearUsage(xVelocity, yVelocity) then
        self:loop("Run New")
        self:bindEmitter("run-trail", {xpos=1, ypos=-10, alpha=0.75})
    end
end


function player:jump()
    if self.gear[air] == negRocket or self.gear[air] == negBooster then
        self:sound("gearJetpack")
    else
        self:sound("randomJump")
    end

    local ledge = self.attachedLedge

    self.attachedLedge:release(self)

    if ledge and ledge.destroyAfter then
        after(ledge.destroyAfter, function() 
            ledge:selfDestruct()
            player.attachedLedge = nil
            player.jumpedFrom    = nil
        end)
    end

    self.jumpedFrom     = ledge
    self.attachedLedge  = nil
    self.image.rotation = 0

    if self.main then
        curve.showTrajectory = false
    end

    -- initiallty set to temporary mode "jumpStart" to avoid change of getting snagged on ledge jumping from
    -- ledge only looks for jump for collision detection so wont get trapped (e.g. negatively rotated ledges)
    self.mode = playerJumpStart

    if self.jumpTypeHigh then
        self.jumpType = "HIGH"
    else
        self.jumpType = curve:calcJumpType(self.xVelocity, self.yVelocity)
    end

    if     self.negableRocketOn  then self:animate("Powerup ROCKET")
    elseif self.negableBoosterOn then self:animate("Powerup BOOSTER")
    else   self:animate("Jump "..self.jumpType) end

    self:stopMomentum()
    self:applyForce(self.xVelocity + self.jumpXBoost, self.yVelocity)

    -- Switch to stone jump mode straight after launching off
    after(50, function()
        if self.mode ~= playerKilled then
            self.mode = playerJump
        end
    end)

    self:createJumpActionTriggers()
    self:createJumpTrail()
end


-- if a gear trigger was set, fire it after the specified time
function player:createJumpActionTriggers()
    local actions = self.triggerJumpAction
    if actions then
        for i=1, #actions do
            after(actions[i], function()
                -- ensure player still in jump state
                if self.mode == playerJump then
                    self:jumpAction()
                end
            end)
        end
        self.triggerJumpAction = nil
    end
end


function player:createJumpTrail()
    local xpos, ypos = 1, 1

    if self.direction == right then
        if     self.jumpType == "HIGH"     then xpos, ypos = 20,  -30
        elseif self.jumpType == "STANDARD" then xpos, ypos = -33, -18
        elseif self.jumpType == "LONG"     then xpos, ypos = 10,  -40 end
    else
        if     self.jumpType == "HIGH"     then xpos, ypos = -20, -30
        elseif self.jumpType == "STANDARD" then xpos, ypos = 33,  -18
        elseif self.jumpType == "LONG"     then xpos, ypos = -10, -40 end
    end

    self:bindEmitter("jump-trail", {xpos=xpos, ypos=ypos, alpha=0.75})
end


-- Used only for landing on ledges
function player:land(ledge)
    if self.mode == playerKilled then return end

    -- Stuff that must happen even when landing on a spring ledge (which bounces straight off again)
    local xv, yv = self.image:getLinearVelocity()
    self:clearJumpAction()

    -- record if player has progressed through level
    if ledge.id > self.highestLedgeId then
        self.highestLedgeId = ledge.id
    end

    -- If landing on a spring, then bounce off (EXIT EARLY)
    if ledge.surface == spring then
        self:animate("Jump "..self.jumpType)

        if self.infiniteCallback then
            self.infiniteCallback(ledge)
        end
        
        return self.image:setLinearVelocity(self.xVelocity, self.yVelocity)
    end

    self:landUpdateState(ledge)
    self:landEffects(ledge)
    self:landCorrection(ledge)
    self:landGearUsage(ledge)

    if self.main then
        hud:showGearFull()
    end

    if self.infiniteCallback then
        self.infiniteCallback(ledge)
    end
end


function player:landUpdateState(ledge)
    local prevMode     = self.mode
    self.mode          = playerReady
    self.attachedLedge = ledge

    -- Only set this ledge as the next start ledge (i.e. reset to here if die) if not a deadly ledge
    if ledge:canStartOn() then
        self.startLedge = ledge
    end

    if self.attachedObstacle ~= nil then
        self.attachedObstacle:release(self)
        self.attachedObstacle = nil
    end
    
    -- Set specific animation if right near an edge
    if prevMode == playerClimb then
        -- dunno
    elseif prevMode == playerFall then
        self:soundLand()
        self:animate("Landing HIGH")

    elseif self:x() < self:ledgeLeftLimit(20) then
        self:soundLand(true)
        self:animate("Landing NEAR EDGE")

    elseif self:x() > self:ledgeRightLimit(50) then
        self:soundLand(true)
        self:animate("Landing FAR EDGE")
    else
        self:soundLand()
        self:animate("Landing "..self.jumpType)
        
        -- Score jump if not landing on the same one
        if self.main and (self.jumpedFrom == nil or self.jumpedFrom.id ~= ledge.id) then
            ledge:scoreJump(self)
        end
    end

    if self.main then
        hud:showGearFull()
    elseif self.ai then
        self:aiLanded()
    end
end


function player:landEffects(ledge)
    self:destroyEmitter()
    self:emit("landing-"..ledge:getDustColor().."good", {ypos=ledge:topEdge(), alpha=0.75, duration=1000})
end


function player:landCorrection(ledge)
    -- if really near an edge start correcting the position, so charater doesnt float
    if self:x() < self:ledgeLeftLimit(1) then
        self.correctBy = 28
    elseif self:x() > self:ledgeRightLimit(30) then
        self.correctBy = -28
    end

    if ledge.type == "finish" then
        self.startLedge = ledge
        self:completedCallback()
    end

    after(100, function()
        if ledge.rotation ~= nil then
            self.image.rotation = ledge.rotation
        elseif self.image.rotation ~= nil then
            self.image.rotation = nil
        end
    end)

    after(1500, function()
        if self.mode == playerReady then
            self:stand()
        end
    end)

    if self:onStartLedge() then
        after(500, function()
            -- walk to level start point if jumped too far back on start ledge
            self:changeDirection(right)
            
            local start, x = self:startPosition(), self:x()
            if x < start then 
                self:moveOnLedge(start - x)
            end
        end)
    end
end


function player:grabObstacle(obstacle)
    if self.mode ~= playerKilled then
        self.attachedObstacle = obstacle

        self:destroyEmitter()

        if self.ai then
            self:aiGrabbed()
        end

        if obstacle.isDeathSlide or obstacle.isRopeSwing or obstacle.isSpaceRocketCapsule then
            self:setPhysicsFilter("addObstacle")
        end
    end
end


function player:missLedge(ledge, edge)
    self:destroyEmitter()
    self:emit("landing-whitegood", {ypos=ledge:topEdge(), alpha=0.75, duration=500})

    -- Check if player is wearing gloves
    if ledge.surface ~= spring and self.gear[land] == gearGloves then
        self:climbLedgeStarted(ledge, edge)
    else
        if ledge.surface == spring then
            local xvel, yvel = self.image:getLinearVelocity()
            local scale      = self.camera.scaleVelocity
            self:applyForce(-500*scale, yvel)
        end

        self:miss(edge)
    end
end


function player:miss(edge, delay)
    if self.mode ~= playerKilled then
        self:intangible()
        self.image.gravityScale = 1
        self.mode = playerMissedDeath

        if edge == left then
            self:animate("Death JUMP NEAR EDGE")
        else
            self:animate("Landing FAR EDGE")
        end

        after(250, function()
            if self.mode == playerMissedDeath then
                self:animate("Death JUMP HIGH")
            end
        end)

        -- make solid again so we can fall on any ledges below
        after(delay or 500, function() self:solid() end)
    end 
end


---------- PLAYER SECONDARY COMPLEX ACTIONS -----------

function player:moveOnLedge(moveBy)
    if self.mode == playerReady and moveBy and moveBy ~= 0 then
        -- cancel if on left limit of start ledge
        if self:onStartLedge() and moveBy < 0 and self:x() < self:startPosition() then
            return
        end
        
        local speed    = self.constWalkSpeed * self.scaled
        local animName = "Walk"
        self.mode      = playerWalk
        self.walkUntil = moveBy

        if moveBy < 0 then
            self.walkSpeed, self.walked = -speed, -speed
            if self.direction == right then animName = "Walk BACKWARD" end
        else
            self.walkSpeed, self.walked = speed, speed
            if self.direction == left then animName = "Walk BACKWARD" end
        end

        self:loop(animName)
    end
end


function player:swingOffAction()
    if self.mode ~= playerKilled then
        self:soundLand(true)
        self:sound("ledgeRopeswingActivated")

        local swing = self.attachedObstacle
        swing:release(self)

        self.mode             = playerJumpStart
        self.jumpedFrom       = swing
        self.attachedObstacle = nil

        self:setGravity(1)
        self:applyForce(swing:getVelocity())
        self:setPhysicsFilter("removeObstacle")
        
        local x,y = self.image:getLinearVelocity()

        self:animate("Death JUMP HIGH")

        after(250, function() self.mode=playerJump end)
        self:createJumpActionTriggers()
    end
end


function player:letGoAction(dontAnimate)
    local obstacle = self.attachedObstacle

    if obstacle and self.mode ~= playerKilled then
        self:soundLand(true)

        if obstacle.isPole then
            self:sound("poleSlide")
        end

        obstacle:release(self)

        self.mode             = playerFallStart
        self.jumpedFrom       = obstacle
        self.attachedObstacle = nil

        self:setGravity(1)
        self:setPhysicsFilter("removeObstacle")

        if not dontAnimate then
            after(150, function()
                if self.mode ~= playerKilled then
                    self.mode = playerFall
                    self:animate("Death JUMP HIGH")
                end
            end)
        end

        self:createJumpActionTriggers()
    end
end


function player:escapeVehicleAction()
    if self.vehicleImage and self.mode ~= playerKilled then
        self.vehicleImage:removeSelf()
        self.vehicleImage = nil

        self.mode = playerJump
        self:rotate(0)
        self:applyForce(0,0)
        self:setPhysicsFilter("removeObstacle")
        self:parachuteStarted()
    end
end


function player:ironSkinCollision()
    self:destroyEmitter()
    self.ironSkin = self.ironSkin - 1

    local xvel, yvel = self:getForce()
    self:applyForce(-xvel, -yvel)

    self:soundLand(true)
    self:animate("Landing FAR EDGE")
end

--------- PLAYER V PLAYER ACTIONS -----------


function player:targetOtherPlayer(victim)
    local attacker = self
    local mode     = attacker.mode
    local attackerLedge = attacker.attachedLedge
    local victimLedge   = victim.attachedLedge

    -- attacker must be on a ledge and it must be the same as the victims
    if (mode == playerReady or mode == playerWalk or mode == playerRun or mode == playerDrag) and
       attackerLedge and victimLedge and attackerLedge.id == victimLedge.id 
    then
        local distance = victim:x() - self:x()

        -- face other player
        if (self:x() > victim:x() and self.direction == right) or
           (self:x() < victim:x() and self.direction == left) 
        then
            self:changeDirection()
        end

        --if distance <= self.width then
        if math.abs(distance) <= 50 then
            self:attackOtherPlayer(victim)
            -- fix possibility player has also entered drag mode if also triggering their own touchArea
            after(50, function() self.mode=playerReady end)
        else
            attacker.attackTarget = victim
            self:moveOnLedge(distance)
        end
    end
end


function player:attackOtherPlayer(victim)
    local distance = victim:x() - self:x()

    if math.abs(distance) <= 50 then
        if (self:x() > victim:x() and self.direction == right) or
           (self:x() < victim:x() and self.direction == left) 
        then
            self:changeDirection()
        end

        local attack = math_random(3)
        if attack == 1 then
            self:shove(victim)
        elseif attack == 2 then
            self:yank(victim)
        elseif attack == 3 then
            self:trip(victim)
        end
    end
    self.attackTarget = nil
end


function player:shove(victim)
    self:animate("Attack PUSH")

    after(250, function()
        if table.indexOf(playerAttackableModes, victim.mode) then
            local self  = player
            victim.mode = playerJumpStart
            victim:animate("Death JUMP HIGH")

            local pushVelocity = 150
            if self.direction == left then pushVelocity = -150 end
            victim.image:setLinearVelocity(pushVelocity,-400)

            after(50, function() 
                if victim.mode ~= playerKilled then
                    victim.mode = playerJump
                end
            end)
        end
    end)
end


function player:yank(victim)
    self:animate("Attack GRAB")

    after(500, function()
        if table.indexOf(playerAttackableModes, victim.mode) then
            local self = player
            victim.mode = playerJumpStart
            victim:animate("Death JUMP HIGH")

            local pushVelocity = -200
            if self.direction == left then pushVelocity = 200 end
            victim.image:setLinearVelocity(pushVelocity,-400)

            after(50, function() 
                if victim.mode ~= playerKilled then
                    victim.mode = playerJump
                end
            end)
        end
    end)
end


function player:trip(victim)
    self:animate("Attack TRIP")

    after(250, function()
        if table.indexOf(playerAttackableModes, victim.mode) then
            victim.mode = playerFall
            victim:animate("Death LAVA LEDGE BACKWARD")

            after(500, function() player:animate("Taunt 1") end)

            after(2000, function() 
                if victim.mode ~= playerKilled then
                    victim.mode = playerReady
                    victim:stand()
                end
            end)
        end
    end)
end


function player:prepareThrow(icon, negable, category)
    print("throwing "..category.." "..negable)
    self.mode = playerThrowing
    self:animate("Negable THROW PREP")
    self.gear[category] = negable
    self.negableShot    = icon
    self.negableShot.category = category

    print("self.gear[category]="..self.gear[category])
end


function player:cancelThrow()
    print("cancel throw")
    if self.negableShot then
        self.camera:remove(self.negableShot)
        self.negableShot:removeSelf()
        self.negableShot = nil
    end
end


function player:throwNegable(velocityX, velocityY)
    if self.negableShot == nil then
        print("something went wrong with the throw, aborting")
        return self:stand()
    end

    -- modify velocity based on jumping for throwing
    local category = self.negableShot.category
    local item     = self.gear[category]
    local scale    = self.camera.scaleVelocity
    velocityX      = (velocityX * 1.3) * scale
    velocityY      = (velocityY * 1.2) * scale

    print("throwing this sucka: "..velocityX..", "..velocityY.." -> "..category)
    print("throwing "..item)

    self:animate("Negable THROW")

    local x, y    = self.negableShot.x, self.negableShot.y
    local negable = self.level:generateGear(x, y, {item})
    negable.isGear         = false
    negable.isNegable      = true
    negable.image.isSensor = true
    negable.ignoreObject   = self:key()
    negable:applyForce(velocityX, velocityY)

    self.camera:remove(self.negableShot)
    self.negableShot:removeSelf()
    self.negableShot    = nil
    self.gear[category] = nil

    if self.main then
        hud:useUpGear(item)
    end

    after(100, function()
        negable.image.isSensor = false 
        negable.ignoreObject   = nil
        self.mode = playerReady
    end)
    after(2000, function()
        if self.mode == playerReady then
            player:stand()
        end
    end)
end


return player