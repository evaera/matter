--[[
	Serves as just a source container right now.
]]

local BaseInstance = import("./BaseInstance")
local InstanceProperty = import("../InstanceProperty")

local Script = BaseInstance:extend("Script", {
	creatable = true,
})

Script.properties.Source = InstanceProperty.normal({
	getDefault = function()
		return ""
	end,
})

return Script