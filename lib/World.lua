local Llama = require(script.Parent.Parent.Llama)
local Archetype = require(script.Parent.Archetype)
local Iterator = require(script.Parent.Iterator)
local TopoRuntime = require(script.Parent.TopoRuntime)

local archetypeOfDict = Archetype.archetypeOfDict
local archetypeOf = Archetype.archetypeOf
local areArchetypesCompatible = Archetype.areArchetypesCompatible

local ERROR_NO_ENTITY = "Entity doesn't exist, use world:contains to check before inserting"

local function keyByMetatable(list)
	local result = {}

	for index, entry in ipairs(list) do
		if typeof(entry) ~= "table" then
			error(("Non-table in list at index %d"):format(index))
		end

		local metatable = getmetatable(entry)

		if metatable == nil then
			error(("Table in list at index %d does not have a metatable"):format(index))
		end

		if result[metatable] ~= nil then
			error(
				("Two tables with the same metatable appear twice in this list, duplicate found at index %d"):format(
					index
				)
			)
		end

		result[metatable] = entry
	end

	return result
end

local World = {}
World.__index = World

function World.new()
	return setmetatable({
		_archetypes = {},
		_entityArchetypes = {},
		_queryCache = {},
		_nextId = 0,
		_size = 0,
		_changedStorage = {},
	}, World)
end

function World:spawn(...)
	local id = self._nextId
	self._nextId += 1
	self._size += 1

	return self:replace(id, ...)
end

function World:_newQueryArchetype(queryArchetype)
	if self._queryCache[queryArchetype] == nil then
		self._queryCache[queryArchetype] = {}
	else
		return -- Archetype isn't actually new
	end

	for entityArchetype in pairs(self._archetypes) do
		if areArchetypesCompatible(queryArchetype, entityArchetype) then
			self._queryCache[queryArchetype][entityArchetype] = true
		end
	end
end

function World:_updateQueryCache(entityArchetype)
	for queryArchetype, compatibileArchetypes in pairs(self._queryCache) do
		if areArchetypesCompatible(queryArchetype, entityArchetype) then
			compatibileArchetypes[entityArchetype] = true
		end
	end
end

function World:_transitionArchetype(id, components)
	local newArchetype
	local oldArchetype = self._entityArchetypes[id]

	local oldComponents
	if oldArchetype then
		oldComponents = self._archetypes[oldArchetype][id]
		self._archetypes[oldArchetype][id] = nil

		-- Keep archetypes around because they're likely to exist again in the future
	end

	if components then
		newArchetype = archetypeOfDict(components)

		for metatable in pairs(components) do
			local old = oldComponents and oldComponents[metatable]
			local new = components[metatable]

			if old ~= new then
				self:_trackChanged(metatable, id, old, new)
			end
		end
	end

	if oldComponents then
		for metatable in pairs(oldComponents) do
			if components and components[metatable] then
				continue
			end

			self:_trackChanged(metatable, id, oldComponents[metatable], nil)
		end
	end

	if newArchetype then
		if self._archetypes[newArchetype] == nil then
			self._archetypes[newArchetype] = {}

			self:_updateQueryCache(newArchetype)
		end

		self._archetypes[newArchetype][id] = components
	end

	self._entityArchetypes[id] = newArchetype
end

function World:replace(id, ...)
	local components = keyByMetatable({ ... })

	self:_transitionArchetype(id, components)

	return id
end

function World:despawn(id)
	self:_transitionArchetype(id, nil)

	self._size -= 1
end

function World:clear()
	self._entityArchetypes = {}
	self._archetypes = {}
	self._size = 0
end

function World:contains(id)
	return self._entityArchetypes[id] ~= nil
end

function World:get(id, ...)
	local archetype = self._entityArchetypes[id]
	local entity = self._archetypes[archetype][id]

	local length = select("#", ...)

	if length == 1 then
		return entity[...]
	end

	local components = {}
	for i = 1, length do
		components[i] = entity[select(i, ...)]
	end

	return unpack(components, 1, length)
end

function World:_getListOfCompatibleMaps(archetype)
	debug.profilebegin("World:_getListOfCompatibleMaps")

	if self._queryCache[archetype] == nil then
		self:_newQueryArchetype(archetype)
	end

	local compatibleArchetypes = self._queryCache[archetype]

	if compatibleArchetypes == nil then
		error(("No archetype compatibility information for %s"):format(archetype))
	end

	local listOfMaps = {}

	for targetArchetype, map in pairs(self._archetypes) do
		if compatibleArchetypes[targetArchetype] then
			table.insert(listOfMaps, map)
		end
	end

	debug.profileend()
	return listOfMaps
end

function World:query(...)
	debug.profilebegin("World:query")
	local metatables = { ... }

	local listOfMaps = self:_getListOfCompatibleMaps(archetypeOf(metatables))

	debug.profileend()
	return Iterator.fromListOfMaps(listOfMaps, metatables)
end

function World:queryChanged(metatable, empty)
	assert(empty == nil, "queryChanged does not take additional parameters")

	local hookState = TopoRuntime.useHookState(metatable)

	if not hookState.storage then
		if not self._changedStorage[metatable] then
			self._changedStorage[metatable] = {}
		end

		local storage = {}
		hookState.storage = storage

		table.insert(self._changedStorage[metatable], storage)
	end

	return function()
		local index, value = next(hookState.storage)

		if index then
			hookState.storage[index] = nil

			return index, value
		end
	end
end

function World:_trackChanged(metatable, id, old, new)
	if not self._changedStorage[metatable] then
		return
	end

	local record = table.freeze({
		old = old,
		new = new,
	})

	for _, storage in ipairs(self._changedStorage[metatable]) do
		storage[id] = record
	end
end

function World:insert(id, ...)
	if not self:contains(id) then
		error(ERROR_NO_ENTITY, 2)
	end

	local existingComponents = self._archetypes[self._entityArchetypes[id]][id]

	self:_transitionArchetype(id, Llama.Dictionary.merge(existingComponents, keyByMetatable({ ... })))
end

function World:remove(id, ...)
	if not self:contains(id) then
		error(ERROR_NO_ENTITY, 2)
	end

	local toRemove = Llama.List.toSet({ ... })

	local existingComponents = self._archetypes[self._entityArchetypes[id]][id]

	local newComponents = {}
	local removed = {}

	for metatable, value in pairs(existingComponents) do
		if toRemove[metatable] then
			removed[metatable] = value
		else
			newComponents[metatable] = value
		end
	end

	self:_transitionArchetype(id, newComponents)

	return removed
end

function World:size()
	return self._size
end

return World
