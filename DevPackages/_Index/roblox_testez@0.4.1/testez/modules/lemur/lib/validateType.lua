local typeof = import("./functions/typeof")

return function(name, value, expectedTypeAsString)
	local actualType = typeof(value)
	if actualType ~= expectedTypeAsString then
		error(string.format("%s must be type `%s`, got type `%s`", name, expectedTypeAsString, actualType), 3)
	end
end
