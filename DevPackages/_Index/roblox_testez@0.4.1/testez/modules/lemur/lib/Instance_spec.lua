local Instance = import("./Instance")

describe("Instance", function()
	it("should create instances of objects", function()
		local new = Instance.new("Folder")

		assert.not_nil(new)
	end)

	it("should error when given invalid instance names", function()
		assert.has.errors(function()
			Instance.new("ugh no")
		end)
	end)

	describe("Parent", function()
		it("should be set to nil by default", function()
			local instance = Instance.new("Folder")

			assert.equal(instance.Parent, nil)
		end)

		it("should be set to the given value if available", function()
			local parent = Instance.new("Folder")

			local child = Instance.new("Folder", parent)
			child.Name = "foo"

			assert.equal(child.Parent, parent)
			assert.equal(parent:FindFirstChild("foo"), child)
		end)
	end)
end)