local CoreGui = import("./CoreGui")

describe("instances.CoreGui", function()
	it("should instantiate", function()
		local instance = CoreGui:new()

		assert.not_nil(instance)
	end)

	it("should have a ScreenGui child named RobloxGui", function()
		local instance = CoreGui:new()

		local robloxGui = instance:FindFirstChild("RobloxGui")

		assert.not_nil(robloxGui)
		assert.equal(robloxGui.ClassName, "ScreenGui")
	end)
end)