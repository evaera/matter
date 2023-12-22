local Humanoid = import("./Humanoid")
local Instance = import("../Instance")
local Workspace = import("./Workspace")

describe("instances.Humanoid", function()
	it("should instantiate", function()
		local instance = Instance.new("Humanoid")

		assert.not_nil(instance)
		assert.equal(instance.Health, 100)
		assert.equal(instance.MaxHealth, 100)
	end)

	it("should clamp health and max health", function()
		local instance = Humanoid:new()

		instance.MaxHealth = 50
		assert.equal(instance.MaxHealth, 50)
		assert.equal(instance.Health, 50)

		instance.MaxHealth = 100
		assert.equal(instance.MaxHealth, 100)
		assert.equal(instance.Health, 50)

		instance.Health = 300
		assert.equal(instance.MaxHealth, 100)
		assert.equal(instance.Health, 100)

		instance.Health = -10
		assert.equal(instance.Health, 0)

		instance.MaxHealth = -10
		assert.equal(instance.MaxHealth, 0)
		assert.equal(instance.Health, 0)
	end)

	it("should call Died when Health is set to 0 and the Humanoid is in Workspace", function()
		local instance = Humanoid:new()

		local spy = spy.new(function() end)
		instance.Died:Connect(spy)
		instance.Health = 0
		assert.spy(spy).was_called(0)
		instance.Health = 100
		assert.spy(spy).was_called(0)

		instance.Parent = Workspace:new()
		assert.spy(spy).was_called(0)
		instance.Health = 0
		assert.spy(spy).was_called(1)
	end)
end)
