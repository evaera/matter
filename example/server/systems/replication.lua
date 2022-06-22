local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(ReplicatedStorage.Game.components)
local useEvent = require(ReplicatedStorage.Packages.Matter).useEvent

local RemoteEvent = Instance.new("RemoteEvent")
RemoteEvent.Name = "MatterRemote"
RemoteEvent.Parent = ReplicatedStorage

local replicatedComponents = {
	Components.Roomba,
	Components.Model,
	Components.Health,
	Components.Target,
	Components.Mothership,
}

local function replication(world)
	for _, player in useEvent(Players, "PlayerAdded") do
		local payload = {}

		for entityId, entityData in world do
			local entityPayload = {}
			payload[tostring(entityId)] = entityPayload

			for component, componentData in entityData do
				entityPayload[tostring(component)] = { data = componentData }
			end
		end

		print("Sending initial payload to", player)
		RemoteEvent:FireClient(player, payload)
	end

	local changes = {}

	for _, component in replicatedComponents do
		for entityId, record in world:queryChanged(component) do
			local key = tostring(entityId)
			local name = tostring(component)

			if changes[key] == nil then
				changes[key] = {}
			end

			if world:contains(entityId) then
				changes[key][name] = { data = record.new }
			end
		end
	end

	if next(changes) then
		RemoteEvent:FireAllClients(changes)
	end
end

return {
	system = replication,
	priority = math.huge,
}
