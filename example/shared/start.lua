local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Matter = require(ReplicatedStorage.Lib.Matter)
local Plasma = require(Packages.plasma)
local HotReloader = require(script.Parent.HotReloader)

local function start(container)
	local world = Matter.World.new()
	local state = {}

	local loop = Matter.Loop.new(world, state)

	local hotReloader = HotReloader.new()

	local firstRunSystems = {}
	local systemsByModule = {}

	local function addSystemModule(child)
		hotReloader:listen(child, function(module)
			local ok, system = pcall(require, module)

			if not ok then
				warn("Error when hot-reloading system", module.name, system)
				return
			end

			if firstRunSystems then
				table.insert(firstRunSystems, system)
			elseif systemsByModule[child] then
				loop:replaceSystem(systemsByModule[child], system)
			else
				loop:scheduleSystem(system)
			end

			systemsByModule[child] = system
		end, function() end)
	end

	local function removeSystemModule(child)
		if systemsByModule[child] then
			loop:evictSystem(systemsByModule[child])
			systemsByModule[child] = nil
		end
	end

	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("ModuleScript") then
			addSystemModule(child)
		end
	end

	container.ChildAdded:Connect(function(child)
		if CollectionService:HasTag(child, "RewireClonedModule") then
			return
		end

		if child:IsA("ModuleScript") then
			addSystemModule(child)
		end
	end)

	container.ChildRemoved:Connect(function(child)
		if CollectionService:HasTag(child, "RewireClonedModule") then
			return
		end

		if child:IsA("ModuleScript") then
			removeSystemModule(child)
		end
	end)

	loop:scheduleSystems(firstRunSystems)
	firstRunSystems = nil

	local plasmaNode = Plasma.new(workspace)

	loop:addMiddleware(function(nextFn)
		return function()
			Plasma.start(plasmaNode, nextFn)
		end
	end)

	loop:begin({
		default = RunService.Heartbeat,
		RenderStepped = if RunService:IsClient() then RunService.RenderStepped else nil,
	})

	return world, state
end

return start
