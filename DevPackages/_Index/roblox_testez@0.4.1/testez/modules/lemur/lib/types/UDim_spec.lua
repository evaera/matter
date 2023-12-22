local UDim = import("./UDim")

local function extractValues(udim)
	return { udim.Scale, udim.Offset }
end

describe("types.UDim", function()
	it("should have an empty constructor", function()
		local udim = UDim.new()

		assert.not_nil(udim)
		assert.are.same({0, 0}, extractValues(udim))
	end)

	it("should have a constructor with two parameters", function()
		local udim = UDim.new(1, 200)

		assert.not_nil(udim)
		assert.are.same({1, 200}, extractValues(udim))
	end)

	it("should throw when bad params are passed to the constructor", function()
		assert.has.errors(function()
			UDim.new(1, "test")
		end)

		assert.has.errors(function()
			UDim.new("test", 10)
		end)
	end)

	it("should add another UDim", function()
		local udimA = UDim.new(1, 200)
		local udimB = UDim.new(100, 500)
		local udim = udimA + udimB

		assert.not_nil(udim)
		assert.are.same({101, 700}, extractValues(udim))
	end)

	it("should equal another UDim with the same scale and offset", function()
		local udimA = UDim.new(1, 200)
		local udimB = UDim.new(1, 200)

		assert.equals(udimA, udimB)
	end)

	it("should not equal another UDim with different scale and offset", function()
		local udimA = UDim.new(1, 200)

		local udimB1 = UDim.new(1, 201)
		local udimB2 = UDim.new(50, 200)
		local udimB3 = UDim.new(3, 7)

		assert.not_equals(udimA, udimB1)
		assert.not_equals(udimA, udimB2)
		assert.not_equals(udimA, udimB3)
	end)
end)
