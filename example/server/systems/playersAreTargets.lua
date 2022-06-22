local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(ReplicatedStorage.Game.components)
local Matter = require(ReplicatedStorage.Lib.Matter)

local function playersAreTargets(world)
	for _, player in ipairs(Players:GetPlayers()) do
		for _, character in Matter.useEvent(player, "CharacterAdded") do
			world:spawn(
				Components.Target(),
				Components.Model({
					model = character,
				})
			)
		end
	end

	-- players can die
	for id in world:query(Components.Target):without(Components.Model) do
		world:despawn(id)
	end
end

return playersAreTargets
