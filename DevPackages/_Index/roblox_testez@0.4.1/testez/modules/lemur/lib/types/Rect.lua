local assign = import("../assign")
local typeKey = import("../typeKey")
local typeof = import("../functions/typeof")
local Vector2 = import("./Vector2")

local Rect = {}

setmetatable(Rect, {
	__tostring = function()
		return "Rect"
	end,
})

local prototype = {}

local metatable = {}
metatable[typeKey] = "Rect"

function metatable:__index(key)
	local internal = getmetatable(self).internal

	if internal[key] ~= nil then
		return internal[key]
	end

	if prototype[key] ~= nil then
		return prototype[key]
	end

	error(string.format("%s is not a valid member of Rect", tostring(key)), 2)
end

function metatable:__eq(other)
	return self.Min == other.Min and self.Max == other.Max
end

function Rect.new(...)
	if select("#", ...) == 4 then
		local minX, minY, maxX, maxY = ...
		if type(minX) ~= "number" or type(minY) ~= "number" or
			type(maxX) ~= "number" or type(maxY) ~= "number" then
			error("Rect.new(minX, minY, maxX, maxY) takes in 4 numbers", 2)
		end

		return Rect.new(
			Vector2.new(minX, minY),
			Vector2.new(maxX, maxY)
		)
	end

	local min, max = ...

	if typeof(min) ~= "Vector2" or typeof(max) ~= "Vector2" then
		error("Rect.new(min, max) takes in 2 Vector2s", 2)
	end

	local internalInstance = {
		Min = min,
		Max = max,
		Width = max.X - min.X,
		Height = max.Y - min.Y,
	}
	local instance = newproxy(true)

	assign(getmetatable(instance), metatable)
	getmetatable(instance).internal = internalInstance

	return instance
end

return Rect
