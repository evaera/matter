local Player = import("./Player")

describe("instances.Player", function()
	it("should instantiate", function()
		local instance = Player:new()

		assert.not_nil(instance)
		assert.equals(instance.UserId, 0)
	end)

	it("should take a userId", function()
		local instance = Player:new(1234)

		assert.equals(instance.UserId, 1234)
	end)

	it("should throw when userId is not a number", function()
		assert.has.errors(function()
			Player:new("1234")
		end)
	end)
end)