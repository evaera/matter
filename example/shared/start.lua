local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.ExamplePackages
local Matter = require(ReplicatedStorage.Packages.Matter)
local Plasma = require(Packages.plasma)
local HotReloader = require(Packages.rewire).HotReloader

local function start(container)
	local hotReloader = HotReloader.new()
	local world = Matter.World.new()
	local state = {}
	local loop = Matter.Loop.new(world, state)

	local firstRun = true
	local systems = {}
	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("ModuleScript") then
			hotReloader:listen(child, function(module)
				if firstRun then
					table.insert(systems, require(module))
				else
					loop:scheduleSystem(require(module))
				end
			end, function(module)
				loop:evictSystem(require(module))
			end)
		end
	end

	loop:scheduleSystems(systems)
	firstRun = false

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
