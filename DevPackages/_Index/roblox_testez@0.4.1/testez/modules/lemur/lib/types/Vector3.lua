local assign = import("../assign")
local typeKey = import("../typeKey")
local typeof = import("../functions/typeof")

local Vector3 = {}

setmetatable(Vector3, {
	__tostring = function()
		return "Vector3"
	end,
})

local prototype = {}

local metatable = {}
metatable[typeKey] = "Vector3"

function metatable:__index(key)
	local internal = getmetatable(self).internal

	if internal[key] ~= nil then
		return internal[key]
	end

	if prototype[key] ~= nil then
		return prototype[key]
	end

	error(string.format("%s is not a valid member of Vector3", tostring(key)), 2)
end

function metatable:__add(other)
	return Vector3.new(self.X + other.X, self.Y + other.Y, self.Z + other.Z)
end

function metatable:__sub(other)
	return Vector3.new(self.X - other.X, self.Y - other.Y, self.Z - other.Z)
end

function metatable:__mul(other)
	if typeof(self) == "Vector3" and typeof(other) == "Vector3" then
		return Vector3.new(self.X * other.X, self.Y * other.Y, self.Z * other.Z)
	elseif typeof(self) == "Vector3" and typeof(other) == "number" then
		return Vector3.new(self.X * other, self.Y * other, self.Z * other)
	elseif typeof(self) == "number" and typeof(other) == "Vector3" then
		return Vector3.new(other.X * self, other.Y * self, other.Z * self)
	else
		error("attempt to multiply a Vector3 with an incompatible value type or nil")
	end
end

function metatable:__div(other)
	if typeof(self) == "Vector3" and typeof(other) == "Vector3" then
		return Vector3.new(self.X / other.X, self.Y / other.Y, self.Z / other.Z)
	elseif typeof(self) == "Vector3" and typeof(other) == "number" then
		return Vector3.new(self.X / other, self.Y / other, self.Z / other)
	elseif typeof(self) == "number" and typeof(other) == "Vector3" then
		return Vector3.new(other.X / self, other.Y / self, other.Z / self)
	else
		error("attempt to divide a Vector3 with an incompatible value type or nil")
	end
end

function metatable:__eq(other)
	return self.X == other.X and self.Y == other.Y and self.Z == other.Z
end

function Vector3.new(...)
	if select("#", ...) == 0 then
		return Vector3.new(0, 0, 0)
	end

	local X, Y, Z = ...
	if type(X) ~= "number" or type(Y) ~= "number" or type(Z) ~= "number" then
		error("Vector3.new takes in 3 numbers", 2)
	end

	local internalInstance = {
		X = X,
		Y = Y,
		Z = Z,
	}

	local instance = newproxy(true)

	assign(getmetatable(instance), metatable)
	getmetatable(instance).internal = internalInstance

	return instance
end

return Vector3
