local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.ExamplePackages
local Matter = require(ReplicatedStorage.Packages.Matter)
local Plasma = require(Packages.plasma)
local Components = require(ReplicatedStorage.Game.components)
local RemoteEvent = ReplicatedStorage:WaitForChild("MatterRemote")

local world = Matter.World.new()
local state = {}
local loop = Matter.Loop.new(world, state)

local systems = {}
for _, child in ipairs(script.systems:GetChildren()) do
	if child:IsA("ModuleScript") then
		table.insert(systems, require(child))
	end
end

loop:scheduleSystems(systems)

local plasmaNode = Plasma.new(workspace)

loop:addMiddleware(function(nextFn)
	return function()
		Plasma.start(plasmaNode, nextFn)
	end
end)

loop:begin({
	default = RunService.Heartbeat,
	RenderStepped = RunService.RenderStepped,
})

local entityIdMap = {}

RemoteEvent.OnClientEvent:Connect(function(entities)
	for serverEntityId, componentMap in entities do
		local clientEntityId = entityIdMap[serverEntityId]

		if clientEntityId and next(componentMap) == nil then
			world:despawn(clientEntityId)
			print(string.format("Despawn %ds%d", clientEntityId, serverEntityId))
			continue
		end

		local componentsToInsert = {}
		local componentsToRemove = {}

		local insertNames = {}
		local removeNames = {}

		for name, container in componentMap do
			if container.data then
				table.insert(componentsToInsert, Components[name](container.data))
				table.insert(insertNames, name)
			else
				table.insert(componentsToRemove, Components[name])
				table.insert(removeNames, name)
			end
		end

		if clientEntityId == nil then
			clientEntityId = world:spawn(unpack(componentsToInsert))

			entityIdMap[serverEntityId] = clientEntityId

			print(string.format("Spawn %ds%d with %s", clientEntityId, serverEntityId, table.concat(insertNames, ",")))
		else
			if #componentsToInsert > 0 then
				world:insert(clientEntityId, unpack(componentsToInsert))
			end

			if #componentsToRemove > 0 then
				world:remove(clientEntityId, unpack(componentsToRemove))
			end

			print(
				string.format(
					"Modify %ds%d adding %s, removing %s",
					clientEntityId,
					serverEntityId,
					if #insertNames > 0 then table.concat(insertNames, ", ") else "nothing",
					if #removeNames > 0 then table.concat(removeNames, ", ") else "nothing"
				)
			)
		end
	end
end)
