local TopoRuntime = require(script.Parent.Parent.TopoRuntime)

--[=[
	@within Matter

	:::info Topologically-aware function
	This function is only usable if called within the context of [`Loop:begin`](/api/Loop#begin).
	:::

	Returns the `os.clock()` time delta between the start of this and last frame.
]=]
local function useDeltaTime(): number
	local state = TopoRuntime.useFrameState()

	return state.deltaTime
end

return useDeltaTime
