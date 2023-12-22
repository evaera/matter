local StarterPlayerScripts = import("./StarterPlayerScripts")

describe("instances.StarterPlayerScripts", function()
	it("should instantiate", function()
		local instance = StarterPlayerScripts:new()

		assert.not_nil(instance)
	end)
end)
