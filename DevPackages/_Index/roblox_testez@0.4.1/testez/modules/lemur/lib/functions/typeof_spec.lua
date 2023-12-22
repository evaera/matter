local typeof = import("./typeof")

describe("functions.typeof", function()
	it("should identify all Lua primitives", function()
		local values = {
			true, false, 0, "hello", {}, newproxy(true),
		}

		for _, value in ipairs(values) do
			assert.equal(type(value), typeof(value))
		end
	end)

	it("should identify all Instances as Instance", function()
		local instances = import("../instances")

		for _, instance in pairs(instances) do
			assert.equal("Instance", typeof(instance:new()))
		end
	end)
end)