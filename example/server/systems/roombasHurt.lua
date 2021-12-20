local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(script.Parent.Parent.components)
local Matter = require(ReplicatedStorage.Matter)

local function roombasHurt(world)
	for id, roomba, model in world:query(Components.Roomba, Components.Model) do
		for _, part in Matter.useEvent(model.model.PrimaryPart, "Touched") do
			local touchedModel = part:FindFirstAncestorWhichIsA("Model")
			if not touchedModel then
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
