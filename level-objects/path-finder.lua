local anim  = require("core.animations")

local math_abs    = math.abs
local math_random = math_random
local math_round  = math.round


-- Manually created matrix showing what pull distances can reaches ledges at ket distances:
local ledgePullDistances = {
	["big"] = {
	--  distX:1	distY:2	minX:3	maxX:4	minY:5	maxY:6
		{100,	0,		30,		120,	0,		200},
		{100,	0,		30,		120,	0,		200},
		{100,	100,	15,		65,		125,	200},
		{100,	200,	50,		50,		200,	200},
		{100,	280,	10,		10,		200,	200},
		{200,	0,		55,		190,	0,		200},
		{200,	100,	65,		160,	75,		200},
		{200,	200,	75,		130,	150,	200},
		{200,	280,	55,		90,		200,	200},
		{300,	0,		75,		200,	25,		200},
		{300,	100,	90,		200,	85,		200},
		{300,	200,	110,	200,	140,	200},
		{300,	280,	120,	120,	200,	200},
		{400,	0,		110,	200,	70,		200},
		{400,	100,	120,	200,	115,	200},
		{400,	200,	140,	200,	160,	200},
		{400,	280,	170,	190,	190,	200},
		{500,	0,		140,	200,	110,	200},
		{500,	100,	145,	200,	140,	200},
		{500,	200,	170,	200,	180,	200},
		{500,	280,	200,	200,	200,	200},
	},
	["small"] = {
	--  distX:1	distY:2	minX:3	maxX:4	minY:5	maxY:6
		{100,	0,		5,		55,		0,		165},
		{100,	100,	5,		45,		80,		200},
		{100,	200,	10,		25,		160,	200},
		{100,	280,	10,		10,		200,	200},
		{150,	0,		10,		95,		0,		200},
		{150,	100,	20,		75,		85,		200},
		{150,	200,	25,		50,		160,	200},
		{150,	280,	35,		35,		200,	200},		
		{200,	0,		25,		120,	0,		200},
		{200,	100,	30,		110,	80,		200},
		{200,	200,	45,		75,		150,	200},
		{200,	280,	55,		55,		200,	200},
		{250,	0,		35,		150,	0,		200},
		{250,	100,	50,		150,	65,		200},
		{250,	200,	55,		100,	150,	200},
		{250,	280,	70,		70,		200,	200},
		{300,	0,		55,		180,	0,		200},
		{300,	100,	60,		165,	70,		200},
		{300,	200,	75,		120,	150,	200},
		{300,	280,	90,		90,		200,	200},
		{350,	0,		65,		200,	0,		200},
		{350,	100,	75,		200,	70,		200},
		{350,	200,	90,		145,	150,	200},
		{350,	280,	105,	105,	200,	200},
		{400,	0,		75,		200,	20,		200},
		{400,	100,	90,		200,	80,		200},
		{400,	200,	100,	165,	150,	200},
		{400,	280,	125,	125,	200,	200},
		{450,	0,		85,		200,	45,		200},
		{450,	100,	100,	200,	100,	200},
		{450,	200,	120,	180,	150,	200},
		{450,	280,	145,	145,	200,	200},
		{500,	0,		105,	200,	70,		200},
		{500,	100,	120,	200,	115,	200},
		{500,	200,	140,	200,	160,	200},
		{500,	280,	160,	160,	200,	200},
		{550,	0,		120,	200,	95,		200},
		{550,	100,	130,	200,	130,	200},
		{550,	200,	155,	185,	180,	200},
		{550,	280,	180,	180,	200,	200},
	},
	["deathslide"] = {
	--  distX:1	distY:2	minX:3	maxX:4	minY:5	maxY:6
		{200,	50,		15,		75,		0,		150},
		{200,	100,	5,		85,		0,		200},
		{200,	150,	5,		120,	0,		200},
		{200,	200,	15,		200,	0,		200},
		{200,	250,	15,		200,	35,		200},
		{200,	300,	20,		200,	75,		200},
		{200,	350,	25,		200,	130,	200},
		{200,	400,	30,		200,	185,	200},
		{200,	450,	35,		140,	200,	200},
		{250,	50,		15,		70,		0,		200},
		{250,	100,	15,		70,		0,		200},
		{250,	150,	20,		85,		0,		200},
		{250,	200,	25,		115,	0,		200},
		{250,	250,	30,		200,	35,		200},
		{250,	300,	35,		200,	70,		200},
		{250,	350,	40,		200,	115,	200},
		{250,	400,	45,		200,	160,	200},
		{250,	450,	50,		180,	200,	200},
		{300,	50,		30,		90,		0,		200},
		{300,	100,	35,		95,		0,		200},
		{300,	150,	40,		115,	0,		200},
		{300,	200,	40,		155,	0,		200},
		{300,	250,	45,		200,	35,		200},
		{300,	300,	50,		200,	70,		200},
		{300,	350,	55,		200,	115,	200},
		{300,	400,	60,		200,	160,	200},
		{300,	450,	65,		200,	185,	200},
		{350,	50,		40,		105,	0,		200},
		{350,	100,	45,		120,	0,		200},
		{350,	150,	50,		145,	0,		200},
		{350,	200,	55,		190,	0,		200},
		{350,	250,	60,		200,	35,		200},
		{350,	300,	65,		200,	75,		200},
		{350,	350,	70,		200,	115,	200},
		{350,	400,	75,		200,	140,	200},
		{350,	450,	85,		200,	180,	200},
		{400,	50,		55,		130,	0,		200},
		{400,	100,	60,		145,	0,		200},
		{400,	150,	65,		175,	0,		200},
		{400,	200,	70,		200,	15,		200},
		{400,	250,	75,		200,	45,		200},
		{400,	300,	80,		200,	85,		200},
		{400,	350,	85,		200,	115,	200},
		{400,	400,	95,		200,	140,	200},
		{400,	450,	105,	200,	180,	200},
		{450,	50,		65,		155,	0,		200},
		{450,	100,	70,		175,	0,		200},
		{450,	150,	75,		200,	10,		200},
		{450,	200,	80,		200,	30,		200},
		{450,	250,	85,		200,	60,		200},
		{450,	300,	90,		200,	95,		200},
		{450,	350,	100,	200,	120,	200},
		{450,	400,	110,	200,	145,	200},
		{450,	450,	125,	200,	180,	200},
		{500,	50,		80,		175,	0,		200},
		{500,	100,	85,		200,	0,		200},
		{500,	150,	90,		200,	25,		200},
		{500,	200,	95,		200,	50,		200},
		{500,	250,	100,	200,	75,		200},
		{500,	300,	105,	200,	105,	200},
		{500,	350,	115,	200,	135,	200},
		{500,	400,	125,	200,	160,	200},
		{500,	450,	145,	200,	180,	200},
		{550,	50,		90,		200,	0,		200},
		{550,	100,	95,		200,	25,		200},
		{550,	150,	100,	200,	45,		200},
		{550,	200,	105,	200,	70,		200},
		{550,	250,	110,	200,	90,		200},
		{550,	300,	120,	200,	115,	200},
		{550,	350,	130,	200,	140,	200},
		{550,	400,	145,	200,	160,	200},
	}
}


