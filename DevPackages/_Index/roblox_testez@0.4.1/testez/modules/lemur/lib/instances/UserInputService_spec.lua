local UserInputService = import("./UserInputService")

describe("instances.UserInputService", function()
	it("should instantiate", function()
		local instance = UserInputService:new()

		assert.not_nil(instance)
	end)
end)