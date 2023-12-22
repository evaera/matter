local Instance = import("../Instance")

describe("instances.Frame", function()
	it("should instantiate", function()
		local instance = Instance.new("Frame")

		assert.not_nil(instance)
	end)
end)