local pathFinderLoader = {}


-- obstruction detector collission event
local function obstructionSensorCollision(self, event)
	local sensor = self
	local hit    = event.other.object

	if hit and event.phase == "began" then
		-- TODO: possibly work out how much the object intersects to determine if it counts as a problems
		if sensor.fromIndex ~= hit.zoneRouteIndex and sensor.targetIndex ~= hit.zoneRouteIndex then
			-- ignore from and target jump items
			if (hit.isLedge and not hit.destroyed) or hit.isWall or hit.isSpike or (hit.isEnemy and hit.deadly) then
				-- only elements above count as an obstruction
				sensor.pathFinder.mode = "obstructionDetected"
				--print("***obstructionSensorCollision: "..hit.key)
			end
		end
	end
end


-- pathFinder shot collision event
local function shotCollision(self, event)
	local shot = self
	local hit  = event.other.object

	if not hit then return end

	if event.phase == "began" then
		self:setFillColor(1,0.2,0.2)

		if shot.fromIndex == hit.zoneRouteIndex then
			--print("ignore from collision")
		elseif shot.targetIndex == hit.zoneRouteIndex then
			if hit.isLedge then
		        local shotX = shot.x
		        local shotY = shot.y + (shot.height/2)
		        local left  = hit:leftEdge()
		        local right = hit:rightEdge()
		        local top   = hit:topEdge(0, shotX)
		        local width = 0

		        left, right, top = left-width, right+width, top+10

		        --print("target collision: "..shotX.." < ".. left.." or "..shotX.." > "..right.." | "..shotY.." > "..top)

		        if shotY > top then
		        	shot:hitSide()
		        elseif shotX < left or shotX > right then
		        	shot:hitCorner()
				else
					shot:success()
				end
			elseif hit.isObstacle and hit:canGrab(shot) then
				shot:success()
			end
		elseif (hit.isLedge and not hit.destroyed) or hit.isWall or hit.isSpike or (hit.isEnemy and hit.deadly) then
			shot:intercepted(hit)
		end
	elseif shot.targetIndex == hit.zoneRouteIndex and hit.isObstacle and hit:canGrab(shot) then
		shot:success()
	elseif event.phase == "ended" then
		self:setFillColor(0.5,0.5,0.5, 0.5)
	end
