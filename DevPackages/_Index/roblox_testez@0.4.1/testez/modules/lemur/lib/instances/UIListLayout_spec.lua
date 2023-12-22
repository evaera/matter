local Instance = import("../Instance")
local typeof = import("../functions/typeof")

describe("instances.UIListLayout", function()
	it("should instantiate", function()
		local instance = Instance.new("UIListLayout")

		assert.not_nil(instance)
	end)

	it("should inherit from UIGridStyleLayout", function()
		local instance = Instance.new("UIListLayout")

		assert.True(instance:IsA("UIGridStyleLayout"))
	end)

	it("should have properties defined", function()
		local instance = Instance.new("UIListLayout")

		assert.equals(typeof(instance.Padding), "UDim")
	end)
end)