local useCurrentSystem = require(script.Parent.Parent.topoRuntime).useCurrentSystem

local widgets = {
	"arrow",
	"blur",
	"button",
	"checkbox",
	"error",
	"portal",
	"row",
	"slider",
	"spinner",
	"window",
	"label",
	"heading",
	"space",
	"table",
}

local dummyHandles = {
	checkbox = {
		clicked = function()
			return false
		end,
		checked = function()
			return false
		end,
	},

	button = {
		clicked = function()
			return false
		end,
	},

	slider = function(config)
		if type(config) == "table" then
			config = config.initial
		end
		return config
	end,

	window = {
		closed = function()
			return false
		end,
	},

	table = {
		selected = function() end,
		hovered = function() end,
	},
}

local function hookWidgets(debugger)
	local hookedWidgets = {}

	for _, name in widgets do
		local widget = debugger.plasma[name]

		hookedWidgets[name] = function(...)
			local debugSystem = debugger.debugSystem

			if debugSystem == nil or debugSystem ~= useCurrentSystem() then
				local dummyHandle = dummyHandles[name]
				if type(dummyHandle) == "function" then
					dummyHandle = dummyHandle(...)
				end
				return dummyHandle
			end

			if debugger._windowCount > 0 then
				return widget(...)
			end

			local args = table.pack(...)

			local parent = if name == "window" then debugger.parent else debugger.frame

			local returnValue
			debugger.plasma.portal(parent, function()
				returnValue = widget(unpack(args, 1, args.n))
			end)

			return returnValue
		end
	end

	local window = hookedWidgets.window
	hookedWidgets.window = function(title, fn)
		return window(title, function()
			debugger._windowCount += 1
			fn()
			debugger._windowCount -= 1
		end)
	end

	return hookedWidgets
end

return hookWidgets
