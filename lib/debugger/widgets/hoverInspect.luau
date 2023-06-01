local formatTableModule = require(script.Parent.Parent.formatTable)
local formatTable = formatTableModule.formatTable
local FormatMode = formatTableModule.FormatMode

return function(plasma)
	return plasma.widget(function(world, id, custom)
		local entityData = world:_getEntity(id)

		local str = "Entity " .. id .. "\n\n"

		for component, componentData in pairs(entityData) do
			str ..= tostring(component) .. " "

			if next(componentData) == nil then
				str ..= "{ }"
			else
				str ..= formatTable(componentData, FormatMode.Long, 0, 2)
			end
			str ..= "\n"
		end

		custom.tooltip(str)
	end)
end
