local Loop = require(script.Parent.Loop)
local useHookState = require(script.Parent.topoRuntime).useHookState
local World = require(script.Parent.World)
local component = require(script.Parent).component
local BindableEvent = require(script.Parent.mock.BindableEvent)

local bindable = BindableEvent.new()

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

		it("should allow evicting systems", function()
			local loop = Loop.new()

			local cleanedUp = false
			local function customHook()
				useHookState(nil, function()
					cleanedUp = true
				end)
			end

			local counts = {}
			local function system1()
				customHook()
				counts[1] = (counts[1] or 0) + 1
			end

			local function system2()
				counts[2] = (counts[2] or 0) + 1
			end

			loop:scheduleSystems({ system1, system2 })

			local bindable = BindableEvent.new()

			loop:begin({
				default = bindable.Event,
			})

			bindable:Fire()

			expect(cleanedUp).to.equal(false)
			expect(counts[1]).to.equal(1)
			expect(counts[2]).to.equal(1)

			loop:evictSystem(system1)

			expect(cleanedUp).to.equal(true)

			bindable:Fire()

			expect(counts[1]).to.equal(1)
			expect(counts[2]).to.equal(2)
		end)

		it("should allow replacing systems", function()
			local state = {}
			local loop = Loop.new(state)

			local function sampleHook(value)
				local storage = useHookState()

				if value then
					storage.value = value
				end

				return storage.value
			end

			local function makeSystem(isFirst)
				return function(state)
					local param = if isFirst then "sample text" else nil
					local returnValue = sampleHook(param)

					if isFirst then
						state.foo = "one"
					else
						state.foo = returnValue
					end
				end
			end

			local system1 = makeSystem(true)
			local system2 = makeSystem(false)

			loop:scheduleSystem(system1)

			local bindable = BindableEvent.new()

			loop:begin({
				default = bindable.Event,
			})

			bindable:Fire()

			expect(state.foo).to.equal("one")

			loop:replaceSystem(system1, system2)

			bindable:Fire()

			expect(state.foo).to.equal("sample text")
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

		it("should optimize queries of worlds used inside it", function()
			local world = World.new()
			local loop = Loop.new(world)

			local A = component()

			world:spawn(A())

			loop:scheduleSystem(function(world)
				world:query(A)
			end)

			local bindable = BindableEvent.new()
			loop:begin({
				default = bindable.Event,
			})

			bindable:Fire()

			expect(#world._storages).to.equal(1)
		end)
	end)
end
