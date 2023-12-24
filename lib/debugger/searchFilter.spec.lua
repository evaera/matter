local searchFilter = require(script.Parent.dynamicQuery)
local component = require(script.Parent.component).newComponent
local World = require(script.Parent.World)

return function()
	describeFOCUS("Search Filter", function()
		it("should find Oliver", function()
			local world = World.new()
			local Test = component("Test")
			local Friend = component("Friend")
			world:spawn(Test(), Friend({ name = "Oliver" }))
			world:spawn(Test())
			world:spawn(Friend())

			local entities = searchFilter(world, "Friend, ?Test")

			print(entities)
			expect(entities[1]["Friend"].name).to.equal("Oliver")
		end)
	end)
end
