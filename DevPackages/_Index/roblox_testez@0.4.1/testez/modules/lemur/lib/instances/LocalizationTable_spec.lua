local Instance = import("../Instance")
local typeof = import("../functions/typeof")

describe("instances.LocalizationTable", function()
	it("should instantiate", function()
		local instance = Instance.new("LocalizationTable")

		assert.not_nil(instance)
	end)

	describe("SourceLocaleId", function()
		it("should be a string", function()
			local instance = Instance.new("LocalizationTable")
			assert.equals(typeof(instance.SourceLocaleId), "string")
		end)

		it("should be writeable", function()
			local instance = Instance.new("LocalizationTable")
			local value = "TestValue"
			instance.SourceLocaleId = value
			assert.equals(instance.SourceLocaleId, value)
		end)
	end)

	it("should translate text", function()
		local instance = Instance.new("LocalizationTable")

		local translationDictionary = [[
			[
				{
					"key": "TEST_STRING",
					"values": {
						"es-mx": "SPANISH",
						"en-us": "VALUE"
					}
				}
			]
		]]

		instance:SetContents(translationDictionary)

		assert.equals(instance:GetString("en-us", "TEST_STRING"), "VALUE")
		assert.equals(instance:GetString("es-mx", "TEST_STRING"), "SPANISH")
		assert.equals(instance:GetString("language-not-defined", "TEST_STRING"), nil)
		assert.equals(instance:GetString("en-us", "STRING_KEY_NOT_DEFINED"), nil)
	end)
end)