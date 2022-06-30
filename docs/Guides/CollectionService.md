---
sidebar_position: 4
---

# Using CollectionService tags

As a pure ECS first and foremost, Matter provides no special functionality for CollectionService tags out of the box. However, it's rather simple to implement this yourself. Here's an example taken from the official [Matter example game](https://github.com/evaera/matter/tree/main/example/server).

```lua
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(ReplicatedStorage.Game.components)

local boundTags = {
	Spinner = Components.Spinner,
}

local function setupTags(world)
	local function spawnBound(instance, component)
		local id = world:spawn(
			component(),
			Components.Model({
				model = instance,
			}),
			Components.Transform({
				cframe = instance.PrimaryPart.CFrame,
			})
		)

		instance:SetAttribute("entityId", id)
	end

	for tagName, component in pairs(boundTags) do
		for _, instance in ipairs(CollectionService:GetTagged(tagName)) do
			spawnBound(instance, component)
		end

		CollectionService:GetInstanceAddedSignal(tagName):Connect(function(instance)
			spawnBound(instance, component)
		end)

		CollectionService:GetInstanceRemovedSignal(tagName):Connect(function(instance)
			local id = instance:GetAttribute("entityId")
			if id then
				world:despawn(id)
			end
		end)
	end
end

return setupTags

```

This example can be modified to meet your game's needs as you see fit.