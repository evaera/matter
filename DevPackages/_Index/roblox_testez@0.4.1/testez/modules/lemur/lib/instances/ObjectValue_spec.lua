local Instance = import("../Instance")

describe("instances.ObjectValue", function()
	it("should instantiate", function()
		local instance = Instance.new("ObjectValue")

		assert.not_nil(instance)
		assert.equal("Value", instance.Name)
		assert.equal(nil, instance.Value)
	end)

	it("should set values", function()
		local instance = Instance.new("ObjectValue")

		instance.Value = instance

		assert.equal(instance.Value, instance)
	end)
end)