local TopoRuntime = require(script.Parent.Parent.TopoRuntime)
local useEvent = require(script.Parent.useEvent)

return function()
	describe("useEvent", function()
		it("should queue up events until useEvent is called again", function()
			local node = {
				system = {},
			}

			local event = Instance.new("BindableEvent")

			local shouldCall = true
			local shouldCount = 0
			local fn = function()
				if shouldCall then
					local count = 0
					useEvent(event, event.Event, function()
						count += 1
					end)
					expect(count).to.equal(shouldCount)
				end
			end

			TopoRuntime.start(node, fn)

			event:Fire()

			shouldCount = 1
			TopoRuntime.start(node, fn)

			shouldCount = 3

			event:Fire()
			event:Fire()
			event:Fire()

			TopoRuntime.start(node, fn)

			shouldCount = 0

			TopoRuntime.start(node, fn)

			event:Fire()
			event:Fire()

			shouldCall = false

			TopoRuntime.start(node, fn)

			shouldCall = true

			-- Count should still be 0 as last frame didn't call useEvent
			TopoRuntime.start(node, fn)
		end)

		it("should cleanup if the event changes", function()
			local node = {
				system = {},
			}

			local event1 = Instance.new("BindableEvent")
			local event2 = Instance.new("BindableEvent")

			local event = event1
			local shouldCount = 0
			local fn = function()
				local count = 0
				useEvent(event, "Event", function()
					count += 1
				end)
				expect(count).to.equal(shouldCount)
			end

			TopoRuntime.start(node, fn)

			event1:Fire()
			event1:Fire()

			shouldCount = 2
			TopoRuntime.start(node, fn)

			event1:Fire()
			event1:Fire()
			event = event2

			shouldCount = 0
			TopoRuntime.start(node, fn)

			event2:Fire()

			shouldCount = 1
			TopoRuntime.start(node, fn)
		end)
	end)
end
