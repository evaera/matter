local Color3 = import("../types/Color3")
local GuiButton = import("./GuiButton")
local InstanceProperty = import("../InstanceProperty")
local Rect = import("../types/Rect")
local ScaleType = import("../Enum/ScaleType")
local Vector2 = import("../types/Vector2")

local ImageButton = GuiButton:extend("ImageButton", {
	creatable = true,
})

ImageButton.properties.Image = InstanceProperty.typed("string", {
	getDefault = function()
		return ""
	end,
})

ImageButton.properties.ImageColor3 = InstanceProperty.typed("Color3", {
	getDefault = function()
		return Color3.new()
	end,
})

ImageButton.properties.ImageRectOffset = InstanceProperty.typed("Vector2", {
	getDefault = function()
		return Vector2.new(0, 0)
	end,
})

ImageButton.properties.ImageRectSize = InstanceProperty.typed("Vector2", {
	getDefault = function()
		return Vector2.new(0, 0)
	end,
})

ImageButton.properties.ScaleType = InstanceProperty.enum(ScaleType, {
	getDefault = function()
		return ScaleType.Stretch
	end,
})

ImageButton.properties.SliceCenter = InstanceProperty.typed("Rect", {
	getDefault = function()
		return Rect.new(0, 0, 1, 1)
	end,
})

return ImageButton