local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Matter = require(ReplicatedStorage.Lib.Matter)
local Plasma = require(Packages.plasma)
local HotReloader = require(script.Parent.HotReloader)

local function start(container)
	local world = Matter.World.new()
	local state = {}

	local debugger = Matter.debugger.new(Plasma)

	local loop = Matter.Loop.new(world, state, debugger:getWidgets())

	-- Set up hot reloading

	local hotReloader = HotReloader.new()

	local firstRunSystems = {}
	local systemsByModule = {}

	hotReloader:scan(container, function(module, context)
		local originalModule = context.originalModule

		local ok, system = pcall(require, module)

		if not ok then
			warn("Error when hot-reloading system", module.name, system)
			return
		end

		if firstRunSystems then
			table.insert(firstRunSystems, system)
		elseif systemsByModule[originalModule] then
			loop:replaceSystem(systemsByModule[originalModule], system)
			debugger:replaceSystem(systemsByModule[originalModule], system)
		else
			loop:scheduleSystem(system)
		end

		systemsByModule[originalModule] = system
	end, function(_, context)
		if context.isReloading then
			return
		end

		local originalModule = context.originalModule
		if systemsByModule[originalModule] then
			loop:evictSystem(systemsByModule[originalModule])
			systemsByModule[originalModule] = nil
		end
	end)

	loop:scheduleSystems(firstRunSystems)
	firstRunSystems = nil

	debugger:autoInitialize(loop)

	-- Begin running our systems

	loop:begin({
		default = RunService.Heartbeat,
	})

	return world, state
end

return start
