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
			local systemA = {
				system = function()
					table.insert(order, "a")
				end,
			}
			local systemB = {
				system = function()
					table.insert(order, "b")
				end,
				priority = -1,
			}
			local systemC = {
				system = function()
					table.insert(order, "c")
				end,
				priority = 1,
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
			expect(order[1]).to.equal("b")
			expect(order[2]).to.equal("a")
			expect(order[3]).to.equal("c")

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
