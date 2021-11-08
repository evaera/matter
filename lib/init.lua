local RunService = game:GetService("RunService")
-- local t = require(script.Parent.t)

local World = require(script.World)
local newComponent = require(script.Component).newComponent

return {
	World = World,
	component = newComponent,
}
