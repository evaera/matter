local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.ExamplePackages
local Matter = require(ReplicatedStorage.Packages.Matter)
local Plasma = require(Packages.plasma)
local Components = require(ReplicatedStorage.Game.components)

local world = Matter.World.new()
local state = {}
local loop = Matter.Loop.new(world, state)

local systems = {}
for _, child in ipairs(script.systems:GetChildren()) do
	if child:IsA("ModuleScript") then
		table.insert(systems, require(child))
	end
end

loop:scheduleSystems(systems)

local plasmaNode = Plasma.new(workspace)

loop:addMiddleware(function(nextFn)
	return function()
		Plasma.start(plasmaNode, nextFn)
	end
end)

loop:begin({
	default = RunService.Heartbeat,
	RenderStepped = RunService.RenderStepped,
})

local boundTags = {
	Spinner = Components.Spinner,
}

local function spawnBound(instance, component)
	local id = world:spawn(
		component(),
		Components.Bind({
			instance = instance,
		}),
		Components.Transform({
			cframe = instance.CFrame,
		})
	)

	instance:SetAttribute("entityId", id)
end

for tagName, component in pairs(boundTags) do
	for _, instance in ipairs(CollectionService:GetTagged(tagName)) do
		spawnBound(instance, component)
	end

	CollectionService:GetInstanceAddedSignal(tagName):Connect(function(instance)
		spawnBound(instance, component)
	end)

	CollectionService:GetInstanceRemovedSignal(tagName):Connect(function(instance)
		local id = instance:GetAttribute("entityId")
		if id then
			world:despawn(id)
		end
	end)
end
