local World = require(script.Parent.World)
local Loop = require(script.Parent.Loop)
local component = require(script.Parent).component

local function deepEquals(a, b)
	if type(a) ~= "table" or type(b) ~= "table" then
		return a == b
	end

	for k in pairs(a) do
		local av = a[k]
		local bv = b[k]
		if type(av) == "table" and type(bv) == "table" then
			local result = deepEquals(av, bv)
			if not result then
				return false
			end
		elseif av ~= bv then
			return false
		end
	end

	-- extra keys in b
	for k in pairs(b) do
		if a[k] == nil then
			return false
		end
	end

	return true
end

local function assertDeepEqual(a, b)
	if not deepEquals(a, b) then
		print("EXPECTED:", b)
		print("GOT:", a)
		error("Tables were not deep-equal")
	end
end

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

			local found = {}
			local foundCount = 0

			for entityId, player, health in world:query(Player, Health) do
				foundCount += 1
				found[entityId] = {
					[Player] = player,
					[Health] = health,
				}
			end

			expect(foundCount).to.equal(2)

			expect(found[one]).to.be.ok()
			expect(found[one][Player].name).to.equal("alice")
			expect(found[one][Health].value).to.equal(100)

			expect(found[two]).to.be.ok()
			expect(found[two][Player].name).to.equal("bob")
			expect(found[two][Health].value).to.equal(99)

			local count = 0
			for id, player in world:query(Player) do
				expect(type(player.name)).to.equal("string")
				expect(type(id)).to.equal("number")
				count += 1
			end
			expect(count).to.equal(2)

			local withoutCount = 0
			for _id, _player in world:query(Player):without(Poison) do
				withoutCount += 1
			end

			expect(withoutCount).to.equal(1)
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

		it("should track changes", function()
			local world = World.new()

			local loop = Loop.new(world)

			local A = component()
			local B = component()

			local expectedResults = {
				nil,
				{
					0,
					{
						new = {
							generation = 1,
						},
					},
				},
				{
					1,
					{
						new = {
							generation = 1,
						},
					},
				},
				{
					0,
					{
						new = {
							generation = 2,
						},
						old = {
							generation = 1,
						},
					},
				},
				nil,
				{
					0,
					{
						old = {
							generation = 2,
						},
					},
				},
			}

			local resultIndex = 0

			loop:scheduleSystem(function(w)
				local ran = false
				for entityId, record in w:queryChanged(A) do
					ran = true
					resultIndex += 1

					expect(entityId).to.equal(expectedResults[resultIndex][1])

					assertDeepEqual(record, expectedResults[resultIndex][2])
				end

				if not ran then
					resultIndex += 1
					expect(expectedResults[resultIndex]).to.equal(nil)
				end
			end)

			local infrequentCount = 0
			loop:scheduleSystem({
				system = function(w)
					infrequentCount += 1

					local count = 0
					local results = {}
					for entityId, record in w:queryChanged(A) do
						count += 1
						results[entityId] = record
					end

					if count == 0 then
						expect(infrequentCount).to.equal(1)
					else
						expect(infrequentCount).to.equal(2)
						expect(count).to.equal(2)

						expect(results[0].old.generation).to.equal(2)
						expect(results[1].new.generation).to.equal(1)
					end
				end,
				event = "infrequent",
			})

			local defaultBindable = Instance.new("BindableEvent")
			local infrequentBindable = Instance.new("BindableEvent")

			loop:begin({ default = defaultBindable.Event, infrequent = infrequentBindable.Event })

			defaultBindable:Fire()
			infrequentBindable:Fire()

			local entityId = world:spawn(A({
				generation = 1,
			}))

			defaultBindable:Fire()

			world:insert(
				entityId,
				A({
					generation = 2,
				})
			)

			world:insert(
				entityId,
				B({
					foo = "bar",
				})
			)

			world:spawn(A({
				generation = 1,
			}))

			defaultBindable:Fire()
			defaultBindable:Fire()

			world:despawn(entityId)

			defaultBindable:Fire()

			infrequentBindable:Fire()
		end)
	end)
end
