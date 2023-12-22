local Font = import("../Enum/Font")
local Vector2 = import("../types/Vector2")
local typeof = import("../functions/typeof")

local TextService = import("./TextService")

describe("instances.TextService", function()
	it("should instantiate", function()
		local instance = TextService:new()

		assert.not_nil(instance)
	end)

	describe("GetTextSize", function()
		it("should verify parameters", function()
			local instance = TextService:new()

			assert.has.errors(function()
				instance:GetTextSize(100, 36, Font.Legacy, Vector2.new(1, 1))
			end)
			assert.has.errors(function()
				instance:GetTextSize("text", "str", Font.Legacy, Vector2.new(1, 1))
			end)
			assert.has.errors(function()
				instance:GetTextSize("text", 36, "hey", Vector2.new(1, 1))
			end)
			assert.has.errors(function()
				instance:GetTextSize("text", 36, Font.Legacy, 100)
			end)
		end)

		it("should return a Vector2", function()
			local instance = TextService:new()
			local result = instance:GetTextSize("text", 36, Font.Legacy, Vector2.new(1000, 1000))

			assert.equals(typeof(result), "Vector2")
		end)

		it("should clip the rect down", function()
			local instance = TextService:new()
			local result = instance:GetTextSize("VERY LARGE TEXT", 36, Font.Legacy, Vector2.new(1, 1))

			assert.same({result.X, result.Y}, {1, 1})
		end)
	end)
end)