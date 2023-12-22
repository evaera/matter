local Instance = import("../Instance")

describe("instances.NumberValue", function()
	it("should instantiate", function()
		local instance = Instance.new("NumberValue")

		assert.not_nil(instance)
		assert.equal("Value", instance.Name)
		assert.equal(0, instance.Value)
	end)

	it("should work with decimals", function()
		local instance = Instance.new("NumberValue")
		instance.Value = 0.5
		assert.equal(instance.Value, 0.5)
	end)
end)