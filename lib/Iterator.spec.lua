local Iterator = require(script.Parent.Iterator)

local testData = {
	{
		a = "aa",
		b = "bb",
	},
	{
		c = "cc",
	},
}

return function()
	describe("Iterator", function()
		it("should iterate over values", function()
			local iterator = Iterator.fromListOfMaps(testData)

			local x, y = iterator:next()
			expect(x).to.equal("a")
			expect(y).to.equal("aa")

			x, y = iterator:next()
			expect(x).to.equal("b")
			expect(y).to.equal("bb")

			x, y = iterator:next()
			expect(x).to.equal("c")
			expect(y).to.equal("cc")
		end)

		it("should collect", function()
			local iterator = Iterator.fromListOfMaps(testData)

			local length = 0

			for _ in pairs(iterator:collect()) do
				length += 1
			end

			expect(length).to.equal(3)
		end)

		it("should allow iter to be used in for loop", function()
			local iterator = Iterator.fromListOfMaps(testData)

			local length = 0

			for _ in iterator:iter() do
				length += 1
			end

			expect(length).to.equal(3)
		end)

		it("should allow chaining", function()
			local iterator = Iterator.fromListOfMaps(testData)

			local length = 0
			local results = {}

			for key, value in iterator
				:filter(function(_, value)
					return value ~= "bb"
				end)
				:iter() do
				length += 1

				results[key] = value
			end

			expect(length).to.equal(2)
			expect(results.a).to.equal("aa")
			expect(results.c).to.equal("cc")
			expect(results.b).to.never.be.ok()
		end)

		it("should work with without", function()
			local iterator = Iterator.fromListOfMaps({
				{
					a = {
						g = true,
						h = true,
					},
					b = {
						h = true,
					},
				},
				{
					c = {
						h = true,
					},
				},
			})

			local length = 0
			local results = {}

			for key, value in iterator:without("g"):iter() do
				length += 1

				results[key] = value
			end

			expect(length).to.equal(2)
			expect(results.b).to.be.ok()
			expect(results.c).to.be.ok()
			expect(results.a).to.never.be.ok()
		end)
	end)
end
