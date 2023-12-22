local BaseInstance = import("./BaseInstance")
local InstanceProperty = import("../InstanceProperty")

local ParticleEffect = BaseInstance:extend("ParticleEffect", {
	creatable = true,
})

ParticleEffect.properties.Enabled = InstanceProperty.normal({
	getDefault = function()
		return true
	end,
})

return ParticleEffect