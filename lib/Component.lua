local Llama = require(script.Parent.Parent.Llama)

local function newComponent(name)
	name = name or debug.info(2, "s") .. "@" .. debug.info(2, "l")

	local component = {}
	component.__index = component

	function component.new(data)
		return table.freeze(setmetatable(data or {}, component))
	end

	function component:patch(data)
		return getmetatable(self).new(Llama.Dictionary.merge(self, data))
	end

	setmetatable(component, {
		__call = function(_, ...)
			return component.new(...)
		end,
		__tostring = function()
			return name
		end,
	})

	return component
end

return {
	newComponent = newComponent,
}
