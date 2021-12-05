local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(script.Parent.Parent.components)
local Matter = require(ReplicatedStorage.Matter)
local useEvent = Matter.useEvent
local useDeltaTime = Matter.useDeltaTime

local BoundInstance = Components.BoundInstance

local function partsChangeColor(world)
	for entityId, boundInstance in world:query(BoundInstance):without(Components.ColorTween) do
		useEvent(boundInstance.instance.Touched, function()
			world:insert(
				entityId,
				Components.ColorTween({
					goal = BrickColor.random().Color,
					time = os.clock(),
				})
			)
		end)
	end

	for entityId, boundInstance, tween in world:query(BoundInstance, Components.ColorTween) do
		boundInstance.instance.Color = boundInstance.instance.Color:lerp(tween.goal, useDeltaTime() * 2)

		if os.clock() - tween.time > 1 then
			world:remove(entityId, Components.ColorTween)
		end
	end
end

return partsChangeColor
