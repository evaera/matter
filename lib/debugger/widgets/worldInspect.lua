local formatTableModule = require(script.Parent.Parent.formatTable)
local formatTable = formatTableModule.formatTable

return function(plasma)
	return plasma.widget(function(debugger, objectStack)
		local custom = debugger._customWidgets
		local style = plasma.useStyle()

		local world = debugger.debugWorld

		local cache, setCache = plasma.useState()
		local debugComponent, setDebugComponent = plasma.useState()

		local closed = plasma.window({
			title = "World inspect",
			closable = true,
		}, function()
			local skipIntersections

			plasma.row(function()
				plasma.heading("Size")
				plasma.label(world:size())

				plasma.space(30)
				skipIntersections = plasma.checkbox("Hide intersecting components"):checked()

				if plasma.button("view raw"):clicked() then
					table.clear(objectStack)
					objectStack[1] = {
						value = world,
						key = "Raw World",
					}
				end
			end)

			if not cache or os.clock() - cache.createdTime > debugger.componentRefreshFrequency then
				cache = {
					createdTime = os.clock(),
					uniqueComponents = {},
				}

				setCache(cache)

				for entityId, entityData in world do
					for component in entityData do
						cache.uniqueComponents[component] = (cache.uniqueComponents[component] or 0) + 1
					end
				end
			end

			local items = {}
			for component, count in cache.uniqueComponents do
				table.insert(items, {
					icon = count,
					text = tostring(component),
					component = component,
					selected = debugComponent == component,
				})
			end
			table.sort(items, function(a, b)
				return a.text < b.text	
			end)

			plasma.row({ padding = 30 }, function()
				local selectedItem = custom.selectionList(items, {
					width = 200,
				}):selected()

				if selectedItem then
					setDebugComponent(selectedItem.component)
				end

				if debugComponent then
					local items = { { "Entity ID", tostring(debugComponent) } }
					local intersectingComponents = {}

					local intersectingData = {}

					for entityId, data in world:query(debugComponent) do
						table.insert(items, {
							entityId,
							formatTable(data),

							selected = debugger.debugEntity == entityId,
						})

						intersectingData[entityId] = {}

						if skipIntersections then
							continue
						end

						for component, value in world:_getEntity(entityId) do
							if component == debugComponent then
								continue
							end

							local index = table.find(intersectingComponents, component)

							if not index then
								table.insert(intersectingComponents, component)

								index = #intersectingComponents
							end

							intersectingData[entityId][index] = value
						end
					end

					for i, item in items do
						if i == 1 then
							for _, component in intersectingComponents do
								table.insert(item, tostring(component))
							end

							continue
						end

						for i = 1, #intersectingComponents do
							local data = intersectingData[item[1]][i]

							table.insert(item, if data then formatTable(data) else "")
						end
					end

					plasma.useKey(tostring(debugComponent))

					local tableWidget = plasma.table(items, {
						font = Enum.Font.Code,
						selectable = true,
						headings = true,
					})

					local selectedRow = tableWidget:selected()
					local hovered = tableWidget:hovered()

					if selectedRow then
						debugger.debugEntity = selectedRow[1]
					end

					if hovered then
						local entityId = hovered[1]

						if debugger.debugEntity == entityId or not world:contains(entityId) then
							return
						end

						if debugger.findInstanceFromEntity then
							local model = debugger.findInstanceFromEntity(entityId)

							if model then
								plasma.highlight(model, {
									fillColor = style.primaryColor,
								})
							end
						end
					end
				end
			end)
		end):closed()

		if closed then
			return closed
		end
		return nil
	end)
end
