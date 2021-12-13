local World = require(script.Parent.World)
local component = require(script.Parent).component

return function()
	describe("World", function()
		it("should have correct size", function()
			local world = World.new()
			world:spawn()
			world:spawn()
			world:spawn()

			local id = world:spawn()
			world:despawn(id)

			expect(world:size()).to.equal(3)

			world:clear()

			expect(world:size()).to.equal(0)
		end)

		it("should report contains correctly", function()
			local world = World.new()
			local id = world:spawn()

			expect(world:contains(id)).to.equal(true)
			expect(world:contains(1234124124124124124124)).to.equal(false)
		end)

		it("should allow inserting and removing components from existing entities", function()
			local world = World.new()

			local Player = component()
			local Health = component()

			local id = world:spawn(Player())

			expect(world:query(Player):next()).to.be.ok()
			expect(world:query(Health):next()).to.never.be.ok()

			world:insert(id, Health())

			expect(world:query(Player):next()).to.be.ok()
			expect(world:query(Health):next()).to.be.ok()
			expect(world:size()).to.equal(1)

			world:remove(id, Player)

			expect(world:query(Player):next()).to.never.be.ok()
			expect(world:query(Health):next()).to.be.ok()
			expect(world:size()).to.equal(1)
		end)

		it("should be queryable", function()
			local world = World.new()

			local Player = component()
			local Health = component()
			local Poison = component()

			local one = world:spawn(
				Player({
					name = "alice",
				}),
				Health({
					value = 100,
				}),
				Poison()
			)

			world:spawn( -- Spawn something we don't want to get back
				component(),
				component()
			)

			local two = world:spawn(
				Player({
					name = "bob",
				}),
				Health({
					value = 99,
				})
			)

			local result = world:query(Player, Health):collect()

			local found = {}
			local foundCount = 0

			for entityId, entityData in pairs(result) do
				found[entityId] = entityData
				foundCount += 1
			end

			expect(foundCount).to.equal(2)

			expect(found[one]).to.be.ok()
			expect(found[one][Player].name).to.equal("alice")
			expect(found[one][Health].value).to.equal(100)
			expect(found[one][Poison]).to.be.ok()

			expect(found[two]).to.be.ok()
			expect(found[two][Player].name).to.equal("bob")
			expect(found[two][Health].value).to.equal(99)
			expect(found[two][Poison]).to.never.be.ok()

			local count = 0
			for id, player in world:query(Player) do
				expect(type(player.name)).to.equal("string")
				expect(type(id)).to.equal("number")
				count += 1
			end
			expect(count).to.equal(2)
		end)

		it("should allow getting single components", function()
			local world = World.new()

			local Player = component()
			local Health = component()
			local Other = component()

			local id = world:spawn(Other({ a = 1 }), Player({ b = 2 }), Health({ c = 3 }))

			expect(world:get(id, Player).b).to.equal(2)
			expect(world:get(id, Health).c).to.equal(3)

			local one, two = world:get(id, Health, Player)

			expect(one.c).to.equal(3)
			expect(two.b).to.equal(2)
		end)
	end)
end
