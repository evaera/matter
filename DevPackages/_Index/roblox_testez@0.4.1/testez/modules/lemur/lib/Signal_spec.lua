local Signal = import("./Signal")

describe("Signal", function()
	it("should be instantiable", function()
		local signal = Signal.new()

		assert.is_userdata(signal)
		assert.is_function(signal.Connect)
		assert.is_function(signal.Wait)

		-- This isn't a standard function, but it's how users of Signal fire it!
		assert.is_function(signal.Fire)
	end)

	it("should handle connections", function()
		local signal = Signal.new()
		local spy = spy.new(function() end)

		local connection = signal:Connect(spy)

		assert.not_nil(connection)

		signal:Fire()
		assert.spy(spy).was_called(1)

		signal:Fire()
		assert.spy(spy).was_called(2)

		connection:Disconnect()
		signal:Fire()
		assert.spy(spy).was_called(2)
	end)

	it("should preserve other connections on disconnect", function()
		local signal = Signal.new()
		local spyA = spy.new(function() end)
		local spyB = spy.new(function() end)

		local connectionA = signal:Connect(spyA)
		signal:Connect(spyB)

		signal:Fire()

		assert.spy(spyA).was_called(1)
		assert.spy(spyB).was_called(1)

		connectionA:Disconnect()
		signal:Fire()

		assert.spy(spyA).was_called(1)
		assert.spy(spyB).was_called(2)
	end)

	it("should set Connected", function()
		local signal = Signal.new()

		local connection = signal:Connect(function() end)
		assert.is_true(connection.Connected)

		connection:Disconnect()
		assert.is_false(connection.Connected)
	end)

	it("should catch yields", function()
		local signal = Signal.new()

		signal:Connect(function()
			coroutine.yield()
		end)

		local co = coroutine.create(function()
			signal:Fire()
		end)

		assert(coroutine.resume(co))
		assert.equal(coroutine.status(co), "dead")
	end)

	it("should catch errors", function()
		local signal = Signal.new()

		signal:Connect(function()
			error("The test failed.")
		end)

		signal:Fire()
	end)

	-- Remove this when the event loop is made
	it("should error on Wait", function()
		local signal = Signal.new()

		assert.has.errors(function()
			signal:Wait()
		end)
	end)
end)