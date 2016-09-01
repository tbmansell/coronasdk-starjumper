local level         = require("core.level")
local utils         = require("core.utils")
local pathLoader    = require("level-objects.path-finder")
local objectsLoader = require("core.level-generator-objects")

-- Aliases
local math_random = math.random
local math_abs    = math.abs
local sfind       = string.find
local randomFrom  = utils.randomFrom
local percentFrom = utils.percentFrom
local firstFrom   = utils.firstFrom 

-- The main class
local levelGenerator = {
	deadlyElements = {["obstruction"]=true, ["enemy-brain"]=true, ["enemy-greyufo"]=true, ["warpfield"]=true},
}


-- Creates a new level wit the level generator
function levelGenerator:createLevel(camera)
	local zoneFile 	= ""
	local game  	= state.data.gameSelected
	
	self.pathFinder       = pathLoader:newStatic(camera)
	self.stagesGenerated  = {}
	self.ruleCache        = {}
	self.prevDeadlyTimed  = false
	self.infinitePosition = 0
	self.lastJumpObject   = nil
	self.lastJumpHeight   = 0
	self.lastJumpDir      = nil
	self.lastJumpFlipped  = false
	self.lastIsObstacle   = false
	ruleCache             = nil

	if game == gameTypeArcadeRacer then 
		zoneFile = "-arcade-racer"
		self.isClimbChase = false
		self.isRacing     = true
	elseif game == gameTypeTimeRunner then 
		zoneFile = "-arcade-timer"
		self.isClimbChase = false
		self.isRacing     = false
	elseif game == gameTypeClimbChase then 
		zoneFile = "-arcade-climber"
		self.isClimbChase = true
		self.isRacing     = false
	end
	
	level:new(camera, game, state.data.planetSelected, zoneFile)

	self.stageGeneration   = level.data.stageGeneration
	self.sceneryGeneration = level.data.sceneryGeneration
	self.sceneryDefs       = level.planetDetails.sceneryDefs
    self.lastJumpObject    = level:createElements()

    self.lastJumpObject.infinitePosition = 0

	return level
end


function levelGenerator:destroy()
	self.stagesGenerated   = nil
	self.stageGeneration   = nil
	self.sceneryGeneration = nil
	self.sceneryDefs       = nil
	self.pathFinder        = nil
	self.lastJumpObject    = nil
end


function levelGenerator:checkGenerateNextStage(camera, ledge)
	self.scale = camera.scaleImage
	
	local maxStage = #self.stagesGenerated

	-- only generate the next stage of elements IF this is the start OR we have REACHED or PASSED the MIDDLE of the LAST stage (could have jumped past middle)
	if ledge == nil or (ledge.stage == maxStage and ledge.infinitePosition >= 5) then
		-- check if we have already created the next stages elements (e.g. new character jumps on same ledge or a character jumps back to it)
		local nextStage = maxStage + 1

		if self.stagesGenerated[nextStage] == nil then
			self:generateNextStage(nextStage)
		end
	elseif ledge.climbChaseKiller then
		-- Climb Chase: when jumping past the last stages exit ledge, to the first ledge of the new stage
		-- we remove the last stages exit ledge and the UFO boss immediately
		local exitLedge = level:getLedge(ledge.id-1)
		if exitLedge then
			exitLedge:destroy()
			--level.friends:destroyUniqueId(ledge.climbChaseKiller)
			local ufoboss = level.friends:getTargetName(ledge.climbChaseKiller)
			if ufoboss then
				ufoboss:destroy()
			end
		end
	end
end


function levelGenerator:generateNextStage(nextStage)
	-- do this straight away incase a second player jumps straight after on same ledge
	self.stagesGenerated[nextStage] = true

	-- check about deleting a previous scenes objects
	if nextStage > 2 then
		level:destroyStageElements(nextStage-2)
	end

	math.randomseed(os.time())

	local rules = nextStage
	if rules > #self.stageGeneration then
		rules = #self.stageGeneration
	end

	-- marking global stage var allows all created items to be marked in makeGameObject()
	globalInfiniteStage   = nextStage
	self.infinitePosition = 0

	if self.isClimbChase then
		self.ringsRemaining = 10
	end

	self:createRoute(level:getLastLedge(), 0, 9, 1)

	if self.isClimbChase then
		self:generateClimbRouteEnd(level:getLastLedge())
	end

	globalInfiniteStage = nil
