local Rect = import("./Rect")
local Vector2 = import("./Vector2")
local typeof = import("../functions/typeof")

local function extractRect(r)
	return { r.Min.X, r.Min.Y, r.Max.X, r.Max.Y, r.Width, r.Height }
end

describe("types.Rect", function()
	it("should not have an empty constructor", function()
		assert.has.errors(function()
			Rect.new()
		end)
	end)

	it("should have a constructor with two parameters", function()
		local r = Rect.new(Vector2.new(10, 20), Vector2.new(50, 100))

		assert.not_nil(r)
		assert.are.same({10, 20, 50, 100, 40, 80}, extractRect(r))
	end)

	it("should have a constructor with four parameters", function()
		local r = Rect.new(10, 20, 50, 100)

		assert.not_nil(r)
		assert.are.same({10, 20, 50, 100, 40, 80}, extractRect(r))
	end)

	it("should be type Rect", function()
		assert.equal(typeof(Rect.new(0, 0, 0, 0)), "Rect")
	end)

	it("should throw when bad params are passed to the 4-param constructor", function()
		assert.has.errors(function()
			Rect.new("test", 1, 2, 3)
		end)

		assert.has.errors(function()
			Rect.new(1, "test", 2, 3)
		end)

		assert.has.errors(function()
			Rect.new(1, 2, "test", 3)
		end)

		assert.has.errors(function()
			Rect.new(1, 2, 3, "test")
		end)
	end)

	it("should throw when bad params are passed to the 2-param constructor", function()
		assert.has.errors(function()
			Rect.new("test", Vector2.new())
		end)

		assert.has.errors(function()
			Rect.new(Vector2.new(), "test")
		end)
	end)

	it("should equal another Rect with the same values", function()
		local r1 = Rect.new(10, 30, 50, 200)
		local r2 = Rect.new(Vector2.new(10, 30), Vector2.new(50, 200))

		assert.equals(r1, r1)
		assert.equals(r1, r2)
		assert.equals(r2, r2)
	end)

	it("should not equal another Rect with different min and max values", function()
		local rectA = Rect.new(10, 30, 50, 200)

		local rectB1 = Rect.new(11, 30, 50, 200)
		local rectB2 = Rect.new(10, 16, 50, 200)
		local rectB3 = Rect.new(10, 30, 40, 200)
		local rectB4 = Rect.new(10, 30, 50, 205)

		assert.not_equals(rectA, rectB1)
		assert.not_equals(rectA, rectB2)
		assert.not_equals(rectA, rectB3)
		assert.not_equals(rectA, rectB4)
	end)
end)
