-- A listing of each physics objects groupIndex filter: objects with the same negative groupIndex NEVER collide
-- 
-- player: 			  	 groupIndex= -2
-- player (shielded): 	 groupIndex= -3  (wont collide with enemies)
-- player (on obstacle): groupIndex= -5  (wont collide with any ledges while hanging)
-- pathfinder shot:   	 groupIndex= -2  (wont collide with other players)
-- enemy:			  	 groupIndex= -3
-- fuzzy friend:      	 groupIndex= -4
-- ledge:             	 groupIndex= -5


-- A listing of ALL the attributes that can be set for a zone and ALL the options for each type of element
-- * before an element means the attribute is required

local levelData = {
	-- REQUIRED zone attributes
   *name				-- name of the zone as displayed in zone select and various screens
   *tip					-- tip that appears in zone select and if player dies
   *timeBonusSeconds	-- number seconds to complete the zone in for TimeBonus games
   *backgroundOrder		-- lists which background images appear where

    -- OPTIONAL zone attributes that have a defualt value in the planet.lua - only add to override for the zone
    floor               -- bottom height for the zone
    ceiling             -- top height for the zone
    defaultLedgeSize    -- default ledge size if not specified
    defaultRingColor    -- default ring colour if not specified
    defaultLedgeSurface -- default ledge surface if not specified
    defaultLedgePoints  -- default ledge points if not specified
    backgroundSounds	-- replace planet default background sounds with a specific list

    -- OPTIONAL attributes that have no default value
    playerStart  		-- player start sequence (e.g. playerStartWalk, playerStartFall)
    startLedge       	-- debugging: which ledge the player starts on
    turnNight			-- set true to turn background to night when day
    turnDay				-- set true to turn background to day when night
    startAtNight		-- start background at night


    -- COMMON element attributes
   *object			-- broad object category: ledge, obstacle, scenery, spike, wall, rings, enemy, friend, gear, negable, randomizer, emitter
    x				-- X offset from previous ledge or obstacle
    y				-- Y offset from previous ledge or obstacle
    type			-- defines the specific type of object of its category
    layer			-- overrides the default layer the object type is normmaly assigned to
    direction		-- left or right for the starting direction of the element
    flip			-- "x" to flip on X axis, "y" to flip on Y axis
    rotation		-- rotates clockwise for positive and anto for negative
    onLedge			-- usable for all but ledges and obstacles: set true to attach the element to the ledge instead of being seperate
    storyModeOnly 	-- true if the element should only be loaded in story mode and is absent in all other modes
    alwaysAnimate   -- set true to make a spine object always animate even if its center is off screen (useful for warpfield)

    -- MOVING elements
    movement={
       *pattern={ 	-- either predefined movement: movePatternHorizontal, movePatternVertical, movePatternFollow, movePatternCircular
    		{		-- or set of points, each containing:
		   *[1]		-- first element (unamed)  is distance to move along X axis
    	   *[2]		-- second element (unamed) is distance to move along Y axis
    		pause   -- amount of time in milliseconds to wait when element reaches the point in [1],[2]
    		speed   -- change speed to new value from that set in movement {} tag
    		}, ...
    	}
       *speed       -- amount elements moves per frame
    	pause       -- time in milliseconds to wait when reaching each point in the pattern
    	reverse     -- true if element should revesre the pattern when reaching the end
    	oneWay		-- true if element should stop when its completes the pattern
    	distance	-- shorthand for specifying how far to move for movePatternHorizontal, movePatternVertical or movePatternCircular
    	moveStyle   -- adjusts the movement to look more natural when moving such as wave or swing
    	pauseStyle  -- when element is paused, adjusts movement to avoid them appearing completely still
    	logMovement	-- true to store how far element has moved in movedX and movedY attributes
    	arcStart	-- for movePatternCircular: start angle (degrees)
    	arc			-- for movePatternCircular: how far to swing (degrees) from arcStart
    	dontDraw    -- true to not draw the movement path
    	stagger     -- true used for ring movement to allow each ring in pattern to start at different movement position
    	followXOnly -- if true when movement set to follow movePatternFollow - item only follows on the X axis
    	followYOnly -- if true when movement set to follow movePatternFollow - item only follows on the Y axis
    	isTemplate  -- true if the pattern specified is a movement template and needs to be run through the parser: distance is also required
    	steering = {-- optional method of smoothing out element movement between points
    		radius  -- integer - distance from point where reaching point is considered success
    		cap     -- float   - limit put on steering adjustment to velocity per frame (higher=faster steering, lower=slower steering)
    		mass    -- float   - higher=slower steering, lower=faster steering
    	}
    }

    -- BEHAVIOUR for elements with a personality
    behaviour = {
       *mode 		-- starting state
    	awaken		-- number of ledges from starting ledge element will activate (awaken) at: 0=source ledge, 1=1 ledge either side etc
    	range       -- number of ledges from starting ledge element will behave as normal (eg. followPlayer). 1=1 ledge either side from from start etc
    	atRange     -- state element changes to when it reaches its range
    	thefts		-- for enemies that steal: max items they can steal before they stop
	}

	-- SHOOTERS 
	shooting = {
	   *velocity={	-- specifies the velocity variance
	   	   *varyX	-- amount to vary X velocity by randomly
	   	   *varyY   -- amount to vary Y velocity by randomly
	   	}
	   *ammo        -- lists of elements it will fire: negXXX (for negable), gearXXX (for gear)
		minWait		-- minimum seconds to wait before being able to fire again
		maxWait     -- maximum seconds to wait before firing again
		itemsMax    -- number of shots that can exist (not destroyed). If reached, element will stop firing
	}


	-- LEDGES
	type				-- "start", "checkpoint" or "finish"
	surface 			-- surface stats overrides zone/planet defaults
	size            	-- ledge size
	points          	-- number of points for a successful jump
	positionFromCenter 	-- normally a ledge is positioned from the edge of the previous, this allows to position from center (used for overlaps)
	positionFromLedge  	-- normally a ledge is positioned from previous, this allows to position from a specific ledgeId instead
	shape           	-- defines the physics shape
	invisible = {       -- set for invisible ledges
		invisibleFor	-- time in milliseconds to stay invislbe for
	  	visibleFor      -- time in milliseconds to stay visible for
	  	fadeFor         -- time in milliseconds to transition invisible ledge
	  	alpha           -- max visibility for invisible ledge
	}
	rotating = {
		limit			-- max angle to rotate by
		speed           -- speed of rotation defaults to 25
		delay           -- time before rotation starts defaults to 0
	}        	
	canShake        	-- set false to not shake when jumped on
	timerOff			-- for deadly ledges: amount of time ledge stays non-deadly
	timerOn         	-- for deadly ledges: amount of time ledge stays deadly
	dontReset			-- set to true to stop a ledge from being reset
	destroyAfter        -- ledge will be removed from the level after the player jumps - attributes specifies the time after jump before the ledge is destroyed
	triggerLedgeIds 	-- list of ledge IDs that will have their ledge:trigger() function called when player lands on this ledge
	triggerObstacleIds  -- list of obstacle IDs that will have their obstacle:trigger() function when player lands on this ledge
	triggerLock         -- used when a triggerLedge requires certain keys to unlock and apply the triggers - a list of key colours required to unlock
	triggerEvent        -- custom event that occurs when another ledge calls trigger() on this ledge - this function is called instead of the default trigger()
	keylock             -- add to stick a keylock on the ledge: attribute lists the color key required (eg. "Red")

	-- OBSTACLES
   *type				-- "deathslide", "pole", "ropeswing"
   *length              -- for pole: length of pole, for deathslide: {[1]=length X axis, [2]=length Y axis}, for ropeswing: length of rope from center
	sticky              -- for pole: true to make pole sticky
	startAnimation      -- for deathslide: animation to trigger when the obstacle is activated
	animSpeed			-- for deathslide "SLOW", "MEDIUM", "FAST"
	speed 				-- for deathslide: speed of movement (instead of providing in movement={})
	triggerEvent        -- custom event that occurs when another ledge calls trigger() on this ledge - this function is called instead of the default trigger()
	timerOff			-- for deadly obstacles: amount of time ledge stays non-deadly
	timerOn         	-- for deadly obstacles: amount of time ledge stays deadly
	antishield			-- for electric gates: gate will kill player even if using a shield

	-- SPACE ROCKET OBSTACLE
	angle               -- angle of rocket
	takeoff             -- how quickly the countdown starts once landed: fast, medium or slow
	force 				-- {x, y} force 
	rotation = {        -- determines how the rocket rotates once flying
		time 			-- number if milliseconds before angle is changed
		degrees 		-- amount angle is changed each time
	}

	-- SCENERY, WALLS, SPIKES
   *type				-- image name to load
	size				-- amount to scale image by
	alpha				-- image alphs to set
	darken				-- amount to darken image by
	rgb					-- {[1],[2],[3]} color mask to apply over image
	copy 				-- number of times to repeat the element on the X axis (directly after the previous by default)
	gap 				-- if copy set, gap between each copy on X axis
	fixFloor 			-- true to fix element to the zone floor
	fixSky 				-- true to fix element to the zone ceiling
	physics = {			-- ability to specify custom physics attributes
		shape 			-- specifies the physics shape as a list of {[1],[2]} X/Y points OR use "circle"
		shapeOffset		-- instead of specifying shape, this uses default image shape but lists adjustments to each edge: eg. {top: x, bottom: x, left: x, right: x}
		body			-- physics body type eg. dynamic
		bounce			-- amount of bounce
		friction		-- amount of friction
		density			-- amount of density			
	}

	-- RINGS
	color 				-- color of the ring, overrides zone/planet default
	trajectory = {		-- specifies rings are in a jump trajectory layout
	   *x 				-- X offset from ledge / obstacle 
	   *y 				-- Y offset from ledge / obstacle
	   *xforce 			-- X velocity for trajectory
	   *yforce 			-- Y velocity for trajectory
	   *arc 			-- length of the trjectory. arc=number points along curve
	   *num 			-- number of rings along trajectory
	}
	pattern={ 			-- specifies rings are in a set pattern, with a list of ring positions - each entry defines a ring in the set
		{
	    *[1]			-- X offset from ledge (for first entry) or previous ring
	    *[2]			-- Y offset from ledge (for first entry) or previous ring
		color 			-- specify a specific color for a given ring in the set
		}, ...
	}

	-- GEAR, NEGABLES
   *type				-- the constant for the item (eg. gearGloves, negDizzy). TODO: rename to type for consistancy with other elements
    regenerate 			-- for gear: true to regenerate it when player dies

	-- RANDOMIZERS
   *items 				-- list of items that can be generated, using the index as % change: eg. {[40]=gearGloves, [60]=aqua, [100]=negDizzy}
   						-- which means: 40% chance of gearGloves, 20% chance of aqua ring, 40% chance negDizzy

   	-- KEYS
   *color 				-- string color (first letter uppercase)

   -- TIME BONUS
   bonus 				-- time added in seconds (defaults to 10)

   -- WARP FIELD
   size 				-- int scale of visible image with 1 being normal
   radius 				-- radius of gravity effect

	-- EMITTERS
   *timer 				-- time in milliseconds between each elemen this element emits OR random range with {minValue, maxValue}
   *force = { 			-- velocity specified for each item emitted
   		[1] 			-- int X velocity OR random range with {minValue, maxValue}
   		[2]				-- int Y velocity OR random range with {minValue, maxValue}
   		[3]				-- int angle shot at OR OR random range with {minValue, maxValue}
   } 				
   *item 				-- definition of the item emitted with a full sub element spec in {}
	limit 				-- max number of elements this emitter can have bount at any one time

	-- FRIENDS
   *type				-- "fuzzy" or "ufoboss"
    size 				-- amount to scale image by
    color 				-- for fuzzy: color
    kinetic 			-- for fuzzy: movement type = "bounce", "hang", "hangDouble" 
    racer 				-- true if friend is racing player in zone
    loseAction 			-- if racer set, action to take when player wins
    noSound 			-- true if element should make no sound
    hasPassenger 		-- for ufoboss: deterines the model for the passenger
    animation 			-- for ufoboss: animation to use when stationary

	-- ENEMIES
   *type				-- "brain", "stomach", "heart"
    size                -- amount to scale image by
    color 				-- spine skin color to use
    spineDelay 			-- time in miliseonds to delay spine animation, so that multiples of same type dont animate identically


	-- AI SPECIAL ATTRIBUTES that can be applied to various elements to instruct AIs. TODO: All AI attributes are encapsulated by ai={}
	ai = {
		collect 		-- for gear, negables, rings: EITHER true to make ai walk to collect item on ledge OR % chance ai should get (eg. get=50 for 50%)
		ignore 			-- for ledges, obstacles: EITHER true to completly ignore element (not jump to) OR % chance ai should ignore (eg. ignore=50 for 50%)
		nextJump = {    -- for ledges, obstacles: lists possible zoneRouteIndexes for next item to jump to, overriding the next one defined in the zone file
			[%]			-- % chance ai should make this entry the next item to jump to
			index,		-- zoneRouteIndex of the next item to jump to
			...
		}
		jumpAfter       -- for ledges, obstacles: time in milliseconds to perform jump or jump off, overriding AIs own logic
		jumpVelocity    -- for ledges: specifies velocity in format {[1]=xvel, [2]=yvel} to use for next jump, overrding AIs own logic
		loadGear 		-- for ledges, obstacles: specifies gear name to load when jumping from ledge
		useAirGearAfter -- for ledges, obstacles: list of time in milliseconds to activate air gear after the jump is made
		letGoAfter      -- for obstacles: time in milliseconds to let go of an obstacle after jumping for it (not grabbing it)
	}


}

return levelData