local Color3 = import("../types/Color3")
local GuiObject = import("./GuiObject")
local InstanceProperty = import("../InstanceProperty")
local Rect = import("../types/Rect")
local ScaleType = import("../Enum/ScaleType")
local Vector2 = import("../types/Vector2")

local ImageLabel = GuiObject:extend("ImageLabel", {
	creatable = true,
})

ImageLabel.properties.Image = InstanceProperty.typed("string", {
	getDefault = function()
		return ""
	end,
})

ImageLabel.properties.ImageColor3 = InstanceProperty.typed("Color3", {
	getDefault = function()
		return Color3.new()
	end,
})

ImageLabel.properties.ImageRectOffset = InstanceProperty.typed("Vector2", {
	getDefault = function()
		return Vector2.new(0, 0)
	end,
})

ImageLabel.properties.ImageRectSize = InstanceProperty.typed("Vector2", {
	getDefault = function()
		return Vector2.new(0, 0)
	end,
})

ImageLabel.properties.ScaleType = InstanceProperty.enum(ScaleType, {
	getDefault = function()
		return ScaleType.Stretch
	end,
})

ImageLabel.properties.SliceCenter = InstanceProperty.typed("Rect", {
	getDefault = function()
		return Rect.new(0, 0, 1, 1)
	end,
})

return ImageLabel