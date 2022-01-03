local Llama = require(script.Parent.Parent.Llama)
local Archetype = require(script.Parent.Archetype)
local TopoRuntime = require(script.Parent.TopoRuntime)

local archetypeOf = Archetype.archetypeOf
local areArchetypesCompatible = Archetype.areArchetypesCompatible

local ERROR_NO_ENTITY = "Entity doesn't exist, use world:contains to check if needed"

--[=[
	@class World

	A World contains entities which have components.
	The World is queryable and can be used to get entities with a specific set of components.
	Entities are simply ever-increasing integers.
]=]
local World = {}
World.__index = World

--[=[
	Creates a new World.
]=]
function World.new()
	return setmetatable({
		-- Map from entity ID -> archetype string
		_archetypes = {},

		-- Map from archetype string --> entity ID --> entity data
		_entityArchetypes = {},

		-- Cache of the component metatables on each entity. Used for generating archetype.
		-- Map of entity ID -> array
		_entityMetatablesCache = {},

		-- Cache of what query archetypes are compatible with what component archetypes
		_queryCache = {},

		-- The next ID that will be assigned with World:spawn
		_nextId = 0,

		-- The total number of active entities in the world
		_size = 0,

		-- Storage for `queryChanged`
		_changedStorage = {},
	}, World)
end

--[=[
	Spawns a new entity in the world with the given components.

	@param ... ComponentInstance -- The component values to spawn the entity with.
	@return number -- The new entity ID.
]=]
function World:spawn(...)
	local id = self._nextId
	self._nextId += 1
	self._size += 1

	local components = {}
	local metatables = {}

	for i = 1, select("#", ...) do
		local newComponent = select(i, ...)
		local metatable = getmetatable(newComponent)

		if components[metatable] then
			error(("Duplicate component type at index %d"):format(i), 2)
		end

		self:_trackChanged(metatable, id, nil, newComponent)

		components[metatable] = newComponent
		table.insert(metatables, metatable)
	end

	self._entityMetatablesCache[id] = metatables

	self:_transitionArchetype(id, components)

	return id
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
	for queryArchetype, compatibleArchetypes in pairs(self._queryCache) do
		if areArchetypesCompatible(queryArchetype, entityArchetype) then
			compatibleArchetypes[entityArchetype] = true
		end
	end
end

function World:_transitionArchetype(id, components)
	debug.profilebegin("transitionArchetype")
	local newArchetype = nil
	local oldArchetype = self._entityArchetypes[id]

	if oldArchetype then
		self._archetypes[oldArchetype][id] = nil

		-- Keep archetypes around because they're likely to exist again in the future
	end

	if components then
		newArchetype = archetypeOf(unpack(self._entityMetatablesCache[id]))

		if self._archetypes[newArchetype] == nil then
			self._archetypes[newArchetype] = {}

			debug.profilebegin("update query cache")
			self:_updateQueryCache(newArchetype)
			debug.profileend()
		end

		self._archetypes[newArchetype][id] = components
	end

	self._entityArchetypes[id] = newArchetype

	debug.profileend()
end

--[=[
	Replaces a given entity by ID with an entirely new set of components.
	Equivalent to removing all components from an entity, and then adding these ones.

	@param id number -- The entity ID
	@param ... ComponentInstance -- The component values to spawn the entity with.
]=]
function World:replace(id, ...)
	if not self:contains(id) then
		error(ERROR_NO_ENTITY, 2)
	end

	local components = {}
	local metatables = {}
	local existingComponents = self._archetypes[self._entityArchetypes[id]][id]

	for i = 1, select("#", ...) do
		local newComponent = select(i, ...)
		local metatable = getmetatable(newComponent)

		if components[metatable] then
			error(("Duplicate component type at index %d"):format(i), 2)
		end

		self:_trackChanged(metatable, id, existingComponents[metatable], newComponent)

		components[metatable] = newComponent
		table.insert(metatables, metatable)
	end

	for metatable, component in pairs(existingComponents) do
		if not components[metatable] then
			self:_trackChanged(metatable, id, component, nil)
		end
	end

	self._entityMetatablesCache[id] = metatables

	self:_transitionArchetype(id, components)
end

--[=[
	Despawns a given entity by ID, removing it and all its components from the world entirely.

	@param id number -- The entity ID
]=]
function World:despawn(id)
	local existingComponents = self._archetypes[self._entityArchetypes[id]][id]

	for metatable, component in pairs(existingComponents) do
		self:_trackChanged(metatable, id, component, nil)
	end

	self._entityMetatablesCache[id] = nil
	self:_transitionArchetype(id, nil)

	self._size -= 1
end

--[=[
	Removes all entities from the world.

	:::warning
	Removing entities in this way is not reported by `queryChanged`.
	:::
]=]
function World:clear()
	self._entityArchetypes = {}
	self._archetypes = {}
	self._entityMetatablesCache = {}
	self._size = 0
end

--[=[
	Checks if the given entity ID is currently spawned in this world.

	@param id number -- The entity ID
	@return bool -- `true` if the entity exists
]=]
function World:contains(id)
	return self._entityArchetypes[id] ~= nil
end

