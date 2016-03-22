local spineStore  = require("level-objects.collections.spine-store")
local soundEngine = require("core.sound-engine")


-- @class Base ledge class
local ledge = {
	
	isLedge 		  = true,
    class             = "ledge",
	score         	  = 0,
    trueScore     	  = 0,
    constrainLeft 	  = true,
    immuneWarpFields  = true,

    -- Methods:
    -----------
    -- eventCollide()
    -- getSurfacePhysics()
    -- clone()
    -- *bind()
    -- *release()
    -- canStartOn()
    -- setRotating()
    -- rotate()
    -- setInvisible()
    -- cancelFade()
    -- land()
    -- activateTriggers()
    -- trigger()
    -- scoreJump()
    -- colorLedge()
    -- getDustColor()
    -- shake()
    -- movementCompleted()
    -- scorePosition()
    -- showScoreMarker()
    -- selfDestruct()
    -- getPhysics()
    -- getCustomSize()
    -- toggleDeadlyState()
    -- activateSpringLedge()
    -- activateLavaLedge()
    -- activateExplodingLedge()
    -- activateCollapsingLedge()
    -- activatePulleyLedge()
    -- killWithElectricity()
    -- killWithSpikes()
    -- killWithLava()
}


-- Physics stats per ledge surface: nothing else needs this info so its a local var
local surfacePhysics = {
	-- defaults
    [stone]      = {density=1, friction=4,   bounce=0},
    [girder]     = {density=1, friction=2,   bounce=0},
    -- spine surfaces
    [exploding]  = {density=1, friction=4,   bounce=0},
    [collapsing] = {density=1, friction=4,   bounce=0},
    [electric]   = {density=1, friction=4,   bounce=0},
    [lava]       = {density=1, friction=4,   bounce=0},
    [spiked]     = {density=1, friction=4,   bounce=0},
    [spring]     = {density=1, friction=4,   bounce=0},
    [pulley]     = {desnity=1, friction=4,   bounce=0},
    [ramp]       = {density=1, friction=2,   bounce=0},
    [oneshot]    = {density=1, friction=4,   bounce=0},
    -- not currently used
    [grass]      = {density=1, friction=10,  bounce=0.4},
    [ice]        = {density=1, friction=0.3, bounce=0},
}


-- Aliases
local table_indexof = table.indexOf
local math_floor    = math.floor
local math_round    = math.round


-- Event handler for the physics collision
-- @param self - ledge image
-- @param event
----
function ledge.eventCollide(self, event)
    local ledge  = self.object
    local object = event.other.object

    if object == nil then return end

    if event.phase == "began" and
        not ledge.destroyed and
        object.isPlayer and
        object.attachedObstacle == nil and
        --(object.attachedLedge == nil or object.attachedLedge.key ~= ledge.key) and
        object.mode and
        table_indexof(playerNonLandModes, object.mode) == nil
    then
        object.lastObstacleId = 0
       
        local playerX, playerY = object:pos()
        local left  = ledge:leftEdge()
        local right = ledge:rightEdge()
        local top   = ledge:topEdge(0, playerX)
        local width = object:width()/2

        left, right, top = left-width, right+width, top+10

        if playerX < left or playerX > right or playerY > top then
            local direction = right
            
            if playerX < left then --[[print("TOO FAR LEFT");]] direction = left end

            --[[if playerX > right then print("TOO FAR RIGHT") end
            if playerY > top   then print("TOO FAR DOWN") end

            print("Missed ledge playerX/Y="..math_round(playerX)..","..math_round(playerY).." left/right/top="..math_round(left)..","..math_round(right)..","..math_round(top).." object.width="..object:width())]]
            object:missLedge(ledge, direction)
        else
            --print("Landed on ledge playerX/Y="..math_round(playerX)..","..math_round(playerY).." left/right/top="..math_round(left)..","..math_round(right)..","..math_round(top).." object.width="..object:width())
            if object.mode ~= playerKilled then
                object:land(ledge)
                ledge:land(object)
            end
        end

    -- Handle the situation where a player is pushed off a ledge (rather than jump) so they are also detached and fall from it
    elseif event.phase == "ended" and
        not ledge.destroyed and
        object.isPlayer and
        object.attachedLedge and
        object.attachedLedge.image and
        --object.attachedLedge.rotation == nil and  -- this causes problems on a rotated ledge as player keeps leaving it as they move
        object.attachedLedge.image.rotation == nil and  -- this causes problems on a rotated ledge as player keeps leaving it as they move
        object.attachedLedge.key == ledge.key and
        object.mode ~= playerJumpStart and object.mode ~= playerJump
    then
        object.attachedLedge:release(object)
        object:miss(nil, 250)
    end
