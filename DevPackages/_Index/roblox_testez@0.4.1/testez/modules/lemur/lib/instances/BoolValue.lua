local BaseInstance = import("./BaseInstance")
local InstanceProperty = import("../InstanceProperty")

local BoolValue = BaseInstance:extend("BoolValue", {
	creatable = true,
})

BoolValue.properties.Value = InstanceProperty.normal({
	getDefault = function()
		return false
	end,
})

function BoolValue:init(instance)
	instance.Name = "Value"
end

return BoolValue