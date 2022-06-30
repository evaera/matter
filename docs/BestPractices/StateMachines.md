# State Machines

A state machine is a general programming term that describes a system that can only be in one of a few known states, and the states it can change into are also all known and defined.

For example, you could define a Jack-in-the-Box as a state machine, with the following states:

- Resting
- Winding up
- Popped out
- Resetting

It might help if you think of these states as animations that play on a 3D model.

By default, the Jack-in-the-Box is resting. But if you start winding it up, it can transition into the Winding Up state.

At this point, it could either go back to resting, or it can go to popped out!

Once it's popped out, we can't go back to resting or winding up. But we can push it back into the box (resetting), which then puts it back into the Resting state.

We can imagine these states as a graph, with the transitions between states defined:

```
Resting <--> Winding Up --> Popped out --> Resetting
    ^                                       |
	|---------------------------------------*
```

You can go from Resting to Winding Up, from Winding up to Popped out, but you can't go from Popped out to Winding up.

## Components as state machines

Now that you (hopefully) understand state machines, we can relate this to components in an ECS.

While some components are mostly static or just update as data changes (like a component that holds the player's current Walk Speed), other components might be a little bit more complex.

Imagine we had a car that we want to drive from point A to point B, then from point B to point C, then from C to D, etc. How do we store what point the car is currently at, and which to go to next?

This is where treating your component as a state machine come in. You can have your component data represent a state in a state machine, and your system code progresses that component one step forward, into the next state.

Our `Car` component could have an array of `Vector3`s in it, the points we want to visit:

```lua
world:spawn(Car({
	destinations = {Vector3.new(0, 0, 0), Vector3.new(10, 0, 5), Vector3.new(-5, 2, 3)}
}))
```

In our system code, we can drive the car towards one of the points, and when it reaches its destination, remove that item from the list and start going towards the next.

```lua
for id, car, model in world:query(Car, Model) do
	local currentPosition = model.model.PrimaryPart.Position

	if (currentPosition - car.destinations[1]).magnitude < 2 then -- Arrived
		table.remove(car.destinations, 1)

		if #car.destinations == 0 then
			world:despawn(id)
			continue
		end
	end

	model.model.PrimaryPart.BodyPosition.Position = car.destinations[1] --example
end
```

In this way, our system "steps" our component forward in time, modifying it when necessary.

## Adding another layer

We can make this a little bit more complicated if we make the car wait at each destination once it arrives.


```lua
world:spawn(Car({
	destinations = {Vector3.new(0, 0, 0), Vector3.new(10, 0, 5), Vector3.new(-5, 2, 3)},
	mode = "driving"
}))

-----

for id, car, model in world:query(Car, Model) do
	if car.mode == "waiting" then
		if os.clock() - car.startedWaiting > 5 then -- Wait 5 seconds
			world:insert(id, car:patch({
				mode = "driving",
				startedWaiting = Matter.None
			}))
		end
	elseif car.mode == "driving" then
		if #car.destinations == 0 then
			world:despawn(id)
			continue
		end

		local currentPosition = model.model.PrimaryPart.Position

		if (currentPosition - car.destinations[1]).magnitude < 2 then -- Arrived
			table.remove(car.destinations, 1)

			world:insert(id, car:patch({
				mode = "waiting",
				startedWaiting = os.clock()
			}))

			continue
		end

		model.model.PrimaryPart.BodyPosition.Position = car.destinations[1] --example
	end
end
```

Now, we've added another layer to our Car component: a `mode` property, that tells our code if the car is waiting or driving. You can see how this could get even more complex, adding other modes, arrays to drain, and other state that allows our system to "step" our component forward in time.