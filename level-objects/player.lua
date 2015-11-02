local anim        = require("core.animations")
local spine       = require("core.spine")
local spineStore  = require("level-objects.collections.spine-store")
local soundEngine = require("core.sound-engine")


-- @class Player main class
local player = {

        isPlayer       		= true,
        class               = "player",
        ingame         		= false,             -- true if player currently in the level
        landingSpeed   		= 2,
        landingLimit   		= 40,
        correctBy      		= 0,
        highestLedgeId 		= 1,
        lastObstacleId 		= 0,     -- used to stop player being able to grab the same obstacle before touching something else
        mode           		= playerReady,
        direction      		= right,
        jumpType       		= "STANDARD",
        lives          		= 50,  --2,
        lostAllLives   		= false,  -- used as a guard to stop destroy() being called more times than player has lives
        hasDied        		= false,
        topJumpsInaRow 		= 0,      -- used for awards
        maxJumpsInaRow 		= 0,
        restartDontDie 		= false,  -- used for survival mode to simply restart the player at the start of the level instead of ending the level
        lastSpineTime  		= 0,      -- used for spine animation staggering with AIs
        scaled         		= 1,      -- if player is scaled or not
        intHeight      		= 110,    -- used by physics engine for shape and other height calcs
        intWidth       		= 20,     -- 30
        constRunSpeed  		= 8,      -- 60fps = 10    30fps = 15
        constWalkSpeed 		= 1.2,    -- 60fps = 2     30fps = 3
        startLeftLimit 		= 150,    -- distance left from right edge of start ledge, which player cant go past
        jumpXBoost     		= 0,
        jetpackFuel       	= 0,      -- number of jetpack uses remaining in current selection
        gliding           	= false,  -- used to indicate if player using glider
        parachuting       	= false,  -- used to indicate if player using parachute

        -- Methods:
        -----------
        -- !topEdge()
        -- !bottomEdge()
        -- !width()
        -- !height()
        -- midHeight()
        -- runDistance()
        -- ledgeLeftLimit()
        -- ledgeRightLimit()
        -- onLedge()
        -- onStartLedge()
        -- startPosition()
        -- stopMomentum()
        -- isDead()
        -- setMode()
        -- initForGameType()
        -- setPhysics()
        -- setPhysicsFilter()
        -- murder()
        -- explode()
        -- kill()
        -- loseLife()
        -- *destroy()
        -- cantRestart()
        -- reset()
        -- resetClearUp()
        -- resetLedge()
        -- resetReload()
        -- resetGear()
        -- showFlash()
        -- setGear()
        -- setIndividualGear()
        -- !pose()
        -- loadGear()
        -- !sound()
        -- soundLand()
        -- walkOntoLevel()
        -- standingReady()
        -- fallFromShip()
        -- startClimbChase()
}


-- Aliases:
local play     = globalSoundPlayer
local math_abs = math.abs
local osTime   = os.time



function player:topEdge()
    return self.image.y - (self.intHeight * self.scaled)
end


function player:bottomEdge()
    return self.image.y
end


function player:width()
    return self.intWidth
end


function player:height()
    return self.intHeight
end


function player:midHeight()
    return self.image.y - ((self.intHeight/2) * self.scaled)
end


-- @returns how much distance player has left to runup before jumping from the end of the ledge
function player:runDistance(direction)
    -- Use direction passed in or players direction if not passed in
    direction = direction or self.direction

    local ledge = self.attachedLedge

    if direction == right then
        return math_abs((ledge:x() + (ledge:width()/2) - self:x()))
    else
        return math_abs(self:x() - (ledge:x() - ledge:width()/2))
    end
end


function player:ledgeLeftLimit(range)
    return (self.attachedLedge:x() - (self.attachedLedge:width()/2)) + range
end


function player:ledgeRightLimit(range)
    return (self.attachedLedge:x() + (self.attachedLedge:width()/2)) - range
end


function player:onLedge(ledge)
    return self.attachedLedge ~= nil and ledge.id == self.attachedLedge.id
end


function player:onStartLedge()
    local ledge = self.attachedLedge
    return ledge and ledge.isStart and not ledge.isMiddle
end


function player:startPosition()
    if self.startLedge == -1 or self.startLedge.isDestroyed then
        self.startLedge = hud:firstLedge()

        if self.startLedge == -1 or self.startLedge.isDestroyed then
            return self:x()
        end
    end

    local start = self.startLedge

    if start.id == 1 then
        return start:rightEdge(150 * self.scaled), start:y() - start:height()/2
    else
        return start:x(), start:y() - start:height()/2
    end
end


function player:stopMomentum(completely)
    self.image.angularVelocity = 0
    self.image:setLinearVelocity(0, 0)

    if completely then
    	self:setGravity(0)
    end
