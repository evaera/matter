local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(ReplicatedStorage.Shared.components)

local function spawnRoombas(world)
	for id, transform in world:query(Components.Transform, Components.Roomba):without(Components.Model) do
		local model = ReplicatedStorage.Assets.KillerRoomba:Clone()
		model.Parent = workspace
		model.PrimaryPart:SetNetworkOwner(nil)

		world:insert(
			id,
			Components.Model({
				model = model,
			})
		)
	end
end

return spawnRoombas
