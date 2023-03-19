---
sidebar_position: 4
---

# Getting Started

:::tip
We **highly recommend** checking out the source code of our example game to see what this all looks like when set up in a real game. Clone the repo, build the project, open it up in your favorite editor and get some first hand experience. There's no better way to learn!

See the [`/example` directory in the matter repo](https://github.com/evaera/matter/tree/main/example/).
:::

## Scaffolding a new project

Here's how you scaffold a project with Matter.

First, import Matter at the top of your file. Then, create your [`World`](/api/World) and your [`Loop`](/api/Loop).

```lua title="init.server.lua"
local Matter = require(ReplicatedStorage.Matter)

local world = Matter.World.new()

local loop = Matter.Loop.new(world) -- This makes Loop pass the world to all your systems.
```

Then, we should collect all of your systems and schedule them. Assuming they're in a `systems` folder inside this script:

```lua title="init.server.lua"
local systems = {}
for _, child in ipairs(script.systems:GetChildren()) do
	if child:IsA("ModuleScript") then
		table.insert(systems, require(child))
	end
end

loop:scheduleSystems(systems)
```

Then, simply start the loop.

```lua title="init.server.lua"
loop:begin({
	default = RunService.Heartbeat
})
```

Now your systems would run every heartbeat, if you had any. Let's make some.

```lua title="systems/myFirstSystem.lua"
local function myFirstSystem()
	print("Hello world!")
end

return myFirstSystem
```

Now we're printing something 60 times per second. We should probably do something actually interesting instead.

Let's create a couple components.

```lua title="components.lua"
local Matter = require(ReplicatedStorage.Matter)

return {
	Health = Matter.component(),
	Poison = Matter.component(),
}
```

Let's make a system that removes 0.1 health every frame from things that are poisoned.

```lua title="systems/poisonHurts.lua"
local Components = require(script.Parent.components)
local Health = Components.Health
local Poison = Components.Poison

local function poisonHurts(world)
	for id, health in world:query(Health, Poison) do
		world:insert(id, health:patch({
			value = health.value - 0.1
		}))
	end
end
```

We make use of the [`Component:patch`](/api/Component#patch) function, which returns a new component with an updated
value, so we don't have to mutate the existing component.


## Next steps
You should dive in to the [API reference](/api/Matter)! The Matter API is simple and documented in detail.

And if you haven't already, check out the [`/example` directory in the matter repo](https://github.com/evaera/matter/tree/main/example/).
