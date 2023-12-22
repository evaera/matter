local Instance = import("../Instance")

describe("instances.NotificationService", function()
	it("should instantiate", function()
		local instance = Instance.new("NotificationService")

		assert.not_nil(instance)
	end)
end)