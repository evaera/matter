local VirtualInputManager = import("./VirtualInputManager")

describe("instances.VirtualInputManager", function()
	it("should instantiate", function()
		local instance = VirtualInputManager:new()

		assert.not_nil(instance)
	end)
end)