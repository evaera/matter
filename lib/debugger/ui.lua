local RunService = game:GetService("RunService")
local World = require(script.Parent.Parent.World)
local rollingAverage = require(script.Parent.Parent.rollingAverage)

local formatTableModule = require(script.Parent.formatTable)
local formatTable = formatTableModule.formatTable
local FormatMode = formatTableModule.FormatMode

local function systemName(system)
	local systemFn = if type(system) == "table" then system.system else system
	local name = debug.info(systemFn, "n")

	if name ~= "" and name ~= "system" then
		return name
	end

	local source = debug.info(systemFn, "s")
	local segments = string.split(source, ".")

	return segments[#segments]
end

local timeUnits = { "s", "ms", "μs", "ns" }
local function formatDuration(duration)
	local unit = 1
	while duration < 1 and unit < #timeUnits do
		duration *= 1000
		unit += 1
	end

	return duration, timeUnits[unit]
end

local function ui(debugger, loop)
	local plasma = debugger.plasma
	local custom = debugger._customWidgets

	custom.container(function()
		if debugger:_isServerView() then
			return
		end

		local objectStack = plasma.useState({})
		local worldView, setWorld = plasma.useState()

		custom.panel(function()
			if
				custom.realmSwitch({
					left = "client",
					right = "server",
					isRight = RunService:IsServer(),
					tag = if RunService:IsServer() then "MatterDebuggerSwitchToClientView" else nil,
				}):clicked()
			then
				if RunService:IsClient() then
					debugger:switchToServerView()
				end
			end

			plasma.space(30)

			plasma.heading("STATE")
			plasma.space(10)

			local items = {}

			for index, object in loop._state do
				local isWorld = getmetatable(object) == World

				table.insert(items, {
					text = (if isWorld then "World" else "table") .. " " .. index,
					icon = if isWorld then "🌐" else "{}",
					object = object,
					selected = if #objectStack > 0 then object == objectStack[#objectStack].value else false,
					isWorld = isWorld,
				})
			end

			local selectedState = custom.selectionList(items):selected()

			if selectedState then
				if selectedState.isWorld then
					setWorld({ world = selectedState.object })
				else
					table.clear(objectStack)

					objectStack[1] = {
						key = selectedState.text,
						icon = selectedState.icon,
						value = selectedState.object,
					}
				end
			end

			plasma.space(30)
			plasma.heading("SYSTEMS")
			plasma.space(10)

			for _, eventName in debugger._eventOrder do
				local systems = loop._orderedSystemsByEvent[eventName]

				if not systems then
					continue
				end

				plasma.heading(eventName, {
					font = Enum.Font.Gotham,
				})
				plasma.space(10)
				local items = {}

				for _, system in systems do
					local samples = loop.profiling[system]
					local averageFrameTime = ""
					local icon

					if samples then
						local duration = rollingAverage.getAverage(samples)

						if duration > 0.004 then -- 4ms
							icon = "⚠️"
						end

						local humanDuration, unit = formatDuration(duration)

						averageFrameTime = string.format("%.0f%s", humanDuration, unit)
					end

					table.insert(items, {
						text = systemName(system),
						sideText = averageFrameTime,
						selected = debugger.debugSystem == system,
						system = system,
						icon = icon,
					})
				end

				local selected = custom.selectionList(items):selected()

				if selected then
					if selected.system == debugger.debugSystem then
						debugger.debugSystem = nil
					else
						debugger.debugSystem = selected.system
					end
				end

				plasma.space(20)
			end
		end)

		debugger.parent = custom.container(function()
			if worldView then
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
								worldView.cache.uniqueComponents[component] = (
										worldView.cache.uniqueComponents[component] or 0
									) + 1
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
			end

			if worldView and worldView.focusEntity then
				local closed = plasma.window({
					title = string.format("Entity %d", worldView.focusEntity),
					closable = true,
				}, function()
					plasma.row(function()
						if plasma.button("despawn"):clicked() then
							worldView.world:despawn(worldView.focusEntity)
						end
					end)

					local items = { { "Component", "Data" } }

					if not worldView.world:contains(worldView.focusEntity) then
						worldView.focusEntity = nil
						return
					end

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
			end

			if #objectStack > 0 then
				local closed = plasma.window({
					title = "Inspect",
					closable = true,
				}, function()
					plasma.row({ padding = 5 }, function()
						for i, object in objectStack do
							if custom.link(object.key, {
								icon = object.icon or "{}",
							}):clicked() then
								local difference = #objectStack - i

								for _ = 1, difference do
									table.remove(objectStack, #objectStack)
								end
							end

							if i < #objectStack then
								custom.link("▶", {
									disabled = true,
								})
							end
						end
					end)

					local items = {}

					for key, value in pairs(objectStack[#objectStack].value) do
						local valueItem

						if type(value) == "table" then
							valueItem = function()
								if
									custom.link(formatTable(value), {
										font = Enum.Font.Code,
									}):clicked()
								then
									table.insert(objectStack, {
										key = if type(key) == "table" then formatTable(key) else tostring(key),
										value = value,
									})
								end
							end
						else
							valueItem = tostring(value)
						end

						table.insert(items, {
							tostring(key),
							valueItem,
						})
					end

					plasma.useKey(tostring(objectStack[#objectStack].key) .. ":" .. #objectStack)

					if #items == 0 then
						return plasma.label("(empty table)")
					end

					plasma.table(items)
				end):closed()

				if closed then
					table.clear(objectStack)
				end
			end

			if debugger.debugSystem then
				plasma.window("System config", function()
					plasma.useKey(systemName(debugger.debugSystem))
					plasma.heading(systemName(debugger.debugSystem))
					plasma.space(0)

					local currentlyDisabled = loop._skipSystems[debugger.debugSystem]

					if plasma.checkbox("Disable system", {
						checked = currentlyDisabled,
					}):clicked() then
						loop._skipSystems[debugger.debugSystem] = not currentlyDisabled
					end
				end)
			end

			debugger.frame = custom.frame()
		end, {
			marginTop = 46,
			marginLeft = 10,
			direction = Enum.FillDirection.Horizontal,
		})
	end, {
		direction = Enum.FillDirection.Horizontal,
		padding = 0,
	})
end

return ui
