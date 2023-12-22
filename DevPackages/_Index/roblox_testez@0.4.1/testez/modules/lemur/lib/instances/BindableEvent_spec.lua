local Instance = import("../Instance")

describe("instances.BindableEvent", function()
	it("should instantiate", function()
		local instance = Instance.new("BindableEvent")

		assert.not_nil(instance)
		assert.not_nil(instance.Event)
	end)

	it("should fire Event when fired", function()
		local instance = Instance.new("BindableEvent")

		local testSpy = spy.new(function() end)
		instance.Event:Connect(testSpy)

		instance:Fire()

		assert.spy(testSpy).was_called(1)
	end)
end)