end


-- Gets the physics shape for the ledges surface
-- @return table of physics data
----
function ledge:getSurfacePhysics()
    return surfacePhysics[self.surface]
end


-- Makes a spec copy of the key values in this ledge in order to create a ne wone
-- @return table of key stats matching this ledge
----
function ledge:clone()
    local clonedValues = {
        "object", "isLedge", "key", "id", "zoneRouteIndex", "type", "size", "rotation"
    }

    local clone = { 
        x = self:x(),
        y = self:y()
    }

    for key,value in pairs(clonedValues) do
        clone[value] = self[value]
    end

    return clone
end


-- Overrides gameObject:bind() to assign to object.attachedLedge and also rotate if the ledge is rotated
-- @param object to bind
----
function ledge:bind(object)
    self.boundItems[object.key] = object
    object.attachedLedge = self

    if self.image.rotation then
        object:rotate(self.image.rotation)
    end
end


-- Overrides gameObject:release() to free object.assignLedge
-- @param object to free
----
function ledge:release(object)
    self.boundItems[object.key] = nil
    object.attachedLedge = nil

    if self.image.rotation then
        object:rotate(0)
    end
end


-- Determines if a player can restart on a ledge when they die
-- @return true if player can restart on a ledge
----
function ledge:canStartOn()
    return self.surface == ramp or not spineSurfaces[self.surface]
end


function ledge:setRotating(rotating)
	after(rotating.delay or 0, function()
	    self.rotating = rotating
	    self.rotatingFromStart = true

	    local speed = 25
	    if self.rotating.speed then
	        speed = self.rotating.speed
	    end

    	self.timerRotatingHandle = timer.performWithDelay(speed, function() self:rotate() end, 0)
    end)
end


function ledge:rotate()
    if self.rotatingFromStart then
        if self.image.rotation < self.rotating.limit then
            self.image.rotation = self.image.rotation + 1
        else
            self.rotatingFromStart = false
        end
    else
        if self.image.rotation > -self.rotating.limit then
            self.image.rotation = self.image.rotation - 1
        else
            self.rotatingFromStart = true
        end
    end
    -- Rotate attached items
    for _,object in pairs(self.boundItems) do
        local r = self.image.rotation
        object:rotate(r)
        -- slide player on ledge so looks a bit better
        if object.isPlayer then 
        	object:moveBy(r/10, 0) 
        end
    end
end


function ledge:setInvisible()
    self.image.alpha  = 0
    self.invisible.invisibleFor = self.invisible.invisibleFor or 5000
    self.invisible.fadeFor      = self.invisible.fadeFor      or 1000
    self.invisible.visibleFor   = self.invisible.visibleFor   or 500
    self.invisible.alpha        = self.invisible.alpha        or 0.1

    local inv      = self.invisible
    local minTimer = (inv.fadeFor * 2) + inv.visibleFor

    if inv.invisibleFor < minTimer then
        inv.invisibleFor = minTimer
    end

    self.timerAnimationHandle   = timer.performWithDelay(inv.invisibleFor, function()
        self.tranFadeHandle     = transition.to(self.image, {time=inv.fadeFor, alpha=inv.alpha, onComplete=function()
            self.tranFadeHandle = transition.to(self.image, {time=inv.fadeFor, alpha=0, delay=inv.visibleFor})
        end})
    end, 0)
end


function ledge:cancelFade()
    if self.tranFadeHandle ~= nil then
        transition.cancel(self.tranFadeHandle)
        self.tranFadeHandle = nil
    end
end


-- Called when a player lands on a ledge
-- @param player which landed
----
function ledge:land(player)
    self:bind(player)
    -- trigger any special features of this ledge
    self:trigger(player)
    -- check if this ledge triggers special features on other ledges or obstacles
    self:activateTriggers(player)
    self:shake(player.camera)
end


