local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local panel = require(script.Parent.widgets.panel)
local selectionList = require(script.Parent.widgets.selectionList)
local container = require(script.Parent.widgets.container)
local frame = require(script.Parent.widgets.frame)
local hookWidgets = require(script.Parent.hookWidgets)

local function systemName(system)
	local systemFn = if type(system) == "table" then system.system else system

	return debug.info(systemFn, "n")
end

local Debugger = {}
Debugger.__index = Debugger

function Debugger.new(plasma)
	local self = setmetatable({
		plasma = plasma,
		_windowCount = 0,
		_seenEvents = {},
		_eventOrder = {},
	}, Debugger)

	return self
end

function Debugger:autoInitialize(loop)
	local parent = Instance.new("ScreenGui")
	parent.Name = "Plasma"
	parent.ResetOnSpawn = false

	if RunService:IsClient() then
		parent.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	else
		parent.Parent = workspace
	end

	local plasmaNode = self.plasma.new(parent)

	loop:addMiddleware(function(nextFn, eventName)
		return function()
			if not self._seenEvents[eventName] then
				self._seenEvents[eventName] = true
				table.insert(self._eventOrder, eventName)
			end

			if eventName == self._eventOrder[1] then
				self._continueHandle = self.plasma.start(plasmaNode, function()
					self:update(loop)

					nextFn()
				end)
			elseif self._continueHandle then
				self.plasma.continue(self._continueHandle, function()
					nextFn()
				end)
			end
		end
	end)
end

function Debugger:replaceSystem(old, new)
	if self.debugSystem == old then
		self.debugSystem = new
	end
end

function Debugger:update(loop)
	local plasma = self.plasma

	container(function()
		panel({}, function()
			plasma.heading("SYSTEMS", 1)
			plasma.space(30)

			for _, eventName in self._eventOrder do
				local systems = loop._orderedSystemsByEvent[eventName]

				if not systems then
					continue
				end

				plasma.heading(eventName)
				plasma.space(10)
				local items = {}

				for _, system in systems do
					table.insert(items, {
						text = systemName(system),
						selected = self.debugSystem == system,
						system = system,
					})
				end

				local selected = selectionList(items):selected()

				if selected then
					if selected.system == self.debugSystem then
						self.debugSystem = nil
					else
						self.debugSystem = selected.system
					end
				end

				plasma.space(50)
			end
		end)

		if self.debugSystem then
			plasma.window("System config", function()
				plasma.useKey(systemName(self.debugSystem))
				plasma.heading(systemName(self.debugSystem))
				plasma.space(0)

				local currentlyDisabled = loop._skipSystems[self.debugSystem]

				if plasma.checkbox("Disable system", {
					checked = currentlyDisabled,
				}):clicked() then
					loop._skipSystems[self.debugSystem] = not currentlyDisabled
				end
			end)
		end

		self.parent = container(function()
			self.frame = frame()
		end)
	end, {
		direction = Enum.FillDirection.Horizontal,
	})
end

function Debugger:getWidgets()
	return hookWidgets(self)
end

return Debugger
