local ReplicatedFirst = import("./ReplicatedFirst")

describe("instances.ReplicatedFirst", function()
	it("should instantiate", function()
		local instance = ReplicatedFirst:new()

		assert.not_nil(instance)
	end)
end)