local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Matter = require(ReplicatedStorage.Lib.Matter)
local Plasma = require(Packages.plasma)
local HotReloader = require(script.Parent.HotReloader)
local hookWidgets = require(script.Parent.hookWidgets)
local debugUI = require(script.Parent.debugUI)

local function start(container)
	local world = Matter.World.new()
	local state = {}

	local debugState = {}
	local debugWidgets = hookWidgets(debugState)

	local loop = Matter.Loop.new(world, state, debugWidgets)

	debugState.loop = loop

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

			if debugState.debugSystem == systemsByModule[originalModule] then
				debugState.debugSystem = system
			end
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

	local parent = workspace

	if RunService:IsClient() then
		parent = Instance.new("ScreenGui")
		parent.Name = "Plasma"
		parent.ResetOnSpawn = false
		parent.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	end

	local plasmaNode = Plasma.new(parent)

	loop:addMiddleware(function(nextFn)
		return function()
			Plasma.start(plasmaNode, function()
				debugUI(debugState)

				nextFn()
			end)
		end
	end)

	loop:begin({
		default = RunService.Heartbeat,
	})

	return world, state
end

return start
