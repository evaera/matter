return function(taskScheduler)
	return function(delay)
		if delay == nil then
			delay = 0.03
		end

		taskScheduler:schedule(delay, coroutine.running())
		coroutine.yield()
	end
end