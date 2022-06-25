local topoRuntime = require(script.Parent.Parent.topoRuntime)
local useEvent = require(script.Parent.useEvent)
local BindableEvent = require(script.Parent.Parent.mock.BindableEvent)

return function()
	describe("useEvent", function()
		it("should queue up events until useEvent is called again", function()
			local node = {
				system = {},
			}

			local event = BindableEvent.new()

			local a, b, c
			local shouldCall = true
			local shouldCount = 0
			local fn = function()
				if shouldCall then
					local count = 0
					for index, fa, fb, fc in useEvent(event, event.Event) do
						expect(index).to.equal(count + 1)
						count += 1
						a = fa
						b = fb
						c = fc
					end
					expect(count).to.equal(shouldCount)
				end
			end

			topoRuntime.start(node, fn)

			event:Fire(3, 4, 5)

			shouldCount = 1
			topoRuntime.start(node, fn)

			expect(a).to.equal(3)
			expect(b).to.equal(4)
			expect(c).to.equal(5)

			shouldCount = 3

			event:Fire()
			event:Fire()
			event:Fire()

			topoRuntime.start(node, fn)

			shouldCount = 0

			topoRuntime.start(node, fn)

			event:Fire()
			event:Fire()

			shouldCall = false

			topoRuntime.start(node, fn)

			shouldCall = true

			-- Count should still be 0 as last frame didn't call useEvent
			topoRuntime.start(node, fn)
		end)

		it("should cleanup if the event changes", function()
			local node = {
				system = {},
			}

			local event1 = BindableEvent.new()
			local event2 = BindableEvent.new()

			local event = event1
			local shouldCount = 0
			local fn = function()
				local count = 0
				for _ in useEvent(event, "Event") do
					count += 1
				end
				expect(count).to.equal(shouldCount)
			end

			topoRuntime.start(node, fn)

			event1:Fire()
			event1:Fire()

			shouldCount = 2
			topoRuntime.start(node, fn)

			event1:Fire()
			event1:Fire()
			event = event2

			shouldCount = 0
			topoRuntime.start(node, fn)

			event2:Fire()

			shouldCount = 1
			topoRuntime.start(node, fn)
		end)
	end)
end
