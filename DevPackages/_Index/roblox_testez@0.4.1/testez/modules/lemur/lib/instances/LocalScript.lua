--[[
	Serves as just a source container right now.
]]

local BaseInstance = import("./BaseInstance")
local InstanceProperty = import("../InstanceProperty")

local LocalScript = BaseInstance:extend("LocalScript", {
	creatable = true,
})

LocalScript.properties.Source = InstanceProperty.normal({
	getDefault = function()
		return ""
	end,
})

return LocalScript