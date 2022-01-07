---
sidebar_position: 1
---

# Reconciliation

## The Data Model

In Roblox, the Data Model is the tree of instances which embodies all the things in your game. In Lua, the `game` global is assigned to the root of this tree, whose class is `DataModel`. The Data Model is also sometimes called the DOM (Document Object Model), a term borrowed from the Web world.

When making a game on Roblox, whether a conscious decision or not, the source of truth for game state lives in either in some Lua data structure (e.g., a table), or in the Data Model itself.

As an example, the Humanoid object has a `Health` field. Most games on Roblox use the Humanoid's `Health` field as the source of truth for players. Thus, the source of truth for player health lives in the Data Model.

On the other hand, imagine in your game players can earn points by completing objectives. You create a table which maps players to the number of points they have (e.g., `{[Player]: number}`). To display the points to the player, you update some text in the game every time the points change. This is an example of the source of truth living in your own code: the `points` map is the source of truth, and you update the DataModel to reflect this.

Many games use a mix of these two ideas for different pieces of state. While this *can* work, it can lead to problems down the line. Largely, these problems are caused by the instances and properties available in the DataModel being unable to adequately represent complex game state in a convenient way. Developers are forced to contort their game state around what's available in the DataModel, which makes code difficult to reason about. [Attributes](https://developer.roblox.com/en-us/articles/instance-attributes) are an attempt to help solve this problem, but ultimately fall short due to design limitations. You cannot create an attribute with a complex data structure, only primitive values are allowed. And, attributes must be placed on existing instance types, which hamstrings the developer's ability to have control over the state of their own game.

Code becomes simpler to reason about if we instead treat Instances and the Data Model as a sort of *intermediate representation* of our game's state, which is only derived from our true game state: some data structure (e.g., tables) that we keep in Lua.

This is what the ECS world is: it's a place where you can structure your game state however you want, optimized for fast batch operations. There are other approaches to storing game state (e.g. object-oriented classes and encapsulation), but this is an ECS library, so that's what we'll focus on.

## Reconciliation

Reconciliation, in this context, means taking state from one form and turning it into another. In our case, we want to reconcile our Lua state into Instances in the Data Model, so that users can see and interact with it. A key idea and benefit of reconciliation is that it's possible to reconcile the same state in multiple different ways. If we have enemies in our world at certain positions, we can reconcile them into the world with character models, but also onto a minimap with red blips. It's the same state being converted into two different ways to view the data.

When writing code in an ECS like Matter, it's ideal for all of our gameplay code to operate on the ECS world alone. In the Matter example game, for example, there are ships that fly to certain points in space. For example, instead of updating the ships in the Data Model directly, we store the current goal position in the Ship component. The Ship component knows nothing about the Data Model. It has no reference to the physical ship Instance in the Data Model, it only contains the state about the ship.

