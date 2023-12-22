local ContextActionService = import("./ContextActionService")

describe("instances.ContextActionService", function()
	it("should instantiate", function()
		local instance = ContextActionService:new()

		assert.not_nil(instance)
	end)

	it("should have core binding methods", function()
		local instance = ContextActionService:new()

		instance:BindCoreAction("Foo", function()
			-- no op
		end, false)

		instance:UnbindCoreAction("Foo")
	end)
end)