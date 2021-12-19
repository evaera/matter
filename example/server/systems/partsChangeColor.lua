local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(script.Parent.Parent.components)
local Matter = require(ReplicatedStorage.Matter)
local useEvent = Matter.useEvent
local useThrottle = Matter.useThrottle
local useDeltaTime = Matter.useDeltaTime

local Bind = Components.Bind

local function partsChangeColor(world)
	for entityId, bind in world:query(Bind):without(Components.ColorTween) do
		for _ in useEvent(bind.instance, "Touched") do
			if useThrottle(1, entityId) then
				world:insert(
					entityId,
					Components.ColorTween({
						goal = BrickColor.random().Color,
						time = os.clock(),
					})
				)
			end
		end
	end

	for entityId, bind, tween in world:query(Bind, Components.ColorTween) do
		bind.instance.Color = bind.instance.Color:lerp(tween.goal, useDeltaTime() * 2)

		if os.clock() - tween.time >= 1 then
			world:remove(entityId, Components.ColorTween)
		end
	end

	for entityId, tweenRecord, bind in world:queryChanged(Components.ColorTween, Bind) do
		if tweenRecord.new then
			bind.instance.Transparency = 0.5
		else
			bind.instance.Transparency = 0
		end
	end
end

return partsChangeColor
