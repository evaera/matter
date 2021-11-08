local Llama = require(script.Parent.Parent.Llama)

local valueIds = {}
local nextValueId = 0
local compatibilityCache = {}

local function getValueId(value)
	if valueIds[value] == nil then
		valueIds[value] = nextValueId
		nextValueId += 1
	end

	return valueIds[value]
end

function archetypeOf(values)
	local list = Llama.List.map(values, getValueId)
	table.sort(list)

	return table.concat(list, "_")
end

function archetypeOfDict(dict)
	return archetypeOf(Llama.Dictionary.keys(dict))
end

function areArchetypesCompatible(query, target)
	local cachedCompatibility = compatibilityCache[query .. "-" .. target]
	if cachedCompatibility ~= nil then
		return cachedCompatibility
	end

	local queryIds = string.split(query, "_")
	local targetIds = Llama.List.toSet(string.split(target, "_"))

	for _, queryId in ipairs(queryIds) do
		if targetIds[queryId] == nil then
			compatibilityCache[query .. "-" .. target] = false
			return false
		end
	end

	compatibilityCache[query .. "-" .. target] = true
	return true
end

function getCompatibleArchetypes(query, archetypeMap)
	local listOfMaps = {}

	for targetArchetype, map in pairs(archetypeMap) do
		if areArchetypesCompatible(query, targetArchetype) then
			table.insert(listOfMaps, map)
		end
	end

	return listOfMaps
end

return {
	archetypeOf = archetypeOf,
	archetypeOfDict = archetypeOfDict,
	getCompatibleArchetypes = getCompatibleArchetypes,
	areArchetypesCompatible = areArchetypesCompatible,
}
