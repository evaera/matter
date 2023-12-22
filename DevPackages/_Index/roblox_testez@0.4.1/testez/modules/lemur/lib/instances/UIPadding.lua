local BaseInstance = import("./BaseInstance")
local InstanceProperty = import("../InstanceProperty")
local UDim = import("../types/UDim")

local UIPadding = BaseInstance:extend("UIPadding", {
	creatable = true,
})

UIPadding.properties.PaddingBottom = InstanceProperty.typed("UDim", {
	getDefault = function()
		return UDim.new()
	end,
})

UIPadding.properties.PaddingLeft = InstanceProperty.typed("UDim", {
	getDefault = function()
		return UDim.new()
	end,
})

UIPadding.properties.PaddingRight = InstanceProperty.typed("UDim", {
	getDefault = function()
		return UDim.new()
	end,
})

UIPadding.properties.PaddingTop = InstanceProperty.typed("UDim", {
	getDefault = function()
		return UDim.new()
	end,
})

return UIPadding