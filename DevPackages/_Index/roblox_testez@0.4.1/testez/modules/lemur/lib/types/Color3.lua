local assign = import("../assign")
local typeKey = import("../typeKey")

local function lerpNumber(a, b, alpha)
	return (1 - alpha) * a + b * alpha
end

local Color3 = {}

setmetatable(Color3, {
	__tostring = function()
		return "Color3"
	end,
})

local prototype = {}

function prototype:lerp(goal, alpha)
	return Color3.new(
		lerpNumber(self.r, goal.r, alpha),
		lerpNumber(self.g, goal.g, alpha),
		lerpNumber(self.b, goal.b, alpha)
	)
end

local metatable = {}
metatable[typeKey] = "Color3"

function metatable:__index(key)
	local internal = getmetatable(self).internal

	if internal[key] ~= nil then
		return internal[key]
	end

	if prototype[key] ~= nil then
		return prototype[key]
	end

	error(string.format("%s is not a valid member of Color3", tostring(key)), 2)
end

function metatable:__eq(other)
	return self.r == other.r and self.g == other.g and self.b == other.b
end

function Color3.new(...)
	if select("#", ...) == 0 then
		return Color3.new(0, 0, 0)
	end

	local r, g, b = ...

	local internalInstance = {
		r = r,
		g = g,
		b = b,
	}

	local instance = newproxy(true)

	assign(getmetatable(instance), metatable)
	getmetatable(instance).internal = internalInstance

	return instance
end

function Color3.fromRGB(r, g, b)
	return Color3.new(r / 255, g / 255, b / 255)
end

function Color3.fromHSV(h, s, v)
	-- Convert h to a 360-degree value (inputs as between 0 and 1)
	h = h * 360

	-- Sector of the HSV color space (there are 6) that the hue falls in
	local sector = h / 60
	local chroma = s * v
	local x = chroma * (1 - math.abs(sector % 2 - 1))
	local m = v - chroma

	local r, g, b

	if sector >= 0 and sector <= 1 then
		r, g, b = chroma, x, 0
	elseif sector >= 1 and sector <= 2 then
		r, g, b = x, chroma, 0
	elseif sector >= 2 and sector <= 3 then
		r, g, b = 0, chroma, x
	elseif sector >= 3 and sector <= 4 then
		r, g, b = 0, x, chroma
	elseif sector >= 4 and sector <= 5 then
		r, g, b = x, 0, chroma
	elseif sector >= 5 and sector < 6 then
		r, g, b = chroma, 0, x
	else
		-- Return a default value of 0, 0, 0. This will happen if h is not between 0 and 1.
		return Color3.new(0, 0, 0)
	end

	return Color3.new(r + m, g + m, b + m)
end

function Color3.toHSV(color)
	local minComponent = math.min(color.r, color.g, color.b)
	local maxComponent = math.max(color.r, color.g, color.b)

	-- Grayscale color.
	-- Hue and saturation are 0; value is equal to the RGB value.
	if minComponent == maxComponent then
		return 0, 0, minComponent
	end

	local delta = maxComponent - minComponent
	local hue
	local saturation = delta / maxComponent
	local value = maxComponent

	if color.r == maxComponent then
		hue = (color.g - color.b) / delta
	elseif color.g == maxComponent then
		hue = 2 + (color.b - color.r) / delta
	else
		hue = 4 + (color.r - color.g) / delta
	end

	return (hue * 60) / 360, saturation, value
end

return Color3
