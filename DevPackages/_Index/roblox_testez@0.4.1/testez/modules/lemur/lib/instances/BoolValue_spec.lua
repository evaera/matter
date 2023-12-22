local Instance = import("../Instance")

describe("instances.BoolValue", function()
	it("should instantiate", function()
		local instance = Instance.new("BoolValue")

		assert.not_nil(instance)
		assert.equal("Value", instance.Name)
		assert.equal(false, instance.Value)
	end)
end)