# Replication

Replication is not built into Matter, but it's easy to implement yourself. This guide will give you an overview of one way to implement replication with Matter.

This article will cover the way the [Matter example game](https://github.com/evaera/matter/blob/main/example/shared/start.lua) implements replication.

## Deciding which components to replicate

You need to decide which components are replicated and which are not. You probably don't want to replicate every component, because some components might have data that's only relevant to the server or data that is updated too frequently to comfortably replicate each time it changes.

In this example, we'll just define a list of component names we want to replicate.

```lua
local REPLICATED_COMPONENTS = {
	"Roomba",
	"Model",
	"Health",
	"Target",
	"Mothership",
	"Spinner",
}
```

## Creating the replication system

Create a new system called `replication` on the server. Put the list of replicated components at the top of the file.

We'll create a remote event while we're at it:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvent = Instance.new("RemoteEvent")
RemoteEvent.Name = "MatterRemote"
RemoteEvent.Parent = ReplicatedStorage
```

Let's convert the list of component names into actual components. This is assuming you have a Components module that exports your components, like [the matter example game does](https://github.com/evaera/matter/blob/main/example/shared/components.lua).

```lua
local replicatedComponents = {}

for _, name in REPLICATED_COMPONENTS do
	replicatedComponents[Components[name]] = true
end
```

Let's create an empty function for our system and set up the rest of the system before we really get going.

```lua
local function replication(world)
 -- todo!
end

return {
	system = replication,
	priority = math.huge,
}
```

We set the system `priority` to infinity so that it always runs last, at the end of the frame.

## Replicating changes to the clients

We can use [World:queryChanged](/api/World#queryChanged) to detect when a component changes and replicate it to all players in the game.

```lua
-- In the replication function we created above.

-- Create a table to buffer up our changes so we only send out at most one remote event per frame
local changes = {}

-- Loop over our table of replicated components
for component in replicatedComponents do
	-- Loop over queryChanged for this component
	for entityId, record in world:queryChanged(component) do
		-- We convert the entity ID to a string because tables sent over remote events in Roblox
		-- can only have string keys. (did I just teach you something new?)
		local key = tostring(entityId)

		-- Get the name of the component. This is done with tostring as well because components have
		-- a custom __tostring metamethod that returns their human-readable name.
		local name = tostring(component)

		-- If there aren't any changes from this entity in the buffer so far, create the table for it
		if changes[key] == nil then
			changes[key] = {}
		end

		-- Only send over the changed component if the entity still exists in our world.
		if world:contains(entityId) then
			-- Lua tables can't contain nil as values, this is indistinguishable from the key just
			-- not existing at all.
			-- Instead, we set all values to a table, and then create a key inside that for the real
			-- value. This lets us detect when a component is removed (set to nil)
			changes[key][name] = { data = record.new }
		end
	end

	-- Check if there are any changes in our buffer before sending the changes to all clients.
	if next(changes) then
		RemoteEvent:FireAllClients(changes)
	end
end
```

This works pretty well! Only one problem. What if a player joins late when the world is already created?

## Replicating the existing world to new players

We can augment the system we created above with some special code to handle sending the entire World to new players who join the game late.

```lua
-- Also inside our replication function

-- Run some code every time a player joins
for _, player in useEvent(Players, "PlayerAdded") do
	local payload = {}

	-- Loop over the entire World using the world's __iter metamethod implementation
	for entityId, entityData in world do
		local entityPayload = {}

		-- Loop over all the components the entity has
		for component, componentData in entityData do
			-- Only if it's in our list of replicated components...
			if replicatedComponents[component] then
				-- Add it to the data we're sending for this entity
				entityPayload[tostring(component)] = { data = componentData }
			end
		end

		-- Add the entity data to our overall payload
		payload[tostring(entityId)] = entityPayload
	end

	RemoteEvent:FireClient(player, payload)
end
```

The `payload` object is structured the exact same way as our `changes` object from earlier, so we only need to write one piece of code on the client to handle both of these cases.

## Receiving replication on the client

The code on the client is not a system in our ECS, since it's just attaching an event listener to a Remote Event.

We can put this code in the same file where we create our World, so we have a reference to it already.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(ReplicatedStorage.Game.components) -- example

-- Get our remote event that we created on the server
local RemoteEvent = ReplicatedStorage:WaitForChild("MatterRemote")

-- A lookup table from server entity IDs to client entity IDs. They're different!
local entityIdMap = {}

RemoteEvent.OnClientEvent:Connect(function(entities)
	-- entities is the data sent from the server. Either the `payload` or `changes` from earlier!

	-- Loop over the entities the server is replicating
	for serverEntityId, componentMap in entities do
		-- Check if we've created this entity on the client before
		local clientEntityId = entityIdMap[serverEntityId]

		-- If we've created this entity before, and there are no components inside its list, that means
		-- the entity was despawned on the server. We despawn it here too.
		if clientEntityId and next(componentMap) == nil then
			world:despawn(clientEntityId)

			-- Remove it from our lookup table
			entityIdMap[serverEntityId] = nil
			continue
		end

		local componentsToInsert = {}
		local componentsToRemove = {}

		-- Loop over all the components in the entity
		for name, container in componentMap do
			-- If container.data exists, the component was either changed or added.
			if container.data then
				table.insert(componentsToInsert, Components[name](container.data))
			else -- if it doesn't exist, it was removed!
				table.insert(componentsToRemove, Components[name])
			end
		end

		-- We haven't created this entity on the client before. create it.
		if clientEntityId == nil then
			clientEntityId = world:spawn(unpack(componentsToInsert))

			-- add the client-side entity id to our lookup table
			entityIdMap[serverEntityId] = clientEntityId
		else -- we've seen this entity before.

			-- Just insert or remove any necessary components.

			if #componentsToInsert > 0 then
				world:insert(clientEntityId, unpack(componentsToInsert))
			end

			if #componentsToRemove > 0 then
				world:remove(clientEntityId, unpack(componentsToRemove))
			end

		end
	end
end)
```

And that's all there is to it! You could make this system more advanced in a lot of different ways, but this should get you started with a basic replication system for your game.
