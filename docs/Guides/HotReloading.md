# Hot reloading

Hot reloading allows you to see the results of new code in your game without needing to stop and start the game. Matter supports hot reloading systems. Whenever you make a change to any of your systems, you can see the results in real time in the game.

> Demo of hot reloading and the [Matter debugger](/docs/Guides/MatterDebugger)
<video controls width="800">
	<source src="https://i.eryn.io/2227/9BmdqOYM.mp4" type="video/mp4" />
</video>

## Setting up hot reloading in your game

### Installing rewire

We recommend using the [rewire](https://github.com/sayhisam1/Rewire) library for easy hot reloading.

You can install Rewire using [Wally](https://wally.run), the Roblox open source package manager.

```toml title="wally.toml"
[dependencies]
rewire = "sayhisam1/rewire@0.3.0"
```

### Set up Rewire

In the code where you create your Matter `Loop` object, create a new `HotReloader` object:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local HotReloader = require(Packages.rewire).HotReloader

local hotReloader = HotReloader.new()
```

Then, we call `HotReloader:scan`, passing in the folder that contains your systems, and two functions: one that runs when a system is loaded, and another that runs when a system is unloaded.

```lua
local firstRunSystems = {}
local systemsByModule = {}

hotReloader:scan(container, function(module, context)
	-- The module HotReloader gives us can be a clone of the original module if it's been hot reloaded.

	local originalModule = context.originalModule

	-- Load the cloned module. If it has syntax errors, require will error.
	local ok, system = pcall(require, module)

	if not ok then
		warn("Error when hot-reloading system", module.name, system)
		return
	end


	if firstRunSystems then
		-- On the first run, we want to schedule all systems in one call,
		-- so we buffer them up and call one big `loop:scheduleSystems` at the end.

		table.insert(firstRunSystems, system)
	elseif systemsByModule[originalModule] then
		-- If this system was already loaded once before, we tell the loop to replace it.
		loop:replaceSystem(systemsByModule[originalModule], system)

		-- If you're also using the Matter debugger, tell the debugger the system was reloaded.
		-- debugger:replaceSystem(systemsByModule[originalModule], system)
	else
		-- If this is a new system (i.e., a new module was created during a hot reload), just schedule it.
		loop:scheduleSystem(system)
	end

	-- Keep a reference to the system, keyed by the original module, so we can detect if the system already existed
	-- or not
	systemsByModule[originalModule] = system
end, function(_, context)
	-- This function runs when a system is being unloaded.
	-- context.isReloading is true if the system is about to be hot reloaded. Otherwise, it's been removed.
	-- If it's being hot reloaded, do nothing
	if context.isReloading then
		return
	end
	-- The system is being removed

	local originalModule = context.originalModule
	if systemsByModule[originalModule] then
		-- If the system was loaded, remove it from the loop
		loop:evictSystem(systemsByModule[originalModule])
		systemsByModule[originalModule] = nil
	end
end)
```

That's it! For a real example of this in action, check out the [Matter example game](https://github.com/evaera/matter/blob/main/example/src/shared/start.lua).

