local TopoRuntime = require(script.Parent.Parent.TopoRuntime)

local callbacks = {
	cleanup = function(storage)
		storage.connection:Disconnect()
		table.clear(storage.values)
	end,
}

local function useEvent(instance, event, callback)
	assert(instance ~= nil, "Instance is nil")
	assert(event ~= nil, "Event is nil")
	assert(callback ~= nil, "Callback is nil")

	local storage = TopoRuntime.useHookState(instance, callbacks)

	if type(event) == "string" then
		event = instance[event]
	end

	if storage.event ~= event then
		if storage.cleanup then
			storage.cleanup()
			table.clear(storage)
		end

		local values = {}
		storage.values = values
		storage.event = event

		local connection = event:Connect(function(...)
			table.insert(values, table.pack(...))
		end)

		storage.connection = connection
	end

	for _, args in ipairs(storage.values) do
		callback(unpack(args, 1, args.n))
	end

	table.clear(storage.values)
end

return useEvent
