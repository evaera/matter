local instances = import("./instances")

local Instance = {}

function Instance.new(className, parent)
	local class = instances[className]

	if class == nil or not class.options.creatable then
		error(string.format("Can't make an instance of type %q", tostring(className)), 2)
	end

	local instance = class:new()
	instance.Parent = parent

	return instance
end

return Instance