local Color3 = import("../types/Color3")
local Font = import("../Enum/Font")
local GuiObject = import("./GuiObject")
local InstanceProperty = import("../InstanceProperty")
local TextTruncate = import("../Enum/TextTruncate")
local TextXAlignment = import("../Enum/TextXAlignment")
local TextYAlignment = import("../Enum/TextYAlignment")

local TextLabel = GuiObject:extend("TextLabel", {
	creatable = true,
})

TextLabel.properties.Font = InstanceProperty.enum(Font, {
	getDefault = function()
		return Font.Legacy
	end,
})

TextLabel.properties.Text = InstanceProperty.typed("string", {
	getDefault = function()
		return "Label"
	end,
})

TextLabel.properties.TextColor3 = InstanceProperty.typed("Color3", {
	getDefault = function()
		return Color3.fromRGB(27, 42, 53)
	end,
})

TextLabel.properties.TextSize = InstanceProperty.typed("number", {
	getDefault = function()
		return 14
	end,
})

TextLabel.properties.TextTransparency = InstanceProperty.typed("number", {
	getDefault = function()
		return 0
	end,
})

TextLabel.properties.TextTruncate = InstanceProperty.enum(TextTruncate, {
	getDefault = function()
		return TextTruncate.None
	end,
})

TextLabel.properties.TextWrapped = InstanceProperty.typed("boolean", {
	getDefault = function()
		return false
	end,
})

TextLabel.properties.TextScaled = InstanceProperty.typed("boolean", {
	getDefault = function()
		return false
	end,
})

TextLabel.properties.TextXAlignment = InstanceProperty.enum(TextXAlignment, {
	getDefault = function()
		return TextXAlignment.Left
	end,
})

TextLabel.properties.TextYAlignment = InstanceProperty.enum(TextYAlignment, {
	getDefault = function()
		return TextYAlignment.Top
	end,
})

return TextLabel
