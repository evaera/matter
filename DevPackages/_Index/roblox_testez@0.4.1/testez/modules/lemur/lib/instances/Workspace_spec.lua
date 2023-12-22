local Workspace = import("./Workspace")
local typeof = import("../functions/typeof")

describe("instances.Workspace", function()
	it("should instantiate", function()
		local instance = Workspace:new()

		assert.not_nil(instance)
		assert.equal(typeof(instance.Gravity), "number")
	end)

	describe("CurrentCamera", function()
		it("should be an object of type Camera", function()
			local instance = Workspace:new()
			local camera = instance.CurrentCamera

			assert.not_nil(camera)
			assert.equal(typeof(camera), "Instance")
		end)

		it("should be accessible as a child named Camera", function()
			local instance = Workspace:new()
			local camera = instance:WaitForChild("Camera")

			assert.not_nil(camera)
			assert.equals(instance.CurrentCamera, camera)
		end)
	end)
end)