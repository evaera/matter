local Instance = import("../Instance")

describe("instances.LocalScript", function()
	it("should instantiate", function()
		local instance = Instance.new("LocalScript")

		assert.not_nil(instance)
		assert.is.string(instance.Source)
	end)
end)