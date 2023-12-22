local typeof = import("../functions/typeof")

local GuiButton = import("./GuiButton")

describe("instances.GuiButton", function()
	it("should instantiate", function()
		local instance = GuiButton:new()

		assert.not_nil(instance)
	end)

	it("should have properties defined", function()
		local instance = GuiButton:new()
		assert.equal(typeof(instance.Activated), "RBXScriptSignal")
		assert.equal(typeof(instance.AutoButtonColor), "boolean")
		assert.equal(typeof(instance.Modal), "boolean")
		assert.equal(typeof(instance.MouseButton1Click), "RBXScriptSignal")
	end)
end)
