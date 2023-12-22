local BaseInstance = import("./BaseInstance")
local Vector2 = import("../types/Vector2")
local InstanceProperty = import("../InstanceProperty")

local Camera = BaseInstance:extend("Camera", {
	creatable = true,
})

Camera.properties.ViewportSize = InstanceProperty.normal({
	getDefault = function()
		return Vector2.new(800, 600)
	end,
})

return Camera