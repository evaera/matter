local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(script.Parent.Parent.components)
local Transform = Components.Transform
local Spinner = Components.Spinner
local useDeltaTime = require(ReplicatedStorage.Matter).useDeltaTime

local function move(world)
	for entityId, transform in world:query(Transform, Spinner) do
		world:insertOne(
			entityId,
			Transform({
				cframe = transform.cframe * CFrame.Angles(0, math.rad(90 * useDeltaTime()), 0),
			})
		)
	end
end

return move
