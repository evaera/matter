local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(ReplicatedStorage.Game.components)
local Matter = require(ReplicatedStorage.Lib.Matter)

local function roombasHurt(world)
	for id, roomba, model in world:query(Components.Roomba, Components.Model) do
		for _, part in Matter.useEvent(model.model.PrimaryPart, "Touched") do
			local touchedModel = part:FindFirstAncestorWhichIsA("Model")
			if not touchedModel then
				return
			end

			local player = Players:GetPlayerFromCharacter(touchedModel)

			if not player then
				return
			end

			if player ~= Players.LocalPlayer then
				return
			end

			local humanoid = touchedModel:FindFirstChildWhichIsA("Humanoid")

			if not humanoid then
				return
			end

			humanoid:TakeDamage(5)
		end
	end
end

return roombasHurt
