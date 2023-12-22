local ReplicatedStorage = import("./ReplicatedStorage")

describe("instances.ReplicatedStorage", function()
	it("should instantiate", function()
		local instance = ReplicatedStorage:new()

		assert.not_nil(instance)
	end)
end)