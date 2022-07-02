local archetypeModule = require(script.Parent.archetype)
local topoRuntime = require(script.Parent.topoRuntime)
local Component = require(script.Parent.component)

local assertValidComponentInstance = Component.assertValidComponentInstance
local assertValidComponent = Component.assertValidComponent
local archetypeOf = archetypeModule.archetypeOf
local areArchetypesCompatible = archetypeModule.areArchetypesCompatible

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
	local firstStorage = {}

	return setmetatable({
		-- List of maps from archetype string --> entity ID --> entity data
		_storages = { firstStorage },
		-- The most recent storage that has not been dirtied by an iterator
		_pristineStorage = firstStorage,

		-- Map from entity ID -> archetype string
		_entityArchetypes = {},

		-- Cache of the component metatables on each entity. Used for generating archetype.
		-- Map of entity ID -> array
		_entityMetatablesCache = {},

		-- Cache of what query archetypes are compatible with what component archetypes
		_queryCache = {},

		-- Cache of what entity archetypes have ever existed in the game. This is used for knowing
		-- when to update the queryCache.
		_entityArchetypeCache = {},

		-- The next ID that will be assigned with World:spawn
		_nextId = 1,

		-- The total number of active entities in the world
		_size = 0,

		-- Storage for `queryChanged`
		_changedStorage = {},
	}, World)
end

-- Searches all archetype storages for the entity with the given archetype
-- If found, returns the entity data followed by the storage index the entity was in
function World:_getStorageWithEntity(archetype, id)
	for _, storage in self._storages do
		local archetypeStorage = storage[archetype]
		if archetypeStorage then
			if archetypeStorage[id] then
				return storage
			end
		end
	end
end

function World:_markStorageDirty()
	local newStorage = {}
	table.insert(self._storages, newStorage)
	self._pristineStorage = newStorage

	if topoRuntime.withinTopoContext() then
		local frameState = topoRuntime.useFrameState()

		frameState.dirtyWorlds[self] = true
	end
end

function World:_getEntity(id)
	local archetype = self._entityArchetypes[id]
	local storage = self:_getStorageWithEntity(archetype, id)

	return storage[archetype][id]
end

function World:_next(last)
	local entityId, archetype = next(self._entityArchetypes, last)

	if entityId == nil then
		return nil
	end

	local storage = self:_getStorageWithEntity(archetype, entityId)

	return entityId, storage[archetype][entityId]
end

--[=[
	Iterates over all entities in this World. Iteration returns entity ID followed by a dictionary mapping
	Component to Component Instance.

	**Usage:**

	```lua
	for entityId, entityData in world do
		print(entityId, entityData[Components.Example])
	end
	```

	@return number
	@return {[Component]: ComponentInstance}
]=]
function World:__iter()
	return World._next, self
end

--[=[
	Spawns a new entity in the world with the given components.

	@param ... ComponentInstance -- The component values to spawn the entity with.
	@return number -- The new entity ID.
]=]
function World:spawn(...)
	return self:spawnAt(self._nextId, ...)
end

--[=[
	Spawns a new entity in the world with a specific entity ID and given components.

	The next ID generated from [World:spawn] will be increased as needed to never collide with a manually specified ID.

	@param id number -- The entity ID to spawn with
	@param ... ComponentInstance -- The component values to spawn the entity with.
	@return number -- The same entity ID that was passed in
]=]
function World:spawnAt(id, ...)
	if self:contains(id) then
		error(
			string.format(
				"The world already contains an entity with ID %d. Use World:replace instead if this is intentional.",
				id
			),
			2
		)
	end

	self._size += 1

	if id >= self._nextId then
		self._nextId = id + 1
	end

	local components = {}
	local metatables = {}

	for i = 1, select("#", ...) do
		local newComponent = select(i, ...)

		assertValidComponentInstance(newComponent, i)

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

	for _, storage in self._storages do
		for entityArchetype in storage do
			if areArchetypesCompatible(queryArchetype, entityArchetype) then
				self._queryCache[queryArchetype][entityArchetype] = true
			end
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
	local oldStorage

	if oldArchetype then
		oldStorage = self:_getStorageWithEntity(oldArchetype, id)

		if not components then
			oldStorage[oldArchetype][id] = nil
		end
	end

	if components then
		newArchetype = archetypeOf(unpack(self._entityMetatablesCache[id]))

		if oldArchetype ~= newArchetype then
			if oldStorage then
				oldStorage[oldArchetype][id] = nil
			end

			if self._pristineStorage[newArchetype] == nil then
				self._pristineStorage[newArchetype] = {}
			end

			if self._entityArchetypeCache[newArchetype] == nil then
				debug.profilebegin("update query cache")
				self._entityArchetypeCache[newArchetype] = true
				self:_updateQueryCache(newArchetype)
				debug.profileend()
			end
			self._pristineStorage[newArchetype][id] = components
		else
			oldStorage[newArchetype][id] = components
		end
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
	local entity = self:_getEntity(id)

	for i = 1, select("#", ...) do
		local newComponent = select(i, ...)

		assertValidComponentInstance(newComponent, i)

		local metatable = getmetatable(newComponent)

		if components[metatable] then
			error(("Duplicate component type at index %d"):format(i), 2)
		end

		self:_trackChanged(metatable, id, entity[metatable], newComponent)

		components[metatable] = newComponent
		table.insert(metatables, metatable)
	end

	for metatable, component in pairs(entity) do
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
	local entity = self:_getEntity(id)

	for metatable, component in pairs(entity) do
		self:_trackChanged(metatable, id, component, nil)
	end

	self._entityMetatablesCache[id] = nil
	self:_transitionArchetype(id, nil)

	self._size -= 1
