local assign = import("../assign")
local typeKey = import("../typeKey")
local typeof = import("../functions/typeof")

local Vector2 = {}

setmetatable(Vector2, {
	__tostring = function()
		return "Vector2"
	end,
})

local prototype = {}

local metatable = {}
metatable[typeKey] = "Vector2"

function metatable:__index(key)
	local internal = getmetatable(self).internal

	if internal[key] ~= nil then
		return internal[key]
	end

	if prototype[key] ~= nil then
		return prototype[key]
	end

	error(string.format("%s is not a valid member of Vector2", tostring(key)), 2)
end

function metatable:__add(other)
	return Vector2.new(self.X + other.X, self.Y + other.Y)
end

function metatable:__sub(other)
	return Vector2.new(self.X - other.X, self.Y - other.Y)
end

function metatable:__mul(other)
	if typeof(self) == "Vector2" and typeof(other) == "Vector2" then
		return Vector2.new(self.X * other.X, self.Y * other.Y)
	elseif typeof(self) == "Vector2" and typeof(other) == "number" then
		return Vector2.new(self.X * other, self.Y * other)
	elseif typeof(self) == "number" and typeof(other) == "Vector2" then
		return Vector2.new(other.X * self, other.Y * self)
	else
		error("attempt to multiply a Vector2 with an incompatible value type or nil")
	end
end

function metatable:__div(other)
	if typeof(self) == "Vector2" and typeof(other) == "Vector2" then
		return Vector2.new(self.X / other.X, self.Y / other.Y)
	elseif typeof(self) == "Vector2" and typeof(other) == "number" then
		return Vector2.new(self.X / other, self.Y / other)
	elseif typeof(self) == "number" and typeof(other) == "Vector2" then
		return Vector2.new(other.X / self, other.Y / self)
	else
		error("attempt to divide a Vector2 with an incompatible value type or nil")
	end
end

function metatable:__eq(other)
	return self.X == other.X and self.Y == other.Y
end

function Vector2.new(...)
	if select("#", ...) == 0 then
		return Vector2.new(0, 0)
	end

	local X, Y = ...
	if type(X) ~= "number" or type(Y) ~= "number" then
		error("Vector2.new takes in 2 numbers", 2)
	end

	local internalInstance = {
		X = X,
		Y = Y,
	}

	local instance = newproxy(true)

	assign(getmetatable(instance), metatable)
	getmetatable(instance).internal = internalInstance

	return instance
end

return Vector2
