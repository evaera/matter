local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(script.Parent.Parent.components)
local Matter = require(ReplicatedStorage.Matter)

local function mothershipsSpawnRoombas(world)
	for id, model, lasering, transform in world:query(Components.Model, Components.Lasering, Components.Transform, Components.Mothership) do
		model.model.Beam.Transparency = 1 - math.clamp((lasering.expireTime - os.clock()) / 1, 0, 1)

		if not lasering.spawned then
			local spawnPosition = Vector3.new(transform.cframe.p.X, 11, transform.cframe.p.Z)

			world:spawn(
				Components.Roomba(),
				Components.Charge({
					charge = 100,
				}),
				Components.Transform({
					cframe = CFrame.new(spawnPosition),
				})
			)

			world:insert(id, lasering:patch({ spawned = true }))
		end

		if os.clock() > lasering.expireTime then
			world:remove(id, Components.Lasering)
		end
	end
end

return mothershipsSpawnRoombas
