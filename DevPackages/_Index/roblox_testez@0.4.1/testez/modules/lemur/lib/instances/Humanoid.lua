local BaseInstance = import("./BaseInstance")
local InstanceProperty = import("../InstanceProperty")
local Signal = import("../Signal")
local validateType = import("../validateType")

local Humanoid = BaseInstance:extend("Humanoid", {
	creatable = true,
})

function Humanoid:init(instance)
	getmetatable(instance).instance.died = false
end

Humanoid.properties.Died = InstanceProperty.readOnly({
	getDefault = Signal.new
})

Humanoid.properties.Health = InstanceProperty.normal({
	getDefault = function()
		return 100
	end,

	set = function(self, key, value)
		validateType("Health", value, "number")
		local instance = getmetatable(self).instance
		local health = math.min(
			math.max(0, value),
			self.MaxHealth
		)

		instance.properties.Health = health

		if not instance.died and health == 0 and self:FindFirstAncestorWhichIsA("Workspace") ~= nil then
			instance.died = true
			self.Died:Fire()
		end
	end,
})

Humanoid.properties.MaxHealth = InstanceProperty.normal({
	getDefault = function()
		return 100
	end,

	set = function(self, key, value)
		validateType("MaxHealth", value, "number")
		local instance = getmetatable(self).instance
		local maxHealth = math.max(0, value)

		instance.properties.MaxHealth = maxHealth
		self.Health = math.min(self.Health, maxHealth)
	end,
})

return Humanoid
