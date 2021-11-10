local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Matter)
local Llama = require(ReplicatedStorage.Llama)

local startTime = os.clock()

local world = Matter.World.new()

local components = {}

for _ = 1, 500 do -- 500 entities in the world
	local componentsToAdd = {}

	for _ = 1, math.random(2, 30) do
		local componentId = math.random(1, 300)

		if components[componentId] == nil then
			components[componentId] = Matter.component("Component " .. componentId)
		end

		local component = components[componentId]
		componentsToAdd[component] = component({
			DummyData = math.random(1, 5000),
		})
	end

	world:spawn(Llama.Dictionary.values(componentsToAdd))
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

RunService.Heartbeat:Connect(function()
	local systemStartTime = os.clock()
	for _, componentsToQuery in ipairs(systemComponentsToQuery) do
		for entityId, entityData in world:query(unpack(componentsToQuery)):iter() do
		end
	end

	if results == nil then
		return
	elseif #results < 10 then
		table.insert(results, os.clock() - systemStartTime)
	else
		print("World created in", worldCreateTime, "seconds")
		print("First 10 frame times:")
		for i, result in ipairs(results) do
			print(("%d. %f seconds"):format(i, result))
		end
		results = nil
	end
end)
