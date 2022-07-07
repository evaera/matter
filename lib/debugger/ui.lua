local RunService = game:GetService("RunService")
local World = require(script.Parent.Parent.World)
local rollingAverage = require(script.Parent.Parent.rollingAverage)

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

	plasma.setStyle({
		primaryColor = Color3.fromHex("bd515c"),
	})

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

				local selected = (#objectStack > 0 and object == objectStack[#objectStack].value)
					or (worldView and worldView.world == object)

				table.insert(items, {
					text = (if isWorld then "World" else "table") .. " " .. index,
					icon = if isWorld then "🌐" else "{}",
					object = object,
					selected = selected,
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
				custom.worldInspect(worldView, setWorld, objectStack, debugger)
			end

			if worldView and worldView.focusEntity then
				custom.entityInspect(worldView, debugger)
			end

			if #objectStack > 0 then
				custom.valueInspect(objectStack, custom)
			end

			if debugger.debugSystem then
				local closed = plasma.window({
					title = "System config",
					closable = true,
				}, function()
					plasma.useKey(systemName(debugger.debugSystem))
					plasma.heading(systemName(debugger.debugSystem))
					plasma.space(0)

					local currentlyDisabled = loop._skipSystems[debugger.debugSystem]

					if plasma.checkbox("Disable system", {
						checked = currentlyDisabled,
					}):clicked() then
						loop._skipSystems[debugger.debugSystem] = not currentlyDisabled
					end
				end):closed()

				if closed then
					debugger.debugSystem = nil
				end
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
