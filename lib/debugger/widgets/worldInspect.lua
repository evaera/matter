local TextureGenerationMeshHandler = game:GetService("TextureGenerationMeshHandler")

local formatTableModule = require(script.Parent.Parent.formatTable)
local formatTable = formatTableModule.formatTable

return function(plasma)
	return plasma.widget(function(debugger, objectStack)
		local custom = debugger._customWidgets
		local style = plasma.useStyle()

		local world = debugger.debugWorld

		local cache, setCache = plasma.useState()
		local sort, setSort = plasma.useState("alphabetical")
		local showIntersections, setShowIntersections = plasma.useState(false)
		local debugComponent, setDebugComponent = plasma.useState()

		local closed = plasma
			.window({
				title = `WORLD INSPECT`,
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
					plasma.label(`{world:size()} ({cache.emptyEntities} empty)`)
				end)

				--[[plasma.row(function()
					plasma.heading("Sort")
					--plasma.space(15)

					if plasma.checkbox("Alphabetical", { checked = sort == "alphabetical" }):clicked() then
						setSort("alphabetical")
					end

					if plasma.checkbox("Ascending", { checked = sort == "ascending" }):clicked() then
						setSort("ascending")
					end

					--plasma.space(50)
				end)]]

				plasma.row({ padding = 15 }, function()
					if plasma.checkbox("Show intersections", { checked = showIntersections }):clicked() then
						setShowIntersections(not showIntersections)
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
						icon = count,
						text = tostring(component),
						component = component,
						selected = debugComponent == component,
					})
				end
				table.sort(items, function(a, b)
					if sort == "alphabetical" then
						return a.text < b.text
					else
						return a.icon > b.icon
					end
				end)

				plasma.row({ padding = 30 }, function()
					local newItems = { { "Count", "Component" } }
					for _, data in items do
						print(type(debugComponent), data.text, debugComponent == data.text)
						table.insert(
							newItems,
							{ data.icon, data.text, selected = tostring(debugComponent) == data.text }
						)
					end

					local selectedRow = plasma
						.table(newItems, {
							width = 200,
							headings = true,
							selectable = true,
						})
						:selected()

					if selectedRow then
						local selectedItem = nil
						for _, data in items do
							if data.text == selectedRow[2] then
								selectedItem = data
							end
						end

						print(selectedItem.component)
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

							if not showIntersections then
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
