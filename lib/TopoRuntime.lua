local stack = {}

local function newStackFrame(node)
	return {
		node = node,
		counts = {},
	}
end

local function cleanup()
	local currentFrame = stack[#stack]

	for baseKey, values in pairs(currentFrame.node.system) do
		for i = (currentFrame.counts[baseKey] or 0) + 1, #values do
			local value = values[i]

			if type(value) == "table" and type(value.cleanup) == "function" then
				value.cleanup()
			end

			values[i] = nil
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

local function useHookState(baseName)
	local file = debug.info(3, "s")
	local line = debug.info(3, "l")

	local baseKey = string.format("%s:%s:%d", baseName, file, line)

	local currentFrame = stack[#stack]

	currentFrame.counts[baseKey] = (currentFrame.counts[baseKey] or 0) + 1
	local count = currentFrame.counts[baseKey]

	if not currentFrame.node.system[baseKey] then
		currentFrame.node.system[baseKey] = {}
	end

	local storageList = currentFrame.node.system[baseKey]

	if not storageList[count] then
		storageList[count] = {}
	end

	return storageList[count]
end

return {
	start = start,
	useHookState = useHookState,
	useFrameState = useFrameState,
}
