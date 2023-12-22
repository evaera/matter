local Instance = import("../Instance")

describe("instances.ModuleScript", function()
	it("should instantiate", function()
		local instance = Instance.new("ModuleScript")

		assert.not_nil(instance)
		assert.is.string(instance.Source)
	end)
end)