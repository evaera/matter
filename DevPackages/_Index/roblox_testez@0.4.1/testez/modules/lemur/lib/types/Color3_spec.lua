local Color3 = import("./Color3")

local typeof = import("../functions/typeof")

local function extractColors(color)
	return {
		color.r,
		color.g,
		color.b
	}
end

describe("types.Color3", function()
	it("should have an empty constructor", function()
		local color = Color3.new()

		assert.not_nil(color)
		assert.are.same({ 0, 0, 0 }, extractColors(color))
	end)

	it("should have a constructor that takes rgb values 0-1", function()
		local color = Color3.new(0, 0, 0)

		assert.not_nil(color)
	end)

	it("should have the fromRGB method", function()
		local color = Color3.fromRGB(255, 0, 0)

		assert.are.same({ 1, 0, 0 }, extractColors(color))
	end)

	it("should have the fromHSV method", function()
		local color = Color3.fromHSV(120 / 360, 0.5, 0.75)

		-- Round the colors to the nearest whole number
		-- This ensures we don't get errors from rounding, which are
		-- ultimately fairly unimportant.
		local r = math.floor(color.r * 255 + 0.5)
		local g = math.floor(color.g * 255 + 0.5)
		local b = math.floor(color.b * 255 + 0.5)

		assert.are.same({ 96, 191, 96 }, { r, g, b })
	end)

	it("should have the toHSV method", function()
		local color = Color3.fromHSV(120 / 360, 0.5, 0.75)
		local h, s, v = Color3.toHSV(color)

		assert.are.same({ 120 / 360, 0.5, 0.75 }, { h, s, v })
	end)

	describe("lerp", function()
		local a = Color3.new(0, 0, 0)
		local b = Color3.new(1, 1, 1)

		it("should lerp colors", function()
			-- Middle used to avoid rounding / float precision issues.
			local middle = a:lerp(b, 0.5)
			assert.are.same({ 0.5, 0.5, 0.5 }, extractColors(middle))
		end)

		it("should equal the goal when alpha is 1", function()
			assert.are.same({ 1, 1, 1 }, extractColors(a:lerp(b, 1)))
		end)

		it("should equal the start when alpha is 0", function()
			assert.are.same({ 0, 0, 0 }, extractColors(a:lerp(b, 0)))
		end)
	end)

	it("should compare Color3s", function()
		local c1, c2 = Color3.new(0, 1, 0), Color3.new(0, 1, 0)
		assert.are.equal(c1, c2)
		assert.are_not_equal(c1, Color3.new(0, 0, 0))
	end)

	it("should be detected by typeof", function()
		local type = typeof(Color3.new())
		assert.are.equal("Color3", type)
	end)
end)
