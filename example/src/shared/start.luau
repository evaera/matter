local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Matter = require(ReplicatedStorage.Lib.Matter)
local Plasma = require(Packages.plasma)
local HotReloader = require(Packages.rewire).HotReloader
local components = require(script.Parent.components)

local function start(containers)
	local world = Matter.World.new()
	local state = {}

	local debugger = Matter.Debugger.new(Plasma)

	debugger.findInstanceFromEntity = function(id)
		if not world:contains(id) then
			return
		end

		local model = world:get(id, components.Model)

		return model and model.model or nil
	end

	local loop = Matter.Loop.new(world, state, debugger:getWidgets())

	-- Set up hot reloading

	local hotReloader = HotReloader.new()

	local firstRunSystems = {}
	local systemsByModule = {}

	local function loadModule(module, context)
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
	end

	local function unloadModule(_, context)
		if context.isReloading then
			return
		end

		local originalModule = context.originalModule
		if systemsByModule[originalModule] then
			loop:evictSystem(systemsByModule[originalModule])
			systemsByModule[originalModule] = nil
		end
	end

	for _, container in containers do
		hotReloader:scan(container, loadModule, unloadModule)
	end

	loop:scheduleSystems(firstRunSystems)
	firstRunSystems = nil

	debugger:autoInitialize(loop)

	-- Begin running our systems

	loop:begin({
		default = RunService.Heartbeat,
		Stepped = RunService.Stepped,
	})

	if RunService:IsClient() then
		UserInputService.InputBegan:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.F4 then
				debugger:toggle()

				state.debugEnabled = debugger.enabled
			end
		end)
	end

	return world, state
end

return start
