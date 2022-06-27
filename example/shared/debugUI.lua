local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Plasma = require(ReplicatedStorage.Packages.plasma)
local label = require(script.Parent.widgets.label)
local heading = require(script.Parent.widgets.heading)
local panel = require(script.Parent.widgets.panel)
local space = require(script.Parent.widgets.space)
local selectionList = require(script.Parent.widgets.selectionList)
local container = require(script.Parent.widgets.container)
local frame = require(script.Parent.widgets.frame)

local function systemName(system)
	local systemFn = if type(system) == "table" then system.system else system

	return debug.info(systemFn, "n")
end

local function debugUI(state)
	state.windowCount = state.windowCount or 0

	container(function()
		panel({}, function()
			heading("SYSTEMS", 1)
			space(30)

			for event, systems in state.loop._orderedSystemsByEvent do
				heading(tostring(event))
				space(10)
				local items = {}
				for _, system in systems do
					table.insert(items, {
						text = systemName(system),
						selected = state.debugSystem == system,
						system = system,
					})
				end

				local selected = selectionList(items):selected()

				if selected then
					if selected.system == state.debugSystem then
						state.debugSystem = nil
					else
						state.debugSystem = selected.system
					end
				end

				space(50)
			end
		end)

		if state.debugSystem then
			Plasma.window("System config", function()
				heading(systemName(state.debugSystem))
				space(0)

				local currentlyDisabled = state.loop._skipSystems[state.debugSystem]

				if Plasma.checkbox("Disable system", {
					checked = currentlyDisabled,
				}):clicked() then
					state.loop._skipSystems[state.debugSystem] = not currentlyDisabled
				end
			end)
		end

		state.parent = container(function()
			state.frame = frame()
		end)
	end, {
		direction = Enum.FillDirection.Horizontal,
	})
end

return debugUI
