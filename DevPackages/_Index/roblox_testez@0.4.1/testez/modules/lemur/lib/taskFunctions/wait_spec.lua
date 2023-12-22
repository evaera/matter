local createWait = import("./wait")
local TaskScheduler = import("../TaskScheduler")

describe("taskFunctions.wait", function()
	it("should reschedule self after the specified time", function()
		local scheduler = TaskScheduler.new()
		local wait = createWait(scheduler)

		local aCount = 0
		local bCount = 0
		local cCount = 0

		local co = coroutine.create(function()
			aCount = aCount + 1
			wait(1)

			bCount = bCount + 1
			wait(1)

			cCount = cCount + 1
		end)

		assert(coroutine.resume(co))

		assert.equal(aCount, 1)
		assert.equal(bCount, 0)
		assert.equal(coroutine.status(co), "suspended")

		scheduler:step(1)

		assert.equal(aCount, 1)
		assert.equal(bCount, 1)
		assert.equal(cCount, 0)
		assert.equal(coroutine.status(co), "suspended")

		scheduler:step(1)

		assert.equal(aCount, 1)
		assert.equal(bCount, 1)
		assert.equal(cCount, 1)
		assert.equal(coroutine.status(co), "dead")
	end)

	it("should reschedule after a small amount of time with no argument", function()
		local scheduler = TaskScheduler.new()
		local wait = createWait(scheduler)

		local aCount = 0
		local bCount = 0

		local co = coroutine.create(function()
			aCount = aCount + 1
			wait()
			bCount = bCount + 1
		end)

		assert(coroutine.resume(co))

		assert.equal(aCount, 1)
		assert.equal(bCount, 0)
		assert.equal(coroutine.status(co), "suspended")

		scheduler:step(0.2)

		assert.equal(aCount, 1)
		assert.equal(bCount, 1)
		assert.equal(coroutine.status(co), "dead")
	end)

	it("should reschedule after a small amount of time with a zero argument", function()
		local scheduler = TaskScheduler.new()
		local wait = createWait(scheduler)

		local aCount = 0
		local bCount = 0

		local co = coroutine.create(function()
			aCount = aCount + 1
			wait(0)
			bCount = bCount + 1
		end)

		assert(coroutine.resume(co))

		assert.equal(aCount, 1)
		assert.equal(bCount, 0)
		assert.equal(coroutine.status(co), "suspended")

		scheduler:step(0.2)

		assert.equal(aCount, 1)
		assert.equal(bCount, 1)
		assert.equal(coroutine.status(co), "dead")
	end)
end)