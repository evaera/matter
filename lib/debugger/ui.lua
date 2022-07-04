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

local function formatTable(object)
	local str = "{"

	local count = 0
	for key, value in object do
		if count > 0 then
			str ..= ", "
		end

		count += 1
		if type(key) == "string" then
			str ..= key .. "="
		elseif type(key) == "table" then
			str ..= "[{..}]="
		end

		if type(value) == "string" then
			str ..= '"' .. value:sub(1, 7) .. '"'
		elseif type(value) == "table" then
			str ..= "{..}"
		else
			str ..= tostring(value):sub(1, 7)
		end

		if count > 4 then
			str ..= ", .."
			break
		end
	end

	str ..= "}"

	return str
end

local timeUnits = { "s", "ms", "μs", "ns" }

local function ui(debugger, loop)
	local plasma = debugger.plasma
	local custom = debugger._customWidgets

	debugger.parent = custom.container(function()
		if debugger:_isServerView() then
			custom.panel(function()
				if plasma.button("switch to client"):clicked() then
					debugger:switchToClientView()
				end
			end, {
				fullHeight = false,
			})
			return
		end

		local objectStack = plasma.useState({})

		custom.panel(function()
			if RunService:IsClient() then
				if plasma.button("switch to server"):clicked() then
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
				})
			end

			local selectedState = custom.selectionList(items):selected()

			if selectedState then
				table.clear(objectStack)

				objectStack[1] = {
					key = selectedState.text,
					icon = selectedState.icon,
					value = selectedState.object,
				}
			end

			plasma.space(30)
			plasma.heading("SYSTEMS")
			plasma.space(10)

			for _, eventName in debugger._eventOrder do
				local systems = loop._orderedSystemsByEvent[eventName]

				if not systems then
					continue
				end

				plasma.heading(eventName)
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

						local unit = 1
						while duration < 1 and unit < #timeUnits do
							duration *= 1000
							unit += 1
						end

						averageFrameTime = string.format("%.0f%s", duration, timeUnits[unit])
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

		if #objectStack > 0 then
			local closed = plasma.window({
				title = "Inspect",
				movable = true,
				closable = true,
			}, function()
				plasma.row(function()
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
							custom.link(">", {
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
							if custom.link(formatTable(value), {
								font = Enum.Font.Code,
							}):clicked() then
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
		direction = Enum.FillDirection.Horizontal,
		marginTop = if RunService:IsServer() then 80 else 0,
	})
end

return ui
