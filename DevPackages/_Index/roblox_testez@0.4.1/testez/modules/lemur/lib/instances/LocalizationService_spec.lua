local LocalizationService = import("./LocalizationService")

describe("instances.LocalizationService", function()
	it("should instantiate", function()
		local instance = LocalizationService:new()

		assert.not_nil(instance)
	end)

	describe("SystemLocaleId", function()
		it("should have a string value", function()
			local instance = LocalizationService:new()
			assert.not_nil(instance.SystemLocaleId)
			assert.equals(type(instance.SystemLocaleId), "string")
		end)

		it("should be read-only", function()
			local instance = LocalizationService:new()
			assert.has.errors(function()
				instance.SystemLocaleId = "es-mx"
			end)
		end)
	end)

	describe("RobloxLocaleId", function()
		it("should have a string value", function()
			local instance = LocalizationService:new()
			assert.not_nil(instance.RobloxLocaleId)
			assert.equals(type(instance.RobloxLocaleId), "string")
		end)

		it("should be read-only", function()
			local instance = LocalizationService:new()
			assert.has.errors(function()
				instance.RobloxLocaleId = "es-mx"
			end)
		end)
	end)
end)