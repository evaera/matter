local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Plasma = require(ReplicatedStorage.Packages.plasma)
local Matter = require(ReplicatedStorage.Lib.Matter)
local useCurrentSystem = Matter.useCurrentSystem

local widgets = {
	arrow = Plasma.arrow,
	blur = Plasma.blur,
	button = Plasma.button,
	checkbox = Plasma.checkbox,
	error = Plasma.error,
	portal = Plasma.portal,
	row = Plasma.row,
	spinner = Plasma.spinner,
	window = Plasma.window,

	slider = require(script.Parent.widgets.slider),
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
}

local function hookWidgets(state)
	local hookedWidgets = {}

	for name, widget in widgets do
		hookedWidgets[name] = function(...)
			local debugSystem = state.debugSystem

			if debugSystem == nil or debugSystem ~= useCurrentSystem() then
				return dummyHandles[name]
			end

			if state.windowCount > 0 then
				return widget(...)
			end

			local args = table.pack(...)

			local parent = if name == "window" then state.parent else state.frame

			local returnValue
			Plasma.portal(parent, function()
				returnValue = widget(unpack(args, 1, args.n))
			end)

			return returnValue
		end
	end

	local window = hookedWidgets.window
	hookedWidgets.window = function(title, fn)
		return window(title, function()
			state.windowCount += 1
			fn()
			state.windowCount -= 1
		end)
	end

	return hookedWidgets
end

return hookWidgets
