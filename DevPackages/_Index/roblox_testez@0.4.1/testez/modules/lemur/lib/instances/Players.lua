local BaseInstance = import("./BaseInstance")
local InstanceProperty = import("../InstanceProperty")
local Player = import("./Player")

local Players = BaseInstance:extend("Players")

Players.properties.LocalPlayer = InstanceProperty.normal({
	getDefault = function()
		return Player:new()
	end,
})

function Players.prototype:GetPlayerFromCharacter()
	return nil
end

return Players