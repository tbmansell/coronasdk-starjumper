local object       = display.newImage("images/jump-grid-marker.png", 0,0)
object.speed       = 2
object.radius      = 50
object.mass        = 20
object.steeringCap = 3
object.target      = 0
object.currentVelX = 0
object.currentVelY = 0

local points = {
	{x=800, y=200},
	{x=300, y=50},
	{x=700, y=600},
	{x=500, y=550},
	{x=200, y=500},
	{x=400, y=300},
	{x=0,   y=0}
}

-- display points
for _,point in pairs(points) do
	local circle = display.newCircle(point.x, point.y, object.radius)
end


function distanceTo(from, to)
	return math.sqrt( (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y) )
end


function nextTarget(object)
	if object.target >= #points then
		object.target = 1
	else
		object.target = object.target + 1
	end

	object.dest = points[object.target]
	object.dist = distanceTo(object, object.dest)

	object.desiredVelX = (object.dest.x - object.x) / object.dist
	object.desiredVelY = (object.dest.y - object.y) / object.dist
end


function getTarget(object, points)
	object.dist = distanceTo(object, object.dest)

	if object.dist <= object.radius then
		nextTarget(object)
	end
end


function getSteering(object)
	local steeringX = object.desiredVelX - object.currentVelX
	local steeringY = object.desiredVelY - object.currentVelY
	local cap       = object.steeringCap

	steeringX = steeringX / object.mass
	steeringY = steeringY / object.mass

	if steeringX > cap then 
		steeringX = cap
	elseif steeringX < -cap then 
		steeringX = -cap 
	end

	if steeringY > cap then 
		steeringY = cap 
	elseif steeringY < -cap then 
		steeringY = -cap 
	end

	return steeringX, steeringY
end


function moveObject(object, points)
	getTarget(object, points)

	-- takes object straight along the desired path for every point
	--object.x = object.x + (object.desiredVelX * object.speed)
	--object.y = object.y + (object.desiredVelY * object.speed)

	local steeringX, steeringY = getSteering(object)

	object.currentVelX = object.currentVelX + steeringX
	object.currentVelY = object.currentVelY + steeringY

	object.x = object.x + (object.currentVelX * object.speed)
	object.y = object.y + (object.currentVelY * object.speed)
end



object:toFront()
nextTarget(object)

function enterFrame()
	moveObject(object, points)
end

Runtime:addEventListener("enterFrame", enterFrame)
