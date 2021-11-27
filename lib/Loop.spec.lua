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

			local connection = loop:begin(bindable.Event)

			expect(callCount).to.equal(0)
			bindable:Fire()
			expect(callCount).to.equal(1)
			connection:Disconnect()
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

			local connection = loop:begin(bindable.Event)

			expect(#order).to.equal(0)

			bindable:Fire()

			expect(#order).to.equal(3)
			expect(order[1]).to.equal("a")
			expect(order[2]).to.equal("b")
			expect(order[3]).to.equal("c")

			connection:Disconnect()
		end)
	end)
end
