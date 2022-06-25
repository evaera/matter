local BindableEvent = {}
BindableEvent.__index = BindableEvent

function BindableEvent.new()
	local self = setmetatable({
		_listeners = {},
		_locked = false,
	}, BindableEvent)

	self.Event = self

	return self
end

function BindableEvent:Connect(listener)
	table.insert(self._listeners, listener)

	return {
		Disconnect = function()
			local index = table.find(self._listeners, listener)

			if index then
				table.remove(self._listeners, index)
			end
		end,
	}
end

function BindableEvent:Fire(...)
	if self._locked then
		error("Cannot fire while firing")
	end

	self._locked = true
	for _, listener in self._listeners do
		local ok, errors = pcall(listener, ...)

		if not ok then
			warn(errors)
		end
	end
	self._locked = false
end

return BindableEvent