end


function player:isDead()
    return self.mode == playerKilled or self.mode == playerMissedDeath
end


function player:setMode(mode, ifAlive)
    -- ifAlive to be used so we dont accidentally overwrite status if currently dead
    if ifAlive and self.mode == playerKilled then
        return
    else
        self.mode = mode
    end
end


-- Modifies the player stats and behavioru specific to the game type pased
function player:initForGameType(game)
    if game == gameTypeSurvival then
        self.lives = 0
        self.restartDontDie = true
    elseif game == gameTypeTimeAttack then
        self.lives = 9999
    elseif game == gameTypeRace then
        self.lives = 9999
    elseif game == gameTypeTimeRunner then
        self.lives = 0
        --self.lives = 9999
    elseif game == gameTypeClimbChase then
        self.lives = 0
        --self.lives = 9999
    elseif game == gameTypeArcadeRacer then
        self.lives = 9999
    end
end


function player:setPhysics(s, filter)
    local w, h  = self:width(), self:height()
    local shape = {-10*s,-h*s, w*s,-h*s, w*s,-2*s, -10*s,-2*s}
    physics.addBody(self.image, "dynamic", {shape=shape, density=1, friction=1, bounce=0, filter={ groupIndex=(filter or -2) }})
    self.image.isFixedRotation   = true
    self.image.isSleepingAllowed = false
end


function player:setPhysicsFilter(action)
    local filter = nil

    if action == "addShield" then
        filter = -3  -- immune to enemies
    elseif action == "addObstacle" then
        filter = -5  -- immune to other ledges
    else
        self.physicsFilter = nil
    end

    self.physicsFilterPrev = self.physicsFilter
    self.physicsFilter     = filter

    local xvel, yvel = self:getForce()
    physics.removeBody(self.image)

    self:setPhysics(self:getCamera().scaleImage, filter)

    if xvel ~= 0 or yvel ~= 0 then
        self:applyForce(xvel, yvel)
    end
end


----------------- FUNCTIONS TO HANDLE BEING KILLED -------------------


-- Default way to kill player, where they carry on moving as they die
----
function player:murder(options, sound)
    self:kill(options.animation, sound, false, options.fall, options.message)
end


-- Kill player by exploding them and stopping them dead still
----
function player:explode(options, sound)
    if sound and type(sound) == "table" then
        sound.action = sound.action or "playerDeathExplode"
    end

    self:kill(options.animation, sound, true, false, options.message)
end


-- Base function which performs the common things that happen when a player is killed
function player:kill(animation, sound, stopMoving, fall, message)
    -- guard to stop multiple deaths
    if self.mode ~= playerKilled then
        self.mode = playerKilled

        self:destroyEmitter()
        self:emit("deathflash")
        self:emit("die")

        -- Sound can be empty (no sound), string (just play sound of that name) or table (sound with options)
        if sound then
            if type(sound) == "string" then
                self:sound(sound)
            else
                self:sound(sound.action, sound)
            end
        end

        if self.attachedObstacle then
            self.attachedObstacle:release(self)
        end

        self.animationOverride = nil
        self:animate(animation or "Death EXPLODE BIG")

        if stopMoving then
            self:stopMomentum(true)
        else
            self:setGravity(1)
            if fall then
                self:intangible()
            end
        end

        self:showFlash()
        after(3000, function() self:loseLife() end)

        if message and self.main then
            hud:displayMessageDied(message)
        end
    end
end


-- Function removes a life and calls all the appropriate functions to reset the player or end the level
----
function player:loseLife()
    if self.lostAllLives then return end

    self.hasDied = true

    if (self.lives == 0 and not self.restartDontDie) or self:cantRestart() then
        self.lostAllLives = true
        self:failedCallback()
    else
        -- Survival Mode - start them from the very start
        if self.restartDontDie then
            self.startLedge = hud:firstLedge()
        else
            self.lives = self.lives - 1
        end

        if self.main then
            physics:pause()
            self:reset()
            hud:reset(self)
            hud:removeLife(self)
            hud:showGearFull()
            curve.showGrid = true
            physics:start()
            self:getCamera():track()
        else
            self:reset()
            hud:reset(self)
            self.gear = {[jump]=nil, [air]=nil, [land]=nil}
        end
    end
end


function player:destroy(camera, destroyBoundItems)
	display.remove(self.touchArea)

    if self.cancelGear then
        self.cancelGear:removeSelf()
        self.cancelGear = nil
    end

    if self.ai then
        self:destroyPathFinder()
        if self.raceIndicator then
            self.raceIndicator:removeSelf()
            self.raceIndicator = nil
        end
	end

    self.touchArea      = nil
    self.startLedge     = nil
    self.attachedLedge  = nil
    self.jumpFrom       = nil
    self.jumpTarget     = nil

    self:spineObjectDestroy(camera, destroyBoundItems)
