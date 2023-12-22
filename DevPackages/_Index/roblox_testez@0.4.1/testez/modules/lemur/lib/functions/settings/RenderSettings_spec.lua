local RenderSettings = import("./RenderSettings")
local typeof = import("../typeof")

describe("functions.settings.RenderSettings", function()
	it("should be an object", function()
		local instance = RenderSettings.new()
		assert.not_nil(instance)
		assert.equals(typeof(instance), "RenderSettings")
	end)

	it("should be of type RenderSettings", function()
		local instance = RenderSettings.new()
		assert.equals(typeof(instance), "RenderSettings")
	end)

	it("should have a property QualityLevel", function()
		local instance = RenderSettings.new()
		assert.equals(instance.QualityLevel, 0)
	end)

	it("should allow me to set the property QualityLevel", function()
		local instance = RenderSettings.new()
		instance.QualityLevel = 1
		assert.equals(instance.QualityLevel, 1)
	end)

	it("should not allow me to access undefined properties", function()
		local instance = RenderSettings.new()
		assert.has.errors(function()
			tostring(instance.thisDoesNotExist)
		end)
	end)

	it("should not allow me to set undefined properties", function()
		local instance = RenderSettings.new()
		assert.has.errors(function()
			instance.thisDoesNotExist = "this should throw"
		end)
	end)
end)