local CorePackages = import("./CorePackages")

describe("instances.CorePackages", function()
	it("should instantiate", function()
		local instance = CorePackages:new()

		assert.not_nil(instance)
	end)
end)