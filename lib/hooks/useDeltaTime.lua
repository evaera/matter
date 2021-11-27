local TopoStack = require(script.Parent.Parent.TopoStack)

local function useDeltaTime()
	local state = TopoStack.peek()

	return state.deltaTime
end

return useDeltaTime
