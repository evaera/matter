local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(script.Parent.Parent.components)
local Matter = require(ReplicatedStorage.Matter)
local Plasma = require(ServerScriptService.ExamplePackages.plasma)

local function spawnMotherships(world)
	if Matter.useThrottle(10) then
		local spawnPosition = Vector3.new(500, 500, 500)
			* Vector3.new(math.random(1, 2) == 1 and 1 or -1, 1, math.random(1, 2) == 1 and 1 or -1)

		local despawnPosition = Vector3.new(500, 500, 500)
			* Vector3.new(math.random(1, 2) == 1 and 1 or -1, 1, math.random(1, 2) == 1 and 1 or -1)

		local goalPosition = Vector3.new(math.random(-100, 100), 100, math.random(-100, 100))

		world:spawn(
			Components.Mothership({
				goal = goalPosition,
				nextGoal = despawnPosition,
			}),
			Components.Transform({
				cframe = CFrame.new(spawnPosition),
			})
		)
	end

	for id, transform in world:query(Components.Transform, Components.Mothership):without(Components.Model) do
		local model = ReplicatedStorage.Assets.Mothership:Clone()
		model:SetPrimaryPartCFrame(transform.cframe)
		model.Parent = workspace
		model.PrimaryPart:SetNetworkOwner(nil)

		world:insert(
			id,
			Components.Model({
				model = model,
			})
		)
	end

	for id, mothership, transform in world:query(Components.Mothership, Components.Transform):without(Components.Lasering) do
		if (transform.cframe.p - mothership.goal).magnitude < 10 then
			if mothership.lasered then
				world:despawn(id)
			else
				world:insert(
					id,
					Components.Mothership(Matter.merge(mothership, {
						goal = mothership.nextGoal,
						lasered = true,
					})),
					Components.Lasering({
						expireTime = os.clock() + 1,
					})
				)
			end
		end
	end

	for id, mothership, model in world:query(Components.Mothership, Components.Model):without(Components.Lasering) do
		model.model.Roomba.AlignPosition.Position = mothership.goal
	end
end

return spawnMotherships
