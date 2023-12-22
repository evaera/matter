package.path = "./?/init.lua;" .. package.path
local lemur = require("lib")

describe("Lemur", function()
	it("should load folders correctly", function()
		local habitat = lemur.Habitat:new()

		local root = habitat:loadFromFs("spec/test-project")

		assert.equal(#root:GetChildren(), 3)

		local bar = root:FindFirstChild("bar")
		local usurp = root:FindFirstChild("usurp")
		local normal = root:FindFirstChild("normal-folder")

		assert.equal(bar.ClassName, "ModuleScript")
		assert.equal(usurp.ClassName, "ModuleScript")
		assert.equal(normal.ClassName, "Folder")

		assert.equal(bar.Source, "-- bar.lua")
		assert.equal(usurp.Source, "-- init.lua")

		assert.equal(#usurp:GetChildren(), 1)

		local foo = usurp:FindFirstChild("foo")
		assert.equal(foo.ClassName, "ModuleScript")
		assert.equal(foo.Source, "-- foo.lua")

		assert.equal(#normal:GetChildren(), 1)

		local ack = normal:FindFirstChild("ack")
		assert.equal(ack.ClassName, "ModuleScript")
		assert.equal(ack.Source, "-- ack.lua")
	end)

	it("should not touch init.lua if loadInitModules is false", function()
		local habitat = lemur.Habitat:new()

		local root = habitat:loadFromFs("spec/test-project", {
			loadInitModules = false,
		})

		assert.equal(#root:GetChildren(), 3)

		local usurp = root:FindFirstChild("usurp")
		assert.equal(usurp.ClassName, "Folder")

		local init = usurp:FindFirstChild("init")
		assert.equal(init.ClassName, "ModuleScript")
		assert.equal(init.Source, "-- init.lua")

		local foo = usurp:FindFirstChild("foo")
		assert.equal(foo.ClassName, "ModuleScript")
		assert.equal(foo.Source, "-- foo.lua")
	end)
end)