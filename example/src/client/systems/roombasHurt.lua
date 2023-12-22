local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(ReplicatedStorage.Shared.components)
local Matter = require(ReplicatedStorage.Lib.Matter)

local function roombasHurt(world)
	for _, _, model in world:query(Components.Roomba, Components.Model) do
		for _, part in Matter.useEvent(model.model.PrimaryPart, "Touched") do
			local touchedModel = part:FindFirstAncestorWhichIsA("Model")
			if not touchedModel then
				continue
			end

			local player = Players:GetPlayerFromCharacter(touchedModel)

			if not player then
				continue
			end

			if player ~= Players.LocalPlayer then
				continue
			end

			local humanoid = touchedModel:FindFirstChildWhichIsA("Humanoid")

			if not humanoid then
				continue
			end

			humanoid:TakeDamage(5)
		end
	end
end

return roombasHurt
