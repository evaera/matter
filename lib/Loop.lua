local topoRuntime = require(script.Parent.topoRuntime)
local rollingAverage = require(script.Parent.rollingAverage)

local recentErrors = {}
local recentErrorLastTime = 0

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

--[=[
	@class Loop

	The Loop class handles scheduling and *looping* (who would have guessed) over all of your game systems.

	:::caution Yielding
	Yielding is not allowed in systems. Doing so will result in the system thread being closed early, but it will not
	affect other systems.
	:::
]=]
local Loop = {}
Loop.__index = Loop

--[=[
	Creates a new loop. `Loop.new` accepts as arguments the values that will be passed to all of your systems.

	So typically, you want to pass the World in here, as well as maybe a table of global game state.

	```lua
	local world = World.new()
	local gameState = {}

	local loop = Loop.new(world, gameState)
	```

	@param ... ...any -- Values that will be passed to all of your systems
	@return Loop
]=]
function Loop.new(...)
	return setmetatable({
		_systems = {},
		_skipSystems = {},
		_orderedSystemsByEvent = {},
		_state = { ... },
		_stateLength = select("#", ...),
		_systemState = {},
		_middlewares = {},
	}, Loop)
end

--[=[
	@within Loop
	@type System SystemTable | (...any) -> ()

	Either a plain function or a table defining the system.
]=]

--[=[
	@within Loop
	@interface SystemTable
	.system (...any) -> () -- The system function
	.event? string -- The event the system runs on. A string, a key from the table you pass to `Loop:begin`.
	.priority? number -- Priority influences the position in the frame the system is scheduled to run at.
	.after? {System} -- A list of systems that this system must run after.

	A table defining a system with possible options.

	Systems are scheduled in order of `priority`, meaning lower `priority` runs first.
	The default priority is `0`.
]=]

type System = (...any) -> () | { system: (...any) -> (), event: string?, priority: number?, after: nil | {} }

--[=[
	Schedules a set of systems based on the constraints they define.

	Systems may optionally declare:
	- The name of the event they run on (e.g., RenderStepped, Stepped, Heartbeat)
	- A numerical priority value
	- Other systems that they must run *after*

	If systems do not specify an event, they will run on the `default` event.

	Systems that share an event will run in order of their priority, which means that systems with a lower `priority`
	value run first. The default priority is `0`.

	Systems that have defined what systems they run `after` can only be scheduled after all systems they depend on have
	already been scheduled.

	All else being equal, the order in which systems run is stable, meaning if you don't change your code, your systems
	will always run in the same order across machines.

	:::info
	It is possible for your systems to be in an unresolvable state. In which case, `scheduleSystems` will error.
	This can happen when your systems have circular or unresolvable dependency chains.

	If a system has both a `priority` and defines systems it runs `after`, the system can only be scheduled if all of
	the systems it depends on have a lower or equal priority.

	Systems can never depend on systems that run on other events, because it is not guaranteed or required that events
	will fire every frame or will always fire in the same order.
	:::

	:::caution
	`scheduleSystems` has to perform nontrivial sorting work each time it's called, so you should avoid calling it multiple
	times if possible.
	:::

	@param systems { System } -- Array of systems to schedule.
]=]
function Loop:scheduleSystems(systems: { System })
	for _, system in ipairs(systems) do
		self._systems[system] = system
		self._systemState[system] = {}
	end

	self:_sortSystems()
end

--[=[
	Schedules a single system. This is an expensive function to call multiple times. Instead, try batch scheduling
	systems with [Loop:scheduleSystems] if possible.

	@param system System
]=]
function Loop:scheduleSystem(system: System)
	return self:scheduleSystems({ system })
end

--[=[
	Removes a previously-scheduled system from the Loop. Evicting a system also cleans up any storage from hooks.
	This is intended to be used for hot reloading. Dynamically loading and unloading systems for gameplay logic
	is not recommended.

	@param system System
]=]
function Loop:evictSystem(system: System)
	if self._systems[system] == nil then
		error("Can't evict system because it doesn't exist")
	end

	self._systems[system] = nil

	topoRuntime.start({
		system = self._systemState[system],
	}, function() end)

	self._systemState[system] = nil

	self:_sortSystems()
end

--[=[
	Replaces an older version of a system with a newer version of the system. Internal system storage (which is used
	by hooks) will be moved to be associated with the new system. This is intended to be used for hot reloading.

	@param old System
	@param new System
]=]
function Loop:replaceSystem(old: System, new: System)
	if not self._systems[old] then
		error("Before system does not exist!")
	end

	self._systems[new] = new
	self._systems[old] = nil
	self._systemState[new] = self._systemState[old] or {}
	self._systemState[old] = nil

	if self._skipSystems[old] then
		self._skipSystems[old] = nil
		self._skipSystems[new] = true
	end

	for system in self._systems do
		if type(system) == "table" and system.after then
			local index = table.find(system.after, old)

			if index then
				system.after[index] = new
			end
		end
	end

	self:_sortSystems()
