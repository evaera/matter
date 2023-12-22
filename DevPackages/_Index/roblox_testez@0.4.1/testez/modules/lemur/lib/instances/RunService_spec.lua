local RunService = import("./RunService")
local Signal = import("../Signal")

describe("instances.RunService", function()
	it("should instantiate", function()
		local instance = RunService:new()

		assert.not_nil(instance)
		assert.not_nil(instance.Heartbeat)
	end)

	it("should have the name 'Run Service'", function()
		local instance = RunService:new()
		assert.is_equal(instance.Name, "Run Service")
	end)

	it("should return false when IsStudio() is called", function()
		local instance = RunService:new()
		assert.is_equal(instance:IsStudio(), false)
	end)

	it("should return a bool when IsServer() is called", function()
		local instance = RunService:new()
		assert.is_equal(type(instance:IsServer()), "boolean")
	end)

	it("should have properties defined", function()
		local instance = RunService:new()

		assert.equals(instance.Heartbeat.__index, Signal)
		assert.equals(instance.RenderStepped.__index, Signal)
	end)
end)