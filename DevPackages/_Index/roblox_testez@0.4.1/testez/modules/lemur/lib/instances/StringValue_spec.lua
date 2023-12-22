local Instance = import("../Instance")

describe("instances.StringValue", function()
	it("should instantiate", function()
		local instance = Instance.new("StringValue")

		assert.not_nil(instance)
		assert.equal("Value", instance.Name)
		assert.equal("", instance.Value)
	end)
end)