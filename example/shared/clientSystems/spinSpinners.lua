local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(ReplicatedStorage.Game.components)

local function spinSpinners(world)
	for id, model in world:query(Components.Model, Components.Spinner) do
		model.model.PrimaryPart.CFrame = model.model.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(5), 0)
	end
end

return spinSpinners
