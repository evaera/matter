local typeof = import("../functions/typeof")

local Model = import("./Model")
local Players = import("./Players")

describe("instances.Players", function()
	it("should instantiate", function()
		local instance = Players:new()

		assert.not_nil(instance)
	end)

	it("should have properties defined", function()
		local instance = Players:new()

		assert.equal(typeof(instance.LocalPlayer), "Instance")
	end)

	it("should return nil when using GetPlayerFromCharacter", function()
		local instance = Players:new()

		assert.equal(instance:GetPlayerFromCharacter(Model:new()), nil)
	end)
end)
