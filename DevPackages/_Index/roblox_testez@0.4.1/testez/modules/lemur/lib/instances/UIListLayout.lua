local UIGridStyleLayout = import("./UIGridStyleLayout")
local InstanceProperty = import("../InstanceProperty")
local UDim = import("../types/UDim")

local UIListLayout = UIGridStyleLayout:extend("UIListLayout", {
	creatable = true,
})

UIListLayout.properties.Padding = InstanceProperty.typed("UDim", {
	getDefault = function()
		return UDim.new()
	end,
})

return UIListLayout