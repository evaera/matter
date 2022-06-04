local topoRuntime = require(script.Parent.Parent.topoRuntime)

local function cleanup(storage)
	return os.clock() < storage.expiry
end

--[=[
	@within Matter

	:::info Topologically-aware function
	This function is only usable if called within the context of [`Loop:begin`](/api/Loop#begin).
	:::

	Utility for easy time-based throttling.

	Accepts a duration, and returns `true` if it has been that long since the last time this function returned `true`.
	Always returns `true` the first time.

	This function returns unique results keyed by script and line number. Additionally, uniqueness can be keyed by a
	unique value, which is passed as a second parameter. This is useful when iterating over a query result, as you can
	throttle doing something to each entity individually.

	```lua
	if useThrottle(1) then -- Keyed by script and line number only
		print("only prints every second")
	end

	for id, enemy in world:query(Enemy) do
		if useThrottle(5, id) then -- Keyed by script, line number, and the entity id
			print("Recalculate target...")
		end
	end
	```

	@param seconds number -- The number of seconds to throttle for
	@param discriminator? any -- A unique value to additionally key by
	@return boolean -- returns true every x seconds, otherwise false
]=]
local function useThrottle(seconds, discriminator)
	local storage = topoRuntime.useHookState(discriminator, cleanup)

	if storage.time == nil or os.clock() - storage.time >= seconds then
		storage.time = os.clock()
		storage.expiry = os.clock() + seconds
		return true
	end

	return false
end

return useThrottle
