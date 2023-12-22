local ServerScriptService = import("./ServerScriptService")

describe("instances.ServerScriptService", function()
	it("should instantiate", function()
		local instance = ServerScriptService:new()

		assert.not_nil(instance)
	end)
end)
