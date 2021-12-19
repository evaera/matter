local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(script.Parent.Parent.components)
local useDeltaTime = require(ReplicatedStorage.Matter).useDeltaTime

local Transform = Components.Transform
local Bind = Components.Bind

local function bindInstances(world)
	for _, transform, bind in world:query(Transform, Bind) do
		bind.instance.CFrame = transform.cframe
	end
end

return bindInstances
