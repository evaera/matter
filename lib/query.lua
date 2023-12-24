local archetypeModule = require(script.Parent.archetype)
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

function QueryResult.new(world, expand, queryArchetype, compatibleArchetypes)
	return setmetatable({
		world = world,
		seenEntities = {},
		currentCompatibleArchetype = next(compatibleArchetypes),
		compatibleArchetypes = compatibleArchetypes,
		storageIndex = 1,
		_expand = expand,
		_queryArchetype = queryArchetype,
	}, QueryResult)
end

local function nextItem(query)
	local world = query.world
	local currentCompatibleArchetype = query.currentCompatibleArchetype
	local storageIndex = query.storageIndex
	local seenEntities = query.seenEntities
	local compatibleArchetypes = query.compatibleArchetypes

	local entityId, entityData

	local storages = world._storages
	repeat
		local nextStorage = storages[storageIndex]
		local currently = nextStorage[currentCompatibleArchetype]
		if currently then
			entityId, entityData = next(currently, query.lastEntityId)
		end

		while entityId == nil do
			currentCompatibleArchetype = next(compatibleArchetypes, currentCompatibleArchetype)

			if currentCompatibleArchetype == nil then
				storageIndex += 1

				nextStorage = storages[storageIndex]

				if nextStorage == nil or next(nextStorage) == nil then
					return
				end

				currentCompatibleArchetype = nil

				if world._pristineStorage == nextStorage then
					world:_markStorageDirty()
				end

				continue
			elseif nextStorage[currentCompatibleArchetype] == nil then
				continue
			end

			entityId, entityData = next(nextStorage[currentCompatibleArchetype])
		end

		query.lastEntityId = entityId

	until seenEntities[entityId] == nil

	query.currentCompatibleArchetype = currentCompatibleArchetype

	seenEntities[entityId] = true

	return entityId, entityData
end

function QueryResult:__iter()
	return function()
		return self._expand(nextItem(self))
	end
end

function QueryResult:__call()
	return self._expand(nextItem(self))
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
	return self._expand(nextItem(self))
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
		return nextItem(self)
	end

	for entityId, entityData in iter do
		if entityId then
			table.insert(list, table.pack(self._expand(entityId, entityData)))
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

function QueryResult:without(...)
	local world = self.world
	local filter = table.concat(string.split(archetypeOf(...), "_"), "||")

	local negativeArchetype = `{self._queryArchetype}||{filter}`

	if world._queryCache[negativeArchetype] == nil then
		world:_newQueryArchetype(negativeArchetype)
	end

	local compatibleArchetypes = world._queryCache[negativeArchetype]

	self.compatibleArchetypes = compatibleArchetypes
	self.currentCompatibleArchetype = next(compatibleArchetypes)
	return self
end

--[=[
	@class View
	Provides random access to the results of a query.
	Calling the table is equivalent iterating a query. 
	```lua
	for id, player, health, poison in world:query(Player, Health, Poison):view() do
		-- Do something
	end
	```
]=]

local View = {}
View.__index = View

function View.new()
	return setmetatable({
		fetches = {},
	}, View)
end

function View:__iter()
	local current = self.head
	return function()
		if current then
			local entity = current.entity
			local fetch = self.fetches[entity]
			current = current.next

			return entity, unpack(fetch, 1, fetch.n)
		end
	end
end

--[=[
	Retrieve the query results to corresponding `entity`
	@param entity number - the entity ID
	@return ...ComponentInstance
]=]
function View:get(entity)
	if not self:contains(entity) then
		return
	end

	local fetch = self.fetches[entity]

	return unpack(fetch, 1, fetch.n)
end

--[=[
	Equivalent to `world:contains()`	
	@param entity number - the entity ID
	@return boolean 
]=]

function View:contains(entity)
	return self.fetches[entity] ~= nil
end

--[=[
	Creates a View of the query and does all of the iterator tasks at once at an amortized cost.
	This is used for many repeated random access to an entity. If you only need to iterate, just use a query.
	```lua
	for id, player, health, poison in world:query(Player, Health, Poison):view() do
		-- Do something
	end
	local dyingPeople = world:query(Player, Health, Poison):view()
	local remainingHealth = dyingPeople:get(entity)
	```
	
	@param ... Component - The component types to query. Only entities with *all* of these components will be returned.
	@return View See [View](/api/View) docs.
]=]

function QueryResult:view()
	local function iter()
		return nextItem(self)
	end

	local view = View.new()

	for entityId, entityData in iter do
		if entityId then
			-- We start at 2 on Select since we don't need want to pack the entity id.
			local fetch = table.pack(select(2, self._expand(entityId, entityData)))
			local node = { entity = entityId, next = nil }
			view.fetches[entityId] = fetch
			if not view.head then
				view.head = node
			else
				local current = view.head
				while current.next do
					current = current.next
				end
				current.next = node
			end
		end
	end

	return view
end

return QueryResult
