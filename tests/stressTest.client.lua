local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Matter)
local Llama = require(ReplicatedStorage.Llama)

-- 500 entities
-- 2-30 components on each entity
-- 300 unique components
-- 200 systems
-- 1-10 components to query per system

local startTime = os.clock()

local world = Matter.World.new()

local components = {}

for i = 1, 300 do -- 300 components
	components[i] = Matter.component("Component " .. i)
end

local archetypes = {}
for i = 1, 50 do -- 50 archetypes
	local archetype = {}

	for _ = 1, math.random(2, 30) do
		local componentId = math.random(1, #components)

		table.insert(archetype, components[componentId])
	end

	archetypes[i] = archetype
end

for _ = 1, 1000 do -- 1000 entities in the world
	local componentsToAdd = {}

	local archetypeId = math.random(1, #archetypes)
	for _, component in ipairs(archetypes[archetypeId]) do
		componentsToAdd[component] = component({
			DummyData = math.random(1, 5000),
		})
	end

	world:spawn(unpack(Llama.Dictionary.values(componentsToAdd)))
end

local contiguousComponents = Llama.Dictionary.values(components)
local systemComponentsToQuery = {}

for _ = 1, 200 do -- 200 systems
	local numComponentsToQuery = math.random(1, 10)
	local componentsToQuery = {}

	for _ = 1, numComponentsToQuery do
		table.insert(componentsToQuery, contiguousComponents[math.random(1, #contiguousComponents)])
	end

	table.insert(systemComponentsToQuery, componentsToQuery)
end

local worldCreateTime = os.clock() - startTime
local results = {}
startTime = os.clock()

RunService.Heartbeat:Connect(function()
	if os.clock() - startTime < 2 then
		-- discard first 2 seconds
		return
	end
	local systemStartTime = os.clock()
	for _, componentsToQuery in ipairs(systemComponentsToQuery) do
		for entityId, entityData in world:query(unpack(componentsToQuery)) do
		end
	end

	if results == nil then
		return
	elseif #results < 100 then
		table.insert(results, os.clock() - systemStartTime)
	else
		print("World created in", worldCreateTime * 1000, "ms")
		local sum = 0
		for _, result in ipairs(results) do
			sum += result
		end
		print(("Average frame time: %fms"):format((sum / #results) * 1000))
		results = nil

		local n = 0

		for _ in pairs(world._archetypes) do
			n += 1
		end

		print(
			("%d entities\n%d components\n%d systems\n%d archetypes"):format(
				world:size(),
				#components,
				#systemComponentsToQuery,
				n
			)
		)
	end
end)
