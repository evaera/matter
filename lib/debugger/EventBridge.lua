local RunService = game:GetService("RunService")
local EventBridge = {}
EventBridge.__index = EventBridge

local clientConnections = {}
EventBridge.clientActions = {
	connect = function(fire, instance, event)
		if clientConnections[instance] == nil then
			clientConnections[instance] = {}
		end

		clientConnections[instance][event] = instance[event]:Connect(function(...)
			fire("event", instance, event, ...)
		end)
	end,

	disconnect = function(_fire, instance, event)
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
	self._fire(player, "connect", instance, event)
end

function EventBridge:_disconnectPlayerEvent(player, instance, event)
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

	if not self._storage[instance] or not self._storage[instance][event] then
		warn(player, "fired a debugger event but the instance has no connections")
		return
	end

	self._storage[instance][event](...)
end

return EventBridge
