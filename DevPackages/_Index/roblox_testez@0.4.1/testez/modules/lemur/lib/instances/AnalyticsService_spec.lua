local AnalyticsService = import("./AnalyticsService")

describe("instances.AnalyticsService", function()
	it("should instantiate", function()
		local instance = AnalyticsService:new()

		assert.not_nil(instance)
	end)
end)