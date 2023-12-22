package.path = "./?/init.lua;" .. package.path
local lemur = require("lib")

describe("Lemur", function()
	it("should load modules directly", function()
		local habitat = lemur.Habitat.new()

		local root = habitat:loadFromFs("spec/require")

		local module = root:FindFirstChild("a")

		assert.not_nil(module)

		local value = habitat:require(module)

		assert.equal(value, "foo")

		assert.equal(root:FindFirstChild("a"), module)
		assert.not_nil(root:FindFirstChild("b"))
	end)

	it("should load modules from within folders", function()
		local habitat = lemur.Habitat.new()

		local root = habitat:loadFromFs("spec/require")

		local value = habitat:require(root.foo)

		assert.equal(value, "qux")
	end)

	it("should keep a module cache", function()
		local habitat = lemur.Habitat.new()

		local root = habitat:loadFromFs("spec/require")

		local a = habitat:require(root.cacheme)
		local b = habitat:require(root.cacheme)

		assert.equal(a, b)
	end)

	it("should fail to find non-existent modules", function()
		local habitat = lemur.Habitat.new()

		local root = habitat:loadFromFs("spec/require")

		local function nop()
		end

		assert.has.errors(function()
			nop(root.NOPE_NOT_HERE)
		end)

		local object = root:FindFirstChild("STILL_NOT_HERE")

		assert.is_nil(object)
	end)

	it("should fail to require non-ModuleScripts", function()
		local habitat = lemur.Habitat.new()

		assert.has.errors(function()
			habitat:require(habitat.game)
		end)
	end)
end)