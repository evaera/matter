local Instance = import("../Instance")

describe("instances.Model", function()
	it("should instantiate", function()
		local instance = Instance.new("Model")

		assert.not_nil(instance)
	end)
end)