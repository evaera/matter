local BaseInstance = import("./BaseInstance")
local InstanceProperty = import("../InstanceProperty")

local NumberValue = BaseInstance:extend("NumberValue", {
	creatable = true,
})

NumberValue.properties.Value = InstanceProperty.normal({
	getDefault = function()
		return 0
	end,
})

function NumberValue:init(instance)
	instance.Name = "Value"
end

return NumberValue