end


-- Create pathfinder for level generator
function pathFinderLoader:newStatic(camera)
	local pathFinder = {
		mode              = "none",
		item              = nil,
		camera            = camera,
		from              = nil,
		target            = nil,
		direction         = right,
		findData          = {},
		width             = 0,
		height            = 0,
		shots             = nil,
		shotsActive       = 0,
		pathFoundCallback = nil,
		pathCloseCallback = nil,
		noPathCallback    = nil,
	}

	pathFinderLoader:build(pathFinder)
	return pathFinder
end


-- Create pathfinder for AI for single jump
function pathFinderLoader:new(item, camera, from, direction, target)
	-- we mark an attribute on the passed item to store pathFinder data on, check if this exists & preserve if it does
	if item.pathFinderData == nil then
		item.pathFinderData = {}
	end

	local pathFinder = {
		mode              = "none",
		item              = item,
		camera            = camera,
		from              = from,
		target            = target,
		direction         = direction,
		findData          = item.pathFinderData,
		width             = item:width()+10,
		height            = item:height(),
		shots             = nil,
		shotsActive       = 0,
		pathFoundCallback = nil,
		pathCloseCallback = nil,
		noPathCallback    = nil,
	}

	pathFinderLoader:build(pathFinder)
	return pathFinder
end


