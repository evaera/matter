local rbxString = {}

for key, value in pairs(string) do
	rbxString[key] = value
end

rbxString.split = function(str, sep)
	local result = {}

	if sep == "" then
		for i = 1, #str do
			result[i] = str:sub(i, i)
		end
	else
		if sep == nil then
			sep = ","
		end

		local count = 1
		local pos = 1
		local a, b = str:find(sep, pos, true)

		while a do
			result[count] = str:sub(pos, a - 1)
			count = count + 1
			pos = b + 1
			a, b = str:find(sep, pos, true)
		end

		result[count] = str:sub(pos)
	end

	return result
end

return rbxString
