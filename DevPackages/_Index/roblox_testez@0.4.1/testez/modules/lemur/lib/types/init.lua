local names = {
	"Color3",
	"Rect",
	"UDim",
	"UDim2",
	"Vector2",
	"Vector3",
}

local types = {}

for _, name in ipairs(names) do
	types[name] = import("./" .. name)
end

return types