local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(ReplicatedStorage.Game.components)
local template = ReplicatedStorage.Assets.BillboardGui

local function debugVision(world, state)
	if not state.debugEnabled then
		for id, debugLabel in world:query(Components.DebugLabel) do
			debugLabel.label:Destroy()
			world:remove(id, Components.DebugLabel)
		end

		return
	end

	for id, model in world:query(Components.Model) do
		local debugLabel = world:get(id, Components.DebugLabel)

		if not debugLabel then
			local label = template:Clone()
			label.Parent = model.model.PrimaryPart
			label.Adornee = model.model.PrimaryPart

			debugLabel = Components.DebugLabel({
				label = label,
			})

			world:insert(id, debugLabel)
		end

		local text = ""

		for _, component in Components do
			local data = world:get(id, component)

			if data then
				text ..= tostring(component) .. " {"

				if next(data) then
					for key, value in data do
						text ..= "\n  " .. key .. ": " .. tostring(value)
					end

					text ..= "\n"
				end
				text ..= "}\n"
			end
		end

		debugLabel.label.TextLabel.Text = text
	end
end

return debugVision
