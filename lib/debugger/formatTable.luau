local FormatMode = {
	Short = "Short",
	Long = "Long",
}
local function formatTable(object, mode, _padLength, _depth)
	mode = mode or FormatMode.Short
	_padLength = _padLength or 0
	_depth = _depth or 1

	local max = if mode == FormatMode.Short then 7 else 1000

	local str = ""

	if mode == FormatMode.Short or _depth > 1 then
		str ..= "{"
	end

	local values = {}

	for key, value in pairs(object) do
		table.insert(values, {
			key = key,
			value = value,
		})
	end

	table.sort(values, function(a, b)
		return tostring(a.key) < tostring(b.key)
	end)

	local count = 0
	for _, entry in values do
		local key = entry.key
		local value = entry.value

		local part = ""

		if count > 0 then
			part ..= ", "
		end

		if mode == FormatMode.Long then
			part ..= "\n" .. string.rep("  ", _depth - 1)
		end

		count += 1
		if type(key) == "string" then
			part ..= key .. (if mode == FormatMode.Short then "=" else " = ")
		elseif type(key) == "table" then
			if mode == FormatMode.Short then
				part ..= "[{..}]="
			else
				part ..= "["
				part ..= formatTable(key, FormatMode.Short, #str + #part + _padLength, _depth + 1)
				part ..= "] = "
			end
		end

		if type(value) == "string" then
			part ..= '"' .. value:sub(1, max) .. '"'
		elseif type(value) == "table" then
			if mode == FormatMode.Short then
				part ..= "{..}"
			else
				part ..= formatTable(value, FormatMode.Long, #str + #part + _padLength, _depth + 1)
			end
		elseif mode == FormatMode.Long and (type(value) == "userdata" or type(value) == "vector") then
			if typeof(value) == "CFrame" then
				local x, y, z = value:components()
				part ..= string.format("CFrame(%.1f, %.1f, %.1f, ..)", x, y, z)
			else
				part ..= typeof(value) .. "(" .. tostring(value) .. ")"
			end
		else
			part ..= tostring(value):sub(1, max)
		end

		if mode == FormatMode.Short and #str + #part + _padLength > 30 then
			if count > 1 then
				str ..= ", "
			end

			str ..= ".."

			break
		else
			str ..= part
		end

		if mode == FormatMode.Short and #part + _padLength > 30 then
			part ..= ", .."
			break
		end
	end

	if mode == FormatMode.Long then
		str ..= "\n" .. string.rep("  ", _depth - 2)
	end

	if mode == FormatMode.Short or _depth > 1 then
		str ..= "}"
	end

	return str
end

return {
	formatTable = formatTable,
	FormatMode = FormatMode,
}
