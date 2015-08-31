-- @class master collection is the holding place for a class of game objects (eg. ledges)
-- Each main class of objects will live in its own master collection, which is responsible for creating their id (when added), destroying and locating them.
-- An object can belong to many collections, but only one master collection - as it defines its id
local masterCollection = {
	
	-- reference to a global spine, so it can add objects to it
	spineCollection    = nil,
	-- reference to a global movement collection, so it can add objects to it
	movementCollection = nil,
	-- reference to a global particle emitter collection, so it can add objects to it
	particleEmitterCollection = nil,
	-- Methods:
	-----------
	-- *add()
	-- addToMaster()
	-- addToSpineCollection()
	-- addToMovementCollection()
	-- addToParticleEmitterCollection()
	-- *remove()
	-- +clear()
	-- +destroy()
}


-- Replaces collection.add() to add an object to this as its master and its reference collections
-- @param object to add
----
function masterCollection:add(object)
    self:addToMaster(object)
    self:addToSpineCollection(object)
    self:addToMovementCollection(object)
    self:addToParticleEmitterCollection(object)
end


-- Replace collection.add() to make this the objects master collection - so it defines the objects id
-- NOTE: An object can only belong to one master collection and they have a direct reference to it for shared properties
-- @param object to add
----
function masterCollection:addToMaster(object)
	local newId = #self.items + 1

	object:generateKey(newId)
	object.master = self

	self.items[newId] = object
end


-- Add object to the spine collection if required
-- @param @object to add
----
function masterCollection:addToSpineCollection(object)
    if object.isSpine then
        after(object.spineDelay or 0, function()
            self.spineCollection:add(object)
        end)
    end
end


-- Add object to the movement collection if required
-- @param object to add
----
function masterCollection:addToMovementCollection(object)
    if object.isMoving then
        after(object.movement.delay or 0, function()
            self.movementCollection:add(object)
        end)
    end
end


-- Add object to the particle emitter collection if required
-- @param object to add
----
function masterCollection:addToParticleEmitterCollection(object)
	if object.boundEmitter then
		self.particleEmitterCollection:add(object)
	end
end


-- Replace collection.remove() to remove an object from this collection and nil its master reference
-- @param object to remove
----
function masterCollection:remove(object)
	if object.master and object.master.name == self.name then
		-- instead of setting an element to nil, set to -1 as nil breaks usage of #
		self.items[object.id] = -1
		object.master = nil

	end
end


-- Overrides base clear() to nil refs and then call base clear
----
function masterCollection:clear()
    self.spineCollection    = nil
    self.movementCollection = nil
    self.particleEmitterCollection = nil
    self:baseClear()
end


-- Overrides base destroy() to nil refs and then call base destroy
----
function masterCollection:destroy()
    self.spineCollection    = nil
    self.movementCollection = nil
    self.particleEmitterCollection = nil
    self:baseDestroy()
end


return masterCollection