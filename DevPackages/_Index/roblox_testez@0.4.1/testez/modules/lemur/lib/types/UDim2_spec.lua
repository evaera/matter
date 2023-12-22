local UDim = import("./UDim")
local UDim2 = import("./UDim2")

local function extractUDim2(udim)
	return { udim.X.Scale, udim.X.Offset, udim.Y.Scale, udim.Y.Offset }
end

describe("types.UDim2", function()
	it("should have an empty constructor", function()
		local udim = UDim2.new()

		assert.not_nil(udim)
		assert.are.same({0, 0, 0, 0}, extractUDim2(udim))
	end)

	it("should have a constructor with two parameters", function()
		local udim = UDim2.new(UDim.new(10, 20), UDim.new(50, 100))

		assert.not_nil(udim)
		assert.are.same({10, 20, 50, 100}, extractUDim2(udim))
	end)

	it("should have a constructor with four parameters", function()
		local udim = UDim2.new(10, 20, 50, 100)

		assert.not_nil(udim)
		assert.are.same({10, 20, 50, 100}, extractUDim2(udim))
	end)

	it("should throw when bad params are passed to the 4-param constructor", function()
		assert.has.errors(function()
			UDim2.new("test", 1, 2, 3)
		end)

		assert.has.errors(function()
			UDim2.new(1, "test", 2, 3)
		end)

		assert.has.errors(function()
			UDim2.new(1, 2, "test", 3)
		end)

		assert.has.errors(function()
			UDim2.new(1, 2, 3, "test")
		end)
	end)

	it("should throw when bad params are passed to the 2-param constructor", function()
		assert.has.errors(function()
			-- luacheck: push ignore udim
			local udim = UDim2.new("test", UDim.new())
			-- luacheck: pop
		end)

		assert.has.errors(function()
			-- luacheck: push ignore udim
			local udim = UDim2.new(UDim.new(), "test")
			-- luacheck: pop
		end)
	end)

	it("should have property X equal property Width", function()
		local udim = UDim2.new(10, 20, 50, 100)

		assert.not_nil(udim)
		assert.equals(udim.X, udim.Width)
	end)


	it("should have property Y equal property Height", function()
		local udim = UDim2.new(10, 20, 50, 100)

		assert.not_nil(udim)
		assert.equals(udim.Y, udim.Height)
	end)

	it("should add another UDim2", function()
		local udimA = UDim2.new(10, 30, 50, 200)
		local udimB = UDim2.new(UDim.new(20, 40), UDim.new(100, 500))
		local udim = udimA + udimB

		assert.not_nil(udim)
		assert.are.same({30, 70, 150, 700}, extractUDim2(udim))
	end)

	it("should equal another UDim2 with the same values", function()
		local udimA = UDim2.new(10, 30, 50, 200)
		local udimB = UDim2.new(10, 30, 50, 200)

		assert.equals(udimA, udimB)
	end)

	it("should not equal another UDim with different scale and offset", function()
		local udimA = UDim2.new(10, 30, 50, 200)

		local udimB1 = UDim2.new(11, 30, 50, 200)
		local udimB2 = UDim2.new(10, 15, 50, 200)
		local udimB3 = UDim2.new(10, 30, 60, 200)
		local udimB4 = UDim2.new(10, 30, 50, 100)
		local udimB5 = UDim2.new(1, 2, 3, 4)

		assert.not_equals(udimA, udimB1)
		assert.not_equals(udimA, udimB2)
		assert.not_equals(udimA, udimB3)
		assert.not_equals(udimA, udimB4)
		assert.not_equals(udimA, udimB5)
	end)

	it("should lerp", function()
		local udimA = UDim2.new(0, 100, 200, 300)
		local udimB = UDim2.new(100, 200, 300, 400)

		assert.are.same({0, 100, 200, 300}, extractUDim2(udimA:Lerp(udimB, 0)))
		assert.are.same({50, 150, 250, 350}, extractUDim2(udimA:Lerp(udimB, 0.5)))
		assert.are.same({100, 200, 300, 400}, extractUDim2(udimA:Lerp(udimB, 1)))
	end)
end)
