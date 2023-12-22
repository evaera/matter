local Instance = import("../Instance")

describe("instances.ParticleEffect", function()
	it("should instantiate", function()
		local instance = Instance.new("ParticleEffect")

		assert.not_nil(instance)
		assert.equal(true, instance.Enabled)
	end)
end)