return function(taskScheduler)
	return function(fn)
		taskScheduler:schedule(0.03, coroutine.create(fn))
	end
end