We can create another component (in the [Matter example game](https://github.com/evaera/matter/tree/main/example), we call it `Model`) that holds a reference to the ship Instance.

We can loop over all Ships that don't also have a Model, and create one for it.

```lua title="ships.lua"
for id, ship in world:query(Ship):without(Model) do
	local model = prefabs.Ship:Clone() -- assuming prefabs is a place where you store pre-made models
	model.Parent = workspace

	world:insert(id, Model({
		instance = model
	}))
end
```

Now, whenever there's an entity with Ship without Model, we create the model and insert the Model component. We can then loop over all Ships that have Models, and update the position of the Model.

```lua title="ships.lua"
for id, ship, model in world:query(Ship, Model) do
	model.instance.BodyPosition.Position = ship.goalPosition
end
```

Keep in mind, both of these loops are performed every frame - that's what a system does. This means that in order to create a Ship from some other system, we need only spawn an entity with `Ship` - this system we just wrote takes care of creating and further reconciling the state of the Ship into the Data Model.

We have a problem now, though: whenever an entity with both Ship and Model is despawned, the physical ship Instance in the Data Model will stick around. Since the Model component is generic and could be reused with any other component (it's not specific to just Ship), we can create another system that handles this case for anything that uses Model.

```lua title="removeModels.lua"
for _id, modelRecord in world:queryChanged(Model) do
	if modelRecord.new == nil then
		if modelRecord.old and modelRecord.old.instance then
			modelRecord.old.instance:Destroy()
		end
	end
end
```

Here, we use [`queryChanged`](/api/World#queryChanged) to loop over Model components that have changed in the last frame. `queryChanged` gives us a [`ChangeRecord`](/api/World#ChangeRecord) type, which is a table with `old` and `new` properties. If there was an `old` instance, but no `new` instance, we know that the Model component has been removed. This can happen when the Model component is removed but the entity still exists (e.g., `world:remove(entityId, Model)` and also when the entire entity is despawned (e.g., `world:despawn(entityId)`). We then call `Instance:Destroy()` on the Instance.

Now that we've written this code once for our game, it will operate on any entity that has a Model component. This means that calling `world:despawn` on an entity with Ship and Model will result in the physical Instance also being removed.

## Reverse bindings

### Events

While we generally want our state to flow in one direction (Lua into the DataModel), we must also be able to interact with the things we've created. Roblox Instances have events that fire, (e.g., Touched) which are still things we need to use.

As an example, let's say we wanted the Ship to despawn if it was touched by anything. We can use Matter's [`useEvent`](/api/Matter#useEvent) utility to collect events that fire in a frame and loop over them.

```lua title="ships.lua"
for id, model in world:query(Model, Ship) do
	for _ in Matter.useEvent(model.Instance, "Touched") do
		world:despawn(id)
	end
end
```

### Removal

Sometimes, instances can be removed from the Data Model or destroyed without us doing it. A common cause of this is because parts that are affected by physics fall below the world or get flung to infinity. This can result in those instances being removed without us doing so.

To account for this, we can simply loop over every Model and check if it's still in the world. If not, we can either remove the Model component or despawn the entire entity (whichever makes more sense for your game).

```lua title="removeModels.lua"
for id, model in world:query(Model) do
	if model.instance:IsDescendantOf(game) == false then
		world:remove(id, Model)
	end
end
```

As a side effect, the above code makes it so manually deleting an Instance in a play test in Studio will cause it to be instantly recreated in the same place. This may or may not be the behavior that you want, but it sure is interesting!

It should be noted that this method can cause an infinite loop of a Model being created and destroyed if the last Transform was at an invalid position. This can be solved by either just despawning the entire entity instead, or taking care to reset Transform to a known-safe position when removing models.

## Two-way bindings

Imagine we had a component that held the position and rotation of something. This is often called `Transform`. Our `Transform` component would hold a CFrame value.

There are two potential ways we could want to use this component:
- We want to update our Transform component and have the physical Instance be moved to that place.
- We want the Transform component to be updated based on where the Instance is in the world, because physics can move it around.

We can make a system that handles both of these cases for us.

```lua title="updateTransforms.lua"
-- Handle Transform added/changed to existing entity with Model
for _id, transformRecord, model in world:queryChanged(Transform, Model) do
	-- Take care to ignore the changed event if it was us that triggered it
	if transformRecord.new and not transformRecord.new.doNotReconcile then
		model.instance:SetPrimaryPartCFrame(transformRecord.new.cframe)
	end
end

-- Handle Model added/changed on existing entity with Transform
for _id, modelRecord, transform in world:queryChanged(Model, Transform) do
	if modelRecord.new then
		modelRecord.new.model:SetPrimaryPartCFrame(transform.cframe)
	end
end

-- Update Transform on unanchored Models
for id, model, transform in world:query(Model, Transform) do
	if model.instance.PrimaryPart.Anchored then
		continue
	end

	local existingCFrame = transform.cframe
	local currentCFrame = model.instance.PrimaryPart.CFrame

	-- Only insert if actual position is different from the Transform component
	if currentCFrame ~= existingCFrame then
		world:insert(
			id,
			Components.Transform({
				cframe = currentCFrame,
				doNotReconcile = true,
			})
		)
	end
end
```

The above system handles the following cases:
- When the Transform component is inserted on an entity that also has Model, move the Model to that position.*
- When the Model component is inserted on an entity that also has Transform, move the Model to that position.
- When an unanchored Model moves, update the Transform component to match its new position.

\* We only update the Transform component if it wasn't us that caused it to move.

## Benefits of reconciliation

When we structure our game code in this manner, it allows us to do some cool things. For example:
- Creating a new entity (like a ship) from other systems is as simple as just spawning an entity with a Ship component. We don't have to worry about creating the model for it, because the ship system will look for Ships without Models and make them for us.
- Likewise, despawning an entity does what we expect. We can just despawn it from any system, and our generic model system will handle cleaning up the model.
- We don't need to access the Model component of a ship to know where it is in the world, we only need to read the Transform component, even if it's affected by physics. Likewise, to move a ship, we only need to write to (insert) the Transform component.
- We could copy the entire ECS world at a given point in time, since it's just plain-old data[^1], and then restore it later. Our systems won't know the difference: models that didn't exist and now do will be created, models that exist now but didn't before will be destroyed, and models that still exist will snap into the correct position.
- We can reconcile the same state multiple times into the world, like marking ships on a minimap.

[^1]: If saving the data, we would need to take special care to serialize things like CFrame values and Vector3 into JSON-compatible data, but that's beyond the scope of this article