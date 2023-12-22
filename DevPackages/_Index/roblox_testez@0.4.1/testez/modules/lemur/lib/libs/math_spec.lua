local math = import("./math")

describe("libs.math", function()
	describe("clamp", function()
		it("should be a function", function()
			assert.is_function(math.clamp)
		end)

		it("should clamp if > max", function()
			assert.are.equals(1, math.clamp(2, 0, 1))
		end)

		it("should clamp if < min", function()
			assert.are.equals(0, math.clamp(-1, 0, 1))
		end)

		it("should not clamp if value is between min and max", function()
			assert.are.equals(0.5, math.clamp(0.5, 0, 1))
		end)
	end)
end)