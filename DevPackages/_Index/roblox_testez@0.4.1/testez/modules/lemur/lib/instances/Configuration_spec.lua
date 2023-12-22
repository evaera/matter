local Instance = import("../Instance")

describe("instances.Configuration", function()
	it("should instantiate", function()
		local instance = Instance.new("Configuration")

		assert.not_nil(instance)
	end)
end)