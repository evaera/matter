local createEnum = import("./createEnum")
local typeof = import("./functions/typeof")

describe("createEnum", function()
	it("should stringify as the input name", function()
		local enum = createEnum("Foo", {})

		assert.equal(tostring(enum), "Foo")
	end)

	it("should have typeof 'Enum'", function()
		local enum = createEnum("Bar", {})

		assert.equal(typeof(enum), "Enum")
	end)

	it("should have members for each input", function()
		local values = {
			a = 1,
			b = 2,
		}

		local enum = createEnum("Bar", values)

		for name, value in pairs(values) do
			local enumValue = enum[name]

			assert.equal(typeof(enumValue), "EnumItem")
			assert.equal(tostring(enumValue), string.format("Enum.Bar.%s", name))
			assert.equal(enumValue.Value, value)
			assert.equal(enumValue.Name, name)
			assert.equal(enumValue.EnumType, enum)
		end
	end)

	it("should throw when accessing invalid members", function()
		local enum = createEnum("Frobulon", {})

		assert.has.errors(function()
			tostring(enum.whatever)
		end)
	end)

	it("should throw when accessing invalid members of an enum variant", function()
		local enum = createEnum("Mungulation", {
			foo = 5,
		})

		local variant = enum.foo

		assert.has.errors(function()
			tostring(variant.something)
		end)
	end)
end)