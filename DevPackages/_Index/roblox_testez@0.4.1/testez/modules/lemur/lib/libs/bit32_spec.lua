local bit32 = import("./bit32")

describe("libs.bit32", function()
	describe("bor", function()
		it("should be a function", function()
			assert.is_function(bit32.bor)
		end)

		-- 101 -> 5
		-- 010 -> 2
		-- 101 | 010 = 111 -> 7
		it("should bitwise OR two values", function()
			assert.are.equals(7, bit32.bor(5, 2))
		end)
	end)

	describe("band", function()
		it("should be a function", function()
			assert.is_function(bit32.band)
		end)

		-- 101 -> 5
		-- 110 -> 6
		-- 101 & 110 = 100 -> 4
		it("should bitwise AND two values", function()
			assert.are.equals(4, bit32.band(5, 6))
		end)
	end)
end)