end

--[=[
	Removes all entities from the world.

	:::caution
	Removing entities in this way is not reported by `queryChanged`.
	:::
]=]
function World:clear()
	local firstStorage = {}
	self._storages = { firstStorage }
	self._pristineStorage = firstStorage
	self._entityArchetypes = {}
	self._entityMetatablesCache = {}
	self._size = 0
	self._changedStorage = {}
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

	local entity = self:_getEntity(id)

	local length = select("#", ...)

	if length == 1 then
		assertValidComponent((...), 1)
		return entity[...]
	end

	local components = {}
	for i = 1, length do
		local metatable = select(i, ...)
		assertValidComponent(metatable, i)
		components[i] = entity[metatable]
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

function QueryResult:__iter()
	return function()
		return self._expand(self._next())
	end
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

local snapshot = {
	__iter = function(self)
		local i = 0
		return function()
			i += 1

			local data = self[i]

			if data then
				return unpack(data, 1, data.n)
			end
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
		return self._next()
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

	Order of iteration is not guaranteed.

	```lua
	for id, enemy, charge, model in world:query(Enemy, Charge, Model) do
		-- Do something
	end

	for id in world:query(Target):without(Model) do
		-- Again, with feeling
	end
	```

	@param ... Component -- The component types to query. Only entities with *all* of these components will be returned.
	@return QueryResult -- See [QueryResult](/api/QueryResult) docs.
]=]
function World:query(...)
	debug.profilebegin("World:query")
	assertValidComponent((...), 1)

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

	local currentCompatibleArchetype = next(compatibleArchetypes)
	local lastEntityId
	local storageIndex = 1

	if self._pristineStorage == self._storages[1] then
		self:_markStorageDirty()
	end

	local seenEntities = {}

	local function nextItem()
		local entityId, entityData

		repeat
			if self._storages[storageIndex][currentCompatibleArchetype] then
				entityId, entityData = next(self._storages[storageIndex][currentCompatibleArchetype], lastEntityId)
			end

			while entityId == nil do
				currentCompatibleArchetype = next(compatibleArchetypes, currentCompatibleArchetype)

				if currentCompatibleArchetype == nil then
					storageIndex += 1

					local nextStorage = self._storages[storageIndex]

					if nextStorage == nil or next(nextStorage) == nil then
						return
					end

					currentCompatibleArchetype = nil

					if self._pristineStorage == nextStorage then
						self:_markStorageDirty()
					end

					continue
				elseif self._storages[storageIndex][currentCompatibleArchetype] == nil then
					continue
				end

				entityId, entityData = next(self._storages[storageIndex][currentCompatibleArchetype])
			end
			lastEntityId = entityId

		until seenEntities[entityId] == nil

		seenEntities[entityId] = true
		return entityId, entityData
	end

	return setmetatable({
		_expand = expand,
		_next = nextItem,
	}, QueryResult)
end