end


-- checks if the marked start ledge and the first ledge are destroyed
function player:cantRestart()
    local start = self.startLedge
    local first = hud:firstLedge()

    return (start == nil or start == -1 or start.isDestroyed) and
           (first == nil or first == -1 or first.isDestroyed)
end


function player:reset()
    self:resetClearUp()
    self:resetLedge()
    self:resetReload()
    self:resetGear()
end


function player:resetLedge()
    if self.startLedge == nil or self.startLedge == -1 or self.startLedge.isDestroyed then
        self.startLedge = hud:firstLedge()
    end

    self.attachedLedge = self.startLedge
    self:rotate(self.attachedLedge.rotation)

    if self.attachedLedge and self.attachedLedge.inGame then
        if self.key then
            self.attachedLedge:bind(self)
        else
            self.attachedLedge:queueBind(self)
        end
    end

    self:moveTo(self:startPosition())
end


function player:resetClearUp()
    -- redraw invisble then show once work done (otherwise get screen garbage)
    self:hide()
    self:destroyEmitter()

    if self.attachedObstacle then
        if self.attachedObstacle.detach then
            self.attachedObstacle:detach(self)
        end
        self.attachedObstacle = nil
    end

    if self.grappleJoint then
        self.grappleJoint:removeSelf()
        self.grappleJoint  = nil
        self.grappleTarget = nil
    end

    if self.grappleLine then
        self.grappleLine:removeSelf()
        self.grappleLine = nil
    end

    if self.vehicleImage then
        self.vehicleImage:removeSelf()
        self.vehicleImage = nil
        anim:destroyQueue("vehicleFlight")
    end
end


function player:resetReload()
    self:pose()
    self:stand()
    self:solid()
    self:setGravity(1)

    self.markedOutOfPlay     = nil
    self.lastObstacleId      = nil
    self.lastWallCollision   = nil
    self.repeatWallCollision = nil
    self.jumpPrepared        = false

    -- redraw invisble then show once work done (otherwise get screen garbage)
    after(100, function()
        if self.remote then self:visible(0.5) else self:visible() end
    end)
end


-- Check for any jump gear that was in use for the jump or previous ledge that must expire if they die
function player:resetGear()
    self:shieldExpired()
    self:clearJumpAction(leaveGravity)
    self:gearUsedUp(jump, {gearSpringShoes, gearFreezeTime, gearTrajectory, gearShield})
    self:gearUsedUp(air,  {gearJetpack,     gearGlider,     gearParachute,  gearReverseJump})
    self:gearUsedUp(land, {})
    self.gearDuration = {[jump]=0,   [air]=0,   [land]=0}
    self.slotInUse    = {[jump]=nil, [air]=nil, [land]=nil}
end


function player:showFlash(size)
    spineStore:showFlash(self:getCamera(), self, size)
end


---------------- FUNCTIONS TO HANDLE GEAR ------------------------


function player:setGear(activeGear)
    self.gear = activeGear
    self.jetpackUses = 3
    self:loadGear()

    -- Start negables: if player mode is in air or falling then mark negable as persistant (meaning it will last until next jump)
    local negJump = self.gear[jump]
    local negAir  = self.gear[air]
    local persist = table.indexOf(playerNegPersistModes, self.mode) ~= nil

    if negJump == negTrajectory then
        if persist then self.gearDuration[jump] = 1 end
        self:negableTrajectoryStarted()
    elseif negJump == negDizzy then
        if persist then self.gearDuration[jump] = 1 end
        self:negableDizzyStarted()
    end

    if negAir == negBooster then
        if persist then self.gearDuration[air] = 1 end
        self:negableBoosterStarted()
    elseif negAir == negRocket then
        if persist then self.gearDuration[air] = 1 end
        self:negableRocketStarted()
    end
end


function player:setIndividualGear(newGear)
    local slot = gearSlots[newGear]
    self.gear[slot]  = newGear
    self.jetpackUses = 3
    self:loadGear()
end


-- Replaces gameObject:pose() to call loadGear afterward
function player:pose()
    self.skeleton:setToSetupPose()
    self:loadGear()
end


