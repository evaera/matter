local ServerStorage = import("./ServerStorage")

describe("instances.ServerStorage", function()
	it("should instantiate", function()
		local instance = ServerStorage:new()

		assert.not_nil(instance)
	end)
end)
