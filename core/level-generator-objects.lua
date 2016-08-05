local utils       = require("core.utils")
local pathLoader  = require("level-objects.path-finder")

-- Aliases
local math_random = math.random
local math_abs    = math.abs
local sfind       = string.find
local randomFrom  = utils.randomFrom
local percentFrom = utils.percentFrom
local firstFrom   = utils.firstFrom 

-- The main class: just a loader class
local newObjectsLoader = {}


function newObjectsLoader:load(levelGenerator)
	---------- CREATE NEW LEDGES ----------

	function levelGenerator:newLedge(specialType, isRouteEnd)
		local x 			= self:randomRule("ledges distance x", 200)
		local y 			= self:randomRule("ledges distance y", 0)
		local surface 		= self:percentRule("ledges surface")
		local rotated 		= self:percentRule("ledges rotated", 0)
		local rotating      = self:percentRule("ledges rotating")
		local isDeadlyTimed = deadlyTimedSurfaces[surface]
		local size, flip	= nil, nil

		-- IF specialType is not nil we CANT have a spine ledge (no moving, invisible spine ledges, no spine ledges after an obstacle)
		-- OR previous ledge was a deadly timed ledge - we cant have two together
		if (isDeadlyTimed and self.prevDeadlyTimed) or (specialType and spineSurfaces[surface]) then
			isDeadlyTimed = false
			surface       = nil
		end

		self.prevDeadlyTimed = isDeadlyTimed

		if not spineSurfaces[surface] then
			size = self:percentRule("ledges size") .. self:percentRule("ledges variation", "")
		end

		if math_random(100) > 50 then 
			flip = "x" 
		end

		if rotating then
			rotating = {limit=rotating, delay=math_random(10)}
		end

		local ledge = {object="ledge", x=x, y=y, size=size, surface=surface, rotation=rotated, rotating=rotating, flip=flip}

		self:setLedgeSurface(ledge)
		self:setLedgeSpecialType(ledge, specialType, isRouteEnd)

		if ledge.movement then
			self:setLedgeMovement(ledge)
		end

		return ledge
	end

	-- set ledge surface
	function levelGenerator:setLedgeSurface(ledge)
		local surface = ledge.surface

		if surface == electric then
			ledge.timerOn  = 2000
			ledge.timerOff = 4000
		elseif surface == spiked then
			ledge.timerOff = 4000
		elseif surface == ramp then
			-- direction?
		elseif surface == oneshot then
			ledge.size = medium
			ledge.destroyAfter = 300
		elseif surface == pulley then
			ledge.distance = self:percentRule("ledges pulley", 2000)
		end
	end

	-- set ledge special types (invisible, moving, bobbing)
	function levelGenerator:setLedgeSpecialType(ledge, specialType, isRouteEnd)
		if specialType == "invisible" then
			self:genInvisible(ledge, "ledges special invisible")

		elseif specialType == "moving" and not isRouteEnd then
			self:genMovement(ledge, "ledges special moving", true, false, nil, nil, true)
		else
			if self:chanceRule("ledges bobbing chanceAll") then
				self:genMovement(ledge, "ledges bobbing", true, true, nil, nil, true)
			end
		end
	end

	-- set ledge movement fine tuning based on positions
	function levelGenerator:setLedgeMovement(ledge)
		local pattern, distance = ledge.movement.pattern, ledge.movement.distance
		local distX,   distY    = ledge.movement.distMaxX, ledge.movement.distMaxY

		local origX, origY = ledge.x, ledge.y

		if ledge.y < 0 then
			ledge.y = ledge.y - distY
		else
			ledge.y = ledge.y + distY
		end

		if ledge.x > 0 then
			ledge.x = ledge.x + distX/2
		end

		-- NOTE: moving ledges are always going to the right with this currnet logic
		-- sanity checks:
		if ledge.x + distX < 300 then ledge.x = distX + 300 end
		--if ledge.x > 500 then ledge.x = 500 end

		--print("ledge.x="..ledge.x.." ledge.y="..ledge.y.." origx="..origX.." origY="..origY.." distX="..distX.." distY="..distY.." distance="..distance.." self.lastJumpDir="..self.lastJumpDir)
	end


	---------- CREATE NEW OBSTCALES ----------

	function levelGenerator:newPole()
		local length = self:percentRule("obstacles pole length", 150)
		local xpos   = self:randomRule("obstacles pole distance x")
		local ypos   = -(length/2)

		return {object="obstacle", type="pole", x=xpos, y=ypos, length=length}
	end


	function levelGenerator:newDeathslide()
		local length = self:percentRule("obstacles deathslide length")
		local speed  = self:randomRule("obstacles deathslide speed")
		local xpos   = self:randomRule("obstacles deathslide distance x")
		local ypos   = self:randomRule("obstacles deathslide distance x")

		return {object="obstacle", type="deathslide", x=xpos, y=ypos, length=length, speed=speed}
	end


	function levelGenerator:newRopeSwing(dir)
		local length = self:randomRule("obstacles ropeswing length")
		local speed  = self:randomRule("obstacles ropeswing speed")
		local xpos   = self:randomRule("obstacles ropeswing distance x")
		local ypos   = self:randomRule("obstacles ropeswing distance y")

		return {object="obstacle", type="ropeswing", x=xpos, y=ypos, direction=right, length=length, movement={speed=speed, arcStart=230, arc=90}}
	end


	function levelGenerator:newElectricGate()
		local timer = self:randomRule("obstacles electricgate timer")
		local xpos  = self:randomRule("obstacles electricgate distance x")
		local ypos  = self:randomRule("obstacles electricgate distance y")

		return {object="obstacle", type="electricgate", x=xpos, y=ypos, timerOn=timer, timerOff=timer}
	end


	---------- CREATE NEW COLLECTABLES ----------

	function levelGenerator:newTimeBonus(from, to)
		local location = self:percentRule("objects timebonus location")

		if location == "onledge" or to == nil then
			return {object="timebonus", x=0, y=-80, onLedge=true}

		elseif location == "inair" then
			local jump = self:percentRule("objects timebonus inair jump")
			local arc  = self:randomRule("objects timebonus inair arc")
			local x, y = self:positionTrajectory(from, to, 20, jump, arc)
			return {object="timebonus", x=x, y=y}

		elseif location == "moving" then
			local object = {object="timebonus", x=0}
			self:genMovement(object, "objects timebonus moving", true, true, nil, nil, true)

			object.y = -object.movement.distance
			return object
		end
	end


	function levelGenerator:newRings(from, to)
		local color    = globalInfiniteStage
		local location = self:percentRule("objects rings location")
		local object   = nil
		local maxRings = 5

		if color    > #ringValuesClimbChase then color    = #ringValuesClimbChase end
		if maxRings > self.ringsRemaining   then maxRings = self.ringsRemaining end

		if maxRings and maxRings > 0 then
			local numRings = math_random(maxRings)

			if location == "onledge" or to == nil then
				local  pattern = nil
				if     numRings == 1 then pattern = { {0,-75} }  -- 1 ring: show in center ledge
				elseif numRings == 2 then pattern = { {0,-75}, {0,-75} }  -- 2 rings: show two vertically in center
				elseif numRings == 3 then pattern = { {-75,-100}, {75,-75}, {75,75} } -- 3 rings: triangle
				elseif numRings == 4 then pattern = { {-30,-75}, {0,-75}, {75,0}, {0,75} }  -- 4 rings: square
				elseif numRings == 5 then pattern = { {0,-75}, {0,-75}, {-75,0}, {75,-75}, {75,75} } -- 5 rings: show diamond with one ring in the center
				end

				object = {object="rings", color=color, pattern=pattern}
				
			elseif location == "inair" then
				local arc            = self:randomRule("objects rings inair arc")
				local jump           = self:percentRule("objects rings inair jump")
				local xpos, ypos     = 30, -100
				local forcex, forcey = self.pathFinder:calcJumpToLedgePull(from, to, self.scale, jump, 0)

				if from:x() > to:x() then xpos = -xpos end

				object = {object="rings", color=color, trajectory={x=xpos, y=ypos, xforce=forcex, yforce=math_abs(forcey), arc=arc, num=numRings} }
				
			elseif location == "moving" then
				-- todo
			end

			self.ringsRemaining = self.ringsRemaining - numRings
		end
		return object
	end


	function levelGenerator:newRandomizer()
		local items = self:pickRule("objects randomizer items")
		return {object="randomizer", onLedge=true, items=items}
	end


	function levelGenerator:newWarpField(from, to)
		-- dont allow warpfields on multi routes
		if from.route ~= to.route then return nil end

		local size   = self:randomRule("objects warpfield size")
		local radius = 350*(size/2)

		local xpos, ypos = self:positionWarpField(radius, from, to)

		return {object="warpfield", x=gapX, y=ypos, size=size, radius=radius}
	end

	-- position the warp field
	function levelGenerator:positionWarpField(radius, from, to)
		local xpos,_ = self:genXPosition(from, to, 0)
		local fromY  = from:topEdge()
		local toY    = to:topEdge()
		local gapX   = self:genGapX(from, to)
		local gapY   = math_abs(toY - fromY)
		local ypos   = 0

		-- place above highest ledge if on route 1 or gap too small or random chance if not route 2
		if from.route == 1 or gapX < (radius*2)+200 or (from.route ~= 2 and math_random(100) > 50) then
			-- top
			if fromY < toY then
				ypos = -math_abs(radius+250)
			else
				ypos = -math_abs(radius+250+(gapY/2))
			end
		else
			-- bottom
			if fromY >= toY then
				ypos = -(gapY/2)
			else
				ypos = radius/2
			end
		end

		return xpos, ypos
	end


	---------- CREATE NEW ENEMIES ----------

	function levelGenerator:newEnemyBrain(from, to)
		local xoffset    = self:randomRule( "objects enemy-brain distance x")
		local yoffset    = self:randomRule( "objects enemy-brain distance y")
		local color      = self:percentRule("objects enemy-brain color",  "Purple")
		local size       = self:percentRule("objects enemy-brain size",   0.5)
		local asleep     = self:pickRule(   "objects enemy-brain asleep", 0)
		local xpos, dir  = self:genXPosition(from, to, xoffset)
		local ypos       = self:genYPosition(from, to, yoffset)
		local gapX       = self:genGapX(from, to)
		local moveStyle  = math_random(moveStyleSway, moveStyleSwayBig)
		local pauseStyle = math_random(moveStyleSway, moveStyleSwayBig)
		local flipX      = false

		if dir == left then flipX = true end
		if gapX < 250  then xpos = xpos + 100 end

		local enemy = {object="enemy", type="brain", x=xpos, y=ypos, color=color, size=size}

		if math_random(100) <= asleep then
			enemy.behaviour = {mode=stateSleeping, awaken=0}
		end

		local pattern = self:genMovement(enemy, "objects enemy-brain moving", false, true, moveStyle, pauseStyle, flipX)

		if pattern == moveTemplateVertical then
			enemy.y = -(enemy.movement.distance * 2)
		end
		return enemy
	end


	function levelGenerator:newEnemyHeart()
		local xpos   	 = self:randomRule( "objects enemy-heart distance x")
		local ypos   	 = self:randomRule( "objects enemy-heart distance y")
		local color  	 = self:percentRule("objects enemy-heart color",  "Red")
		local size   	 = self:percentRule("objects enemy-heart size",   1)
		local range  	 = self:randomRule( "objects enemy-heart range",  4)
		local speed  	 = self:randomRule( "objects enemy-heart speed",  1)
		local pause  	 = self:randomRule( "objects enemy-heart pause",  0)
		local thefts 	 = self:randomRule( "objects enemy-heart thefts", 2)
		local moveStyle  = math_random(moveStyleWave, moveStyleWaveBig)
		local pauseStyle = math_random(moveStyleWave, moveStyleWaveBig)

		local enemy     = {object="enemy", type="heart", x=xpos, y=ypos, color=color, size=size}
		enemy.behaviour = {mode=stateSleeping, awaken=0, range=range, atRange=stateResetting, thefts=thefts}
		enemy.movement  = {pattern=movePatternFollow, speed=speed, pause=pause, moveStyle=moveStyle, pauseStyle=pauseStyle}
		return enemy
	end


	function levelGenerator:newEnemyStomach()
		local xpos   	 = self:randomRule( "objects enemy-stomach distance x")
		local ypos   	 = self:randomRule( "objects enemy-stomach distance y")
		local size   	 = self:percentRule("objects enemy-stomach size",     1)
		local range  	 = self:randomRule( "objects enemy-stomach range",    4)
		local speed  	 = self:randomRule( "objects enemy-stomach speed",    3)
		local pause  	 = self:randomRule( "objects enemy-stomach pause",    0)
		local ammo  	 = self:pickRule(   "objects enemy-stomach ammo")
		local moveType   = self:percentRule("objects enemy-stomach moveType", movePatternFollow)
		local moveStyle  = math_random(moveStyleSway, moveStyleSwayBig)
		local pauseStyle = math_random(moveStyleSway, moveStyleSwayBig)

		local enemy     = {object="enemy", type="stomach", x=xpos, y=ypos, size=size}
		enemy.shooting  = {minWait=1, maxWait=3, velocity={varyX=200, varyY=100}, itemsMax=3, ammo=ammo}
		enemy.behaviour = {mode=stateSleeping, awaken=range, range=range, atRange=stateResetting}
		enemy.movement  = {pattern=moveType, speed=speed, pause=pause, moveStyle=moveStyle, pauseStyle=pauseStyle}
		return enemy
	end


	function levelGenerator:newEnemyGreyUfo(from, to)
		local xoffset    = self:randomRule( "objects enemy-greyufo distance x")
		local yoffset    = self:randomRule( "objects enemy-greyufo distance y")
		local size       = self:percentRule("objects enemy-greyufo size", 0.7)
		local xpos, dir  = self:genXPosition(from, to, xoffset)
		local ypos       = self:genYPosition(from, to, yoffset)
		local gapX       = self:genGapX(from, to)

		if gapX < 250  then xpos = xpos + 100 end

		local enemy   = {object="enemy", type="greyufo", x=xpos, y=ypos, size=size}
		local pattern = self:genMovement(enemy, "objects enemy-greyufo moving", false, true, nil, nil, flipX)

		if pattern == moveTemplateVertical then
			enemy.y = -(enemy.movement.distance * 2)
		end
		return enemy
	end


	function levelGenerator:newEnemyGreyNapper()
		local xpos   	 = self:randomRule( "objects enemy-greynapper distance x")
		local ypos   	 = self:randomRule( "objects enemy-greynapper distance y")
		local size   	 = self:percentRule("objects enemy-greynapper size", 0.5)
		local pauseStyle = math_random(moveStyleWave, moveStyleWaveBig)
		local enemy      = {object="enemy", type="greynapper", skin="ring-stealer", x=xpos, y=ypos, size=size}
		--enemy.behaviour  = {mode=stateSleeping, awaken=5, range=5, atRange=stateResetting}
		
		self:genMovement(enemy, "objects enemy-greynapper moving", false, true, nil, pauseStyle)
		return enemy
	end


	function levelGenerator:newEnemyGreyShooter()
		local xpos   	 = self:randomRule( "objects enemy-greyshooter distance x")
		local ypos   	 = self:randomRule( "objects enemy-greyshooter distance y")
		local size   	 = self:percentRule("objects enemy-greyshooter size", 0.5)
		local ammo  	 = self:pickRule(   "objects enemy-greyshooter shooting ammo")
		local wait  	 = self:percentRule("objects enemy-greyshooter shooting wait")
		local velocity   = self:percentRule("objects enemy-greyshooter shooting velocity")
		local maxItems   = self:percentRule("objects enemy-greyshooter shooting maxItems")
		local pauseStyle = math_random(moveStyleWave, moveStyleWaveBig)

		local enemy    = {object="enemy", type="greyshooter", x=xpos, y=ypos, size=size}
		enemy.shooting = {minWait=wait[1], maxWait=wait[2], velocity={varyX=velocity[1], varyY=velocity[2]}, itemsMax=maxItems, ammo=ammo}
		--enemy.behaviour  = {mode=stateSleeping, awaken=5, range=5, atRange=stateResetting}
		
		self:genMovement(enemy, "objects enemy-greyshooter moving", false, true, nil, pauseStyle)
		return enemy
	end


	---------- CREATE NEW SCENERY ----------

	function levelGenerator:newObstruction(from, to)
		if not to or not from.isLedge or not to.isLedge or from.movement or to.movement or (tostring(from.route) ~= tostring(to.route)) then
			return nil
		end

		local objectName  = self:percentRule("objects obstruction physics")
		local item  	  = self:randomScenery(self.sceneryGeneration[objectName].images)
		local size 		  = item.size
		local shape 	  = item.shape
		local x, y, flip, abort = 0, 0, nil, false

		if self.isClimbChase then
			x, y, flip, abort = self:positionSwitchObstruction(from, to, item)
		else
			x, y, flip, abort = self:positionRightObstruction(from, to, item)
		end

		if abort then
			return nil
		end

		local phy = {shape=shape, shapeOffset=item.shapeOffset}
		if objectName == "wall" then phy.bounce = 1	end

		local object = {object=objectName, type=item.image, x=x, y=y, size=size, layer=2, flip=flip, physics=phy}

		if self:chanceRule("objects obstruction bobbing chanceAll") then
			self:genMovement(object, "objects obstruction bobbing", true, true)
		end

		return object
	end


	-- logic used when self.level allows switching jumps from right to left
	function levelGenerator:positionSwitchObstruction(from, to, item)
		local x, y, flip, abort, dir = 0, 0, nil, false, right

		if from:x() > to:x() then dir = left end

		if self.lastJumpFlipped then
			-- position object to the side that you dont jump to
			local xgap, ygap = math_random(10)*10, -(math_random(10)*10)

			if dir == right then
				x = -(from:width()/2) - item.width - xgap
			else
				x = (from:width()/2) + xgap
			end

			y = -(from:height()/2) - item.height + ygap

			if math_random(100) > 50 and item.flipTop and shape then
				flip  = "y"
				shape = reverseShape(shape)
			end
		else
			-- position obstruction at bottom
			local gapX, dir = self:genGapX(from, to)
			local gapY      = to:topEdge() - from:topEdge()
			local space     = gapX - (item.width*item.size)

			if space < 150 then
				abort = true
			end

			if dir == left then
				x = -(from:width()/2) - (gapX/2) - (item.width/2)
			else
				x = (from:width()/2) + (gapX/2) - (item.width/2)
			end

			--y = -(from:height()/2) - item.height
			y = (item.botPull or 0) + (gapY/2)

			if 	   gapX <= 200 then y = y -50
			elseif gapX <= 400 then y = y -100
			elseif gapX <= 500 then y = y -150
			elseif gapX >  500 then y = y -200 end
		end

		-- return the coordinates of the obstruction
		return x, y, flip, abort
	end


	-- logic used when a self.levels only has jumps to the right
	function levelGenerator:positionRightObstruction(from, to, item)
		local gapX, dir = self:genGapX(from, to)
		local gapY  = to:topEdge()  - from:topEdge()
		local space = gapX - (item.width*item.size)
		local route = from.route
		local x     = from:width()/2 + gapX/2 - item.width/2
		local y     = 0
		local flip  = nil

		-- force obstruction to the top if the gap is too small
		if route ~= 2 and (space < 200 or math_random(100) > 50) then
			-- top
			y = -item.height + (item.topPull or 0) + (gapY/2) - from:height()/2

			if 	   gapX <= 200 then y = y -250
			elseif gapX <= 400 then y = y -300
			elseif gapX <= 500 then y = y -350
			elseif gapX >  500 then y = y -400 end

			-- if flipTop set then reverse the physics shape
			if item.flipTop and shape then
				flip  = "y"
				shape = reverseShape(shape)
			end

		elseif route ~= 1 then
			-- bottom
			y = (item.botPull or 0) + (gapY/2)

			if 	   gapX <= 200 then y = y -50
			elseif gapX <= 400 then y = y -100
			elseif gapX <= 500 then y = y -150
			elseif gapX >  500 then y = y -200 end
		else
			-- dont generate the obstruction
			return 0,0,0,true
		end
		-- return the coordinates of the obstruction
		return x, y, flip, false
	end


	function levelGenerator:newForegroundScenery(name, from)
		-- dont put foreground scenery on top route
		if from.route == 1 then return nil end

		local gen    	  = self.sceneryGeneration.foreground[name]
		local item   	  = self:randomScenery(gen.images)
		local darken, rgb = self:genDarkenRgb("scenery foreground "..name)
		local image  	  = item.image
		local width  	  = item.width
		local height 	  = item.height
		local ypos   	  = -(height/2)
		local xpos   	  = 0

		if math_random(100) > 50 then
			ypos = ypos - math_random(height/3)
		else
			ypos = ypos + math_random(height/3)
		end

		return {object="scenery", type=image, x=xpos, y=ypos, alpha=0.85, darken=darken, rgb=rgb}
	end


	function levelGenerator:newLedgeScenery(elements, from)
		local gen = self.sceneryGeneration.ledge
		local num = #gen.chance

		-- limit # ledge scenery based on its size
		if     from.size == small    then num = 2
		elseif from.size == medsmall then num = 3
		elseif from.size == medium   then num = 4 end

		for i=1,num do
			if math_random(100) <= gen.chance[i] then
				local item        = self:randomScenery(gen.images)
				local layer       = math_random(2,4)
				local ypos        = -(item.height/2) - (from:height()/2) + 5
				local xpos        = math_random(from:width()/3)
				local size        = math_random(item.size[1], item.size[2]) / 10
				local darken, rgb = self:genDarkenRgb("scenery ledge")
				local flip        = nil

				if math_random(100) > 50 then xpos = -xpos end

				xpos = xpos - item.width/2
				ypos = ypos + item.height/2

				if math_random(100) > 50 then flip = "x" end

				elements[#elements+1] = {object="scenery", type=item.image, x=xpos, size=size, flip=flip, layer=layer, onLedge=true, darken=darken, rgb=rgb}
			else 
				break
			end
		end
	end


	function levelGenerator:newEmitter()
		local xpos   = self:randomRule("objects emitter distance x")
		local ypos   = self:randomRule("objects emitter distance y")
		local timer  = self:pickRule(  "objects emitter timer")
		local limit  = self:pickRule(  "objects emitter limit")
		local rforce = self:pickRule(  "objects emitter force")
		-- copy force as if we have to negate Y axis this would actually do it for the main reference
		local force  = { {rforce[1][1],rforce[1][2]}, {rforce[2][1],rforce[2][2]}, {rforce[3][1],rforce[3][2]} }

		-- if emitter y > 0 make y force negative (always specified positive)
		if ypos > 0 then
			force[2][1] = -force[2][1]
			force[2][2] = -force[2][2]
		end

		local ritems = self:pickRule("objects emitter items")
		local items  = {}

		for i=1, #ritems do
			local entry  = ritems[i]
			local chance = entry[1]
			local object = entry[2][1]
			local data   = self.sceneryDefs[entry[2][2]]
			local item   = {object=object, type=data.image, size=data.size, darken=data.darken, rgb=data.rgb, physics={body="kinematic", shape=data.shape, shapeOffset=data.shapeOffset} }

			items[#items+1] = {chance,item}
		end

		return {object="emitter", x=xpos, y=ypos, timer=timer, limit=limit, force=force, items=items}
	end

end


return newObjectsLoader