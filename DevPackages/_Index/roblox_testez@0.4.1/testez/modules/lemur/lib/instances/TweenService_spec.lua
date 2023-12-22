local TweenService = import("./TweenService")

describe("instances.TweenService", function()
	it("should instantiate", function()
		local instance = TweenService:new()

		assert.not_nil(instance)
	end)
end)