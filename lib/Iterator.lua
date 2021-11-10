local Iterator = {}
Iterator.__index = Iterator

function Iterator.fromListOfMaps(listOfMaps)
	debug.profilebegin("Iterator.fromListOfMaps")
	local self = setmetatable({
		_thread = coroutine.create(function()
			for _, map in ipairs(listOfMaps) do
				for entityId, entityData in pairs(map) do
					coroutine.yield(entityId, entityData)
				end
			end
		end),
	}, Iterator)

	debug.profileend()
	return self
end

function Iterator:filter(predicate)
	return setmetatable({
		_thread = coroutine.create(function()
			for a, b in self:iter() do
				if predicate(a, b) then
					coroutine.yield(a, b)
				end
			end
		end),
	}, Iterator)
end

function Iterator:next()
	if coroutine.status(self._thread) == "dead" then
		return
	end

	debug.profilebegin("Iterator:next")
	local nextItem = select(2, coroutine.resume(self._thread))
	debug.profileend()

	return nextItem
end

function Iterator:iter()
	return function()
		return self:next()
	end
end

function Iterator:collect()
	local items = {}

	for entityId, entityData in self:iter() do
		items[entityId] = entityData
	end

	return items
end

function Iterator:without(...)
	local metatables = { ... }
	return self:filter(function(_, data)
		for key in pairs(data) do
			if table.find(metatables, key) then
				return false
			end
		end

		return true
	end)
end

return Iterator
