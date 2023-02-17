# Common Mistakes

Here's a list of common mistakes and how to avoid them while using Matter.

## Off by one frame insertions and queries

In Matter as well as any ECS, your systems run in a fixed order every frame. It's important to consider the order that
your systems will run when writing code that deals with removing, inserting, and changing components on entities.

For example, let's say that you have a system that moves NPCs to the correct position every frame. You might do this by
querying over every entity with the `NPC` component and then moving its world model position. We can call this system
`npcUpdater`. You might have another system responsible for spawning new NPCs (`npcSpawner`). If `npcSpawner` runs
*after* `npcUpdater`, newly spawned NPCs will be in their default position for one frame before jumping to their correct
position the next. In addition to players potentially noticing an NPC quickly flash in and out of existence, it could
cause cascading issues in other systems as well.

When it comes to modifying entities, it's best to stick to this general order:

1. Remove any entities or components *early* in the frame, so that no unnecessary work is performed by querying them later
2. Spawn entities or insert components next. Insert things before any systems that rely on them have a chance to query and potentially miss entities that are spawned late.
3. Change existing entities next, so that you can update newly inserted components correctly
4. Queries that run over all of a certain component every frame last

## Using return instead of continue in a query for loop

This is a simple one. When querying, it's easy to just use the wrong control flow. Many of us are so used to writing
code that early returns that it's easy to accidentally use `return` inside a for loop, when you really wanted `continue`.

```lua
function mySystem(world)
	for id, health, poison in world:query(Health, Poison) do
		if not poison.active then
			return -- Oops! After reaching the first inactive poison,
			-- we're going to stop running the entire system!
			-- Should have used `continue` here.
		end

		world:insert(id, health:patch({
			current = health.current - 1
		}))
	end
end
```

## Early return inside systems resetting topologically-aware state

Many functions in matter are *topologically-aware*: this means that they store some state which is referenced by the
file and line number *where the function is called from*. `useEvent`, `useThrottle`, and `World:queryChanged` are
all examples.

Under the hood, the storage for these functions is kept around only as long as you keep calling them from the same call
site (file and line number). If you cease calling a topologically-aware function in the same place every frame, then
the storage that was created for them is automatically cleaned up.

Generally, this is what you want. If you stop calling `useEvent` on a particular instance every frame - it's likely
that you don't care about that instance anymore, so it makes sense for us to disconnect the event and delete any
queued events that happened in the meantime.

However, unintentionally triggering this clean up can lead to behavior you might not expect. For example, `queryChanged`
uses topologically-aware storage to remember what entities have changed since your system last ran, in addition to what
value your system last observed the component as having. Remember, when you call `queryChanged` for the first time
(which is usually on the first frame of your game), it will iterate over all entities that match your query up front.
This is done so that you don't miss any changes that occurred before your system was able to register its interest in
the component you're querying over.

But, if you stop calling `queryChanged` from the same place every frame, like if you have an early return at the top of
your system, this storage is cleaned up. That means the next time your `queryChanged` *does* run, it will iterate over
all matches that are currently in the world as if they are new components (because, as far as it can tell, they are).

```lua
function mySystem()
	if useThrottle(1) then
		for id, health in world:queryChanged(Health) do
			-- Uh oh! Every time this runs, *every* health component will be looped over.
			-- The for loop runs only once per second, which means that on next frame where this code
			-- isn't reached, the storage for queryChanged is cleaned up.
		end
	end
end
```

The solution to this problem is to ensure that your `queryChanged` for loops run unconditionally every time your system runs.
(Unless you really do want this behavior!)

## Replacing a component, then using the old one later

In Matter, components are immutable. They are frozen with `table.freeze` and you can't modify them. This is for two main
reasons:

1. It makes change detection easy and performant. Using `queryChanged` to get a list of changed components is able to
exist and be fast because components are immutable. Since it is not possible to change the component tables,
the only way for a component to change is if a new table is made and the user calls `world:insert` with it.
2. A large class of bugs are rooted in values changing out from underneath you. When you pass tables around, oftentimes
code is not written to expect their values to be able to change arbitrarily. This becomes problematic when more than one
place in your code has an active reference to the same table.

By using immutable tables for our components, we can address these concerns. However, the trade off is that it's now
possible to make the other mistake:

You could get a component from an entity, and call `patch` on it and insert it, like this:

```lua
local health = world:get(id, Health)

world:insert(id, health:patch({
	current = health.current - 10
}))
```

...and then attempt to use the `health` variable later:

```lua
if health.current < 0 then
  -- ...
end
```

**This is not correct!** We just changed the `Health` component on this entity earlier in the function. `health:patch`
**does not modify** the table that is stored in the `health` variable. Thus, the `health` table that we are using in the
comparison in the latter code sample is the *old* value, not the new one we just changed!

One way you can solve this problem is by reassigning `health` to the updated value before inserting it.

```lua
local health = world:get(id, Health)

health = health:patch({
	current = health.current - 10
})

world:insert(id, health)

if health.current < 0 then
  -- ...
end
```