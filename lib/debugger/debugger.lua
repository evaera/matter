local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local panel = require(script.Parent.widgets.panel)
local selectionList = require(script.Parent.widgets.selectionList)
local container = require(script.Parent.widgets.container)
local frame = require(script.Parent.widgets.frame)
local hookWidgets = require(script.Parent.hookWidgets)
local EventBridge = require(script.Parent.EventBridge)

local remoteEvent

local function systemName(system)
	local systemFn = if type(system) == "table" then system.system else system

	return debug.info(systemFn, "n")
end

local Debugger = {}
Debugger.__index = Debugger

function Debugger.new(plasma)
	if not remoteEvent then
		if RunService:IsServer() then
			remoteEvent = Instance.new("RemoteEvent")
			remoteEvent.Name = "MatterDebuggerRemote"
			remoteEvent.Parent = ReplicatedStorage
		else
			remoteEvent = ReplicatedStorage:WaitForChild("MatterDebuggerRemote")

			remoteEvent.OnClientEvent:Connect(function(action, ...)
				if not EventBridge.clientActions[action] then
					return
				end

				EventBridge.clientActions[action](function(...)
					remoteEvent:FireServer(...)
				end, ...)
			end)
		end
	end

	local self = setmetatable({
		plasma = plasma,
		enabled = false,
		_windowCount = 0,
		_seenEvents = {},
		_eventOrder = {},
		_eventBridge = EventBridge.new(function(...)
			remoteEvent:FireClient(...)
		end),
	}, Debugger)

	if RunService:IsServer() then
		remoteEvent.OnServerEvent:Connect(function(player, action, instance, event, ...)
			if action == "event" then
				self._eventBridge:fireEventFromPlayer(player, instance, event, ...)
			elseif action == "start" then
				if not RunService:IsStudio() then
					if self.authorize then
						if not self.authorize(player) then
							return
						end
					else
						warn("Player attempted to connect to matter debugger but no authorize function is configured.")
						return
					end
				end
				self:connectPlayer(player)
			elseif action == "stop" then
				self:disconnectPlayer(player)
			end
		end)
	end

	return self
end

function Debugger:show()
	if not RunService:IsClient() then
		error("show can only be called from the client")
	end

	self.enabled = true
end

function Debugger:hide()
	if not RunService:IsClient() then
		error("hide can only be called from the client")
	end

	self.enabled = false
	self.debugSystem = nil

	if self:_isServerView() then
		self:switchToClientView()
	end

	if self.plasmaNode then
		self.plasma.start(self.plasmaNode, function() end)
	end
end

function Debugger:toggle()
	if not RunService:IsClient() then
		error("toggle can only be called from the client")
	end

	if self.enabled then
		self:hide()
	else
		self:show()
	end
end

function Debugger:connectPlayer(player)
	if not RunService:IsServer() then
		error("connectClient can only be called from the server")
	end

	if not self.enabled then
		print("Matter server debugger started")
		self.enabled = true
	end

	self._eventBridge:connectPlayer(player)
end

function Debugger:disconnectPlayer(player)
	if not RunService:IsServer() then
		error("disconnectClient can only be called from the server")
	end

	self._eventBridge:disconnectPlayer(player)

	if #self._eventBridge.players == 0 then
		self.enabled = false
		print("Matter server debugger stopped")
	end
end

function Debugger:autoInitialize(loop)
	local parent = Instance.new("ScreenGui")
	parent.Name = "MatterDebugger"
	parent.ResetOnSpawn = false

	if RunService:IsClient() then
		parent.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	else
		parent.Parent = ReplicatedStorage
	end

	local plasmaNode = self.plasma.new(parent)
	self.plasmaNode = plasmaNode

	loop:addMiddleware(function(nextFn, eventName)
		return function()
			if not self._seenEvents[eventName] then
				self._seenEvents[eventName] = true
				table.insert(self._eventOrder, eventName)
			end

			if not self.enabled then
				nextFn()

				return
			end

			if eventName == self._eventOrder[1] then
				self._continueHandle = self.plasma.start(plasmaNode, function()
					self.plasma.setEventCallback(function(...)
						self._eventBridge:connect(...)
					end)

					self:draw(loop)

					nextFn()
				end)
			elseif self._continueHandle then
				self.plasma.continue(self._continueHandle, function()
					self.plasma.setEventCallback(function(...)
						self._eventBridge:connect(...)
					end)

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

function Debugger:switchToServerView()
	if not RunService:IsClient() then
		error("switchToServerView may only be called from the client.")
	end

	self.debugSystem = nil

	if not self.serverGui then
		self.serverGui = ReplicatedStorage:WaitForChild("MatterDebugger")

		self.serverGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	end

	remoteEvent:FireServer("start")

	self.serverGui.Enabled = true
end

function Debugger:switchToClientView()
	if not RunService:IsClient() then
		error("switchToClientView may only be called from the client.")
	end

	if not self.serverGui then
		return
	end

	remoteEvent:FireServer("stop")

	self.serverGui.Enabled = false
end

function Debugger:_isServerView()
	return self.serverGui and self.serverGui.Enabled
end

function Debugger:draw(loop)
	local plasma = self.plasma

	container(function()
		if self:_isServerView() then
			panel(function()
				if plasma.button("switch to client"):clicked() then
					self:switchToClientView()
				end
			end, {
				fullHeight = false,
			})
			return
		end

		panel(function()
			if RunService:IsClient() then
				if plasma.button("switch to server"):clicked() then
					self:switchToServerView()
				end
			end

			plasma.space(30)

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
		marginTop = if RunService:IsServer() then 80 else 0,
	})
end

function Debugger:getWidgets()
	return hookWidgets(self)
end

return Debugger
