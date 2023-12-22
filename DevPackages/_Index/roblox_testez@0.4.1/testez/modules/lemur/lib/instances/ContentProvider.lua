local BaseInstance = import("./BaseInstance")
local InstanceProperty = import("../InstanceProperty")
local ContentProvider = BaseInstance:extend("ContentProvider")

ContentProvider.properties.BaseUrl = InstanceProperty.normal({
	getDefault = function()
		return "https://www.roblox.com/"
	end,
})

return ContentProvider