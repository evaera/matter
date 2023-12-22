local createSpawn = import("./spawn")
local TaskScheduler = import("../TaskScheduler")

describe("taskFunctions.spawn", function()
	it("should schedule after a small amount of time", function()
		local scheduler = TaskScheduler.new()
		local spawn = createSpawn(scheduler)

		local spy = spy.new(function() end)
		spawn(function() spy() end)
		scheduler:step(0.2)
		assert.spy(spy).was_called()
	end)
end)