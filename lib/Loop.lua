local Llama = require(script.Parent.Parent.Llama)
local TopoStack = require(script.Parent.TopoStack)

local function getSystemFunction(system: System)
	if type(system) == "table" then
		return system.system
	end

	return system
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
		local fnA = getSystemFunction(a)
		local fnB = getSystemFunction(b)

		local nameA = debug.info(fnA, "s") .. "->" .. debug.info(fnA, "n")
		local nameB = debug.info(fnB, "s") .. "->" .. debug.info(fnB, "n")

		return nameA > nameB
	end)

	local scheduledSystems = {}
	local orderedSystems = {}

	while next(unscheduledSystems) do
		local atLeastOneScheduled = false

		local index = 1
		while index <= #unscheduledSystems do
			local system = unscheduledSystems[index]

			local allScheduled = true

			if type(system) == "table" and system.after then
				for _, dependency in ipairs(system.after) do
					if scheduledSystems[dependency] == nil then
						allScheduled = false
						break
					end
				end
			end

			if allScheduled then
				atLeastOneScheduled = true

				-- swap removal
				unscheduledSystems[index] = unscheduledSystems[#unscheduledSystems]
				unscheduledSystems[#unscheduledSystems] = nil

				scheduledSystems[system] = system
				table.insert(orderedSystems, system)
			else
				index += 1
			end
		end

		if not atLeastOneScheduled then
			error("Unable to schedule systems given current requirements")
		end
	end

	return orderedSystems
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

			TopoStack.push({
				generation = generation,
				deltaTime = deltaTime,
			})

			for _, system in ipairs(self._orderedSystemsByEvent[eventName]) do
				local info = TopoStack.peek()
				info.systemState = self._systemState[system]

				local fn = getSystemFunction(system)
				fn(unpack(self._state, 1, self._stateLength))
			end

			TopoStack.pop()
		end)
	end

	return connections
end

return Loop
