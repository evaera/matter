local Vector2 = import("./Vector2")

local function extractValues(v)
	return { v.X, v.Y }
end


describe("types.Vector2", function()
	it("should have an empty constructor", function()
		local v = Vector2.new()

		assert.not_nil(v)
		assert.are.same({0, 0}, extractValues(v))
	end)

	it("should have a constructor with two parameters", function()
		local v = Vector2.new(1, 200)

		assert.not_nil(v)
		assert.are.same({1, 200}, extractValues(v))
	end)

	it("should throw when bad params are passed to the constructor", function()
		assert.has.errors(function()
			Vector2.new(1, "test")
		end)

		assert.has.errors(function()
			Vector2.new("test", 10)
		end)
	end)

	it("should add another Vector2", function()
		local vectorA = Vector2.new(1, 200)
		local vectorB = Vector2.new(100, 500)
		local v = vectorA + vectorB

		assert.not_nil(v)
		assert.are.same({101, 700}, extractValues(v))
	end)

	it("should subtract another Vector2", function()
		local vectorA = Vector2.new(1, 200)
		local vectorB = Vector2.new(100, 500)
		local v = vectorA - vectorB

		assert.not_nil(v)
		assert.are.same({-99, -300}, extractValues(v))
	end)

	it("should multiply by another Vector2", function()
		local vectorA = Vector2.new(1, 50)
		local vectorB = Vector2.new(2, 0.5)
		local v = vectorA * vectorB

		assert.not_nil(v)
		assert.are.same({2, 25}, extractValues(v))
	end)

	it("should multiply by a number", function()
		local vectorA = Vector2.new(1, 50)
		local v = vectorA * 3

		assert.not_nil(v)
		assert.are.same({3, 150}, extractValues(v))
	end)

	it("should multiply by a number reversed", function()
		local vectorA = Vector2.new(1, 50)
		local v = 3 * vectorA

		assert.not_nil(v)
		assert.are.same({3, 150}, extractValues(v))
	end)

	it("should throw an error when multiplied by an incompatible type", function()
		assert.has.errors(function()
			return Vector2.new(1, 2) * nil
		end)
	end)

	it("should divide by another Vector2", function()
		local vectorA = Vector2.new(1, 50)
		local vectorB = Vector2.new(2, 1)
		local v = vectorA / vectorB

		assert.not_nil(v)
		assert.are.same({0.5, 50}, extractValues(v))
	end)

	it("should divide by a number", function()
		local vectorA = Vector2.new(1, 50)
		local v = vectorA / 4

		assert.not_nil(v)
		assert.are.same({0.25, 12.5}, extractValues(v))
	end)

	it("should divide by a number reversed", function()
		local vectorA = Vector2.new(1, 50)
		local v = 4 / vectorA

		assert.not_nil(v)
		assert.are.same({0.25, 12.5}, extractValues(v))
	end)

	it("should throw an error when divided by an incompatible type", function()
		assert.has.errors(function()
			return Vector2.new(1, 2) / "abc"
		end)
	end)

	it("should equal another Vector2 with the same x and y", function()
		local vectorA = Vector2.new(1, 200)
		local vectorB = Vector2.new(1, 200)

		assert.equals(vectorA, vectorB)
	end)

	it("should not equal another Vector2 with different x and/or y", function()
		local vectorA = Vector2.new(1, 200)

		local vectorB1 = Vector2.new(10, 200)
		local vectorB2 = Vector2.new(1, 300)
		local vectorB3 = Vector2.new(5, 10)

		assert.not_equals(vectorA, vectorB1)
		assert.not_equals(vectorA, vectorB2)
		assert.not_equals(vectorA, vectorB3)
	end)
end)
