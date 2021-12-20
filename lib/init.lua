-- local t = require(script.Parent.t)

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

	merge = Llama.Dictionary.merge,
}
