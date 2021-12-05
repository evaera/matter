local TopoRuntime = require(script.Parent.TopoRuntime)

return function()
	describe("TopoRuntime", function()
		it("should restore state", function()
			local function useHook()
				local storage = TopoRuntime.useHookState("test")

				storage.counter = (storage.counter or 0) + 1

				return storage.counter
			end

			local node = {
				system = {},
			}

			local ranCount = 0
			local function fn()
				ranCount += 1
				expect(useHook()).to.equal(ranCount)
			end

			TopoRuntime.start(node, fn)

			TopoRuntime.start(node, fn)

			expect(ranCount).to.equal(2)
		end)

		it("should cleanup", function()
			local cleanedUpCount = 0
			local function useHook()
				local storage = TopoRuntime.useHookState("test")

				storage.counter = (storage.counter or 0) + 1

				storage.cleanup = function()
					cleanedUpCount += 1
				end

				return storage.counter
			end

			local node = {
				system = {},
			}

			local shouldRunHook = true
			local function fn()
				if shouldRunHook then
					expect(useHook()).to.equal(1)
				end
			end

			TopoRuntime.start(node, fn)

			expect(cleanedUpCount).to.equal(0)

			shouldRunHook = false

			TopoRuntime.start(node, fn)

			expect(cleanedUpCount).to.equal(1)

			shouldRunHook = true

			TopoRuntime.start(node, fn)

			expect(cleanedUpCount).to.equal(1)
		end)
	end)
end
