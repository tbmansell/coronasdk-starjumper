local anim        = require("core.animations")
local spine       = require("core.spine")
local soundEngine = require("core.sound-engine")
local spineStore  = require("level-objects.collections.spine-store")


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
    lives          		= globalPlayerLives,
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
    -- selectFilter()
    -- !detachFromObstacle()
    -- murder()
    -- explode()
    -- kill()
    -- loseLife()
    -- *destroy()
    -- destroyVehicle()
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
    return self.intWidth * self.scaled
end


function player:height()
    return self.intHeight * self.scaled
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
    if self.image then
        self.image.angularVelocity = 0
        self.image:setLinearVelocity(0, 0)
    end

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
    elseif game == gameTypeClimbChase then
        self.lives = 0
    elseif game == gameTypeArcadeRacer then
        self.lives = 9999
    end
end


function player:setPhysics(s, filter)
    local w, h  = self:width(), self:height()
    local shape = {-10*s,-h, w,-h, w,-2*s, -10*s,-2*s}
    physics.addBody(self.image, (self.physicsBody or "dynamic"), {shape=shape, density=1, friction=1, bounce=0, filter=(filter or playerFilter)})
    self.image.isFixedRotation   = true
    self.image.isSleepingAllowed = false
end


function player:setPhysicsFilter(action)
    local filter = self:selectFilter(action)

    if self.physicsFilterPrev ~= filter then
        self.physicsFilterPrev = filter

        local xvel, yvel = self:getForce()
        physics.removeBody(self.image)

        self:setPhysics(self:getCamera().scaleImage, filter)

        if xvel ~= 0 or yvel ~= 0 then
            self:applyForce(xvel, yvel)
        end

        -- if on an obstable then keep player from falling off
        if self.attachedObstacle then
            self.image.gravityScale = 0
        end
    end
end


function player:selectFilter(action)
    if action == "addShield" then
        if self.attachedObstacle then
            return playerShieldedOnObstacleFilter
        else    
            return playerShieldedFilter
        end
    elseif action == "addObstacle" then
        if self.shielded then
            return playerShieldedOnObstacleFilter
        else
            return playerOnObstacleFilter
        end
    elseif action == "removeShield" then
        if self.attachedObstacle then
            return playerOnObstacleFilter
        else 
            return playerFilter
        end
    elseif action == "removeObstacle" then
        if self.shielded then
            return playerShieldedFilter
        else 
            return playerFilter
        end
    else
        return playerFilter
    end
end


-- Overrides base to set physics filter back so can land on ledges again
function player:detachFromObstacle()
    local obstacle = self.attachedObstacle

    if obstacle then
        if obstacle.isDeathSlide or obstacle.isRopeSwing or obstacle.isSpaceRocketCapsule then
            print("detachFromObstacle")
            self:setPhysicsFilter("removeObstacle")
        end
        -- release will nil this objects reference
        obstacle:release(self)
    end
end


----------------- FUNCTIONS TO HANDLE BEING KILLED -------------------


-- Default way to kill player, where they carry on moving as they die
----
function player:murder(options, sound)
    local options = options or {}

    self:kill(options.animation, sound, false, options.fall, options.message)
end


-- Kill player by exploding them and stopping them dead still
----
function player:explode(options, sound)
    local options = options or {}

    if sound and type(sound) == "table" then
        sound.action = sound.action or "playerDeathExplode"
    else
        sound = "playerDeathExplode"
    end

    self:kill(options.animation, sound, true, false, options.message)
end


-- Base function which performs the common things that happen when a player is killed
function player:kill(animation, sound, stopMoving, fall, message)
    -- guard to stop multiple deaths
    if self.mode ~= playerKilled then
        self.mode = playerKilled

        if self.runSound then
            self:stopSound(self.runSound)
            self.runSound = nil
        end

        self:detachFromObstacle()
        self:detachFromOther()
        self:destroyEmitter()
        self:destroyVehicle()
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

    if (self.lives == 0 and not self.ai and not self.restartDontDie) or self:cantRestart() then
        self.lostAllLives = true
        if self.failedCallback then self:failedCallback() end
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

            if self.ai then 
                self:aiRecordDeath() 
            end

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


function player:destroyVehicle()
    if self.vehicleImage then
        self.vehicleImage:destroy(self)
        self.vehicleImage:removeSelf()
        self.vehicleImage = nil
        anim:destroyQueue("vehicleFlight")
    end
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
    
    if self.physicsBody == nil then
        self:rotate(self.attachedLedge.rotation)
    end

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
    self:detachFromObstacle()
    self:detachFromOther()

    if self.grappleJoint and self.grappleJoint.removeSelf then
        self.grappleJoint:removeSelf()
        self.grappleJoint  = nil
        self.grappleTarget = nil
    end

    if self.grappleLine and self.grappleLine.removeSelf then
        self.grappleLine:removeSelf()
        self.grappleLine = nil
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

    spineStore:hideGearFlame(self:getCamera(), self)
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

    -- For AI: treat loading a shield as if they are safe to run now
    if self.ai and newGear == gearShield then
        self.loadedShield = true
    end
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
        skeleton:setAttachment("attachment-handback-ledgegloves",  nil)
    end

    if self.gear[land] == gearGrappleHook then
        skeleton:setAttachment("attachment-handfront-grapplegun",  "attachment-grapplegun")
    else
        skeleton:setAttachment("attachment-handfront-grapplegun",  nil)
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
    local params = params or {}

    -- The following are special actions that get a random sound to play
    if     action == "randomJump"        then params.sound = soundEngine:getPlayerJump(self.model)
    elseif action == "randomWorry"       then params.sound = soundEngine:getPlayerWorry(self.model)
    elseif action == "randomCelebrate"   then params.sound = soundEngine:getPlayerCelebrate(self.model)
    elseif action == "randomImpactVoice" then params.sound = soundEngine:getPlayerImpact(self.model)
    elseif action == "randomFall"        then params.sound = soundEngine:getRandomPlayerFall()
    elseif action == "randomImpact"      then params.sound = soundEngine:getRandomImpact()
    elseif action == "randomRing"        then params.sound = soundEngine:getRandomRing()
    else
        params.sound = params.sound or sounds[action]
    end

    if self.main and not params.manage then
        -- Sound should be in full and not in sound engine as its the main player
        play(params.sound, params)
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

    self:sound("playerRunRock")
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
        self:sound("randomFall")
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