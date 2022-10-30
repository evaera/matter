# Matter Debugger

The Matter debugger allows you to view your systems and create debug UI elements right inside your systems.

![Debugger screenshot](https://i.eryn.io/2228/89tcYlOq.png)

Inside your system code, you can create UI elements and check user input inline. Here's the code for the above screenshot:

```lua
local function spinSpinners(world, _, ui)
	if ui.checkbox("Disable Spinning"):checked() then
		return
	end

	local transparency = ui.slider(1)

	local randomize = ui.button("Randomize colors!"):clicked()

	for id, model in world:query(Components.Model, Components.Spinner) do
		model.model.PrimaryPart.Transparency = transparency

		if randomize then
			model.model.PrimaryPart.BrickColor = BrickColor.random()
		end
	end
end
```

This is accomplished using [Plasma](https://eryn.io/plasma/), an immediate-mode widget library. The widgets are only created while the debugger is active. Leaving the widget calls in your systems all the time is fine, because calling a widget function when the debugger is not open is a no-op.

The [Matter example game](https://github.com/evaera/matter/blob/main/example/shared/start.lua) comes with the debugger set up already. If you want to see an example of the debugger already set up in a game, check out that page.

## Adding the Matter debugger to your game

### Installing Plasma
You need to install [Plasma](https://eryn.io/plasma/) as a dependency to your project. We recommend you do this with [Wally](https://wally.run), the Roblox open source package manager.

```toml title="wally.toml"
[dependencies]
plasma = "evaera/plasma@0.4.2"
```

### Create the debugger
Create the debugger where you create your `Loop` and `World`:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Matter = require(Packages.matter)
local Plasma = require(Packages.plasma)

local debugger = Matter.Debugger.new(Plasma) -- Pass Plasma into the debugger!
local widgets = debugger:getWidgets()

local loop = Matter.Loop.new(world, state, widgets) -- Pass the widgets to all your systems!
```

Call `debugger:autoInitialize(loop)` to automatically set up the Loop middleware necessary to invoke the debugger every frame:

```lua
debugger:autoInitialize(loop)
```

Finally, we need a way to open the debugger You might want to only allow certain players to open the debugger, but that's up to you!

```lua
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F4 then
		debugger:toggle()
	end
end)
```

### Authorization

By default, the server-side debugger only works in Studio. To allow players to connect to the server-side debugger in live games, you need to specify an `authorize` function:

```lua
debugger.authorize = function(player)
	if player:GetRankInGroup(372) > 250 then -- example
		return true
	end
end
```

## Entity Highlight

### Highlight selected entity

To highlight the selected entity in the World inspector, create the `findInstanceFromEntity` function in the debugger.

```lua
debugger.findInstanceFromEntity = function(id)
	if not world:contains(id) then
		return
	end

	local model = world:get(id, components.Model)

	return model and model.model or nil
end
```

Change the above function so that it works with your game's component structure.

### Hover selection

Create attributes `clientEntityId` and `serverEntityId` on instances to enable in-world hover selection when you hold the <kbd>ALT</kbd> key. Click to select the entity.

<video controls width="600">
	<source src="https://i.eryn.io/2228/JzUKh1xj.mp4" type="video/mp4" />
</video>

This can be done by creating a system like this on both the client and the server.

```lua
local name = RunService:IsServer() and "serverEntityId" or "clientEntityId"

local function updateModelAttribute(world)
	for id, record in world:queryChanged(Components.Model) do
		if record.new then
			record.new.model:SetAttribute(name, id)
		end
	end
end
```

Change the above function so that it works with your game's component structure.

## Available widgets

The following Plasma widgets are available:

- arrow (3D Arrow gizmo for debugging Vector math)
- blur (blurs the camera background)
- button
- checkbox
- heading
- label
- portal (Insert instances into somewhere other than the provided frame)
- row (lay elements out horizontally)
- slider
- space (empty space)
- spinner (loading spinner)
- table
- window

For details on these widgets, check out the [Plasma docs](https://eryn.io/plasma/api/Plasma)

## Demo videos

> Demo of hot reloading and the [Matter debugger](/docs/Guides/MatterDebugger)
<video controls width="800">
	<source src="https://i.eryn.io/2227/9BmdqOYM.mp4" type="video/mp4" />
</video>

> Demo of the server-side debugger
<video controls width="800">
	<source src="https://i.eryn.io/2227/AHAItqM1.mp4" type="video/mp4" />
</video>

Note: When multiple players connect to the server-side debugger, their views are linked. There is only one instance of the server debugger (because creating UI elements within the server systems means the UI is owned by the server). Multiple players can connect to and share the server debugger.
