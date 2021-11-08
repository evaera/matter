local Component = require(script.Parent.Component)
local component = Component.newComponent

return function()
	describe("Component", function()
		it("should create components", function()
			local a = component()
			local b = component()

			expect(getmetatable(a)).to.be.ok()

			expect(getmetatable(a)).to.never.equal(getmetatable(b))

			expect(typeof(a.new)).to.equal("function")
		end)

		it("should allow calling the table to construct", function()
			local a = component()

			expect(getmetatable(a())).to.equal(getmetatable(a.new()))
		end)
	end)
end