function player:loadGear()
    local airgear  = self.gear[air]
    local skeleton = self.skeleton
    
    if airgear == gearGlider then
        skeleton:setAttachment("Back Attachment", "attachment-glider")
    elseif airgear == gearParachute then
        skeleton:setAttachment("Back Attachment", "attachment-parachute")
    elseif airgear == gearJetpack then
        skeleton:setAttachment("Back Attachment", "attachment-rocket")
    elseif airgear == negBooster then
        skeleton:setAttachment("Back Attachment", "attachment-negable-booster")
        self:negableBoosterStarted()
    elseif airgear == negRocket then
        skeleton:setAttachment("Back Attachment", "attachment-negable-rocket")
        --self:negableRocketStarted()
    else
        skeleton:setAttachment("Back Attachment", nil)
    end

    if self.gear[land] == gearGloves then
        skeleton:setAttachment("attachment-handfront-ledgegloves", "attachment-handfront-ledgegloves")
        skeleton:setAttachment("attachment-handback-ledgegloves",  "attachment-handback-ledgegloves")
    else
        skeleton:setAttachment("attachment-handfront-ledgegloves", nil)
        skeleton:setAttachment("attachment-handback-ledgegloves", nil)
    end

    if state.data.planetSelected == 2 then
        skeleton:setAttachment("Head - Gear Skin", "Head - Gear Skin")
    end
end


function player:addKey(color)
    self.keyCard = color
end


function player:hasKey(color)
    return (self.keyCard == color)
end


function player:hasUnlocked(color)
    return (table.indexOf(self.keysUnlocked, color) ~= nil)
end


function player:getKey()
    return self.keyCard
end


function player:useKey()
    self.keysUnlocked[#self.keysUnlocked+1] = self.keyCard
    self.keyCard = nil

    if self.main then
        hud:removeKeyCollected()
    end
end


------------- SOUND --------------------------------


-- Replaces gameObject:sound()
-- @param string action - name of the sound (under global sounds) which also double as the action name for a managed sound
-- @param table  param  - optional list of sound properties
----
function player:sound(action, params)
    local params    = params or {}
    params.duration = params.duration or 2000

    -- The following are special actions that get a random sound to play
    if     action == "randomJump"        then params.sound = soundEngine:getPlayerJump(self.model)
    elseif action == "randomWorry"       then params.sound = soundEngine:getPlayerWorry(self.model)
    elseif action == "randomCelebrate"   then params.sound = soundEngine:getPlayerCelebrate(self.model)
    elseif action == "randomImpactVoice" then params.sound = soundEngine:getPlayerImpact(self.model)
    elseif action == "randomImpact"      then params.sound = soundEngine:getRandomImpact()
    elseif action == "randomRing"        then params.sound = soundEngine:getRandomRing()
    else
        params.sound = sounds[action]
    end

    if self.main then
        -- Sound should be in full and not in sound engine as its the main player
        play(params.sound, params, params.volume)
    else
        -- Some sounds should be allowed to be playe as many times as called and not bound by the action name:
        if action == "randomRing" then
            action = action..osTime()
        end

        soundEngine:playManagedAction(self, action, params)
    end
end


-- Shortcut function to save callers having to make multiple sound calls
-- @param bool bad - optional if true landing is bad and different sound is played
function player:soundLand(bad)
    self:sound("randomImpact")

    if bad then
        self:sound("randomWorry")
    else
        self:sound("randomImpactVoice")
    end
end


------------- PLAYER START SCENARIOS ---------------


function player:walkOntoLevel(callback)
    --[[if self.type == "main" then
        hub:publicMessage("game-start")
    end]]

    self:sound("playerRun")
    self:x(-200)
    self:loop("Run New")

    transition.to(self.image, {x=self:startPosition(), time=1500, delay=500, onComplete=function() callback(nil, self) end})
end


function player:standingReady(callback)
    self:x(self:startPosition())
    self:pose()
    self:animate("Jump PREPERATION")
    --self:readyJump()

    -- Adjustment for AI races
    if self.moveByAfterStart then
        self:x(self.moveByAfterStart)
    end

    after(500,  function() self:cancelJump() end)
    after(1000, function() callback(nil, self) end)
end


function player:fallFromShip(camera, spaceship, callback)
    self.mode = playerFall
    self:x(self:startPosition())
    self:y(self.startLedge:y() - 1000)
    self:hide()
    
    if self.main then camera:track() end
    
    spaceship:moveTo(120, self:y()+10)

    local seq = anim:chainSeq("fallFromShip", spaceship, false)
    seq:callbackAfter(500, function()
        self:hide()
        self:sound("checkpoint")
        self:sound("levelComplete")

        spaceship:animate("Ejection")
    end)
    seq:callbackAfter(1500, function()
        if self.main then physics:start() end

        self:visible()
        self:animate("Death JUMP HIGH")
        self:sound("checkpoint")
        self:sound("playerFall")
    end)
    seq:wait(1700)
    seq.onComplete = function()
        callback(nil, self)
        spaceship:destroy()
    end

    seq:start()
end


function player:startClimbChase(camera)
    self:x(centerX)
    camera:setXPosition(200)
end


return player