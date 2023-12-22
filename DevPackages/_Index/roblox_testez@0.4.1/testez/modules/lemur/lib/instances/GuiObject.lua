local BaseInstance = import("./BaseInstance")
local Color3 = import("../types/Color3")
local InstanceProperty = import("../InstanceProperty")
local Signal = import("../Signal")
local SizeConstraint = import("../Enum/SizeConstraint")
local UDim2 = import("../types/UDim2")
local Vector2 = import("../types/Vector2")

local GuiObject = BaseInstance:extend("GuiObject")

GuiObject.properties.AbsolutePosition = InstanceProperty.readOnly({
	get = function(self)
		if self:FindFirstAncestorOfClass("ScreenGui") == nil then
			return Vector2.new()
		end

		local parentAbsolutePosition = self.Parent.AbsolutePosition
		local parentAbsoluteSize = self.Parent.AbsoluteSize
		local position = self.Position

		return Vector2.new(
			parentAbsolutePosition.X + position.X.Scale * parentAbsoluteSize.X + position.X.Offset,
			parentAbsolutePosition.Y + position.Y.Scale * parentAbsoluteSize.Y + position.Y.Offset
		)
	end,
})

GuiObject.properties.AbsoluteSize = InstanceProperty.readOnly({
	get = function(self)
		if self:FindFirstAncestorOfClass("ScreenGui") == nil then
			return Vector2.new()
		end

		local size = self.Size
		local scaleX, scaleY = 0, 0

		if self.Parent ~= nil and (self.Parent:IsA("GuiObject") or self.Parent:IsA("ScreenGui")) then
			local parentSize = self.Parent.AbsoluteSize
			scaleX = parentSize.X
			scaleY = parentSize.Y
		end

		return Vector2.new(
			scaleX * size.X.Scale + size.X.Offset,
			scaleY * size.Y.Scale + size.Y.Offset
		)
	end,
})

GuiObject.properties.Active = InstanceProperty.typed("boolean", {
	getDefault = function()
		return true
	end,
})

GuiObject.properties.AnchorPoint = InstanceProperty.typed("Vector2", {
	getDefault = function()
		return Vector2.new()
	end,
})

GuiObject.properties.BackgroundColor3 = InstanceProperty.typed("Color3", {
	getDefault = function()
		return Color3.new()
	end,
})

GuiObject.properties.BackgroundTransparency = InstanceProperty.typed("number", {
	getDefault = function()
		return 0
	end,
})

GuiObject.properties.BorderSizePixel = InstanceProperty.typed("number", {
	getDefault = function()
		return 0
	end,
})

GuiObject.properties.BorderColor3 = InstanceProperty.typed("Color3", {
	getDefault = function()
		return Color3.fromRGB(27, 42, 53)
	end,
})

GuiObject.properties.ClipsDescendants = InstanceProperty.typed("boolean", {
	getDefault = function()
		return false
	end,
})

GuiObject.properties.InputBegan = InstanceProperty.readOnly({
	getDefault = function()
		return Signal.new()
	end,
})

GuiObject.properties.InputEnded = InstanceProperty.readOnly({
	getDefault = function()
		return Signal.new()
	end,
})

GuiObject.properties.LayoutOrder = InstanceProperty.typed("number", {
	getDefault = function()
		return 0
	end,
})

GuiObject.properties.MouseEnter = InstanceProperty.readOnly({
	getDefault = function()
		return Signal.new()
	end,
})

GuiObject.properties.MouseLeave = InstanceProperty.readOnly({
	getDefault = function()
		return Signal.new()
	end,
})

GuiObject.properties.Position = InstanceProperty.typed("UDim2", {
	getDefault = function()
		return UDim2.new()
	end,
})

GuiObject.properties.Selectable = InstanceProperty.typed("boolean", {
	getDefault = function()
		return true
	end,
})

GuiObject.properties.Size = InstanceProperty.typed("UDim2", {
	getDefault = function()
		return UDim2.new()
	end,
})

GuiObject.properties.SizeConstraint = InstanceProperty.enum(SizeConstraint, {
	getDefault = function()
		return SizeConstraint.RelativeXY
	end,
})

GuiObject.properties.Visible = InstanceProperty.typed("boolean", {
	getDefault = function()
		return true
	end,
})

GuiObject.properties.ZIndex = InstanceProperty.typed("number", {
	getDefault = function()
		return 1
	end,
})

return GuiObject