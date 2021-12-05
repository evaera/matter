local TopoRuntime = require(script.Parent.Parent.TopoRuntime)

local DEFAULT = {}

local function useThrottle(seconds, discriminator)
	local storage = TopoRuntime.useHookState("useThrottle")

	if discriminator == nil then
		discriminator = DEFAULT
	end

	if storage[discriminator] == nil then
		storage[discriminator] = os.clock()
	elseif os.clock() - storage[discriminator] >= seconds then
		storage[discriminator] = os.clock()
		return true
	end

	return false
end

return useThrottle
