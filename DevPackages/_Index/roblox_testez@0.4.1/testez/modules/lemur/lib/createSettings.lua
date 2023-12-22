--[[
	This file creates the settings() method.
	Since settings implements the GetFFlag method, we need to pass fast flags
	from a Habitat instance.
]]
local assign = import("./assign")
local RenderSettings = import("./functions/settings/RenderSettings")

local Settings = {}

setmetatable(Settings, {
	__tostring = function()
		return "Settings"
	end,
})

local prototype = {}

--[[
	GetFFlag will throw on missing fast flags if ignoreMissingFFlags setting is false/nil
]]
function prototype:GetFFlag(name)
	if self.settings.flags[name] == nil then
		error(string.format("Fast flag %s does not exist", name), 2)
	end

	return self.settings.flags[name]
end

local metatable = {}
metatable.type = Settings

function metatable:__index(key)
	local internal = getmetatable(self).internal

	if internal[key] ~= nil then
		return internal[key]
	end

	if prototype[key] ~= nil then
		return prototype[key]
	end

	error(string.format("%s is not a valid member of Settings", tostring(key)), 2)
end

function Settings.new(settings)
	local internalInstance = {
		settings = settings or {},
		Rendering = RenderSettings.new()
	}

	internalInstance.settings.flags = internalInstance.settings.flags or {}

	local instance = newproxy(true)

	assign(getmetatable(instance), metatable)
	getmetatable(instance).internal = internalInstance

	return instance
end

return function(settings)
	local instance = Settings.new(settings)
	return function()
		return instance
	end
end
