local TopoRuntime = require(script.Parent.Parent.TopoRuntime)

local function useDeltaTime()
	local state = TopoRuntime.useFrameState()

	return state.deltaTime
end

return useDeltaTime
