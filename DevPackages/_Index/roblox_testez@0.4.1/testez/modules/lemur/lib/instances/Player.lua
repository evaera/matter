local BaseInstance = import("./BaseInstance")
local InstanceProperty = import("../InstanceProperty")
local Player = BaseInstance:extend("Player")

function Player:init(instance, userId)
	if userId ~= nil then
		if type(userId) ~= "number" then
			error("userId must be an int64", 2)
		end

		getmetatable(instance).instance.properties.UserId = userId
	end
end

Player.properties.UserId = InstanceProperty.readOnly({
	getDefault = function()
		return 0
	end,
})

return Player