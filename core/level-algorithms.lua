local lfs     = require("lfs")
local utils   = require("core.utils")
local builder = require("level-objects.builders.builder")


local generator = {
	output = "",
	nested = 0,
	orders = {
		[1] = {"name", "timeBonusSeconds", "floor", "ceiling", "defaultLedgeSize", "playerStart", "aiRace", "lavaChase", "startAtNight", "turnDay", "startLedge", "backgroundOrder", "elements"},
		[3] = {"object", "x", "y", "type", "size"}
	},
	order  = nil,
	rewrite = {
		"name             ", 
		"timeBonusSeconds ", 
		"floor            ", 
		"ceiling          ", 
		"defaultLedgeSize ", 
		"playerStart      ", 
		"aiRace           ", 
		"lavaChase        ", 
		"startAtNight     ", 
		"turnDay          ", 
		"startLedge       ",
		"backgroundOrder  ", 
		"elements "
	},
	inElements = false,
	nestedElements = {"scenery", "wall", "spike", "rings", "gear", "negable", "randomizer", "friend", "enemy", "emitter", "livebgr", "warpfield"}
}


--[[
	Problems needing a decision on
	==============================
	1. Deathslides need some extra logic
	2. Poles may need extra logic
	3. Movement patterns are not reversed
	4. Floor and Ceiling are not modified to cater for switch in Y axis
	5. Any value that matches an int constant (eg color) will show the int value rather than the constant name
]]


-- local functions

local function keyCompare(a, b)
	local indexA = table.indexOf(generator.order, a)
	local indexB = table.indexOf(generator.order, b)

	if indexA and indexB then
		return indexA < indexB
	elseif indexA then
		return true
	else
		return false
	end
end


local function keyCompareGeneral(a, b)
	if type(a) ~= type(b) then
		return false
	else
		return a < b
	end
end


local function add(value)
	generator.output = generator.output..value
end


-- Member functions

function generator:run(algorithm)
	if algorithm == "reverse" then
		self:runReverseAlgorithm()
	else
		print("Unrecognised algorithm: "..algorithm)
	end
end


function generator:runReverseAlgorithm()
	local planet   = state.data.planetSelected
	local zone     = state.data.zoneSelected
	local pathIn   = "levels.planet"..planet..".zone"..zone
    local pathOut  = system.pathForFile("reverse_planet"..planet.."_zone"..zone..".lua", system.DocumentsDirectory)
	local level    = require(pathIn)
	local modified = self:modifyForReverse(level)

	self:makeOutput(modified)
	print(self.output)

	local file, errorString = io.open(pathOut, "w")

	if not file then
		print("Error saving recorder data to file: "..pathOut.." "..errorString)
	else
		file:write("levelData = ")
		file:write(self.output)
		file:write("\nreturn levelData")
		io.close(file)
	end
end


function generator:modifyForReverse(data)
	local srcElements  = data.elements
	local newElements  = {}
	local elementCache = {}
	local finishLedge  = builder:newClone(srcElements[#srcElements])
	
	-- 1. Copy start ledge as is
	table.insert(newElements, builder:newClone(srcElements[1]))

	for i=#srcElements-1, 2, -1 do
		local element = builder:newClone(srcElements[i])
		local object  = element.object

		if object == "ledge" or object == "obstacle" then
			-- when we hit a jump object - we add it then everything from the cache (in reverse [so keeping original non ump order for easier comparison - doesnt make a difference])
			-- also reverse y to show reverse 
			if element.y then element.y = - element.y end

			table.insert(newElements, element)

			for x=#elementCache, 1, -1 do
				table.insert(newElements, builder:newClone(elementCache[x]))
			end

			elementCache = {}
		else
			-- when we hit a non jumpObject, we store it up, so that we add it AFTER the next jumpObject we come accross - this keeps the elements based on the ledge the same
			table.insert(elementCache, element)
		end
	end

	-- X. Add finish ledge to the end
	table.insert(newElements, builder:newClone(finishLedge))

	-- X. Replace original elements with new ones
	data.elements = newElements

	return data
end


function generator:makeOutput(data)
    local dataType = type(data)
    
    if dataType == 'table' then
    	self.nested = self.nested + 1

    	self:makeOutputTable(data)

        self.nested = self.nested - 1

    elseif dataType == "string" then
    	add("\""..data.."\"")
    else
    	add(tostring(data))
    end
end


function generator:makeOutputTable(data)
	self:makeOutputTableStart(data)

    local sep        = false
    local sortedKeys = self:sortKeys(data)

    for i=1, #sortedKeys do
    	local key   = sortedKeys[i]
    	local value = data[key]

    	if sep then
    		add(", ")

    		if self.nested <= 2 then
    			add("\n")
    			self:indent()
    		end
    	end

    	if type(key) == "string" then
    		add(key.."=")
    	end

    	self:makeOutput(value)

    	sep = true
    end

    self:makeOutputTableEnd(data)
end


function generator:makeOutputTableStart(data)
	local object = data.object

	if object == "ledge" or object == "obstacle" then
		add("\n")
		self:indent(self.nested-1)

	elseif object == "emitter" then
		add("\n")
		self:indent(self.nested)

	elseif table.indexOf(self.nestedElements, object) then
		add("    ")
	end

	add("{")

    if self.nested <= 2 then
    	add("\n")
    	self:indent()
    end
end


function generator:makeOutputTableEnd()
    add("}")

    if self.nested <= 2 then
    	add("\n")
    end
end


function generator:indent(num)
	local val = num or self.nested

    for i=1, val do
    	add("    ")
    end
end


function generator:sortKeys(array)
	local keys = {}

	for key in pairs(array) do
		table.insert(keys, key)
	end

	if self.nested == 1 or self.nested == 3 then
		self.order = self.orders[self.nested]

		table.sort(keys, keyCompare)
	else
		print("nested="..self.nested)
		for k in pairs(keys) do print(k..", ") end

		table.sort(keys, keyCompareGeneral)
	end

	return keys
end


return generator