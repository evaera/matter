local MarketplaceService = import("./MarketplaceService")

describe("instances.MarketplaceService", function()
	it("should instantiate", function()
		local instance = MarketplaceService:new()

		assert.not_nil(instance)
	end)
end)