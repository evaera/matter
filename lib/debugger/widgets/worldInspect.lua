local formatTableModule = require(script.Parent.Parent.formatTable)
local formatTable = formatTableModule.formatTable

return function(plasma)
	return plasma.widget(function(worldView, setWorld, objectStack, custom)
		local closed = plasma.window({
			title = "World inspect",
			closable = true,
		}, function()
			local skipIntersections

			plasma.row(function()
				plasma.heading("Size")
				plasma.label(worldView.world:size())

				plasma.space(30)
				skipIntersections = plasma.checkbox("Hide intersecting components"):checked()

				if plasma.button("view raw"):clicked() then
					table.clear(objectStack)
					objectStack[1] = {
						value = worldView.world,
						key = "Raw World",
					}
				end
			end)

			if not worldView.cache or os.clock() - worldView.cache.createdTime > 3 then
				worldView.cache = {
					createdTime = os.clock(),
					uniqueComponents = {},
				}

				for entityId, entityData in worldView.world do
					for component in entityData do
						worldView.cache.uniqueComponents[component] = (worldView.cache.uniqueComponents[component] or 0)
							+ 1
					end
				end
			end

			local items = {}
			for component, count in worldView.cache.uniqueComponents do
				table.insert(items, {
					icon = count,
					text = tostring(component),
					component = component,
					selected = worldView.focusComponent == component,
				})
			end

			plasma.row({ padding = 30 }, function()
				local selectedItem = custom.selectionList(items, {
					width = 200,
				}):selected()

				if selectedItem then
					worldView.focusComponent = selectedItem.component
				end

				if worldView.focusComponent then
					local items = { { "Entity ID", tostring(worldView.focusComponent) } }
					local intersectingComponents = {}

					local intersectingData = {}

					for entityId, data in worldView.world:query(worldView.focusComponent) do
						table.insert(items, {
							entityId,
							formatTable(data),

							selected = worldView.focusEntity == entityId,
						})

						intersectingData[entityId] = {}

						if skipIntersections then
							continue
						end

						for component, value in worldView.world:_getEntity(entityId) do
							if component == worldView.focusComponent then
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

					plasma.useKey(tostring(worldView.focusComponent))

					local selectedRow = plasma.table(items, {
						font = Enum.Font.Code,
						selectable = true,
						headings = true,
					}):selected()

					if selectedRow then
						worldView.focusEntity = selectedRow[1]
					end
				end
			end)
		end):closed()

		if closed then
			setWorld(nil)
		end
	end)
end
