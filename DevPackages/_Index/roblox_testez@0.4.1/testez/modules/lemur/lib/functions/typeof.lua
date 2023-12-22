local typeKey = import("../typeKey")

local function typeof(object)
	local realType = type(object)

	if realType == "userdata" then
		local metatable = getmetatable(object)

		if metatable == nil then
			return "userdata"
		end

		if metatable[typeKey] ~= nil then
			return metatable[typeKey]
		end
	end

	return realType
end

return typeof