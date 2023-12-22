local assign = import("../../assign")
local typeKey = import("../../typeKey")

local RenderSettings = {}

setmetatable(RenderSettings, {
	__tostring = function()
		return "RenderSettings"
	end,
})

local prototype = {}

local metatable = {}
metatable[typeKey] = "RenderSettings"

function metatable:__index(key)
	local internal = getmetatable(self).internal

	if internal[key] ~= nil then
		return internal[key]
	end

	if prototype[key] ~= nil then
		return prototype[key]
	end

	error(string.format("%s is not a valid member of RenderSettings", tostring(key)), 2)
end

function metatable:__newindex(key, value)
	local internal = getmetatable(self).internal

	if internal[key] ~= nil then
		internal[key] = value
		return
	end

	error(string.format("%q is not a valid member of RenderSettings", tostring(key)), 2)
end


function RenderSettings.new()
	local internalInstance = {
		QualityLevel = 0,
	}

	local instance = newproxy(true)

	assign(getmetatable(instance), metatable)
	getmetatable(instance).internal = internalInstance

	return instance
end

return RenderSettings