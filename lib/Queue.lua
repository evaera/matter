local Queue = {}
Queue.__index = Queue

function Queue.new()
	return setmetatable({
		_head = nil,
		_tail = nil,
	}, Queue)
end

function Queue:pushBack(value)
	local entry = {
		value = value,
		next = nil,
	}

	if self._tail ~= nil then
		self._tail.next = entry
	end

	self._tail = entry

	if self._head == nil then
		self._head = entry
	end
end

function Queue:popFront()
	if self._head == nil then
		return nil
	end

	local value = self._head.value
	self._head = self._head.next

	return value
end

return Queue