end


---------- STAGE RULE SELECTORS ----------


-- Looks in the current stages rules for the random set passed and picks a number: 
-- if it doesnt exist, it loops back to previous stages rules to see if it finds an early one to use
function levelGenerator:findStageRule(ruleNamespace, default, picker)
	local rule = self.ruleCache[ruleNamespace]

	if not rule then
		rule = {}
		-- break the namespace down into parts
		for i in ruleNamespace:gmatch("%S+") do
		    rule[#rule+1] = i
		end
		-- store it in the cache
		self.ruleCache[ruleNamespace] = rule
	end

	-- if getting rules form scenery generation rules then dont use the looping stage fallback logic
	if rule[1] == "scenery" then
		local rules = self.sceneryGeneration
		for i=2,#rule do 
			rules = rules[rule[i]]
			if rules == nil then 
				return default 
			end
		end

		if picker then 
			return picker(rules, default)
		else return 
			rules 
		end
	end

	-- start in current stage: look for rule, then loop backwards if not found
	for i=globalInfiniteStage, 1, -1 do
		local rules = self.stageGeneration[i]
		local num   = #rule
		local found = true

		for i=1,num do
			local index = rule[i]
			rules = rules[index]
			if rules == nil then
				found = false
				break
			end
		end

		if found then
			if picker then
				return picker(rules, default)
			else
				return rules
			end
		end
	end

	return default
end

-- Uses randomFrom for stage fallback rules
function levelGenerator:randomRule(ruleNamespace, default)
	return self:findStageRule(ruleNamespace, default, randomFrom)
end

-- Uses percentFrom for stage fallback rules
function levelGenerator:percentRule(ruleNamespace, default)
	return self:findStageRule(ruleNamespace, default, percentFrom)
end

-- Picks the rules and if not nil does a % check to see if the chance is <= 100
function levelGenerator:chanceRule(ruleNamespace)
	local chance = self:findStageRule(ruleNamespace, default)
	return chance and math_random(100) <= chance
end

-- Simple picks the whole rule using stage fallback rules, without trying to interact with it
function levelGenerator:pickRule(ruleNamespace, default)
	return self:findStageRule(ruleNamespace, default)
end


-- picks a scenery definition from the planetData
function levelGenerator:randomScenery(set, default)
	return self.sceneryDefs[randomFrom(set, default)]
end


---------- ROUTE CREATORS ----------


function levelGenerator:createRoute(from, routeStart, routeEnd, route)
	local specialItems, otherItems, multiRoute = self:assignAllStageElements()
	local elements = {}

	if route == 1 and not multiRoute then
		for pos=0,9 do
			local last = false
			if pos == 9 then last = true end
			self:generateNextJump(elements, specialItems, pos, last)
		end
		self.lastJumpObject = self:createElements(elements, otherItems, from, 0, 9)

	elseif route == 1 and multiRoute then
		for pos=0, multiRoute-1 do
			self:generateNextJump(elements, specialItems, pos, false)
		end

		self:generateRouteJump(elements, multiRoute, "start", route)

		local routeLength = self:pickRule("ledges special multiroute length")
		local routeEnd    = multiRoute + math_random(routeLength[1], routeLength[2]) - 1

		if routeEnd > 9 then routeEnd = 9 end

		for pos = multiRoute+1, routeEnd do
			self:generateRouteJump(elements, pos, "mid", route)
		end

		self:createElements(elements, otherItems, from, 0, routeEnd)

		-- recurse:
		from = level:getLastLedge()
		self:createRoute(from, multiRoute+1, routeEnd+1, route+1)

	elseif route == 2 then
		self.prevDeadlyTimed = false
		self:generateRouteJump(elements, routeStart-1, "start", route)

		local stageEnd = routeEnd + (9-routeEnd)

		for pos = routeStart+1, routeEnd do
			self:generateRouteJump(elements, pos, "mid", route)
		end

		self:generateRouteJump(elements, routeEnd+1, "end")

		for pos = routeEnd+2, stageEnd do
			local last = false
			if pos == stageEnd then last = true end
			self:generateNextJump(elements, specialItems, pos, last)
		end
 
		self.lastJumpObject = self:createElements(elements, otherItems, from, 0, 1+stageEnd-routeStart)
	end
end


function levelGenerator:createElements(elements, otherItems, from, posStart, posEnd)
	local last  = level:appendElements(elements, from)
	local num   = #elements-1
	local index = 0
	
	if num > #otherItems then 
		num = #otherItems 
	end

	self.lastJumpFlipped = false

	for pos=0, num do
		if from then
			local to = level:nextJumpObject(from.zoneRouteIndex)

			-- dont adorn the jump from an obstacle to its ledge
			if from.isLedge then
				local x, y = from:pos()
				local dir  = right

				if to:x() < x then dir = left end
				if self.lastJumpDir ~= dir then self.lastJumpFlipped=true else self.lastJumpFlipped=false end

				local elements = self:generateOtherElements(otherItems, from, to, index)
				level:createElementsFromData(elements, from)

				index = index + 1
				self.lastJumpDir = dir
			end

			from = to
		end
	end
	return last
end


---------- ASSIGNMENT FUNCTIONS -----------


function levelGenerator:assignAllStageElements()
	local specialItems = {[0]={},[1]={},[2]={},[3]={},[4]={},[5]={},[6]={},[7]={},[8]={},[9]={}}
	local otherItems   = {[0]={},[1]={},[2]={},[3]={},[4]={},[5]={},[6]={},[7]={},[8]={},[9]={}}
	local multiRoute   = nil

	self:assignElements("obstacles", 	      specialItems, true)
	self:assignElements("ledges special",     specialItems, true)
	self:assignElements("objects",   	      otherItems,   false, specialItems)
	self:assignElements("scenery foreground", otherItems,   false, specialItems)

	for i=1,#specialItems do
		local special = specialItems[i][1]

		-- only allow multiroute if there is enough room left in the stage
		if special == "multiroute" then
			--local maxlen = gen.ledges.special["multiroute"].length[2]
			local maxlen = self:randomRule("ledges special multiroute length", 3)
			if i + maxlen < 10 then
				multiRoute = i
			end
		end
	end

	return specialItems, otherItems, multiRoute
end


-- for each type of item in otherItems, loop through each jump position to see if they are placed
function levelGenerator:assignElements(ruleName, items, oneOnly, restrictions)
	local list = self:pickRule(ruleName)

	if list then
		for itemName, rules in pairs(list) do
			-- first look for the existence of the standard chance/gap rules:
			local chance = self:pickRule(ruleName.." "..itemName.." chance")

			if chance then
				local gap = self:pickRule(ruleName.." "..itemName.." gap")
				-- normal chance means we specifiy how many times and how likely those times are: if one chance fails we stop checking further
				self:assignElementsWithChance(itemName, chance, gap, items, oneOnly, restrictions)
			else
				chance = self:pickRule(ruleName.." "..itemName.." chanceAll")
				if chance then
					-- chanceAll means that every position has an equal chance of an item being generated & we check every posiotn & dont stop if one position fails
					for i=1,9 do
						if math_random(100) <= chance then
							table.insert(items[i], itemName)
--							print("assigned "..itemName.." at "..i)
						end
					end
				end
			end	
		end
	end
end


-- loop through each items chance attribute, which is a list of item appearing and consequetive items appearing after
function levelGenerator:assignElementsWithChance(itemName, chance, gap, items, oneOnly, restrictions)
	local num      = #chance
	local position = 0

	for i=1,num do
		if math_random(100) <= chance[i] then
			position = position + math_random(gap[1], gap[2])

			if position >= 10 then
				break  -- no room to place item
			end

			if oneOnly then
				-- if only one item can appear per slot, look for the next free one
				while position < 10 do
					if #items[position] == 0 then
						break  -- allow to fall through to insert below
					end
					position = position + 1
				end
			end

			-- if restrictions, some items dont play well with them
			if restrictions then
				while position < 10 do
					if not self:isRestrictiveItem(restrictions[position], itemName) then
						break  -- allow to fall through to insert below
					end
					position = position + 1
				end
			end
			
			if position < 10 then
				table.insert(items[position], itemName)
--				print("assigned "..itemName.." at "..position)
			end
		else
			-- chance failed, no more can appear
			break
		end
	end
end


-- return true if the special item name cannto play nice items that go on ledges or obstructions
function levelGenerator:isRestrictiveItem(special, item)
	return (special == "pole" or special == "deathslide" or special == "ropeswing" or special == "electricgate" or special == "multiroute")
	   and (item == "timebonus" or item == "randomizer" or item == "obstruction")
end


---------- GENERATION FUNCTIONS ----------


function levelGenerator:generateNextJump(elements, specialItems, position, isRouteEnd)
	local specialItem = specialItems[position][1]
	local obstacle    = nil
	local dir         = right

	if     specialItem == "pole"         then obstacle = self:newPole()
	elseif specialItem == "deathslide"   then obstacle = self:newDeathslide()
	elseif specialItem == "ropeswing"    then obstacle = self:newRopeSwing()
	elseif specialItem == "electricgate" then obstacle = self:newElectricGate()	end

	if obstacle then
		if obstacle.x < 0 then dir = left end

		-- ensure that if previous jump was obstacle then the next ledge is going the same way
		if self.lastJumpDir ~= dir then
			dir = self.lastJumpDir
			obstacle.x = -obstacle.x
		end

		elements[#elements+1] = obstacle
		if specialItem == "ropeswing" then
			elements[#elements+1] = self:pickRule("obstacles ropeswing scenery")
		end
	end

	local ledge = self:newLedge(specialItem, isRouteEnd)

	ledge.infinitePosition = self.infinitePosition + 1
	self.infinitePosition  = self.infinitePosition + 1

	if not obstacle and ledge.x < 0 then 
		dir = left 
	end

	self:repositionNextJump(ledge, specialItem, position, obstacle, dir)

	elements[#elements+1] = ledge
end


-- After a new jump is created, we modfy it based on if it was a special ledge or an obstacle was involved
function levelGenerator:repositionNextJump(ledge, specialItem, position, obstacle, dir)
	-- if previous obstacle was a pole or deathslide then set ledge X to 0 and Y must be > obstacle Y
	if specialItem == "pole" then
		ledge.x = 0
		if ledge.y < 150 then ledge.y = 150 end
	elseif specialItem == "deathslide" then
		ledge.x = 0
		if ledge.y < 300 then ledge.y = 300 end
	elseif specialItem == "ropeswing" then
		if dir == left then ledge.x = -400 else ledge.x = 400 end
		ledge.y = 200
	elseif specialItem == "electricgate" then
		if dir == left then ledge.x = -400 else ledge.x = 400 end
		ledge.y = 100
	else
		-- In climb chase we need to check if we are positioning a ledge over a previous one, and if so enforce a minimum height
		if (dir == right and self.lastJumpDir == left) or (dir == left and self.lastJumpDir == right) then
			if self.lastJumpHeight >= -200 and ledge.y >= -200 then
				ledge.y = -250
			end
		end
		-- ensure that if previous jump was obstacle then the next ledge is going the same way
		if self.lastIsObstacle and self.lastJumpDir ~= dir then
			ledge.x = -ledge.x
		end
	end

	-- record this ledges jump stats
	self.lastJumpDir = dir
	if obstacle then
		self.lastIsObstacle = true
		self.lastJumpHeight = obstacle.y
	else
		self.lastIsObstacle = false
		self.lastJumpHeight = ledge.y
	end

	if self.isClimbChase and position == 9 then
		ledge.size, ledge.surface, ledge.movement, ledge.invisible, ledge.rotation = "big", nil, nil, nil, nil
	end
end


-- Obstacles and special ledge types are not allowed as part of routes to avoid complications and impossible routes
function levelGenerator:generateRouteJump(elements, position, routeType, route)
	local ledge = self:newLedge()
	ledge.route = route
	ledge.infinitePosition = self.infinitePosition + 1
	self.infinitePosition  = self.infinitePosition + 1

	if routeType == "start" then
		if route == 1 then
			ledge.y = -250
		else
			ledge.y = 250
			ledge.positionFromLedge = self.lastJumpObject.id + position
		end
	elseif routeType == "end" then
		ledge.y = -250
	else
		ledge.y = 0
	end

	elements[#elements+1] = ledge
end


function levelGenerator:generateClimbRouteEnd(lastLedge)
	local preLastLedge = level:getLastLedge(1)
	-- set for left alignment
	local exitX  = -200
	local nextX  = 700
	local flip   = "x"
	local ufoDir = left
	local target = "ufoboss-"..globalInfiniteStage
	local color  = globalInfiniteStage + 1

	if preLastLedge:x() < lastLedge:x() then
		exitX  = 200
		nextX  = -700
		flip   = nil
		ufoDir = right
	end

	if color > blue then color = blue end

	local elements = {
		{object="scenery", type="climb-chase-exit", x=-100, theme="rocky", onLedge=true, flip=flip, layer=4},

		{object="ledge", type="finish", style="finish-middle", x=exitX, y=0, collideWithWarp=true},
	        {object="friend", x=0, y=-150, type="ufoboss", size=0.7, direction=ufoDir, layer=2, targetName=target, collideWithWarp=true,
	        	movement={speed=1, pause=10000, distance=10, pauseStyle=moveStyleWaveBig, pattern=movePatternVertical}
	        },

		{object="ledge", size="big", x=nextX, y=-250, climbChaseKiller=target},
			{object="rings", color=color, pattern={ {-35,-75}, {75,0} }}
	}

	level:appendElements(elements, lastLedge)
end


function levelGenerator:generateOtherElements(items, from, to, position)
	local itemsAt  = items[position]
	local num      = #itemsAt
	local elements = {}
	local deadly   = false

	if itemsAt then
		for i=1,num do
			local name   = itemsAt[i]
			local object = nil

			-- dont generate a deadly element at a position if one has already been created
			if not deadly or not self.deadlyElements[name] then
				if     name == "obstruction"       then object = self:newObstruction(from, to)
				elseif name == "timebonus"         then object = self:newTimeBonus(from, to)
				elseif name == "rings"             then object = self:newRings(from, to)
				elseif name == "randomizer"        then object = self:newRandomizer()
				elseif name == "emitter"           then object = self:newEmitter()
				elseif name == "enemy-brain"       then object = self:newEnemyBrain(from, to)
				elseif name == "enemy-heart"       then object = self:newEnemyHeart()
				elseif name == "enemy-stomach"     then object = self:newEnemyStomach()
				elseif name == "enemy-greyufo"     then object = self:newEnemyGreyUfo(from, to)
				elseif name == "enemy-greynapper"  then object = self:newEnemyGreyNapper()
				elseif name == "enemy-greyshooter" then object = self:newEnemyGreyShooter()
				elseif name == "warpfield"         then object = self:newWarpField(from, to)
				elseif sfind(name, "foreground-")  then object = self:newForegroundScenery(name, from) end

				if object then
					elements[#elements+1] = object
					deadly = self.deadlyElements[name]
				end
			end
		end
	end

	-- if from is a ledge with normal surface, see if we should generate random scenery on it
	if from.isLedge and (from.rotation == nil or from.rotation == 0) and not spineSurfaces[from.surface] and not from.rotating then
		self:newLedgeScenery(elements, from)
	end

	return elements
end


-------------- POSITIONERS ---------------


function levelGenerator:positionTrajectory(from, to, width, jump, arcPoint)
	-- assumes going to the right
	local jumpX, jumpY = from:rightEdge(), from:topEdge()

	if from:x() > to:x() then jumpX = from:leftEdge() end

	local velx, vely   = self.pathFinder:calcJumpToLedgeVelocity(from, to, self.scale, jump, 0)
	local xpos, ypos   = self.pathFinder:selectTrajectoryPoint(jumpX, jumpY, velx, vely, self.scale, arcPoint)

	-- sanity positioning so wont go below target ledge:
	local ylimit = to:topEdge() - 80
	if ypos > ylimit then ypos = ylimit	end

	-- localise offset from global coords (taking width of bonus into account)
	return (xpos - jumpX) + (width * self.scale),
		   (ypos - jumpY) + (width * self.scale)
end


------------- GENERAL GENERATORS ---------------


-- generate movement properties and apply to an object
function levelGenerator:genMovement(object, ruleNamespace, reverse, dontDraw, moveStyle, pauseStyle, flipX, flipY)
	local pattern  = self:percentRule(ruleNamespace.." pattern")
	local distance = self:randomRule(ruleNamespace.." range", 100)
	local speed    = self:randomRule(ruleNamespace.." speed", 1)
	local pause    = self:randomRule(ruleNamespace.." pause", 0)
	local steering, distMaxX, distMaxY, origPattern = nil, nil, nil, pattern

	-- some elements use range for their distance others distance - try range first
	if not distance then
		distance = self:randomRule(ruleNamespace.." distance")
	end

	if not reverse then
		-- one way patterns need to have revesre set on them or the element will keep moving away from their origin
		if pattern == moveTemplateVertical or pattern == moveTemplateHorizontal or pattern == moveTemplateDiagonalUp or pattern == moveTemplateSlantedUp or pattern == moveTemplateLeanedUp then
			reverse = true
		end
	end

	if pattern ~= movePatternHorizontal and pattern ~= movePatternVertical and pattern ~= movePatternFollow and pattern ~= movePatterCircular then
		distMaxX, distMaxY = getMovementDistance(pattern, distance)
    	pattern  = parseMovementPattern(pattern, distance, flipX)
    	steering = self:pickRule(ruleNamespace.." steering")
    end

    if pattern then
	    object.movement = {
	    	pattern    = pattern,
	    	speed      = speed,
	    	distance   = distance,
	    	distMaxX   = distMaxX,
	    	distMaxY   = distMaxY,
	    	pause      = pause,
	    	steering   = steering,
	    	reverse    = reverse,
	    	dontDraw   = dontDraw,
	    	moveStyle  = moveStyle,
	    	pauseStyle = pauseStyle
		}
	end

	if pattern == movePatternFollow then
		object.movement.followXOnly = self:percentRule(ruleNamespace.." followXOnly")
		object.movement.followYOnly = self:percentRule(ruleNamespace.." followYOnly")
	end

	-- return original pattern passed (before modification so we can check)
	return origPattern
end


-- generate invisibility from gen rules and apply to object
function levelGenerator:genInvisible(object, ruleNamespace)
	if self:pickRule(ruleNamespace) then
	    object.invisible = {
	    	invisibleFor = self:randomRule(ruleNamespace.." invisibleFor"),
	    	visisbleFor  = self:randomRule(ruleNamespace.." visibleFor"),
	    	fadeFor      = self:randomRule(ruleNamespace.." fadeFor"),
	    	alpha        = self:randomRule(ruleNamespace.." alpha"),
	    }
	end
end


-- generate darken or rgb properties from gen rules
function levelGenerator:genDarkenRgb(ruleNamespace)
	local darkenRule  = self:pickRule(ruleNamespace.." darken")
	local rgbRule     = self:pickRule(ruleNamespace.." rgb")
	local darken, rgb = nil, nil

	if darkenRule then
		darken = math_random(darkenRule[1], darkenRule[2])
	end

	if rgbRule then
		rgb = {
			[1]=math_random(rgbRule.red[1],   rgbRule.red[2]), 
			[2]=math_random(rgbRule.green[1], rgbRule.green[2]), 
			[3]=math_random(rgbRule.blue[1],  rgbRule.blue[2])
		}
	end
	return darken, rgb
end


-- generates position between two ledges
function levelGenerator:genXPosition(from, to, offsetX)
	-- we go right IF: the next jump is to the right
	-- we go left  IF: the next jump is to the left
	-- IF: we have switched ledge directions then we have to go the opposite side to avoid blocking 
	if (from:x() < to:x() and not self.lastJumpFlipped) or (from:x() > to:x() and self.lastJumpFlipped) then
		local gap = to:leftEdge() - from:rightEdge()
		return from:width()/2 + gap/2 + offsetX, right
	else
		local gap = from:leftEdge() - to:rightEdge()
		return -from:width()/2 - gap/2 - offsetX, left
	end
end


function levelGenerator:genYPosition(from, to, offsetY)
	if from:topEdge() < to:topEdge() then
		return to:topEdge() - from:topEdge() + offsetY
	else
		return from:topEdge() - to:topEdge() + offsetY
	end
end


function levelGenerator:genGapX(from, to)
	if from:x() < to:x() then
		return to:leftEdge() - from:rightEdge(), right
	else
		return from:leftEdge() - to:rightEdge(), left
	end
end


-- Load functions to generate specific objects from another file (too large otherwise)
objectsLoader:load(levelGenerator, level)


return levelGenerator