--[=[
	Gets a specific component (or set of components) from a specific entity in this world.

	@param id number -- The entity ID
	@param ... Component -- The components to fetch
	@return ... -- Returns the component values in the same order they were passed in
]=]
function World:get(id, ...)
	if not self:contains(id) then
		error(ERROR_NO_ENTITY, 2)
	end

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
	return self._expand(self._next())
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
	return self._expand(self._next())
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
	local metatables = { ... }
	return function()
		while true do
			local entityId, entityData = self._next()

			if not entityId then
				break
			end

			local skip = false
			for _, metatable in ipairs(metatables) do
				if entityData[metatable] then
					skip = true
					break
				end
			end

			if skip then
				continue
			end

			return self._expand(entityId, entityData)
		end
	end
end

--[=[
	Performs a query against the entities in this World. Returns a [QueryResult](/api/QueryResult), which iterates over
	the results of the query.

	```lua
	for id, enemy, charge, model in world:query(Enemy, Charge, Model) do
		-- Do something
	end

	for id in world:query(Target):without(Model) do
		-- Again, with feeling
	end
	```

	&nbsp;

	:::danger Modifying the World while iterating
	- **Do not insert new components or spawn entities that would then match the query while iterating.** The iteration
	behavior is undefined if the World is changed while iterating so that additional results would be returned.

	- **Removing components during iteration may cause the iterator to return the same entity multiple times**,
	*if* the component would still meet the requirements of the query. It is safe to remove components
	during iteration *if and only if* the entity would no longer meet the query requirements.
	:::

	To mitigate against these limitations, simply build up a queue of actions to take after iteration, and then do them
	after your iteration loop. **Inserting existing components** and **despawning entities** during iteration is safe,
	however.

	@param ... Component -- The component types to query. Only entities with *all* of these components will be returned.
	@return QueryResult -- See [QueryResult](/api/QueryResult) docs.
]=]
function World:query(...)
	debug.profilebegin("World:query")
	local metatables = { ... }
	local queryLength = select("#", ...)

	local archetype = archetypeOf(...)

	if self._queryCache[archetype] == nil then
		self:_newQueryArchetype(archetype)
	end

	local compatibleArchetypes = self._queryCache[archetype]

	debug.profileend()

	if next(compatibleArchetypes) == nil then
		-- If there are no compatible storages avoid creating our complicated iterator
		return setmetatable({
			_expand = function() end,
			_next = function() end,
		}, QueryResult)
	end

	local queryOutput = table.create(queryLength)

	local function expand(entityId, entityData)
		if not entityId then
			return
		end

		for i, metatable in ipairs(metatables) do
			queryOutput[i] = entityData[metatable]
		end

		return entityId, unpack(queryOutput, 1, queryLength)
	end

	local compatibleArchetype = next(compatibleArchetypes)
	local lastEntityId
	local function nextItem()
		local entityId, entityData = next(self._archetypes[compatibleArchetype], lastEntityId)

		while entityId == nil do
			compatibleArchetype = next(compatibleArchetypes, compatibleArchetype)

			if compatibleArchetype == nil then
				return
			end

			entityId, entityData = next(self._archetypes[compatibleArchetype])
		end
		lastEntityId = entityId

		return entityId, entityData
	end

	return setmetatable({
		_expand = expand,
		_next = nextItem,
	}, QueryResult)
end

--[=[
	@interface ChangeRecord
	@within World
	.new? ComponentInstance -- The new value of the component. Nil if just removed.
	.old? ComponentInstance -- The former value of the component. Nil if just added.
]=]

