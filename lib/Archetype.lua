local toSet = require(script.Parent.immutable).toSet

local valueIds = {}
local nextValueId = 0
local compatibilityCache = {}
local archetypeCache = {}

local function getValueId(value)
	local valueId = valueIds[value]
	if valueId == nil then
		valueIds[value] = nextValueId
		valueId = nextValueId
		nextValueId += 1
	end

	return valueId
end

function archetypeOf(...)
	debug.profilebegin("archetypeOf")

	local length = select("#", ...)

	local currentNode = archetypeCache

	for i = 1, length do
		local nextNode = currentNode[select(i, ...)]

		if not nextNode then
			nextNode = {}
			currentNode[select(i, ...)] = nextNode
		end

		currentNode = nextNode
	end

	if currentNode._archetype then
		debug.profileend()
		return currentNode._archetype
	end

	local list = table.create(length)

	for i = 1, length do
		list[i] = getValueId(select(i, ...))
	end

	table.sort(list)

	local archetype = table.concat(list, "_")

	currentNode._archetype = archetype

	debug.profileend()

	return archetype
end

function areArchetypesCompatible(queryArchetype, targetArchetype)
	local cachedCompatibility = compatibilityCache[queryArchetype .. "-" .. targetArchetype]
	if cachedCompatibility ~= nil then
		return cachedCompatibility
	end
	debug.profilebegin("areArchetypesCompatible")

	local queryIds = string.split(queryArchetype, "_")
	local targetIds = toSet(string.split(targetArchetype, "_"))

	for _, queryId in ipairs(queryIds) do
		if targetIds[queryId] == nil then
			compatibilityCache[queryArchetype .. "-" .. targetArchetype] = false
			debug.profileend()
			return false
		end
	end

	compatibilityCache[queryArchetype .. "-" .. targetArchetype] = true

	debug.profileend()
	return true
end

return {
	archetypeOf = archetypeOf,
	areArchetypesCompatible = areArchetypesCompatible,
}
