local TopoRuntime = require(script.Parent.Parent.TopoRuntime)

local function useEvent(event, callback)
	assert(event ~= nil, "Event is nil")
	assert(callback ~= nil, "Callback is nil")

	local storage = TopoRuntime.useHookState("useEvent")

	if storage.event ~= event then
		if storage.cleanup then
			storage.cleanup()
			table.clear(storage)
		end

		local values = {}
		storage.values = values
		storage.event = event

		local connection = event:Connect(function(...)
			table.insert(values, { ... })
		end)

		storage.connection = connection

		storage.cleanup = function()
			connection:Disconnect()
			table.clear(values)
		end
	end

	for _, args in ipairs(storage.values) do
		callback(unpack(args))
	end

	table.clear(storage.values)
end

return useEvent