function pathFinderLoader:build(pathFinder)

	function pathFinder:destroy()
		if self.timeoutHandler then
			timer.cancel(self.timeoutHandler)
			self.timeoutHandler = nil
		end

		if self.obstructionSensor then
			self.camera:remove(self.obstructionSensor)
			self.obstructionSensor:removeSelf()
			self.obstructionSensor = nil
		end

		if self.shots then
			local num = #self.shots
			for i=1,num do
				self:clearShot(i)
			end
		end

		self.shots 	  = nil
		self.item     = nil
		self.camera   = nil
		self.from     = nil
		self.target   = nil
		self.findData = nil
	end


	-- records when a jump type was tried so we can avoid that again
	function pathFinder:recordJumpAttempt(mainType, jumpType, velx, vely, landType)
		local rules = self.findData
		if rules[mainType] == nil then
			rules[mainType] = {}
		end

		if rules[mainType][jumpType] == nil then
			rules[mainType][jumpType] = {count=0}
		end

		local jumpRule = rules[mainType][jumpType]
		jumpRule.count    = jumpRule.count + 1
		jumpRule.velx     = velx
		jumpRule.vely     = vely
		jumpRule.landType = landType
	end


	-- check if a jump type has been tried
	function pathFinder:triedJump(mainType, jumpType)
		local rules = self.findData

		if rules[mainType] == nil then
			return 0
		else
			local jump = rules[mainType][jumpType]
			if jump == nil then
				return 0
			else
				return jump.count
			end
		end
	end


	-- the initial function called by AI to start all pathfnder logic
	function pathFinder:start(pathFoundCallback, pathCloseCallback, noPathCallback)
		self.pathFoundCallback = pathFoundCallback
		self.pathCloseCallback = pathCloseCallback
		self.noPathCallback    = noPathCallback
		self.mode              = "scanningObstructions"

		if not self:startObstructionDetection() then
			self:startPathShots()
		else
			after(50, function()
				if self.obstructionSensor then
					self.obstructionSensor:removeSelf()
					self.obstructionSensor = nil

					if self.mode == "obstructionDetected" then
						pathFinder:startPathShots()
					elseif self.mode == "scanningObstructions" then
						pathFinder:jumpUnobstructed()
					end
				end
			end)
		end
	end


	-- creates a sensor between this and the target to see if any obstructing obstacles are in the way
	-- the shape of the sensor is:
	-- if target same or higher than from: trapezoid from right edge, up to target y (+ player height if target ledge), across to target x
	-- if target lower than from: trapezoid from right edge, across to target x, down to target y
	function pathFinder:startObstructionDetection()
		local scale  = self.camera.scaleImage

		if self.from.image == nil or self.from.target == nil then
