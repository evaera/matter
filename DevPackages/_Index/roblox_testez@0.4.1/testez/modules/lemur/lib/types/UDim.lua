local assign = import("../assign")
local typeKey = import("../typeKey")

local UDim = {}

setmetatable(UDim, {
	__tostring = function()
		return "UDim"
	end,
})

local prototype = {}

local metatable = {}
metatable[typeKey] = "UDim"

function metatable:__index(key)
	local internal = getmetatable(self).internal

	if internal[key] ~= nil then
		return internal[key]
	end

	if prototype[key] ~= nil then
		return prototype[key]
	end

	error(string.format("%s is not a valid member of UDim", tostring(key)), 2)
end

function metatable:__add(other)
	return UDim.new(self.Scale + other.Scale, self.Offset + other.Offset)
end

function metatable:__eq(other)
	return self.Scale == other.Scale and self.Offset == other.Offset
end

function UDim.new(...)
	if select("#", ...) == 0 then
		return UDim.new(0, 0)
	end

	local Scale, Offset = ...
	if type(Scale) ~= "number" or type(Offset) ~= "number" then
		error("UDim.new must take in 2 numbers", 2)
	end

	local internalInstance = {
		Scale = Scale,
		Offset = Offset,
	}

	local instance = newproxy(true)

	assign(getmetatable(instance), metatable)
	getmetatable(instance).internal = internalInstance

	return instance
end

return UDim