local function cleanupQueryChanged(hookState)
	local world = hookState.world
	local componentToTrack = hookState.componentToTrack

	for index, object in world._changedStorage[componentToTrack] do
		if object == hookState.storage then
			table.remove(world._changedStorage[componentToTrack], index)
			break
		end
	end

	if next(world._changedStorage[componentToTrack]) == nil then
		world._changedStorage[componentToTrack] = nil
	end
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

	It should be noted that `queryChanged` does not have the same iterator invalidation concerns as `World:query`.

	:::caution
	The first time your system runs (i.e., on the first frame), no results are returned. Results only begin to be
	tracked after the first time your system calls this function.
	:::

	:::info
	Calling this function from your system creates storage internally for your system. Then, changes meeting your
	criteria are pushed into your storage. Calling `queryChanged` again each frame drains this storage.

	If your system isn't called every frame, the storage will continually fill up and does not empty unless you drain
	it.

	If you stop calling `queryChanged` in your system, changes will stop being tracked.
	:::

	### Returns
	`queryChanged` returns an iterator function, so you call it in a for loop just like `World:query`.

	The iterator returns the entity ID, followed by a [`ChangeRecord`](#ChangeRecord).

	The `ChangeRecord` type is a table that contains two fields, `new` and `old`, respectively containing the new
	component instance, and the old component instance. `new` and `old` will never be the same value.

	`new` will be nil if the component was removed (or the entity was despawned), and `old` will be nil if the
	component was just added.

	The `old` field will be the value of the component the last time this system observed it, not
	necessarily the value it changed from most recently.

	The `ChangeRecord` table is potentially shared with multiple systems tracking changes for this component, so it
	cannot be modified.

	```lua
	for id, record in world:queryChanged(Model) do
		if record.new == nil then
			-- Model was removed

			if enemy.type == "this is a made up example" then
				world:remove(id, Enemy)
			end
		end
	end
	```

	@param componentToTrack Component -- The component you want to listen to changes for.
	@return () -> (id, ChangeRecord) -- Iterator of entity ID and change record
]=]
function World:queryChanged(componentToTrack, ...: nil)
	if ... then
		error("World:queryChanged does not take any additional parameters", 2)
	end

	local hookState = topoRuntime.useHookState(componentToTrack, cleanupQueryChanged)

	if not hookState.storage then
		if not self._changedStorage[componentToTrack] then
			self._changedStorage[componentToTrack] = {}
		end

		local storage = {}
		hookState.storage = storage
		hookState.world = self
		hookState.componentToTrack = componentToTrack

		table.insert(self._changedStorage[componentToTrack], storage)
	end

	return function()
		local entityId, component = next(hookState.storage)

		if entityId then
			hookState.storage[entityId] = nil

			return entityId, component
		end
	end
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
		-- If this entity has changed since the last time this system read it,
		-- we ensure that the "old" value is whatever the system saw it as last, instead of the
		-- "old" value we have here.
		if storage[id] then
			storage[id] = table.freeze({ old = storage[id].old, new = new })
		else
			storage[id] = record
		end
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

	local entity = self:_getEntity(id)

	local wasNew = false
	for i = 1, select("#", ...) do
		local newComponent = select(i, ...)

		assertValidComponentInstance(newComponent, i)

		local metatable = getmetatable(newComponent)

		local oldComponent = entity[metatable]

		if not oldComponent then
			wasNew = true

			table.insert(self._entityMetatablesCache[id], metatable)
		end

		self:_trackChanged(metatable, id, oldComponent, newComponent)

		entity[metatable] = newComponent
	end

	if wasNew then -- wasNew
		self:_transitionArchetype(id, entity)
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

	local entity = self:_getEntity(id)

	local length = select("#", ...)
	local removed = {}

	for i = 1, length do
		local metatable = select(i, ...)

		assertValidComponent(metatable, i)

		local oldComponent = entity[metatable]

		removed[i] = oldComponent

		self:_trackChanged(metatable, id, oldComponent, nil)

		entity[metatable] = nil
	end

	-- Rebuild entity metatable cache
	local metatables = {}

	for metatable in pairs(entity) do
		table.insert(metatables, metatable)
	end

	self._entityMetatablesCache[id] = metatables

	self:_transitionArchetype(id, entity)

	return unpack(removed, 1, length)
end

--[=[
	Returns the number of entities currently spawned in the world.
]=]
function World:size()
	return self._size
end

--[=[
	:::tip
	[Loop] automatically calls this function on your World(s), so there is no need to call it yourself if you're using
	a Loop.
	:::

	If you are not using a Loop, you should call this function at a regular interval (i.e., once per frame) to optimize
	the internal storage for queries.

	This is part of a strategy to eliminate iterator invalidation when modifying the World while inside a query from
	[World:query]. While inside a query, any changes to the World are stored in a separate location from the rest of
	the World. Calling this function combines the separate storage back into the main storage, which speeds things up
	again.
]=]
function World:optimizeQueries()
	if #self._storages == 1 then
		return
	end

	local firstStorage = self._storages[1]

	for i = 2, #self._storages do
		local storage = self._storages[i]

		for archetype, entities in storage do
			if firstStorage[archetype] == nil then
				firstStorage[archetype] = entities
			else
				for entityId, entityData in entities do
					if firstStorage[archetype][entityId] then
						error("Entity ID already exists in first storage...")
					end
					firstStorage[archetype][entityId] = entityData
				end
			end
		end
	end

	table.clear(self._storages)

	self._storages[1] = firstStorage
	self._pristineStorage = firstStorage
end

return World