-- Runs through any triggers this ledge causes on other ledges or obstacles and fires them off
-- @param ignoreKeylock - true to bypass keylock to trigger
-- TODO: get all players on the activated ledges and make sure they are affected
----
function ledge:activateTriggers(player, ignoreKeylock)
    -- By default dont allow triggers if the ledge is keylocked
    if not self.keylock or ignoreKeylock then
        self:activateTriggerOn(self.triggerLedgeIds,    "ledge")
        self:activateTriggerOn(self.triggerObstacleIds, "obstacle")

        -- Only trigger custom events if the ledge is not locked (they will be linked) - important that trigger() is called first give the ledge a chance to unlock
        if self.triggerEvent and not self.locked then
            hud.level:triggerCustomEvent(self.triggerEvent, player, self)
        end
    end
end


-- Activates triggers on the list of objects passed
-- @param objects
----
function ledge:activateTriggerOn(ids, type)
    if ids then
        for _,id in pairs(ids) do
            local delay = 0
            if self.keylock then delay=1000 end

            after(delay, function() 
                local target = nil

                if     type == "ledge"    then target = hud.level:getLedge(id)
                elseif type == "obstacle" then target = hud.level:getObstacle(id) end

                if target and target ~= -1 then
                    target:trigger() 
                end
            end)
        end
    end
end


-- Activates any special features of a ledge
-- @param player - on the ledge
----
function ledge:trigger(player)
    if not self.triggered then
        self.triggered = true

        local surface = self.surface

        if 	   surface == collapsing then self:activateCollapsingLedge(player, "Activated Fast")  -- Trigger is too fast (1.2s), whereas this is 3.5s
	    elseif surface == exploding  then self:activateExplodingLedge(player, "Trigger")
	    elseif surface == lava       then self:activateLavaLedge(player, "Trigger")
	    elseif surface == pulley 	 then self:activatePulleyLedge(player)
	    elseif surface == spring     then self:activateSpringLedge() end

	    if self.invisible then
	        timer.pause(self.timerAnimationHandle)
	        self:cancelFade()
	        transition.to(self.image, {alpha=1, time=500})
	    end
    end

    if self.keylock and self.isLocked then
        if player:hasKey(self.keylockColor) then
            player:useKey()
            self.keylock:animate("Activated")
            self.isLocked = false
            self:activateTriggers(player, true)
        end
    end
end


function ledge:scorePosition()
    local x = self:x()
    
    if self.pointsPos == left then
        return x - self:width()/3
    elseif self.pointsPos == right then
        return x +self:width()/3
    else
        return x
    end
end


function ledge:scoreJump(player)
    -- each time a player jumps on a lege we save their highest score only
    if not self.isSpine and self.points and self.trueScore < self.points then
        local newScore      = self.trueScore 
        local possibleScore = self.points
        local pos           = self:scorePosition()
        local x             = player:x()
        local scoreCat      = 0
        
        --print("scoring for ledge: "..ledge.id.." points="..ledge.points.." pointsPos="..pos.." x="..x)
        -- we score by:
        -- 1. player lands in center area = 100%
        -- 2. player lands in second area = 50%
        -- 3. player lands in third  area = 25%
        for i=1,3 do
            local dist = i*25
            if x > (pos - dist) and x < (pos + dist) then
                if     i == 1 then newScore = self.points
                elseif i == 2 then newScore = math_floor(self.points/2)
                elseif i == 3 then newScore = math_floor(self.points/4) end
                --print("scored in section "..i.." with newScore="..newScore)
                scoreCat = i
                break
            end
        end

        -- Track top scores in a row for awards (ensure they didnt go back and do it repeatedly)
        if newScore == self.points and self.trueScore == 0 then
            player.topJumpsInaRow = player.topJumpsInaRow + 1

            if player.topJumpsInaRow > player.maxJumpsInaRow then
                player.maxJumpsInaRow = player.topJumpsInaRow
            end

            after(500, function() player:sound("randomCelebrate") end)
        else
            player.topJumpsInaRow = 0
        end
        -- End award calculation

        --print("ledge "..ledge.id.." newScore="..newScore.." scoreLastPlay="..self.score.." scoreLastJump="..self.trueScore)
        
        if newScore > self.score then
            local jumpScore    = newScore - self.score
            self.score         = newScore
            self.scoreCategory = scoreCat
            self:colorLedge()
        end

        -- store current run (not against stored previous zone play score) for ranking
        if newScore > self.trueScore then
            local jumpScore = newScore - self.trueScore
            self.trueScore  = newScore
            
            if newScore == self.points then
                hud:displayMessageJump("top-score")
            end

            hud:animateScoreText(jumpScore, self.scoreCategory, self:x(), self:y())
            hud:showStory("explain-score")
        end
    end
