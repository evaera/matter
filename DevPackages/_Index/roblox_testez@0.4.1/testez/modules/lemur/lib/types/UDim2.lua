local assign = import("../assign")
local typeKey = import("../typeKey")
local typeof = import("../functions/typeof")
local UDim = import("./UDim")

local function lerpNumber(a, b, alpha)
	return (1 - alpha) * a + b * alpha
end

local UDim2 = {}

setmetatable(UDim2, {
	__tostring = function()
		return "UDim2"
	end,
})

local prototype = {}

function prototype:Lerp(goal, alpha)
	return UDim2.new(
		lerpNumber(self.X.Scale, goal.X.Scale, alpha),
		lerpNumber(self.X.Offset, goal.X.Offset, alpha),
		lerpNumber(self.Y.Scale, goal.Y.Scale, alpha),
		lerpNumber(self.Y.Offset, goal.Y.Offset, alpha)
	)
end

local metatable = {}
metatable[typeKey] = "UDim2"

function metatable:__index(key)
	local internal = getmetatable(self).internal

	if internal[key] ~= nil then
		return internal[key]
	end

	if prototype[key] ~= nil then
		return prototype[key]
	end

	error(string.format("%s is not a valid member of UDim2", tostring(key)), 2)
end

function metatable:__eq(other)
	return self.X == other.X and self.Y == other.Y
end

function metatable:__add(other)
	return UDim2.new(self.X + other.X, self.Y + other.Y)
end

function UDim2.new(...)
	if select("#", ...) == 0 then
		return UDim2.new(
			UDim.new(0, 0),
			UDim.new(0, 0)
		)
	end

	if select("#", ...) == 4 then
		local xScale, xOffset, yScale, yOffset = ...
		if type(xScale) ~= "number" or type(xOffset) ~= "number" or
			type(yScale) ~= "number" or type(yOffset) ~= "number" then
			error("UDim2.new(xScale, xOffset, yScale, yOffset) takes in 4 numbers", 2)
		end

		return UDim2.new(
			UDim.new(xScale, xOffset),
			UDim.new(yScale, yOffset)
		)
	end

	local xDim, yDim = ...

	if typeof(xDim) ~= "UDim" or typeof(yDim) ~= "UDim" then
		error("UDim2.new(xDim, yDim) takes in 2 UDims", 2)
	end

	local internalInstance = {
		X = xDim,
		Y = yDim,
		Width = xDim,
		Height = yDim,
	}
	local instance = newproxy(true)

	assign(getmetatable(instance), metatable)
	getmetatable(instance).internal = internalInstance

	return instance
end

return UDim2
