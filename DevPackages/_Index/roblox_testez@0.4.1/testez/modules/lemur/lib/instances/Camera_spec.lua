local Instance = import("../Instance")
local typeof = import("../functions/typeof")

describe("instances.Camera", function()
	it("should instantiate", function()
		local instance = Instance.new("Camera")

		assert.not_nil(instance)
	end)

	it("should have properties defined", function()
		local instance = Instance.new("Camera")
		assert.equal(typeof(instance.ViewportSize), "Vector2")
	end)
end)