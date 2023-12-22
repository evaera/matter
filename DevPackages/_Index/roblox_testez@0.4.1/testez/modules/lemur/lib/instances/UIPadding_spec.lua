local Instance = import("../Instance")
local typeof = import("../functions/typeof")

describe("instances.UIPadding", function()
	it("should instantiate", function()
		local instance = Instance.new("UIPadding")

		assert.not_nil(instance)
	end)

	it("should have properties defined", function()
		local instance = Instance.new("UIPadding")
		assert.equal(typeof(instance.PaddingBottom), "UDim")
		assert.equal(typeof(instance.PaddingLeft), "UDim")
		assert.equal(typeof(instance.PaddingRight), "UDim")
		assert.equal(typeof(instance.PaddingTop), "UDim")
	end)
end)