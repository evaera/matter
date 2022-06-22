local topoRuntime = require(script.Parent.Parent.topoRuntime)
local Queue = require(script.Parent.Parent.Queue)

local function cleanup(storage)
	storage.connection:Disconnect()
	storage.queue = nil
end

--[=[
	@within Matter

	:::info Topologically-aware function
	This function is only usable if called within the context of [`Loop:begin`](/api/Loop#begin).
	:::

	Collects events that fire during the frame and allows iteration over event arguments.

	```lua
	for _, player in ipairs(Players:GetPlayers()) do
		for i, character in useEvent(player, "CharacterAdded") do
			world:spawn(
				Components.Target(),
				Components.Model({
					model = character,
				})
			)
		end
	end
	```

	Returns an iterator function that returns an ever-increasing number, starting at 1, followed by any event arguments
	from the specified event.

	Events are returned in the order that they were fired.

	:::caution
	`useEvent` keys storage uniquely identified by **the script and line number** `useEvent` was called from, and the
	first parameter (instance). If the second parameter, `event`, is not equal to the event passed in for this unique
	storage last frame, the old event is disconnected from and the new one is connected in its place.

	Tl;dr: on a given line, you should hard-code a single event to connect to. Do not dynamically change the event with
	a variable. Dynamically changing the first parameter (instance) is fine.

	```lua
	for _, instance in pairs(someTable) do
		for i, arg1, arg2 in useEvent(instance, "Touched") do -- This is ok

		end
	end

	for _, instance in pairs(someTable) do
		local event = getEventSomehow()
		for i, arg1, arg2 in useEvent(instance, event) do -- PANIC! This is NOT OK

		end
	end
	```
	:::

	If `useEvent` ceases to be called on the same line with the same instance and event, the event connection is
	disconnected from automatically.

	You can also pass the actual event object instead of its name as the second parameter:

	```lua
	useEvent(instance, instance.Touched)

	useEvent(instance, instance:GetPropertyChangedSignal("Name"))
	```

	@param instance Instance -- The instance that has the event you want to connect to
	@param event string | RBXScriptSignal -- The name of or actual event that you want to connect to
]=]
local function useEvent(instance, event): () -> (number, ...any)
	assert(instance ~= nil, "Instance is nil")
	assert(event ~= nil, "Event is nil")

	local storage = topoRuntime.useHookState(instance, cleanup)

	if type(event) == "string" then
		event = instance[event]
	end

	if storage.event ~= event then
		if storage.event then
			storage.connection:Disconnect()
			warn("useEvent event changed:", storage.event, "->", event)
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
