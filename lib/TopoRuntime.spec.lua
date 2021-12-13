local TopoRuntime = require(script.Parent.TopoRuntime)

return function()
	describe("TopoRuntime", function()
		it("should restore state", function()
			local function useHook()
				local storage = TopoRuntime.useHookState()

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
			local shouldCleanup = false
			local cleanedUpCount = 0
			local function useHook()
				local storage = TopoRuntime.useHookState(nil, function()
					if shouldCleanup then
						cleanedUpCount += 1
					else
						return true
					end
				end)

				storage.counter = (storage.counter or 0) + 1

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

			expect(cleanedUpCount).to.equal(0)

			shouldCleanup = true

			TopoRuntime.start(node, fn)

			expect(cleanedUpCount).to.equal(1)

			shouldRunHook = true

			TopoRuntime.start(node, fn)

			expect(cleanedUpCount).to.equal(1)
		end)

		it("should allow keying by unique values", function()
			local function useHook(unique)
				local storage = TopoRuntime.useHookState(unique)

				storage.counter = (storage.counter or 0) + 1

				return storage.counter
			end

			local node = {
				system = {},
			}

			local ranCount = 0
			local function fn()
				ranCount += 1
				expect(useHook("a value")).to.equal(ranCount)
			end

			TopoRuntime.start(node, fn)

			TopoRuntime.start(node, fn)

			expect(ranCount).to.equal(2)

			TopoRuntime.start(node, function()
				fn()
				fn()
			end)

			expect(ranCount).to.equal(4)
		end)
	end)
end
