local Instance = import("../Instance")
local typeof = import("../functions/typeof")

describe("instances.UITextSizeConstraint", function()
	it("should instantiate", function()
		local instance = Instance.new("UITextSizeConstraint")

		assert.not_nil(instance)
	end)

	it("should have properties defined", function()
		local instance = Instance.new("UITextSizeConstraint")
		assert.equal(typeof(instance.MaxTextSize), "number")
	end)
end)