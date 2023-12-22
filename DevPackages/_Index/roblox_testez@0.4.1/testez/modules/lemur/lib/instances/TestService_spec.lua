local TestService = import("./TestService")

describe("instances.TestService", function()
	it("should instantiate", function()
		local instance = TestService:new()

		assert.not_nil(instance)
		assert.not_nil(instance.Error)
	end)

	it("should write to stderr", function()
		local instance = TestService:new()
		local oldErr = io.stderr

		local writeSpy = spy.new(function(_, msg) end)

		io.stderr = { -- luacheck: ignore
			write = writeSpy
		}

		instance:Error("Testing tests in a library for testing?")

		assert.spy(writeSpy).was_called_with(io.stderr, "Testing tests in a library for testing?")

		io.stderr = oldErr -- luacheck: ignore
	end)
end)
