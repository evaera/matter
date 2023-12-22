--[[
	This key is used to mark Roblox objects and make typeof return the correct
	value.

	Use it as a key into a userdata object's metatable; its value will be what
	is returned by typeof.
]]

local typeKey = newproxy(true)

getmetatable(typeKey).__tostring = function()
	return "<Lemur Type Identifier>"
end

return typeKey