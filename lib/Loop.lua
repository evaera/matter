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

-- TODO: Let systems specify what event they run on by string name
function Loop.new(...)
	return setmetatable({
		_systems = {},
		_orderedSystems = {},
		_state = { ... },
		_stateLength = select("#", ...),
		_systemState = {},
		_generation = false,
	}, Loop)
end

type System = (...any) -> () | { system: (...any) -> () }

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

function Loop:getOrderedSystems()
	return self._orderedSystems
end

function Loop:_sortSystems()
	local unscheduledSystems = Llama.Dictionary.keys(self._systems)

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

	self._orderedSystems = orderedSystems
end

-- TODO: Pass map of name -> event
function Loop:begin(event)
	local lastTime = os.clock()

	return event:Connect(function()
		local currentTime = os.clock()
		local deltaTime = currentTime - lastTime
		lastTime = currentTime

		self._generation = not self._generation

		TopoStack.push({
			generation = self._generation,
			deltaTime = deltaTime,
		})

		for _, system in ipairs(self._orderedSystems) do
			local info = TopoStack.peek()
			info.systemState = self._systemState[system]

			local fn = getSystemFunction(system)
			fn(unpack(self._state, 1, self._stateLength))
		end

		TopoStack.pop()
	end)
end

return Loop
