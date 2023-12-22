return function(taskScheduler)
	return function(delay, fn)
		if type(delay) ~= "number" then
			error("Bad argument provided to delay, number expected, received " .. type(delay))
		end

		taskScheduler:schedule(math.max(0.03, delay), coroutine.create(fn))
	end
end