local typeof = import("./functions/typeof")
local createEnum = import("./createEnum")

local createEnumGroup = import("./createEnumGroup")

describe("createEnumGroup", function()
	it("should stringify as 'Enums'", function()
		local group = createEnumGroup({})

		assert.equal(tostring(group), "Enums")
	end)

	it("should have type 'Enums'", function()
		local group = createEnumGroup({})

		assert.equal(typeof(group), "Enums")
	end)

	it("should contain all input enums", function()
		local Foo = createEnum("Foo", {})
		local group = createEnumGroup({
			Foo = Foo,
		})

		assert.equal(group.Foo, Foo)
	end)

	it("should throw when passing non-enum values in", function()
		assert.has.errors(function()
			createEnumGroup({
				something = {},
			})
		end)
	end)

	it("should throw when indexing with unknown keys", function()
		local group = createEnumGroup({})

		assert.has.errors(function()
			tostring(group.whatever)
		end)
	end)
end)