local Archetype = require(script.Parent.Archetype)
local component = require(script.Parent).component

return function()
	describe("Archetype", function()
		it("should report same sets as same archetype", function()
			local a = component()
			local b = component()
			expect(Archetype.archetypeOf(a, b)).to.equal(Archetype.archetypeOf(b, a))
		end)
		it("should identify compatible archetypes", function()
			local a = component()
			local b = component()
			local c = component()

			local archetypeA = Archetype.archetypeOf(a, b, c)
			local archetypeB = Archetype.archetypeOf(a, b)
			local archetypeC = Archetype.archetypeOf(b, c)

			expect(Archetype.areArchetypesCompatible(archetypeA, archetypeB)).to.equal(false)
			expect(Archetype.areArchetypesCompatible(archetypeB, archetypeA)).to.equal(true)

			expect(Archetype.areArchetypesCompatible(archetypeC, archetypeA)).to.equal(true)
			expect(Archetype.areArchetypesCompatible(archetypeB, archetypeC)).to.equal(false)
		end)
	end)
end
