local Instance = import("../Instance")

describe("instances.Script", function()
	it("should instantiate", function()
		local instance = Instance.new("Script")

		assert.not_nil(instance)
		assert.is.string(instance.Source)
	end)
end)