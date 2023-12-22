local typeKey = import("./typeKey")

local function createEnumVariant(enum, variantName, variantValue)
	local enumVariant = newproxy(true)

	local internal = {
		Value = variantValue,
		Name = variantName,
		EnumType = enum,
	}

	getmetatable(enumVariant)[typeKey] = "EnumItem"

	getmetatable(enumVariant).__tostring = function()
		return ("Enum.%s.%s"):format(tostring(enum), variantName)
	end

	getmetatable(enumVariant).__index = function(self, key)
		local value = internal[key]

		if value == nil then
			error(("%s is not a valid member"):format(tostring(key)), 2)
		end

		return value
	end

	return enumVariant
end

local function createEnum(enumName, variantValues)
	local enum = newproxy(true)

	local variants = {}

	for variantName, value in pairs(variantValues) do
		variants[variantName] = createEnumVariant(enum, variantName, value)
	end

	getmetatable(enum)[typeKey] = "Enum"

	getmetatable(enum).__tostring = function()
		return enumName
	end

	getmetatable(enum).__index = function(self, key)
		local variant = variants[key]

		if variant == nil then
			error(("%s is not a valid EnumItem"):format(tostring(key)), 2)
		end

		return variant
	end

	return enum
end

return createEnum