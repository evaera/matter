local StarterPlayer = import("./StarterPlayer")

describe("instances.StarterPlayer", function()
	it("should instantiate", function()
		local instance = StarterPlayer:new()

		assert.not_nil(instance)
	end)

	it("should contain StarterPlayerScripts and StarterCharacterScripts", function()
		local instance = StarterPlayer:new()

		assert.not_nil(instance:FindFirstChild("StarterPlayerScripts"))
		assert.not_nil(instance:FindFirstChild("StarterCharacterScripts"))
	end)
end)
