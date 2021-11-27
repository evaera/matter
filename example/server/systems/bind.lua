local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(script.Parent.Parent.components)
local useDeltaTime = require(ReplicatedStorage.Matter).useDeltaTime

local Transform = Components.Transform
local BoundInstance = Components.BoundInstance

local function bind(world)
	for _, transform, boundInstance in world:query(Transform, BoundInstance) do
		boundInstance.instance.CFrame = transform.cframe
	end
end

return bind
