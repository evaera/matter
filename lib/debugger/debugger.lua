local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local hookWidgets = require(script.Parent.hookWidgets)
local EventBridge = require(script.Parent.EventBridge)
local ui = require(script.Parent.ui)

local customWidgetConstructors = {
	panel = require(script.Parent.widgets.panel),
	selectionList = require(script.Parent.widgets.selectionList),
	container = require(script.Parent.widgets.container),
	frame = require(script.Parent.widgets.frame),
	link = require(script.Parent.widgets.link),
	logo = require(script.Parent.widgets.logo),
	realmSwitch = require(script.Parent.widgets.realmSwitch),
}

local remoteEvent

-- Assert plasma is compatible via feature detection
local function assertCompatiblePlasma(plasma)
	if not plasma.table then
		error("Plasma passed to Matter debugger is out of date, please update it to use the debugger.")
	end
end

--[=[
	@class Debugger

	Attaches a Debugger to the Matter instance, allowing you to create debug widgets in your systems.

	```lua
	local debugger = Matter.Debugger.new(Plasma)

	local widgets = debugger:getWidgets()
	local loop = Matter.Loop.new(world, widgets) -- pass the widgets to your systems

	debugger:autoInitialize(loop)

	if RunService:IsClient() then
		debugger:show()
	end
	```

	When the debugger is not open, the widgets do not render.
]=]
local Debugger = {}
Debugger.__index = Debugger

--[=[
	@prop authorize (player: Player) -> boolean
	@within Debugger

	Create this property in Debugger to specify a function that will be called to determine if a player should be
	allowed to connect to the server-side debugger.

	If not specified, the default behavior is to allow anyone in Studio and disallow everyone in a live game.

	```lua
	debugger.authorize = function(player)
		if player:GetRankInGroup(372) > 250 then -- etc
			return true
		end
	end
	```
]=]

--[=[
	Creates a new Debugger.

	You need to depend on [Plasma](https://eryn.io/plasma/) in your project and pass a handle to it here.

	@param plasma Plasma -- The instance of Plasma used in your game.
	@return Debugger
]=]
function Debugger.new(plasma)
	assertCompatiblePlasma(plasma)

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
		_customWidgets = {},
	}, Debugger)

	for name, create in customWidgetConstructors do
		self._customWidgets[name] = create(plasma)
	end

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
	else
		CollectionService:GetInstanceAddedSignal("MatterDebuggerSwitchToClientView"):Connect(function(instance)
			instance.Activated:Connect(function()
				self:switchToClientView()
			end)
		end)
	end

	return self
end

--[=[
	@client

	Shows the debugger panel
]=]
function Debugger:show()
	if not RunService:IsClient() then
		error("show can only be called from the client")
	end

	self.enabled = true
end

--[=[
	@client

	Hides the debugger panel
]=]
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

--[=[
	@client

	Toggles visibility of the debugger panel
]=]
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
		self.debugSystem = nil
		print("Matter server debugger stopped")
	end
end

--[=[
	Adds middleware to your Loop to set up the debugger every frame.

	:::tip
	The debugger must also be shown on a client with [Debugger:show] or [Debugger:toggle] to be used.
	:::

	If you also want to use Plasma for more than just the debugger, you can opt to not call this function and instead
	do what it does yourself.

	@param loop Loop
]=]
function Debugger:autoInitialize(loop)
	local parent = Instance.new("ScreenGui")
	parent.Name = "MatterDebugger"
	parent.ResetOnSpawn = false
	parent.IgnoreGuiInset = true

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
				loop.profiling = nil

				nextFn()

				return
			end

			loop.profiling = loop.profiling or {}

			if eventName == self._eventOrder[1] then
				self._continueHandle = self.plasma.beginFrame(plasmaNode, function()
					self.plasma.setEventCallback(function(...)
						return self._eventBridge:connect(...)
					end)

					self:draw(loop)

					nextFn()
				end)
			elseif self._continueHandle then
				self.plasma.continueFrame(self._continueHandle, function()
					self.plasma.setEventCallback(function(...)
						return self._eventBridge:connect(...)
					end)

					nextFn()
				end)
			end

			if eventName == self._eventOrder[#self._eventOrder] then
				self.plasma.finishFrame(plasmaNode)
			end
		end
	end)

	if RunService:IsClient() then
		self.plasma.hydrateAutomaticSize()
	end
end

--[=[
	Alert the debugger when a system is hot reloaded.

	@param old System
	@param new System
]=]
function Debugger:replaceSystem(old, new)
	if self.debugSystem == old then
		self.debugSystem = new
	end
end

--[=[
	@client

	Switch the client to server view. This starts the server debugger if it isn't already started.
]=]
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

--[=[
	Switch the client to client view. This stops the server debugger if there are no other players connected.
]=]
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

--[=[
	This should be called to draw the debugger UI.

	This is automatically set up when you call [Debugger:autoInitialize], so you don't need to call this yourself unless
	you didn't call `autoInitialize`.

	@param loop Loop
]=]
function Debugger:draw(loop)
	ui(self, loop)
end

--[=[
	Returns a handle to the debug widgets you can pass to your systems.

	All [plasma widgets](https://eryn.io/plasma/api/Plasma#arrow) are available under this namespace.

	```lua
	-- ...
	local debugger = Debugger.new(Plasma)

	local loop = Loop.new(world, state, debugger:getWidgets())
	```

	When the Debugger is not open, calls to widgets are no-ops.

	If the widget normally returns a handle (e.g., button returns a table with `clicked`), it returns a static dummy
	handle that always returns a default value:

	- `checkbox`
		- `clicked`: false
		- `checked`: false
	- `button`
		- `clicked`: false
	- `slider`: 0

	@return {[string]: Widget}
]=]
function Debugger:getWidgets()
	return hookWidgets(self)
end

return Debugger
