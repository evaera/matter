local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(ReplicatedStorage.Game.components)

local function updateModelAttribute(world)
	for id, record in world:queryChanged(Components.Model) do
		if record.new then
			record.new.model:SetAttribute("serverEntityId", id)
		end
	end
end

return updateModelAttribute
