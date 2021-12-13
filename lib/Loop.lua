local Llama = require(script.Parent.Parent.Llama)
local TopoRuntime = require(script.Parent.TopoRuntime)

local function systemFn(system: System)
	if type(system) == "table" then
		return system.system
	end

	return system
end

local function systemName(system: System)
	local fn = systemFn(system)
	return debug.info(fn, "s") .. "->" .. debug.info(fn, "n")
end

local function systemPriority(system: System)
	if type(system) == "table" then
		return system.priority or 0
	end

	return 0
end

local Loop = {}
Loop.__index = Loop

function Loop.new(...)
	return setmetatable({
		_systems = {},
		_orderedSystemsByEvent = {},
		_state = { ... },
		_stateLength = select("#", ...),
		_systemState = {},
	}, Loop)
end

type System = (...any) -> () | { system: (...any) -> (), event: string? }

function Loop:scheduleSystem(system: System)
	return self:scheduleSystems({ system })
end

function Loop:scheduleSystems(systems: { System })
	for _, system in ipairs(systems) do
		self._systems[system] = system
		self._systemState[system] = {}
	end

	self:_sortSystems()
end

local function orderSystemsByDependencies(unscheduledSystems: { System })
	table.sort(unscheduledSystems, function(a, b)
		return systemPriority(a) < systemPriority(b) or systemName(a) < systemName(b)
	end)

	local scheduledSystemsSet = {}
	local scheduledSystems = {}
	local tombstone = {}

	while #scheduledSystems < #unscheduledSystems do
		local atLeastOneScheduled = false

		local index = 1
		local priority
		while index <= #unscheduledSystems do
			local system = unscheduledSystems[index]

			-- If the system has already been scheduled it will have been replaced with this value
			if system == tombstone then
				index += 1
				continue
			end

			if priority == nil then
				priority = systemPriority(system)
			elseif systemPriority(system) ~= priority then
				break
			end

			local allScheduled = true

			if type(system) == "table" and system.after then
				for _, dependency in ipairs(system.after) do
					if scheduledSystemsSet[dependency] == nil then
						allScheduled = false
						break
					end
				end
			end

			if allScheduled then
				atLeastOneScheduled = true

				unscheduledSystems[index] = tombstone

				scheduledSystemsSet[system] = system
				table.insert(scheduledSystems, system)
			end

			index += 1
		end

		if not atLeastOneScheduled then
			error("Unable to schedule systems given current requirements")
		end
	end

	return scheduledSystems
end

function Loop:_sortSystems()
	local systemsByEvent = {}

	for system in pairs(self._systems) do
		local eventName = "default"

		if type(system) == "table" and system.event then
			eventName = system.event
		end

		if not systemsByEvent[eventName] then
			systemsByEvent[eventName] = {}
		end

		table.insert(systemsByEvent[eventName], system)
	end

	self._orderedSystemsByEvent = {}

	for eventName, systems in pairs(systemsByEvent) do
		self._orderedSystemsByEvent[eventName] = orderSystemsByDependencies(systems)
	end
end

function Loop:begin(events)
	local connections = {}

	for eventName, event in pairs(events) do
		if not self._orderedSystemsByEvent[eventName] then
			-- Skip events that have no systems
			continue
		end

		local lastTime = os.clock()
		local generation = false

		connections[eventName] = event:Connect(function()
			local currentTime = os.clock()
			local deltaTime = currentTime - lastTime
			lastTime = currentTime

			generation = not generation

			for _, system in ipairs(self._orderedSystemsByEvent[eventName]) do
				TopoRuntime.start({
					system = self._systemState[system],
					frame = {
						generation = generation,
						deltaTime = deltaTime,
					},
				}, function()
					local fn = systemFn(system)
					debug.profilebegin("system: " .. systemName(system))
					fn(unpack(self._state, 1, self._stateLength))
					debug.profileend()
				end)
			end
		end)
	end

	return connections
end

return Loop
