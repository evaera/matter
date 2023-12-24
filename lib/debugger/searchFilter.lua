local function tokenize(query: string)
	return string.split(query, ",")
end

local function removeWhitespaces(input: string)
	return string.gsub(input, " ", "")
end

local function searchFilter(world, query: string)
	local tokens = tokenize(removeWhitespaces(query))

	local queryLength = 0

	for _, token in tokens do
		if string.find(token, "!") then
			continue
		end
		queryLength += 1
	end

	if queryLength == 0 then
		error("No valid component")
	end

	local entities = {}
	for entity, entityData in world._entityMetatablesCache do
		local skip = false
		for _, metatable in entityData do
			for _, token in tokens do
				local without = false
				if string.find(token, "!") and without == false then
					without = true
					token = string.sub(token, 2, string.len(token))
				end
				if tostring(metatable) == token then
					if without then
						skip = true
						continue
					end

					if skip then
						continue
					end

					table.insert(entities, {
						id = entity,
						component = token,
						data = world:get(entity, metatable),
					})
				end
			end
		end
	end

	return entities
end

return searchFilter