end


function ledge:colorLedge()
	local  cat =  self.scoreCategory
    if     cat == scoreCategoryFirst  then self.image:setFillColor(0.4,1,0.4)
    elseif cat == scoreCategorySecond then self.image:setFillColor(1,1,0.4)
    elseif cat == scoreCategoryThird  then self.image:setFillColor(1,0.4,0.4) end
end


function ledge:getDustColor()
	local cat = self.scoreCategory

    if cat then
        if     cat == scoreCategoryFirst  then return "green"
        elseif cat == scoreCategorySecond then return "yellow"
        elseif cat == scoreCategoryThird  then return "red" end
    elseif self.isStart then
        return "green"
    elseif self.isFinish then
        return "red"
    end
    return "white"
end


-- Applies a shake movement to a ledge when it has an impact (replaces and restore any existing movement)
----
function ledge:shake(camera)
    -- only shake if not marked unshakable and not currently in a pause movement timer (as it will shake after and be all odd)
    if self.canShake and not self.isShaking and self.pauseMovementHandle == nil then
        self.isShaking = true

        -- for moving ledges we need to stop their movement and do the shake, then resume it
        if self.movement then
            self.stashedMovement = self.movement
        end
        self:setMovement(camera, self.master.ledgeShakeMovement)
        -- remove ledge before adding to ensure we dont needlessly add two entries in movement collection
        self:stop()
        self:move()
    end
end


-- Called when a oneway movement has completed and movement should be stopped (or previous movement should be resumed)
function ledge:movementCompleted()
    -- ensure that shaking a pulley ledge does not trigger it to move after it has been reset (as has an existing movement pattern)
    if self.stashedMovement and (self.surface ~= pulley or self.triggeredPulley) then
        -- resume movement for moving ledges
        self.movement        = self.stashedMovement
        self.stashedMovement = nil

    else
        self:stop()
    end

    self.isShaking = false
end


function ledge:showScoreMarker()
    return not self.invisible and not self.image.isSensor and not self.destroyed
end


function ledge:selfDestruct()
    self:sound("ledgeOneshotActivated")
    self:animate("Activated")

    after(1500, function()
        self:stop()
        self.invisible = false
        self:destroy()
    end)
end


function ledge:getPhysics(s)
    local stats = surfacePhysics[self.surface]
    local w, h  = 150, 15

    if self.surface == lava then
        h = 31
        stats.shape = {-w+12,-h, w+8,-h, w+8,0, -w+12,0}
        
    elseif self.surface == spring then
        w, h = 105, 32
        stats.shape = {-w+5,-h, w-5,-h, w,0, -w,0}

    elseif self.surface == electric then
        h = 40
        stats.shape = {-w,-h, w,-h, w,-h+10, -w,-h+10}

    elseif self.surface == spiked then
        w, h = 100, 30
        stats.shape = {-w,-h, w,-h, w,-h+10, -w,-h+10}

    elseif self.surface == exploding then
        w, h = 120, 20
        stats.shape = {-w,0, w,0, w,h, -w,h}

    elseif self.surface == collapsing then
        w, h = 120, 30
        -- the collapsing ledge is off center, so modify it based on if its flipped on X:
        if self.flip == "x" then
            stats.shape = {-w+10,-h, w+10,-h, w+10,-h+10, -w+10,-h+10}
        else
            stats.shape = {-w-10,-h, w-10,-h, w-10,-h+10, -w-10,-h+10}
        end

    elseif self.surface == pulley then
        w, h = 100, 40
        stats.shape = {-w,-h, w,-h, w,-h+15, -w,-h+15}

    elseif self.surface == ramp then
        h = 0
        stats.shape = {-w-10,-h, w-10,-h, w-10,-h+10, -w-10,-h+10}

    elseif self.surface == oneshot then
        if     self.size == "medium"    then w, h = 100, 0
        elseif self.size == "med-small" then w, h = 75,  0 end

        stats.shape = {-w,-h, w,-h, w,-h+10, -w,-h+10}
    else
        stats.shape = {-w,-h, w,-h, w,-h+10, -w,-h+10}
    end

    for i=1, #stats.shape do
        stats.shape[i] = stats.shape[i] * s
    end

    stats.filter = { groupIndex=-5 }

    return stats
end


