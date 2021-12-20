local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(script.Parent.Parent.components)
local Matter = require(ReplicatedStorage.Matter)
local removeMissingModels = require(script.Parent.removeMissingModels)

local function updateTransforms(world)
	for id, model in world:query(Components.Model, Components.Transform) do
		world:insert(
			id,
			Components.Transform({
				cframe = model.model.PrimaryPart.CFrame,
			})
		)
	end
end

return {
	system = updateTransforms,
	after = { removeMissingModels },
}
