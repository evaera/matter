local exists, bit32 = pcall(require, "bit32")

if exists then
	local rbxBit32 = {}
	for key, value in pairs(bit32) do
		rbxBit32[key] = value
	end
	return rbxBit32
else
	return setmetatable({}, {
		__index = function(self, index)
			return function()
				error("Please install `bit32` to use bit32 features.", 2)
			end
		end
	})
end