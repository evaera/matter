local GuiObject = import("./GuiObject")
local InstanceProperty = import("../InstanceProperty")
local Signal = import("../Signal")
local GuiButton = GuiObject:extend("GuiButton")

GuiButton.properties.Activated = InstanceProperty.readOnly({
	getDefault = function()
		return Signal.new()
	end,
})

GuiButton.properties.AutoButtonColor = InstanceProperty.typed("boolean", {
	getDefault = function()
		return false
	end,
})

GuiButton.properties.Modal = InstanceProperty.typed("boolean", {
	getDefault = function()
		return false
	end,
})

GuiButton.properties.MouseButton1Click = InstanceProperty.readOnly({
	getDefault = function()
		return Signal.new()
	end,
})

return GuiButton