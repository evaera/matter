local Llama = require(script.Parent.Parent.Llama)
local Archetype = require(script.Parent.Archetype)
local Iterator = require(script.Parent.Iterator)

local archetypeOfDict = Archetype.archetypeOfDict
local archetypeOf = Archetype.archetypeOf
local getCompatibleArchetypes = Archetype.getCompatibleArchetypes

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
		_nextId = 0,
		_size = 0,
	}, World)
end

function World:spawn(components)
	local id = self._nextId
	self._nextId += 1
	self._size += 1

	return self:replaceSpawn(id, components)
end

function World:_transitionArchetype(id, components)
	local newArchetype
	local oldArchetype = self._entityArchetypes[id]

	if components then
		newArchetype = archetypeOfDict(components)
	end

	if oldArchetype then
		self._archetypes[oldArchetype][id] = nil

		if next(self._archetypes[oldArchetype]) == nil then
			self._archetypes[oldArchetype] = nil
		end
	end

	if newArchetype then
		if self._archetypes[newArchetype] == nil then
			self._archetypes[newArchetype] = {}
		end
		self._archetypes[newArchetype][id] = components
	end

	self._entityArchetypes[id] = newArchetype
end

function World:replaceSpawn(id, components)
	components = keyByMetatable(components or {})

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

function World:query(...)
	local metatables = { ... }

	local listOfMaps = getCompatibleArchetypes(archetypeOf(metatables), self._archetypes)

	return Iterator.fromListOfMaps(listOfMaps)
end

function World:insert(id, components)
	if not self:contains(id) then
		error(ERROR_NO_ENTITY)
	end

	local existingComponents = self._archetypes[self._entityArchetypes[id]][id]

	self:_transitionArchetype(id, Llama.Dictionary.merge(existingComponents, keyByMetatable(components)))
end

function World:insertOne(id, component)
	self:insert(id, { component })
end

function World:remove(id, metatables)
	if not self:contains(id) then
		error(ERROR_NO_ENTITY)
	end

	local toRemove = Llama.List.toSet(metatables)

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

function World:removeOne(id, metatable)
	self:remove(id, { metatable })
end

function World:size()
	return self._size
end

return World
