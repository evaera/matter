local TopoRuntime = require(script.Parent.Parent.TopoRuntime)
local Queue = require(script.Parent.Parent.Queue)

local function cleanup(storage)
	storage.connection:Disconnect()
	storage.queue = nil
end

local function useEvent(instance, event)
	assert(instance ~= nil, "Instance is nil")
	assert(event ~= nil, "Event is nil")

	local storage = TopoRuntime.useHookState(instance, cleanup)

	if type(event) == "string" then
		event = instance[event]
	end

	if storage.event ~= event then
		if storage.cleanup then
			storage.cleanup()
			table.clear(storage)
		end

		local queue = Queue.new()
		storage.queue = queue
		storage.event = event

		local connection = event:Connect(function(...)
			queue:pushBack(table.pack(...))
		end)

		storage.connection = connection
	end

	local index = 0
	return function()
		index += 1

		local arguments = storage.queue:popFront()

		if arguments then
			return index, unpack(arguments, 1, arguments.n)
		end
	end
end

return useEvent
