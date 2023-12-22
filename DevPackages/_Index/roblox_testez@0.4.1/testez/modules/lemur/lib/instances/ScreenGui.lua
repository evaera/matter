local BaseInstance = import("./BaseInstance")
local InstanceProperty = import("../InstanceProperty")
local Vector2 = import("../types/Vector2")
local ZIndexBehavior = import("../Enum/ZIndexBehavior")

local ScreenGui = BaseInstance:extend("ScreenGui", {
	creatable = true,
})

ScreenGui.properties.AbsolutePosition = InstanceProperty.readOnly({
	get = function(self)
		return Vector2.new(0, 0)
	end,
})

ScreenGui.properties.AbsoluteSize = InstanceProperty.readOnly({
	get = function(self)
		return Vector2.new(800, 600)
	end,
})

ScreenGui.properties.DisplayOrder = InstanceProperty.typed("number", {
	getDefault = function()
		return 0
	end,
})

ScreenGui.properties.AutoLocalize = InstanceProperty.typed("boolean", {
	getDefault = function()
		return true
	end,
})

ScreenGui.properties.IgnoreGuiInset = InstanceProperty.typed("boolean", {
	getDefault = function()
		return false
	end,
})

ScreenGui.properties.ZIndexBehavior = InstanceProperty.enum(ZIndexBehavior, {
	getDefault = function()
		return ZIndexBehavior.Global
	end,
})

ScreenGui.properties.Enabled = InstanceProperty.typed("boolean", {
	getDefault = function()
		return true
	end,
})

ScreenGui.properties.OnTopOfCoreBlur = InstanceProperty.typed("boolean", {
	getDefault = function()
		return false
	end,
})

return ScreenGui
