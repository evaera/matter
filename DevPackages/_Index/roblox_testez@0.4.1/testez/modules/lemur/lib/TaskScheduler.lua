local function taskCompare(a, b)
	return a.time > b.time
end

local TaskScheduler = {}
TaskScheduler.prototype = {}
TaskScheduler.__index = TaskScheduler.prototype

function TaskScheduler.new()
	local self = {}

	self.currentTime = 0
	self._tasks = {}

	setmetatable(self, TaskScheduler)

	return self
end

function TaskScheduler.prototype:schedule(delay, co)
	local task = {
		co = co,
		time = self.currentTime + delay,
	}

	table.insert(self._tasks, task)
	table.sort(self._tasks, taskCompare)
end

function TaskScheduler.prototype:step(deltaTime)
	self.currentTime = self.currentTime + deltaTime

	while true do
		local top = self._tasks[#self._tasks]

		if top == nil or top.time > self.currentTime then
			break
		end

		self._tasks[#self._tasks] = nil
		assert(coroutine.resume(top.co))
	end
end

return TaskScheduler