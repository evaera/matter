local BaseInstance = import("./BaseInstance")
local InstanceProperty = import("../InstanceProperty")

local IntValue = BaseInstance:extend("IntValue", {
	creatable = true,
})

IntValue.properties.Value = InstanceProperty.normal({
	getDefault = function()
		return 0
	end,
})

function IntValue:init(instance)
	instance.Name = "Value"
end

return IntValue