--[=[
	@class Matter

	Matter. It's what everything is made out of.
]=]

--[=[
	@within Matter
	@prop World World
]=]

--[=[
	@within Matter
	@prop Loop Loop
]=]

--[=[
	@within Matter
	@prop Debugger Debugger
]=]

--[=[
	@within Matter
	@prop None None

	A value should be interpreted as nil when merging dictionaries.

	`Matter.None` is used by [`Component:patch`](/api/Component#patch).
]=]

--[=[
	@within Matter
	@function component
	@param name? string -- Optional name for debugging purposes
	@param defaultData? {} -- Default data that will be merged with data passed to the component when created
	@return Component -- Your new type of component

	Creates a new type of component. Call the component as a function to create an instance of that component.

	If `defaultData` is specified, it will be merged with data passed to the component when the component instance is
	created. Note that this is not *fallback* data: if you later remove a field from a component instance that is
	specified in the default data, it won't fall back to the value specified in default data.

	```lua
	-- Component:
	local MyComponent = Matter.component("My component")

	-- component instance:
	local myComponentInstance = MyComponent({
		some = "data"
	})
	```
]=]

local immutable = require(script.immutable)
local World = require(script.World)
local Loop = require(script.Loop)
local newComponent = require(script.component).newComponent
local topoRuntime = require(script.topoRuntime)

export type World = typeof(World.new())
export type Loop = typeof(Loop.new())

return table.freeze({
	World = World,
	Loop = Loop,

	component = newComponent,

	useEvent = require(script.hooks.useEvent),
	useDeltaTime = require(script.hooks.useDeltaTime),
	useThrottle = require(script.hooks.useThrottle),
	log = require(script.hooks.log),
	useHookState = topoRuntime.useHookState,
	useCurrentSystem = topoRuntime.useCurrentSystem,

	merge = immutable.merge,
	None = immutable.None,

	Debugger = require(script.debugger.debugger),
})
