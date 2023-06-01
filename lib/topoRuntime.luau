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
				local cleanupCallback = state.cleanupCallback

				if cleanupCallback then
					local shouldAbortCleanup = cleanupCallback(value)

					if shouldAbortCleanup then
						continue
					end
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

local function withinTopoContext()
	return #stack ~= 0
end

local function useFrameState()
	return stack[#stack].node.frame
end

local function useCurrentSystem()
	if #stack == 0 then
		return
	end

	return stack[#stack].node.currentSystem
end

--[=[
	@within Matter

	:::tip
	**Don't use this function directly in your systems.**

	This function is used for implementing your own topologically-aware functions. It should not be used in your
	systems directly. You should use this function to implement your own utilities, similar to `useEvent` and
	`useThrottle`.
	:::

	`useHookState` does one thing: it returns a table. An empty, pristine table. Here's the cool thing though:
	it always returns the *same* table, based on the script and line where *your function* (the function calling
	`useHookState`) was called.

	### Uniqueness

	If your function is called multiple times from the same line, perhaps within a loop, the default behavior of
	`useHookState` is to uniquely identify these by call count, and will return a unique table for each call.

	However, you can override this behavior: you can choose to key by any other value. This means that in addition to
	script and line number, the storage will also only return the same table if the unique value (otherwise known as the
	"discriminator") is the same.

	### Cleaning up
	As a second optional parameter, you can pass a function that is automatically invoked when your storage is about
	to be cleaned up. This happens when your function (and by extension, `useHookState`) ceases to be called again
	next frame (keyed by script, line number, and discriminator).

	Your cleanup callback is passed the storage table that's about to be cleaned up. You can then perform cleanup work,
	like disconnecting events.

	*Or*, you could return `true`, and abort cleaning up altogether. If you abort cleanup, your storage will stick
	around another frame (even if your function wasn't called again). This can be used when you know that the user will
	(or might) eventually call your function again, even if they didn't this frame. (For example, caching a value for
	a number of seconds).

	If cleanup is aborted, your cleanup function will continue to be called every frame, until you don't abort cleanup,
	or the user actually calls your function again.

	### Example: useThrottle

	This is the entire implementation of the built-in `useThrottle` function:

	```lua
	local function cleanup(storage)
		return os.clock() < storage.expiry
	end

	local function useThrottle(seconds, discriminator)
		local storage = useHookState(discriminator, cleanup)

		if storage.time == nil or os.clock() - storage.time >= seconds then
			storage.time = os.clock()
			storage.expiry = os.clock() + seconds
			return true
		end

		return false
	end
	```

	A lot of talk for something so simple, right?

	@param discriminator? any -- A unique value to additionally key by
	@param cleanupCallback (storage: {}) -> boolean? -- A function to run when the storage for this hook is cleaned up
]=]
local function useHookState(discriminator, cleanupCallback): {}
	local file, line = debug.info(3, "sl")
	local fn = debug.info(2, "f")

	local baseKey = string.format("%s:%s:%d", tostring(fn), file, line)

	local currentFrame = stack[#stack]

	if currentFrame == nil then
		error("Attempt to access topologically-aware storage outside of a Loop-system context.", 3)
	end

	if not currentFrame.accessedKeys[baseKey] then
		currentFrame.accessedKeys[baseKey] = {}
	end

	local accessedKeys = currentFrame.accessedKeys[baseKey]

	local key = #accessedKeys

	if discriminator ~= nil then
		if type(discriminator) == "number" then
			discriminator = tostring(discriminator)
		end

		key = discriminator
	end

	accessedKeys[key] = true

	if not currentFrame.node.system[baseKey] then
		currentFrame.node.system[baseKey] = {
			storage = {},
			cleanupCallback = cleanupCallback,
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
	useCurrentSystem = useCurrentSystem,
	withinTopoContext = withinTopoContext,
}
