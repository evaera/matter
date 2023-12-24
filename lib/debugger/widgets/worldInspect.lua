local formatTableModule = require(script.Parent.Parent.formatTable)
local formatTable = formatTableModule.formatTable

return function(plasma)
	return plasma.widget(function(debugger, objectStack)
		local custom = debugger._customWidgets
		local style = plasma.useStyle()

		local world = debugger.debugWorld

		local cache, setCache = plasma.useState()
		-- TODO #97 Implement sorting by descending as well.
		local ascendingOrder, _ = plasma.useState(false)
		local skipIntersections, setSkipIntersections = plasma.useState(true)
		local debugComponent, setDebugComponent = plasma.useState()

		local closed = plasma
			.window({
				title = "World inspect",
				closable = true,
			}, function()
				if not cache or os.clock() - cache.createdTime > debugger.componentRefreshFrequency then
					cache = {
						createdTime = os.clock(),
						uniqueComponents = {},
						emptyEntities = 0,
					}

					setCache(cache)

					for _, entityData in world do
						if next(entityData) == nil then
							cache.emptyEntities += 1
						else
							for component in entityData do
								cache.uniqueComponents[component] = (cache.uniqueComponents[component] or 0) + 1
							end
						end
					end
				end

				plasma.row(function()
					plasma.heading("Size")
					plasma.label(
						`{world:size()} {if cache.emptyEntities > 0 then `({cache.emptyEntities} empty)` else ""}`
					)
				end)

				plasma.row({ padding = 15 }, function()
					if plasma.checkbox("Show intersections", { checked = not skipIntersections }):clicked() then
						setSkipIntersections(not skipIntersections)
					end

					if plasma.button("View Raw"):clicked() then
						table.clear(objectStack)
						objectStack[1] = {
							value = world,
							key = "Raw World",
						}
					end
				end)

				local items = {}
				for component, count in cache.uniqueComponents do
					table.insert(items, {
						count,
						tostring(component),
						selected = debugComponent == component,
						component = component,
					})
				end

				table.sort(items, function(a, b)
					if ascendingOrder then
						return a[1] < b[1]
					end

					-- Default to alphabetical
					return a[2] < b[2]
				end)

				table.insert(items, 1, { "Count", "Component" })

				plasma.row({ padding = 30 }, function()
					local selectedRow = plasma
						.table(items, {
							width = 200,
							headings = true,
							selectable = true,
						})
						:selected()

					if selectedRow then
						setDebugComponent(selectedRow.component)
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
			end)
			:closed()

		if closed then
			return closed
		end
		return nil
	end)
end
