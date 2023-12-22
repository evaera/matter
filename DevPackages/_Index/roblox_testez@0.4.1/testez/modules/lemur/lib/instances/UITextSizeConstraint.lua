local BaseInstance = import("./BaseInstance")
local InstanceProperty = import("../InstanceProperty")

local UITextSizeConstraint = BaseInstance:extend("UITextSizeConstraint", {
	creatable = true,
})

UITextSizeConstraint.properties.MaxTextSize = InstanceProperty.typed("number", {
	getDefault = function()
		return 100
	end,
})

return UITextSizeConstraint