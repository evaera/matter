local BaseInstance = import("./BaseInstance")
local InstanceProperty = import("../InstanceProperty")
local json = import("../json")

local LocalizationTable = BaseInstance:extend("LocalizationTable", {
	creatable = true,
})

LocalizationTable.properties.SourceLocaleId = InstanceProperty.normal({
	getDefault = function()
		return "en-us"
	end,
})

function LocalizationTable:init(instance)
	getmetatable(instance).instance.contents = {}
end

function LocalizationTable.prototype:SetContents(contents)
	getmetatable(self).instance.contents = json.decode(contents)
end

function LocalizationTable.prototype:GetString(targetLocaleId, key)
	local contents = getmetatable(self).instance.contents

	for _, entry in ipairs(contents) do
		if entry.key == key then
			return entry.values[targetLocaleId]
		end
	end

	return nil
end

return LocalizationTable