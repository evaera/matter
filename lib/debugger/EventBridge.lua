local RunService = game:GetService("RunService")
local EventBridge = {}
EventBridge.__index = EventBridge

local debouncedEvents = {
	InputChanged = true,
}

local debounce = {}

local function serialize(...)
	local first = ...

	if first and typeof(first) == "Instance" and first:IsA("InputObject") then
		return {
			Delta = first.Delta,
			KeyCode = first.KeyCode,
			Position = first.Position,
			UserInputState = first.UserInputState,
			UserInputType = first.UserInputType,
		}
	end

	return ...
end

local clientConnections = {}
EventBridge.clientActions = {
	connect = function(fire, instance, event)
		local instanceFromServer = instance

		if type(instance) == "string" then
			instance = game:GetService(instance)
		end

		if clientConnections[instance] == nil then
			clientConnections[instance] = {}
		end

		clientConnections[instance][event] = instance[event]:Connect(function(...)
			if debouncedEvents[event] and not RunService:IsStudio() then
				local args = table.pack(serialize(...))

				if debounce[instance] and debounce[instance][event] then
					debounce[instance][event] = args
				else
					if debounce[instance] == nil then
						debounce[instance] = {}
					end

					debounce[instance][event] = args

					task.delay(0.25, function()
						local args = debounce[instance][event]

						fire("event", instanceFromServer, event, unpack(args, 1, args.n))

						debounce[instance][event] = nil

						if next(debounce[instance]) == nil then
							debounce[instance] = nil
						end
					end)
				end

				return
			end

			fire("event", instanceFromServer, event, serialize(...))
		end)
	end,

	disconnect = function(_fire, instance, event)
		if type(instance) == "string" then
			instance = game:GetService(instance)
		end

		if clientConnections[instance] and clientConnections[instance][event] then
			clientConnections[instance][event]:Disconnect()
			clientConnections[instance][event] = nil
		end
	end,
}

function EventBridge.new(fire)
	return setmetatable({
		_fire = fire,
		_storage = {},
		players = {},
	}, EventBridge)
end

function EventBridge:connect(instance, event, handler)
	if RunService:IsClient() then
		return instance[event]:Connect(handler)
	end

	if not game:IsAncestorOf(instance) then
		local connection

		connection = instance.AncestryChanged:Connect(function()
			if connection == nil then
				return
			end

			if game:IsAncestorOf(instance) then
				connection:Disconnect()
				connection = nil
				self:connect(instance, event, handler)
			end
		end)

		return
	end

	if self._storage[instance] == nil then
		self._storage[instance] = {}

		instance.Destroying:Connect(function()
			for event in self._storage[instance] do
				self:_disconnect(instance, event)
			end
		end)
	end

	self._storage[instance][event] = handler

	for _, player in self.players do
		self:_connectPlayerEvent(player, instance, event)
	end

	return {
		Disconnect = function()
			self:_disconnect(instance, event)
		end,
	}
end

function EventBridge:_connectPlayerEvent(player, instance, event)
	if instance.Parent == game then
		instance = instance.ClassName
	end

	self._fire(player, "connect", instance, event)
end

function EventBridge:_disconnectPlayerEvent(player, instance, event)
	if instance.Parent == game then
		instance = instance.ClassName
	end

	self._fire(player, "disconnect", instance, event)
end

function EventBridge:connectPlayer(player)
	for instance, events in self._storage do
		for event in events do
			self:_connectPlayerEvent(player, instance, event)
		end
	end

	table.insert(self.players, player)
end

function EventBridge:disconnectPlayer(player)
	local index = table.find(self.players, player)

	if not index then
		return
	end

	table.remove(self.players, index)

	for instance, events in self._storage do
		for event in events do
			self:_disconnectPlayerEvent(player, instance, event)
		end
	end
end

function EventBridge:_disconnect(instance, event)
	self._storage[instance][event] = nil

	for _, player in self.players do
		self:_disconnectPlayerEvent(player, instance, event)
	end
end

function EventBridge:fireEventFromPlayer(player, instance, event, ...)
	if not table.find(self.players, player) then
		warn(player, "fired a debugger event but they aren't authorized")
		return
	end

	if type(instance) == "string" then
		instance = game:GetService(instance)
	end

	if not self._storage[instance] or not self._storage[instance][event] then
		-- warn(player, "fired a debugger event but the instance has no connections")
		return
	end

	self._storage[instance][event](...)
end

return EventBridge
