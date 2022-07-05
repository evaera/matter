local FormatMode = {
	Short = "Short",
	Long = "Long",
}
local function formatTable(object, mode)
	mode = mode or FormatMode.Short

	local max = if mode == FormatMode.Short then 7 else 1000

	local str = ""

	if mode == FormatMode.Short then
		str ..= "{"
	end

	local count = 0
	for key, value in object do
		if mode == FormatMode.Long and count > 0 then
			str ..= "\n"
		elseif count > 0 then
			str ..= ", "
		end

		count += 1
		if type(key) == "string" then
			str ..= key .. (if mode == FormatMode.Short then "=" else " = ")
		elseif type(key) == "table" then
			if mode == FormatMode.Short then
				str ..= "[{..}]="
			else
				str ..= "[" .. formatTable(key, FormatMode.Short) .. "] = "
			end
		end

		if type(value) == "string" then
			str ..= '"' .. value:sub(1, max) .. '"'
		elseif type(value) == "table" then
			if mode == FormatMode.Short then
				str ..= "{..}"
			else
				str ..= formatTable(value, FormatMode.Short)
			end
		elseif mode == FormatMode.Long and (type(value) == "userdata" or type(value) == "vector") then
			str ..= typeof(value) .. "(" .. tostring(value) .. ")"
		else
			str ..= tostring(value):sub(1, max)
		end

		if mode == FormatMode.Short and count > 4 then
			str ..= ", .."
			break
		end
	end

	if mode == FormatMode.Short then
		str ..= "}"
	end

	return str
end

return {
	formatTable = formatTable,
	FormatMode = FormatMode,
}
