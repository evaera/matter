local BaseInstance = import("./BaseInstance")
local InstanceProperty = import("../InstanceProperty")
local Signal = import("../Signal")
local MouseBehavior = import("../Enum/MouseBehavior")
local Platform = import("../Enum/Platform")

local UserInputService = BaseInstance:extend("UserInputService")

function UserInputService.prototype:GetPlatform()
	return Platform.Windows
end

UserInputService.properties.InputBegan = InstanceProperty.readOnly({
	getDefault = function()
		return Signal.new()
	end,
})

UserInputService.properties.InputChanged = InstanceProperty.readOnly({
	getDefault = function()
		return Signal.new()
	end,
})

UserInputService.properties.MouseBehavior = InstanceProperty.normal({
	getDefault = function()
		return MouseBehavior.Default
	end
})

return UserInputService