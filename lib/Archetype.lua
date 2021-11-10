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

-- Potential optimization: Take ownership of values table, avoid intermediate table by sorting in-place and
-- having custom concat function
function archetypeOf(values)
	debug.profilebegin("archetypeOf")
	local list = Llama.List.map(values, getValueId)
	table.sort(list)

	local archetype = table.concat(list, "_")

	debug.profileend()
	return archetype
end

function archetypeOfDict(dict)
	return archetypeOf(Llama.Dictionary.keys(dict))
end

function areArchetypesCompatible(queryArchetype, targetArchetype)
	local cachedCompatibility = compatibilityCache[queryArchetype .. "-" .. targetArchetype]
	if cachedCompatibility ~= nil then
		return cachedCompatibility
	end
	debug.profilebegin("areArchetypesCompatible")

	local queryIds = string.split(queryArchetype, "_")
	local targetIds = Llama.List.toSet(string.split(targetArchetype, "_"))

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
	archetypeOfDict = archetypeOfDict,
	areArchetypesCompatible = areArchetypesCompatible,
}

--[[
	local listOfMaps = {}

	for targetArchetype, map in pairs(self._archetypes) do
		if areArchetypesCompatible(query, targetArchetype) then
			table.insert(listOfMaps, map)
		end
	end
]]
