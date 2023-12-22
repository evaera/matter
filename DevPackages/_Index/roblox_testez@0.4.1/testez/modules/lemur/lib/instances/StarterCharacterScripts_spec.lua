local StarterCharacterScripts = import("./StarterCharacterScripts")

describe("instances.StarterCharacterScripts", function()
	it("should instantiate", function()
		local instance = StarterCharacterScripts:new()

		assert.not_nil(instance)
	end)

	it("should inherit StarterPlayerScripts", function()
		assert.True(StarterCharacterScripts:new():IsA("StarterPlayerScripts"))
	end)
end)
