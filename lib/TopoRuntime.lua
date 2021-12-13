local stack = {}

local function newStackFrame(node)
	return {
		node = node,
		accessedKeys = {},
	}
end

local function cleanup()
	local currentFrame = stack[#stack]

	for baseKey, state in pairs(currentFrame.node.system) do
		for key, value in pairs(state.storage) do
			if not currentFrame.accessedKeys[baseKey] or not currentFrame.accessedKeys[baseKey][key] then
				local callbacks = state.callbacks

				if callbacks.shouldCleanup then
					if not callbacks.shouldCleanup(value) then
						continue
					end
				end

				if callbacks.cleanup then
					callbacks.cleanup(value)
				end

				state.storage[key] = nil
			end
		end
	end
end

local function start(node, fn)
	table.insert(stack, newStackFrame(node))
	fn()
	cleanup()
	table.remove(stack, #stack)
end

local function useFrameState()
	return stack[#stack].node.frame
end

local function useHookState(uniqueKey, callbacks)
	local file, line = debug.info(3, "sl")
	local fn = debug.info(2, "f")

	local baseKey = string.format("%s:%s:%d", tostring(fn), file, line)

	local currentFrame = stack[#stack]

	if not currentFrame.accessedKeys[baseKey] then
		currentFrame.accessedKeys[baseKey] = {}
	end

	local accessedKeys = currentFrame.accessedKeys[baseKey]

	local key = #accessedKeys

	if uniqueKey ~= nil then
		if type(uniqueKey) == "number" then
			uniqueKey = tostring(uniqueKey)
		end

		key = uniqueKey
	end

	accessedKeys[key] = true

	if not currentFrame.node.system[baseKey] then
		currentFrame.node.system[baseKey] = {
			storage = {},
			callbacks = callbacks or {},
		}
	end

	local storage = currentFrame.node.system[baseKey].storage

	if not storage[key] then
		storage[key] = {}
	end

	return storage[key]
end

return {
	start = start,
	useHookState = useHookState,
	useFrameState = useFrameState,
}
