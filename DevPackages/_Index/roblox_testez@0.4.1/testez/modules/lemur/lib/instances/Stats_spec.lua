local Stats = import("./Stats")

describe("instances.Stats", function()
	it("should instantiate", function()
		local instance = Stats:new()

		assert.not_nil(instance)
	end)
end)