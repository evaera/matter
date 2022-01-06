local Loop = require(script.Parent.Loop)

local bindable = Instance.new("BindableEvent")

return function()
	describe("Loop", function()
		it("should call systems", function()
			local loop = Loop.new(1, 2, 3)

			local callCount = 0
			loop:scheduleSystem(function(a, b, c)
				callCount += 1

				expect(a).to.equal(1)
				expect(b).to.equal(2)
				expect(c).to.equal(3)
			end)

			local connection = loop:begin({ default = bindable.Event })

			expect(callCount).to.equal(0)
			bindable:Fire()
			expect(callCount).to.equal(1)
			connection.default:Disconnect()
			expect(callCount).to.equal(1)
		end)

		it("should call systems in order", function()
			local loop = Loop.new()

			local order = {}
			local systemA = {
				system = function()
					table.insert(order, "a")
				end,
				after = {},
			}
			local systemB = {
				system = function()
					table.insert(order, "b")
				end,
				after = { systemA },
			}
			local systemC = {
				system = function()
					table.insert(order, "c")
				end,
				after = { systemA, systemB },
			}

			loop:scheduleSystems({
				systemC,
				systemB,
				systemA,
			})

			local connection = loop:begin({ default = bindable.Event })

			expect(#order).to.equal(0)

			bindable:Fire()

			expect(#order).to.equal(3)
			expect(order[1]).to.equal("a")
			expect(order[2]).to.equal("b")
			expect(order[3]).to.equal("c")

			connection.default:Disconnect()
		end)

		it("should call systems with priority in order", function()
			local loop = Loop.new()

			local order = {}

			local function cleanupStartReplication()
				table.insert(order, "e")
			end

			local function replicateEnemies()
				table.insert(order, "d")
			end

			local function spawnSwords()
				table.insert(order, "c")
			end

			local function spawnEnemies()
				table.insert(order, "b")
			end

			local function neutral()
				table.insert(order, "a")
			end

			loop:scheduleSystems({
				{
					system = spawnEnemies,
					priority = 0,
				},
				neutral,
				{
					system = replicateEnemies,
					priority = 100,
				},
				{
					system = spawnSwords,
					priority = 1,
				},
				{
					system = cleanupStartReplication,
					priority = 5000,
				},
			})

			local connection = loop:begin({ default = bindable.Event })

			expect(#order).to.equal(0)

			bindable:Fire()

			expect(#order).to.equal(5)
			expect(order[1]).to.equal("a")
			expect(order[2]).to.equal("b")
			expect(order[3]).to.equal("c")
			expect(order[4]).to.equal("d")
			expect(order[5]).to.equal("e")

			connection.default:Disconnect()
		end)

		it("should call middleware", function()
			local loop = Loop.new(1, 2, 3)

			local called = {}
			loop:addMiddleware(function(nextFn)
				return function()
					table.insert(called, 2)
					nextFn()
				end
			end)
			loop:addMiddleware(function(nextFn)
				return function()
					table.insert(called, 1)
					nextFn()
				end
			end)

			loop:scheduleSystem(function()
				table.insert(called, 3)
			end)

			loop:begin({ default = bindable.Event })

			expect(#called).to.equal(0)
			bindable:Fire()
			expect(#called).to.equal(3)
			expect(called[1]).to.equal(1)
			expect(called[2]).to.equal(2)
			expect(called[3]).to.equal(3)
		end)
	end)
end
