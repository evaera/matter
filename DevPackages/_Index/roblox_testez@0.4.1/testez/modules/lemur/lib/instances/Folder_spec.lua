local Instance = import("../Instance")

describe("instances.Folder", function()
	it("should instantiate", function()
		local instance = Instance.new("Folder")

		assert.not_nil(instance)
	end)
end)