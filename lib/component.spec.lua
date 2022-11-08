local Component = require(script.Parent.component)
local None = require(script.Parent.immutable).None
local component = Component.newComponent
local assertValidComponentInstance = Component.assertValidComponentInstance
local assertValidComponent = Component.assertValidComponent

return function()
	describe("Component", function()
		it("should create components", function()
			local a = component()
			local b = component()

			expect(getmetatable(a)).to.be.ok()

			expect(getmetatable(a)).to.never.equal(getmetatable(b))

			expect(typeof(a.new)).to.equal("function")
		end)

		it("should allow calling the table to construct", function()
			local a = component()

			expect(getmetatable(a())).to.equal(getmetatable(a.new()))
		end)

		it("should allow patching into a new component", function()
			local A = component()

			local a = A({
				foo = "bar",
				unset = true,
			})

			local a2 = a:patch({
				baz = "qux",
				unset = None,
			})

			expect(a2.foo).to.equal("bar")
			expect(a2.unset).to.equal(nil)
			expect(a2.baz).to.equal("qux")
		end)

		it("should allow specifying default data", function()
			local Foo = component("Foo", {
				a = 53,
			})

			local foo = Foo()

			expect(foo.a).to.equal(53)

			local bar = Foo({
				a = 42,
				b = 54,
			})

			expect(bar.a).to.equal(42)
			expect(bar.b).to.equal(54)

			local baz = Foo({
				b = 100,
			})

			expect(baz.a).to.equal(53)
			expect(baz.b).to.equal(100)
		end)
	end)

	describe("assertValidComponentInstance", function()
		it("should throw on invalid components", function()
			expect(function()
				assertValidComponentInstance({})
			end).to.throw()

			expect(function()
				assertValidComponentInstance(55)
			end).to.throw()

			expect(function()
				assertValidComponentInstance(component())
			end).to.throw()

			expect(function()
				assertValidComponentInstance(component().new())
			end).never.to.throw()
		end)
	end)

	describe("assertValidComponent", function()
		it("should throw on invalid components", function()
			expect(function()
				assertValidComponent(component().new())
			end).to.throw()

			expect(function()
				assertValidComponent(55)
			end).to.throw()

			expect(function()
				assertValidComponent(component())
			end).never.to.throw()
		end)
	end)
end
