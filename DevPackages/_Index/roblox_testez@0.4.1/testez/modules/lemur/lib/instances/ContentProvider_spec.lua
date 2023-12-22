local ContentProvider = import("./ContentProvider")

describe("instances.ContentProvider", function()
	it("should instantiate", function()
		local instance = ContentProvider:new()

		assert.not_nil(instance)
	end)

	it("should have a string property BaseUrl", function()
		local instance = ContentProvider:new()

		assert.equals(type(instance.BaseUrl), "string")
	end)
end)