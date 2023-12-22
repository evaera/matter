local createSettings = import("./createSettings")
local typeof = import("./functions/typeof")

describe("functions.settings", function()
	it("should be a function", function()
		assert.is_function(createSettings)
	end)

	it("should return the actual settings() function", function()
		local settings = createSettings({})
		local instance = settings()
		assert.equals(type(instance), "userdata")
	end)

	it("should always return the same object", function()
		local settings = createSettings({})

		local instance = settings()
		local instance2 = settings()
		assert.equals(instance, instance2)
	end)

	describe("GetFFlag", function()
		it("should check fast flags", function()
			local settings = createSettings({
				flags = {
					FFTest = true,
					FFTest2 = true,
					FFDoesSomethingHappen = false,
				}
			})

			local instance = settings()
			assert.True(instance:GetFFlag("FFTest"))
			assert.True(instance:GetFFlag("FFTest2"))
			assert.False(instance:GetFFlag("FFDoesSomethingHappen"))
		end)

		it("should throw if a fast flag does not exist", function()
			local settings = createSettings({
				flags = {
					FFTest = true,
					FFTest2 = true,
					FFDoesSomethingHappen = false,
				}
			})
			local instance = settings()

			assert.has.errors(function()
				instance:GetFFlag("FFUndefinedFastFlag")
			end)
		end)
	end)

	it("should have a property Rendering", function()
		local settings = createSettings({})

		local instance = settings()
		local renderSettings = instance.Rendering

		assert.not_nil(renderSettings)
		assert.equals(typeof(renderSettings), "RenderSettings")
	end)

	it("should not allow me to set the Rendering property", function()
		local settings = createSettings({})

		local instance = settings()
		assert.has.errors(function()
			instance.Rendering = true
		end)
	end)

	it("should not allow me to access undefined properties", function()
		local settings = createSettings({})

		local instance = settings()
		assert.has.errors(function()
			tostring(instance.thisDoesNotExist)
		end)
	end)

	it("should not allow me to set undefined properties", function()
		local settings = createSettings({})

		local instance = settings()
		assert.has.errors(function()
			instance.thisDoesNotExist = "this should throw"
		end)
	end)
end)
