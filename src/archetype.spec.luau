local archetype = require(script.Parent.archetype)
local component = require(script.Parent).component

return function()
	describe("archetype", function()
		it("should report same sets as same archetype", function()
			local a = component()
			local b = component()
			expect(archetype.archetypeOf(a, b)).to.equal(archetype.archetypeOf(b, a))
		end)
		it("should identify compatible archetypes", function()
			local a = component()
			local b = component()
			local c = component()

			local archetypeA = archetype.archetypeOf(a, b, c)
			local archetypeB = archetype.archetypeOf(a, b)
			local archetypeC = archetype.archetypeOf(b, c)

			expect(archetype.areArchetypesCompatible(archetypeA, archetypeB)).to.equal(false)
			expect(archetype.areArchetypesCompatible(archetypeB, archetypeA)).to.equal(true)

			expect(archetype.areArchetypesCompatible(archetypeC, archetypeA)).to.equal(true)
			expect(archetype.areArchetypesCompatible(archetypeB, archetypeC)).to.equal(false)
		end)
	end)
end
