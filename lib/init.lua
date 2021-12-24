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
	@prop None None

	A value should be interpreted as nil when merging dictionaries.

	`Matter.None` is used by [`Component:patch`](/api/Component#patch).
]=]

--[=[
	@within Matter
	@function component
	@param name? string -- Optional name for debugging purposes
	@return Component -- Your new type of component

	Creates a new type of component. Call the component as a function to create an instance of that component.

	```lua
	-- Component:
	local MyComponent = Matter.component("My component")

	-- component instance:
	local myComponentInstance = MyComponent({
		some = "data"
	})
	```
]=]

local Llama = require(script.Parent.Llama)
local World = require(script.World)
local Loop = require(script.Loop)
local newComponent = require(script.Component).newComponent

return {
	World = World,
	Loop = Loop,

	component = newComponent,

	useEvent = require(script.hooks.useEvent),
	useDeltaTime = require(script.hooks.useDeltaTime),
	useThrottle = require(script.hooks.useThrottle),
	useHookState = require(script.TopoRuntime).useHookState,

	merge = Llama.Dictionary.merge,
	None = Llama.None,
}
