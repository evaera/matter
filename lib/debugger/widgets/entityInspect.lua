local formatTableModule = require(script.Parent.Parent.formatTable)
local formatTable = formatTableModule.formatTable
local FormatMode = formatTableModule.FormatMode

return function(plasma)
	return plasma.widget(function(worldView, debugger)
		local style = plasma.useStyle()

		local closed = plasma.window({
			title = string.format("Entity %d", worldView.focusEntity),
			closable = true,
		}, function()
			if not worldView.world:contains(worldView.focusEntity) then
				worldView.focusEntity = nil
				return
			end

			if debugger.findInstanceFromEntityId then
				local model = debugger.findInstanceFromEntityId(worldView.focusEntity)

				if model then
					plasma.highlight(model)
				end
			end

			plasma.row(function()
				if plasma.button("despawn"):clicked() then
					worldView.world:despawn(worldView.focusEntity)
				end
			end)

			local items = { { "Component", "Data" } }

			for component, data in worldView.world:_getEntity(worldView.focusEntity) do
				table.insert(items, {
					tostring(component),
					formatTable(data, FormatMode.Long),
				})
			end

			plasma.useKey(worldView.focusEntity)
			plasma.table(items, {
				headings = true,
				font = Enum.Font.Code,
			})
		end):closed()

		if closed then
			worldView.focusEntity = nil
		end
	end)
end
