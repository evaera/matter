local archetypeModule = require(script.Parent.archetype)
local Component = require(script.Parent.component)

local assertValidComponent = Component.assertValidComponent
local archetypeOf = archetypeModule.archetypeOf

--[=[
	@class QueryResult

	A result from the [`World:query`](/api/World#query) function.

	Calling the table or the `next` method allows iteration over the results. Once all results have been returned, the
	QueryResult is exhausted and is no longer useful.

	```lua
	for id, enemy, charge, model in world:query(Enemy, Charge, Model) do
		-- Do something
	end
	```
]=]
local QueryResult = {}
QueryResult.__index = QueryResult

function QueryResult:__call()
	return self:_expand(self:_next())
end

--[=[
	Returns the next set of values from the query result. Once all results have been returned, the
	QueryResult is exhausted and is no longer useful.

	:::info
	This function is equivalent to calling the QueryResult as a function. When used in a for loop, this is implicitly
	done by the language itself.
	:::

	```lua
	-- Using world:query in this position will make Lua invoke the table as a function. This is conventional.
	for id, enemy, charge, model in world:query(Enemy, Charge, Model) do
		-- Do something
	end
	```

	If you wanted to iterate over the QueryResult without a for loop, it's recommended that you call `next` directly
	instead of calling the QueryResult as a function.
	```lua
	local id, enemy, charge, model = world:query(Enemy, Charge, Model):next()
	local id, enemy, charge, model = world:query(Enemy, Charge, Model)() -- Possible, but unconventional
	```

	@return id -- Entity ID
	@return ...ComponentInstance -- The requested component values
]=]
function QueryResult:next()
	return self:_expand(self:_next())
end

local snapshot = {
	__iter = function(self): any
		local i = 0
		return function()
			i += 1

			local data = self[i]

			if data then
				return unpack(data, 1, data.n)
			end
			return
		end
	end,
}

--[=[
	Creates a "snapshot" of this query, draining this QueryResult and returning a list containing all of its results.

	By default, iterating over a QueryResult happens in "real time": it iterates over the actual data in the ECS, so
	changes that occur during the iteration will affect future results.

	By contrast, `QueryResult:snapshot()` creates a list of all of the results of this query at the moment it is called,
	so changes made while iterating over the result of `QueryResult:snapshot` do not affect future results of the
	iteration.

	Of course, this comes with a cost: we must allocate a new list and iterate over everything returned from the
	QueryResult in advance, so using this method is slower than iterating over a QueryResult directly.

	The table returned from this method has a custom `__iter` method, which lets you use it as you would use QueryResult
	directly:

	```lua
		for entityId, health, player in world:query(Health, Player):snapshot() do

		end
	```

	However, the table itself is just a list of sub-tables structured like `{entityId, component1, component2, ...etc}`.

	@return {{entityId: number, component: ComponentInstance, component: ComponentInstance, component: ComponentInstance, ...}}
]=]
function QueryResult:snapshot()
	local list = setmetatable({}, snapshot)

	local function iter()
		return self:_next()
	end

	for entityId, entityData in iter do
		if entityId then
			table.insert(list, table.pack(self:_expand(entityId, entityData)))
		end
	end

	return list
end

--[=[
	Returns an iterator that will skip any entities that also have the given components.

	:::tip
	This is essentially equivalent to querying normally, using `World:get` to check if a component is present,
	and using Lua's `continue` keyword to skip this iteration (though, using `:without` is faster).

	This means that you should avoid queries that return a very large amount of results only to filter them down
	to a few with `:without`. If you can, always prefer adding components and making your query more specific.
	:::

	@param ... Component -- The component types to filter against.
	@return () -> (id, ...ComponentInstance) -- Iterator of entity ID followed by the requested component values

	```lua
	for id in world:query(Target):without(Model) do
		-- Do something
	end
	```
]=]

function QueryResult:_next()
	local world = self.world
	local currentCompatibleArchetype = self.currentCompatibleArchetype
	local storageIndex = self.storageIndex
	local seenEntities = self.seenEntities
	local compatibleArchetypes = self.compatibleArchetypes

	local entityId, entityData

	repeat
		if world._storages[storageIndex][currentCompatibleArchetype] then
			entityId, entityData = next(world._storages[storageIndex][currentCompatibleArchetype], self.lastEntityId)
		end

		while entityId == nil do
			currentCompatibleArchetype = next(compatibleArchetypes, currentCompatibleArchetype)

			if currentCompatibleArchetype == nil then
				storageIndex += 1

				local nextStorage = world._storages[storageIndex]

				if nextStorage == nil or next(nextStorage) == nil then
					return
				end

				currentCompatibleArchetype = nil

				if world._pristineStorage == nextStorage then
					world:_markStorageDirty()
				end

				continue
			elseif world._storages[storageIndex][currentCompatibleArchetype] == nil then
				continue
			end

			entityId, entityData = next(world._storages[storageIndex][currentCompatibleArchetype])
		end

		self.lastEntityId = entityId

	until seenEntities[entityId] == nil

	self.currentCompatibleArchetype = currentCompatibleArchetype

	seenEntities[entityId] = true

	for _, metatable in self._filter do
		if entityData[metatable] then
			return self:_next()
		end
	end

	return entityId, entityData
end

function QueryResult:without(...)
	self._filter = { ... }

	return self
end

function QueryResult:transform() end

function QueryResult:_expand(entityId, entityData)
	local metatables = self.metatables
	local queryLength = #metatables
	local queryOutput = table.create(queryLength)

	if not entityId then
		return
	end

	for i, metatable in ipairs(metatables) do
		queryOutput[i] = entityData[metatable]
	end

	return entityId, unpack(queryOutput, 1, queryLength)
end

function QueryResult:__iter()
	return function()
		return self:_expand(self:_next())
	end
end

function QueryResult:_transform(phantomData) end

function QueryResult.new(world, ...)
	debug.profilebegin("World:query")
	assertValidComponent((...), 1)

	local metatables = { ... }
	local archetype = archetypeOf(...)

	if world._queryCache[archetype] == nil then
		world:_newQueryArchetype(archetype)
	end

	local compatibleArchetypes = world._queryCache[archetype]
	if next(compatibleArchetypes) == nil then
		-- If there are no compatible storages avoid creating our complicated iterator
	end

	debug.profileend()

	local currentCompatibleArchetype = next(compatibleArchetypes)

	local lastEntityId
	local storageIndex = 1

	if world._pristineStorage == world._storages[1] then
		world:_markStorageDirty()
	end

	local seenEntities = {}

	return setmetatable({
		world = world,
		metatables = metatables,
		seenEntities = seenEntities,
		currentCompatibleArchetype = currentCompatibleArchetype,
		compatibleArchetypes = compatibleArchetypes,
		lastEntityId = lastEntityId,
		storageIndex = storageIndex,
		_filter = {},
	}, QueryResult)
end

return QueryResult
