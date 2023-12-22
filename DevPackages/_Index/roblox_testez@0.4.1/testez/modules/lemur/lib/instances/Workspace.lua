local BaseInstance = import("./BaseInstance")
local Camera = import("./Camera")
local InstanceProperty = import("../InstanceProperty")

local Workspace = BaseInstance:extend("Workspace")

function Workspace:init(instance)
	local camera = Camera:new()
	camera.Name = "Camera"
	camera.Parent = instance
	instance.CurrentCamera = camera
end

Workspace.properties.CurrentCamera = InstanceProperty.normal({})

Workspace.properties.DistributedGameTime = InstanceProperty.readOnly({
	getDefault = function ()
		return 0
	end
})

Workspace.properties.AllowThirdPartySales = InstanceProperty.typed("boolean", {
	getDefault = function ()
		return false
	end
})

Workspace.properties.Gravity = InstanceProperty.typed("number", {
	getDefault = function()
		return 196.2
	end
})

return Workspace