--[=[
	:::info Topologically-aware function
	This function is only usable if called within the context of [`Loop:begin`](/api/Loop#begin).
	:::

	Queries for components that have changed **since the last time your system ran `queryChanged`**.

	Only one changed record is returned per entity, even if the same entity changed multiple times. The order
	in which changed records are returned is not guaranteed to be the order that the changes occurred in.

	It should be noted that `queryChanged` does not have the same iterator invalidation limitations as `World:query`.

	:::caution
	The first time your system runs (i.e., on the first frame), no results are returned. Results only begin to be
	tracked after the first time your system calls this function.
	:::

	:::info
	Calling this function from your system creates storage internally for your system. Then, changes meeting your
	criteria are pushed into your storage. Calling `queryChanged` again each frame drains this storage.

	If you do not call `queryChanged` each frame, or your system isn't called every frame, the storage will continually
	fill up and does not empty unless you drain it. It is assumed that you will call `queryChanged` unconditionally,
	every frame, **until the end of time**.
	:::

	### Arguments

	The first argument to `queryChanged` is the component for which you want to track changes.
	Further arguments are optional, and if passed, are an additional filter on what entities will be returned.

	:::caution
	Additional query arguments are checked against *at the time of iteration*, not when the change ocurred.
	This has the additional implication that entities that have been despawned will never be returned from
	`queryChanged` if additional query arguments are passed, because the entity will have no components, so cannot
	possibly pass any additional query.
	:::

	If no additional query arguments are passed, all changes (including despawns) will be tracked and returned.

	### Returns
	`queryChanged` returns an iterator function, so you call it in a for loop just like `World:query`.

	The iterator returns the entity ID, followed by a [`ChangeRecord`](#ChangeRecord), followed by the component
	instance values of any additional query arguments that were passed (as discussed above).

	The ChangeRecord type is a table that contains two fields, `new` and `old`, respectively containing the new
	component instance, and the old component instance. `new` and `old` will never be the same value.

	`new` will be nil if the component was removed (or the entity was despawned), and `old` will be nil if the
	component was just added.

	The ChangeRecord table is given to all systems tracking changes for this component, and cannot be modified.

	```lua
	for id, modelRecord, enemy in world:queryChanged(Model, Enemy) do
		if modelRecord.new == nil then
			-- Model was removed

			if enemy.type == "this is a made up example" then
				world:remove(id, Enemy)
			end
		end
	end
	```

	&nbsp;

	:::info
	It's conventional to end the name you assign the record with "-Record", to make clear it is a different shape than
	a regular component instance. The ChangeValue is a table with `new` and `old` fields, but additional returns for the
	additional query arguments are regular component instances.
	:::

	@param componentToTrack Component -- The component you want to listen to changes for.
	@param ...? Component -- Additional query components. Checked at time of iteration, not time of change.
	@return () -> (id, ChangeRecord, ...ComponentInstance) -- Iterator of entity ID followed by the requested component values, in order
]=]
function World:queryChanged(componentToTrack, ...)
	local hookState = TopoRuntime.useHookState(componentToTrack)

	if not hookState.storage then
		if not self._changedStorage[componentToTrack] then
			self._changedStorage[componentToTrack] = {}
		end

		local storage = {}
		hookState.storage = storage

		table.insert(self._changedStorage[componentToTrack], storage)
	end

	local queryLength = select("#", ...)
	local queryOutput = table.create(queryLength)
	local queryMetatables = { ... }

	if #queryMetatables == 0 then
		return function()
			local entityId, component = next(hookState.storage)

			if entityId then
				hookState.storage[entityId] = nil

				return entityId, component
			end
		end
	end

	local function queryIterator()
		local entityId, component = next(hookState.storage)

		if entityId then
			hookState.storage[entityId] = nil

			-- If the entity doesn't currently contain the requested components, don't return anything
			if not self:contains(entityId) then
				return queryIterator()
			end

			for i, queryMetatable in ipairs(queryMetatables) do
				local queryComponent = self:get(entityId, queryMetatable)
				if not queryComponent then
					return queryIterator()
				end

				queryOutput[i] = queryComponent
			end

			return entityId, component, unpack(queryOutput, 1, queryLength)
		end
	end

	return queryIterator
end

function World:_trackChanged(metatable, id, old, new)
	if not self._changedStorage[metatable] then
		return
	end

	if old == new then
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

--[=[
	Inserts a component (or set of components) into an existing entity.

	If another instance of a given component already exists on this entity, it is replaced.

	```lua
	world:insert(
		entityId,
		ComponentA({
			foo = "bar"
		}),
		ComponentB({
			baz = "qux"
		})
	)
	```

	@param id number -- The entity ID
	@param ... ComponentInstance -- The component values to insert
]=]
function World:insert(id, ...)
	debug.profilebegin("insert")
	if not self:contains(id) then
		error(ERROR_NO_ENTITY, 2)
	end

	local existingComponents = self._archetypes[self._entityArchetypes[id]][id]

	local wasNew = false
	for i = 1, select("#", ...) do
		local newComponent = select(i, ...)
		local metatable = getmetatable(newComponent)
		local oldComponent = existingComponents[metatable]

		if not oldComponent then
			wasNew = true

			table.insert(self._entityMetatablesCache[id], metatable)
		end

		self:_trackChanged(metatable, id, oldComponent, newComponent)

		existingComponents[metatable] = newComponent
	end

	if wasNew then -- wasNew
		self:_transitionArchetype(id, existingComponents)
	end

	debug.profileend()
end

--[=[
	Removes a component (or set of components) from an existing entity.

	```lua
	local removedA, removedB = world:remove(entityId, ComponentA, ComponentB)
	```

	@param id number -- The entity ID
	@param ... Component -- The components to remove
	@return ...ComponentInstance -- Returns the component instance values that were removed in the order they were passed.
]=]
function World:remove(id, ...)
	if not self:contains(id) then
		error(ERROR_NO_ENTITY, 2)
	end

	local existingComponents = self._archetypes[self._entityArchetypes[id]][id]

	local length = select("#", ...)
	local removed = {}

	for i = 1, length do
		local metatable = select(i, ...)

		local oldComponent = existingComponents[metatable]

		removed[metatable] = oldComponent

		self:_trackChanged(metatable, id, oldComponent, nil)

		existingComponents[metatable] = nil
	end

	-- Rebuild entity metatable cache
	local metatables = {}

	for metatable in pairs(existingComponents) do
		table.insert(metatables, metatable)
	end

	self._entityMetatablesCache[id] = metatables

	self:_transitionArchetype(id, existingComponents)

	return removed
end

--[=[
	Returns the number of entities currently spawned in the world.
]=]
function World:size()
	return self._size
end

return World