end

local function orderSystemsByDependencies(unscheduledSystems: { System })
	table.sort(unscheduledSystems, function(a, b)
		local priorityA = systemPriority(a)
		local priorityB = systemPriority(b)

		if priorityA == priorityB then
			return systemName(a) < systemName(b)
		end

		return priorityA < priorityB
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

--[=[
	Connects to frame events and starts invoking your systems.

	Pass a table of events you want to be able to run systems on, a map of name to event. Systems can use these names
	to define what event they run on. By default, systems run on an event named `"default"`. Custom events may be used
	if they have a `Connect` function.

	```lua
	loop:begin({
		default = RunService.Heartbeat,
		Heartbeat = RunService.Heartbeat,
		RenderStepped = RunService.RenderStepped,
		Stepped = RunService.Stepped,
	})
	```

	&nbsp;

	Returns a table similar to the one you passed in, but the values are `RBXScriptConnection` values (or whatever is
	returned by `:Connect` if you passed in a synthetic event).

	@param events {[string]: RBXScriptSignal} -- A map from event name to event objects.
	@return {[string]: RBXScriptConnection} -- A map from your event names to connection objects.
]=]
function Loop:begin(events)
	local connections = {}

	for eventName, event in pairs(events) do
		local lastTime = os.clock()
		local generation = false

		local function stepSystems()
			if not self._orderedSystemsByEvent[eventName] then
				-- Skip events that have no systems
				return
			end

			local currentTime = os.clock()
			local deltaTime = currentTime - lastTime
			lastTime = currentTime

			generation = not generation

			local dirtyWorlds = {}
			local profiling = self.profiling

			for _, system in ipairs(self._orderedSystemsByEvent[eventName]) do
				topoRuntime.start({
					system = self._systemState[system],
					frame = {
						generation = generation,
						deltaTime = deltaTime,
						dirtyWorlds = dirtyWorlds,
					},
					currentSystem = system,
				}, function()
					if self._skipSystems[system] then
						profiling[system] = nil
						return
					end

					local fn = systemFn(system)
					debug.profilebegin("system: " .. systemName(system))

					local thread = coroutine.create(fn)

					local startTime = os.clock()
					local success, errorValue = coroutine.resume(thread, unpack(self._state, 1, self._stateLength))

					if profiling ~= nil then
						local duration = os.clock() - startTime

						if profiling[system] == nil then
							profiling[system] = {}
						end

						rollingAverage.addSample(profiling[system], duration)
					end

					if coroutine.status(thread) ~= "dead" then
						coroutine.close(thread)

						task.spawn(
							error,
							(
								"Matter: System %s yielded! Its thread has been closed. "
								.. "Yielding in systems is not allowed."
							):format(systemName(system))
						)
					end

					for world in dirtyWorlds do
						world:optimizeQueries()
					end
					table.clear(dirtyWorlds)

					if not success then
						if os.clock() - recentErrorLastTime > 10 then
							recentErrorLastTime = os.clock()
							recentErrors = {}
						end

						local errorString = systemName(system)
							.. ": "
							.. tostring(errorValue)
							.. "\n"
							.. debug.traceback(thread)

						if not recentErrors[errorString] then
							task.spawn(error, errorString)
							warn("Matter: The above error will be suppressed for the next 10 seconds")
							recentErrors[errorString] = true
						end
					end

					debug.profileend()
				end)
			end
		end

		for _, middleware in ipairs(self._middlewares) do
			stepSystems = middleware(stepSystems, eventName)

			if type(stepSystems) ~= "function" then
				error(
					("Middleware function %s:%s returned %s instead of a function"):format(
						debug.info(middleware, "s"),
						debug.info(middleware, "l"),
						typeof(stepSystems)
					)
				)
			end
		end

		connections[eventName] = event:Connect(stepSystems)
	end

	return connections
end

--[=[
	Adds a user-defined middleware function that is called during each frame.

	This allows you to run code before and after each frame, to perform initialization and cleanup work.

	```lua
	loop:addMiddleware(function(nextFn)
		return function()
			Plasma.start(plasmaNode, nextFn)
		end
	end)
	```

	You must pass `addMiddleware` a function that itself returns a function that invokes `nextFn` at some point.

	The outer function is invoked only once. The inner function is invoked during each frame event.

	:::info
	Middleware added later "wraps" middleware that was added earlier. The innermost middleware function is the internal
	function that actually calls your systems.
	:::
	@param middleware (nextFn: () -> (), eventName: string) -> () -> ()
]=]
function Loop:addMiddleware(middleware: (nextFn: () -> ()) -> () -> ())
	table.insert(self._middlewares, middleware)
end

return Loop
