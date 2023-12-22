local HttpRbxApiService = import("./HttpRbxApiService")

describe("instances.HttpRbxApiService", function()
	it("should instantiate", function()
		local instance = HttpRbxApiService:new()

		assert.not_nil(instance)
	end)
end)