--			print("PathFinder from or target nil - aborting")
			return false
		end

		local fx, fy = self.from:jumpRight(), self.from:jumpTop()
		local tx, ty = self.target:x(),       self.target:jumpTop()
		local tl, tr = self.target:jumpLeft(), self.target:jumpRight()
		local halfWidth  = (tx - fx) / 2
		local halfHeight = (fy - ty) / 2
		local shape, ph  = nil, nil

		-- start with max low jumps for now
		self.jumpType = jumpMaxLow

		-- check if we've tried it:
		if self:triedJump(jumpUnobstructed, jumpMaxLow) > 0 then
			if self:triedJump(jumpUnobstructed, jumpMiddle) == 0 then
				self.jumpType = jumpMiddle
			elseif self:triedJump(jumpUnobstructed, jumpMaxHigh) == 0 then
				self.jumpType = jumpMaxHigh
			else
				--print("tried all unobstructed jumps - use pathFinder shots")
				return false
			end
		end

		if self.jumpType == jumpMaxLow then
			ph = self.height * 2
		elseif self.jumpType == jumpMiddle then
			ph = self.height * 3
		elseif self.jumpType == jumpMaxHigh then
			ph = self.height * 4
		end

		if self.direction == left then
			fx = self.from:jumpLeft()
			halfWidth = (tx - fx) / 2
		end

		if fy >= ty then  -- target higher same shape either left or right
			shape = {-halfWidth,halfHeight, -halfWidth,-halfHeight-ph, halfWidth,-halfHeight-ph, halfWidth,-halfHeight}
		elseif self.direction == right then
			shape = {-halfWidth,halfHeight, -halfWidth,halfHeight-ph, halfWidth,halfHeight-ph, halfWidth,-halfHeight, halfWidth-(tx-tl),-halfHeight}
		else
			shape = {-halfWidth,halfHeight, -halfWidth,halfHeight-ph, halfWidth,halfHeight-ph, halfWidth,-halfHeight} -- cant have convex shape:, halfWidth-(tx-tl),-halfHeight}
		end

		local sensor = display.newCircle(fx+halfWidth, fy-halfHeight, 5)
        physics.addBody(sensor, "dynamic", {shape=shape, isSensor=true, filter=pathFilter})
        self.obstructionSensor = sensor

        sensor.gravityScale = 0
        sensor.pathFinder   = self
        sensor.fromIndex    = self.from.zoneRouteIndex
        sensor.targetIndex  = self.target.zoneRouteIndex
        sensor.collision    = obstructionSensorCollision
    	sensor:addEventListener("collision", sensor)
    	self.camera:add(sensor, 3)
    	return true
	end


	function pathFinder:jumpUnobstructed()
		local scale      = self.camera.scaleImage
		local velx, vely = nil, nil

		if self.target.isLedge then
			velx, vely = self:calcJumpToLedgeVelocity(self.from, self.target, scale, self.jumpType, shotId)
		elseif self.target.isObstacle then
			velx, vely = self:calcJumpToObstacleVelocity(self.from, self.target, scale, self.jumpType, shotId)
		end

		self:recordJumpAttempt(jumpUnobstructed, self.jumpType, velx, vely)
		self.pathFoundCallback(self.item, velx, vely)
	end


	-- creates the pathFinder shots when an obstruction is detected to the next target
	function pathFinder:startPathShots()
		self.mode        = "firing"
		self.shots       = {}
		self.shotsActive = 3

		self:fireShot(jumpMaxLow)
		self:fireShot(jumpMaxHigh)
		self:fireShot(jumpMiddle)

		self.timeoutHandler = timer.performWithDelay(2500, function()
			--print("pathFinder timed out")
			self.noPathCallback(self.item)
		end)

		self.mode = "waiting"
	end


	function pathFinder:fireShot(jumpType)
		local scale      = self.camera.scaleImage
		local shotId     = #self.shots + 1
		local velx, vely = nil, nil

		if self.target.isLedge then
			velx, vely = self:calcJumpToLedgeVelocity(self.from, self.target, scale, jumpType, shotId)
		elseif self.target.isObstacle then
			velx, vely = self:calcJumpToObstacleVelocity(self.from, self.target, scale, jumpType, shotId)
		end

		local shot = self:createShot(shotId, velx, vely, scale)

		self.shots[shotId] = {
			velx     = velx,
			vely     = vely,
			jumpType = jumpType,
			shot     = shot
		}
		shot:setLinearVelocity(velx, vely)
        --self:moveItemAlongTrajectory(shot, velx, vely, 180, scale)
		--print("fired "..jumpType.." shot: "..velx..", "..vely)
	end


	function pathFinder:createShot(shotId, velx, vely, scale)
		local width  = self.width  * scale
		local height = self.height * scale
		local from   = self.from
		local x1, x2, y1, y2

		if from.image == nil then
			print("Warning createShot from ledge is nil")
		end

		if from.isLedge then
			local fudge = 10*scale
			y1, y2 = self.item:y()+fudge, -self.height

			if self.direction == right then
				x1, x2 = from:rightEdge() - (self.width - fudge), self.width
			else
				x1, x2 = from:leftEdge()  - fudge, self.width
			end
		elseif from.isDeathSlide then
			--print("cant jump from deathslide yet")
		elseif from.isRopeswing then
			--print("cant jump from ropeswing")
		end

        local shot = display.newRect(x1, y1, x2, y2)
        --shot.alpha = 0
        shot.alpha = 0.5
        shot:setFillColor(0.5,0.5,0.5, 0.4)

        -- NOTE: pathFinder shots wont collide with each other or any players
        -- bear this in mind if this code is used for predicting negables thrown at other players
        physics.addBody(shot, "dynamic", {isSensor=true, density=1, friction=1, bounce=0, filter=pathFilter})
        
        --shot.gravityScale      = 0
        --shot.isBullet          = true
        shot.isPathFinder      = true
        shot.isFixedRotation   = true
        shot.isSleepingAllowed = false
        shot.pathFinder        = self
        shot.id                = shotId
        shot.fromIndex         = from.zoneRouteIndex
        shot.targetIndex       = self.target.zoneRouteIndex
        
        -- attributes / functions to simulate a player in other events coliision handlers
        shot.width     = self.width
        shot.height    = self.height
        shot.camera    = self.camera
        shot.mode      = playerJump
        shot.collision = shotCollision
    	shot:addEventListener("collision", shot)

        function shot:topEdge()
        	return self.y - (self.height * self.camera.scaleImage)
        end

	    function shot:success()
	    	return self.pathFinder:shotSuccessful(self)
	    end

	    function shot:hitSide()
	    	return self.pathFinder:shotHitSide(self)
	    end

	    function shot:hitCorner()
	    	return self.pathFinder:shotHitCorner(self)
	    end

	    function shot:intercepted(itemHit)
	    	return self.pathFinder:shotIntercepted(self, itemHit)
	    end

    	self.camera:add(shot, 3)
        return shot
	end


	function pathFinder:shotSuccessful(shot)
		--print("shot "..shot.id.." hit target")
		self.mode = "found"

		if self.shots then
			local data = self.shots[shot.id]
			self:recordJumpAttempt(jumpObstructed, data.jumpType, data.velx, data.vely, "pure")
			self.pathFoundCallback(self.item, data.velx, data.vely)
		end
	end


	function pathFinder:shotHitSide(shot)
		--print("shot "..shot.id.." hit target side")
		self.mode  = "almostFound"

		if self.shots then
			local data = self.shots[shot.id]
			self:recordJumpAttempt(jumpObstructed, data.jumpType, data.velx, data.vely, "side")
			self.pathCloseCallback(self.item, data.velx, data.vely, "side")
		end
	end


	function pathFinder:shotHitCorner(shot)
		--print("shot "..shot.id.." hit target corner")
		self.mode = "almostFound"

		if self.shots then
			local data = self.shots[shot.id]
			self:recordJumpAttempt(jumpObstructed, data.jumpType, data.velx, data.vely, "corner")
			self.pathCloseCallback(self.item, data.velx, data.vely, "corner")
		end
	end


	function pathFinder:shotIntercepted(shot, itemHit)
		--print("shot "..shot.id.." intercepted by "..itemHit:key())
		self:clearShot(shot.id)
		
		self.shotsActive = self.shotsActive - 1
		if self.shotsActive == 0 and self.mode == "waiting" then
			--print("all shots intercepted")
			timer.cancel(self.timeoutHandler)
			self.timeoutHandler = nil

			self.mode = "failed"
			self.noPathCallback(self.item)
		end
	end


	function pathFinder:clearShot(shotId)
		if self.shots then
			local shotEntry = self.shots[shotId]
			if shotEntry and shotEntry.shot then
				shotEntry.shot:removeSelf()
				shotEntry.shot = nil
				self.shots[shotId] = nil
			end
		end
	end


	-- Forcible moves a passed item along a trajectory curve of a specified velocity
	--[[function pathFinder:moveItemAlongTrajectory(item, velx, vely, arc, scale)
	    local jumpX, jumpY     = item.x, item.y
	    local startingVelocity = { x=velx, y=vely }
	    local i=1

	    if scale then
	        startingVelocity.x = startingVelocity.x * scale
	        startingVelocity.y = startingVelocity.y * scale
	    end

	    timer.performWithDelay(1, function()
	        local trajectoryPosition = curve:getTrajectoryPoint({x=jumpX, y=jumpY}, startingVelocity, i)
	        item.x, item.y = trajectoryPosition.x, trajectoryPosition.y
	        i=i+1
	    end, arc)
	end]]


	function pathFinder:selectTrajectoryPoint(jumpX, jumpY, velx, vely, scale, arc)
	    local startVelX, startVelY = velx, vely
	    local pointX, pointY = jumpX, jumpY

	    if scale then
	        startVelX = startVelX * scale
	        startVelY = startVelY * scale
	    end

	    for i=1,arc do
	        pointX, pointY = curve:getTrajectoryPoint(jumpX, jumpY, startVelX, startVelY, i)
	    end
	    return pointX, pointY
	end


	-- works out the X & Y velocity the player needs to jump to the next obstacle
	function pathFinder:calcJumpToObstacleVelocity(from, to, scale, jumpType, shotId)
		-- loop through pull distances getting lower and upper bounds and calc diff
		local rules        = self.findData
		local xdist, ydist = from:distanceFrom(to)
		local absx, absy   = math_abs(xdist), math_abs(ydist)
		local pullx, pully = nil, nil
		
		local row = self:getLedgeDistanceEntry("deathslide", absx, absy, rules)

		-- by default: choose the lowest jump we can do (maxX, minY)
		-- distX:1	distY:2	 minX:3	 maxX:4	 minY:5	 maxY:6
		if jumpType == jumpMaxLow then
			pullx, pully = row[4], -row[5]
		elseif jumpType == jumpMaxHigh then
			pullx, pully = row[3], -row[6]
		elseif jumpType == jumpMiddle then
			pullx = row[3] + ((row[4]-row[3]) / 2)
			pully = -(row[5] + ((row[6]-row[5]) / 2))
		end

		--print("shot "..(shotId or "none").." to="..to.key.." jumpType="..jumpType.." scale="..scale.." initial pullx/y="..pullx..","..pully)

		-- Jump to the left
		if from:x() > to:x() then
			pullx = -pullx
		end

		--print("    final pullx/y="..pullx..","..pully)
		return curve:calcVelocity(pullx, pully)
	end


	-- works out the X & Y velocity the player needs to jump to the next ledge
	function pathFinder:calcJumpToLedgePull(from, to, scale, jumpType, shotId)
		-- loop through pull distances getting lower and upper bounds and calc diff
		if from.image == nil or to.image == nil then
			print("Warning: calcJumpToLedgePull from or to ledge nil")
			return 0,0
		end

		local rules         = self.findData
		local xdist, ydist  = from:distanceFrom(to)
		local absx, absy    = math_abs(xdist), math_abs(ydist)
		local length        = to:rightEdge() - to:leftEdge()
		local size, dataset = nil, nil
		local pullx, pully  = nil, nil
		
		if length < (150*scale) then
			size, dataset = "small", "small"
		elseif length < (250*scale) then
			size, dataset = "medium", "big"
		else
			size, dataset = "big", "big"
		end

		local row = self:getLedgeDistanceEntry(dataset, absx, absy, rules)

		-- by default: choose the lowest jump we can do (maxX, minY)
		-- distX:1	distY:2	 minX:3	 maxX:4	 minY:5	 maxY:6
		if jumpType == jumpMaxLow then
			pullx, pully = row[4], -row[5]
		elseif jumpType == jumpMaxHigh then
			pullx, pully = row[3], -row[6]
		elseif jumpType == jumpMiddle then
			pullx = row[3] + ((row[4]-row[3]) / 2)
			pully = -(row[5] + ((row[6]-row[5]) / 2))
		end

		--print("shot "..(shotId or "none").." to="..to.key.." jumpType="..jumpType.." scale="..scale.." size="..size.." initial pullx/y="..pullx..","..pully)

		local data = {
			size  = size, 
			scale = scale, 
			row   = row, 
			pullx = pullx, 
			pully = pully, 
			absx  = absx, 
			absy  = absy, 
			xdist = xdist,
			ydist = ydist,
			jumpType = jumpType,
			rules = rules
		}

		-- Choose the highest jump in the following situations as its not possible:
		if dataset == "big" then
			pullx, pully = self:tweakJumpBigLedge(data)
		end

		-- because our pullDifferences table only goes up in 100s, using the 100 before for small ledges doesnt work for max X,
		-- so if the distance from the pullDifference lies close between two rows, do a max Y jump
		if dataset == "small" then
			pullx, pully = self:tweakJumpSmallLedge(data)
		end

		-- Jump to the left
		if from:x() > to:x() then
			pullx = -pullx
		end

		--print("    final pullx/y="..pullx..","..pully)
		return pullx, pully
	end


	function pathFinder:calcJumpToLedgeVelocity(from, to, scale, jumpType, shotId)
		local pullx, pully = self:calcJumpToLedgePull(from, to, scale, jumpType, shotId)
		return curve:calcVelocity(pullx, pully)
	end


	function pathFinder:getLedgeDistanceEntry(dataset, absx, absy, rules)
		local row, rowIndex, rowdiffx, rowdiffy = nil, 0, 0, 0

		for i,set in pairs(ledgePullDistances[dataset]) do
			if row == nil then
				row      = set
				rowdiffx = math_abs(set[1]-absx)
				rowdiffy = math_abs(set[2]-absy)
				rowIndex = i
			else
				local diffx = math_abs(set[1]-absx)
				local diffy = math_abs(set[2]-absy)

				if (diffx + diffy) <= (rowdiffx + rowdiffy) then
					row      = set
					rowdiffx = diffx
					rowdiffy = diffy
					rowIndex = i
				end
			end
		end

		if type(rules.changeJumpDistance) == "number" then
			local mod = rules.changeJumpDistance
			--print("Rule: modifying ledge entry by "..mod)
			row = ledgePullDistances[dataset][rowIndex + mod]

			if row == nil then
				row = ledgePullDistances[dataset][rowIndex]				
			end
		end

		--row = ledgePullDistances[dataset][rowIndex-1]
		--print("selected ledgePullDistance row["..rowIndex.."] row[3]="..row[3].." row[4]="..row[4].." row[5]="..row[5].." row[6]="..row[6])
		return row
	end


	--function pathFinder:tweakJumpBigLedge(size, scale, row, pullx, pully, absx, absy, xdist, ydist, jumpType)
	function pathFinder:tweakJumpBigLedge(data)
		local size, scale, absx, absy, pullx, pully, xdist, ydist, rules = data.size, data.scale, data.absx, data.absy, data.pullx, data.pully, data.xdist, data.ydist, data.rules

		-- medium ledges
		if size == "medium" then
			-- decrease X from medium long jumps
			if absx < (550*scale) and absy < (280*scale) then
				pullx = pullx * (0.8*scale)
				--print("    reduce pullx for medium long jump")
			end
		end

		-- Lower jumps
		if ydist > 0 then
			if rules.ignoreLowerJumpModifier == true then
				--print("Rule: skipping lower ledge modifier")
			else
				if absx < (450*scale) then
					pully = pully * (0.3*scale)
					--print("    reduce pully by 0.3 for lower jump")
				else
					pully = pully * (0.7*scale)
					--print("    reduce pully by 0.7 for lower jump")
				end

				if ydist >= (250*scale) then
					pullx = pullx * (0.8*scale)
					pully = pully * (0.5*scale)
					--print("    reduce pullx by 0.8, pully by 0.5 for lower jump")
				elseif ydist >= (150*scale) and absx <= (500*scale) then
					pullx = pullx * (0.8*scale)
					--print("    reduce pullx by 0.8 for lower jump")
				end
			end
		end
		return pullx, pully
	end


	--function pathFinder:tweakJumpSmallLedge(size, scale, row, pullx, pully, absx, absy, xdist, ydist)
	function pathFinder:tweakJumpSmallLedge(data)
		local scale, absx, absy, pullx, pully, xdist, ydist, rules = data.scale, data.absx, data.absy, data.pullx, data.pully, data.xdist, data.ydist, data.rules

		-- lower jumps
		if ydist > 0 then
			if rules.ignoreLowerJumpModifier == true then
				--print("Rule: skipping lower ledge modifier")
			else
				if ydist < (100*scale) then
					pully = pully * (0.8*scale)
					--print("    reduce pully by 0.8 for lower small jump")
				elseif absx < (500*scale) then
					if ydist >= (150*scale) and ydist < (200*scale) then
						pullx = pullx * (0.6*scale)
						--print("    reduce pullx by 0.6 for lower small jump")
					else
						pullx = pullx * (0.5*scale)
						--print("    reduce pullx by 0.5 for lower small jump")
					end
				else
					if ydist >= (200*scale) then
						pully = pully * (0.5*scale)
						--print("    reduce pully by 0.5 for lower small jump")
					end
					pullx = pullx * (0.7*scale)
					--print("    reduce pullx by 0.7 for lower small jump")
				end
				--print("    lower small jump")
			end
		end
		return pullx, pully
	end
end


return pathFinderLoader