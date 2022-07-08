local formatTableModule = require(script.Parent.Parent.formatTable)
local formatTable = formatTableModule.formatTable
local FormatMode = formatTableModule.FormatMode

return function(plasma)
	return plasma.widget(function(debugger)
		local closed = plasma.window({
			title = string.format("Entity %d", debugger.debugEntity),
			closable = true,
		}, function()
			if not debugger.debugWorld:contains(debugger.debugEntity) then
				debugger.debugEntity = nil
				return
			end

			if debugger.findInstanceFromEntity then
				local model = debugger.findInstanceFromEntity(debugger.debugEntity)

				if model then
					plasma.highlight(model)
				end
			end

			plasma.row(function()
				if plasma.button("despawn"):clicked() then
					debugger.debugWorld:despawn(debugger.debugEntity)
					debugger.debugEntity = nil
				end
			end)

			if not debugger.debugEntity then
				return
			end

			local items = { { "Component", "Data" } }

			for component, data in debugger.debugWorld:_getEntity(debugger.debugEntity) do
				table.insert(items, {
					tostring(component),
					formatTable(data, FormatMode.Long),
				})
			end

			plasma.useKey(debugger.debugEntity)
			plasma.table(items, {
				headings = true,
				font = Enum.Font.Code,
			})
		end):closed()

		if closed then
			debugger.debugEntity = nil
		end
	end)
end
