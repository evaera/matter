local function tokenize(query: string)
	return string.split(query, ",")
end

local function removeWhitespaces(input: string)
	return string.gsub(input, " ", "")
end

local function searchFilter(world, query: string)
	local tokens = tokenize(removeWhitespaces(query))

	local queryLength = #tokens
	local entities = {}
	for entity, entityData in world do
		entities[entity] = {}
		for _, token in tokens do
			for metatable, data in entityData do
				local without = false
				if string.find(token, "?") then
					without = true
					queryLength -= 1
					token = string.sub(token, 2, string.len(token))
				end

				if tostring(metatable) == token then
					if without then
						continue
					end

					entities[entity][token] = data
				end
			end
		end

		local i = 0
		for _ in entities[entity] do
			i += 1
		end
		if i < queryLength then
			entities[entity] = nil
		end
	end

	return entities
end

return searchFilter
