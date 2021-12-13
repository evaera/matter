local TopoRuntime = require(script.Parent.Parent.TopoRuntime)

local function cleanup(storage)
	return os.clock() < storage.expiry
end

local function useThrottle(seconds, discriminator)
	local storage = TopoRuntime.useHookState(discriminator, cleanup)

	if storage.time == nil or os.clock() - storage.time >= seconds then
		storage.time = os.clock()
		storage.expiry = os.clock() + seconds
		return true
	end

	return false
end

return useThrottle
