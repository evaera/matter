local rbxMath = {}

for key, value in pairs(math) do
	rbxMath[key] = value
end

rbxMath.clamp = function(n, min, max)
	return math.min(max, math.max(min, n))
end

return rbxMath