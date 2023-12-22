local InsertService = import("./InsertService")

describe("instances.InsertService", function()
	it("should instantiate", function()
		local instance = InsertService:new()

		assert.not_nil(instance)
	end)
end)