function ledge:getCustomSize(s)
    local w, h = 300, 30

    if     self.surface == lava       then 	 h    = 65
    elseif self.surface == spring     then   w, h = 105, 32
    elseif self.surface == electric   then   h    = 40
    elseif self.surface == spiked     then   w    = 100
    elseif self.surface == exploding  then   w, h = 240, 0
    elseif self.surface == collapsing then   w, h = 240, 60
    elseif self.surface == pulley     then   w, h = 200, 65
    elseif self.surface == ramp       then 	 h    = 0
    elseif self.surface == oneshot    then
        if     self.size == "medium"    then w, h = 200, 0
        elseif self.size == "med-small" then w, h = 150, 0 
        end
    end

    return w*s, h*s
end


---------- DEADLY LEDGE FUNCTIONS ----------

function ledge:toggleDeadlyState()
    if self.deadly then
        self.deadly = false
        self:loop("Standard")
        self.timerAnimationHandle = timer.performWithDelay(self.timerOff, function() self:toggleDeadlyState() end, 1)
    else
        self.deadly = true
        
        if self.surface == electric then
            self:sound("electricActivated", {duration=self.timerOn})
            self:loop("Activated")

        elseif self.surface == spiked then
            self:sound("ledgeSpikesActivated", {duration=self.timerOn})
            self:animate("Strike")
        end

        self.timerAnimationHandle = timer.performWithDelay(self.timerOn, function() self:toggleDeadlyState() end, 1)
    end
end


function ledge:activateSpringLedge(player)
    self:animate("Activated")
end


function ledge:activateLavaLedge(target)
    if target and self.deadly then
        return self:killWithLava(target)
    end

    self:sound("ledgeLavaActivated", {duration=5000})
    self:animate("Activate-100")

    after(3000, function()
        self.deadly = true
        self:loop("Burnt-Out")

        if target and target:onLedge(self) and target.shielded ~= true then
            self:killWithLava(target)
        end
    end)
end


function ledge:activateExplodingLedge(target)
    self:animate("Activated")

    after(2000, function()
        self:intangible()
        self.destroyed = true

        spineStore:showExplosion(self:getCamera(), self)
        self:sound("ledgeExplodingActivated", {duration=4000})

        -- make any attached items dynamic so gravity takes them
        for key,object in pairs(self.boundItems) do
            object:body("dynamic")
	    end

        if target and target:onLedge(self) then
            target:murder({animation="Death JUMP HIGH", fall=true, message="exploding-ledge"})
        end

        after(300, function() self:hide() end)
    end)
end


function ledge:activateCollapsingLedge(target, animation, duration)
    self:sound("ledgeCollapsingActivated", {duration=duration})
    self:animate(animation or "Trigger")

    after(duration or 3500, function()
        self:sound("ledgeCollapsingBreak", {duration=1000})
        self:intangible()
        self.destroyed = true

        -- make any attached items dynamic so gravity takes them
        for _,object in pairs(self.boundItems) do
            if object.image and not object.isPlayer then
                object:body("dynamic")
            end
	    end

        if target and target:onLedge(self) then
            target.mode = playerFall
            target:sound("randomFall")
            target:animate("Death JUMP HIGH")

            if target.main then 
            	hud:displayMessageDied("collapsing-ledge") 
            end
        end
    end)
end


function ledge:activatePulleyLedge(target)
    self:animate("Activated")

    after(self.duration or 1000, function()
        -- If shaking then stop that and reset for new movement
        if self.isShaking then
            self:stop()
        end

        self:sound("ledgePulleyActivated", {duration=9000})
        
        self.triggeredPulley = true
        self:moveNow({pattern=movePatternVertical, speed=(self.speed or 5), distance=(self.distance or 1000), oneWay=true})
    end)
end


function ledge:killWithElectricity(target)
    if target.shielded ~= true then
        local anim = "Death ELECTRIC LEDGE"

        if target:runDistance() < (target:height() - 20) then
            anim = anim .. " BACKWARD"
        end

        target:murder({animation=anim, message="electric-ledge"}, "playerDeathElectric")
    end
end


function ledge:killWithSpikes(target)
    if target.shielded ~= true then
        target:explode({message="spiked-ledge"}, "playerDeathSpikes")
    end
end


function ledge:killWithLava(target)
    if target.shielded ~= true then
        local anim = "Death LAVA LEDGE"

        if target:runDistance() < (target:height() - 20) then
            anim = anim .. " BACKWARD"
        end

        target:murder({animation=anim, message="lava-ledge"}, "playerDeathLava")
    end
end


return ledge