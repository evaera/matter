local None = {}

local function merge(one, two)
	local new = table.clone(one)

	for key, value in two do
		if value == None then
			new[key] = nil
		else
			new[key] = value
		end
	end

	return new
end

-- https://github.com/freddylist/llama/blob/master/src/List/toSet.lua
local function toSet(list)
	local set = {}

	for _, v in ipairs(list) do
		set[v] = true
	end

	return set
end

-- https://github.com/freddylist/llama/blob/master/src/Dictionary/values.lua
local function values(dictionary)
	local valuesList = {}

	local index = 1

	for _, value in pairs(dictionary) do
		valuesList[index] = value
		index = index + 1
	end

	return valuesList
end

return {
	None = None,
	merge = merge,
	toSet = toSet,
	values = values,
}
