local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(script.Parent.Parent.components)
local Matter = require(ReplicatedStorage.Matter)
local removeMissingModels = require(script.Parent.removeMissingModels)

local function updateTransforms(world)
	-- Handle Transform added/changed to existing entity with Model
	for _id, transformRecord, model in world:queryChanged(Components.Transform, Components.Model) do
		if transformRecord.new and not transformRecord.new.doNotReconcile then
			model.model:SetPrimaryPartCFrame(transformRecord.new.cframe)
		end
	end

	-- Handle Model added/changed on existing entity with Transform
	for _id, modelRecord, transform in world:queryChanged(Components.Model, Components.Transform) do
		if modelRecord.new then
			modelRecord.new.model:SetPrimaryPartCFrame(transform.cframe)
		end
	end

	-- Update Transform on unanchored Models
	for id, model in world:query(Components.Model, Components.Transform) do
		if model.model.PrimaryPart.Anchored then
			continue
		end

		local existingCFrame = world:get(id, Components.Transform)
		local currentCFrame = model.model.PrimaryPart.CFrame

		if currentCFrame ~= existingCFrame then
			world:insert(
				id,
				Components.Transform({
					cframe = currentCFrame,
					doNotReconcile = true,
				})
			)
		end
	end
end

return {
	system = updateTransforms,
	after = { removeMissingModels },
}
