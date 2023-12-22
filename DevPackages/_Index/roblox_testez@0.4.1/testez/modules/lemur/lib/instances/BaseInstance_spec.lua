local Game = import("./Game")
local Folder = import("./Folder")
local typeof = import("../functions/typeof")

local BaseInstance = import("./BaseInstance")

describe("instances.BaseInstance", function()
	it("should error when parenting instances to invalid objects", function()
		local new = BaseInstance:new()

		assert.has.errors(function()
			new.Parent = 7
		end)
	end)

	it("should error when setting unknown values", function()
		local new = BaseInstance:new()

		assert.has.errors(function()
			new.frobulations = 6
		end)
	end)

	it("should error when indexing invalid instances", function()
		local instance = BaseInstance:new()

		local function nop()
		end

		assert.has.errors(function()
			nop(instance.neverWillEXIST)
		end)
	end)

	it("should be identified by typeof", function()
		local instance = BaseInstance:new()

		assert.equal(typeof(instance), "Instance")
	end)

	it("should allow the change and read of Name", function()
		local instance = BaseInstance:new()
		assert.equal(instance.Name, "Instance")

		instance.Name = "Foobar"
		assert.equal(instance.Name, "Foobar")
	end)

	it("should not allow the change of ClassName", function()
		local instance = BaseInstance:new()

		assert.has.errors(function()
			instance.ClassName = "Foobar"
		end)
	end)

	describe("Parent", function()
		it("should set to nil", function()
			local parent = BaseInstance:new()

			local child = BaseInstance:new()
			child.Parent = parent
			child.Name = "foo"

			assert.equal(parent:FindFirstChild("foo"), child)

			child.Parent = nil

			assert.equal(parent:FindFirstChild("foo"), nil)
		end)

		it("should set to other instances", function()
			local parent1 = BaseInstance:new()
			local parent2 = BaseInstance:new()

			local child = BaseInstance:new()
			child.Parent = parent1
			child.Name = "foo"

			assert.equal(parent1:FindFirstChild("foo"), child)

			child.Parent = parent2

			assert.equal(parent1:FindFirstChild("foo"), nil)
			assert.equal(child.Parent, parent2)
			assert.equal(parent2:FindFirstChild("foo"), child)
		end)

		-- This may seem like a weird test, but it's for 100% coverage
		it("shouldn't react differently when setting the parent to the existing parent", function()
			local parent = BaseInstance:new()
			local child = BaseInstance:new()
			child.Parent = parent

			assert.has_no_errors(function()
				child.Parent = parent
			end)
		end)
	end)

	describe("FindFirstChild", function()
		it("should never error on invalid index", function()
			local instance = BaseInstance:new()

			assert.equal(instance:FindFirstChild("NEVER. WILL. EXIST!"), nil)
		end)
	end)

	describe("GetChildren", function()
		it("should return no children for empty instances", function()
			local instance = BaseInstance:new()

			assert.equal(#instance:GetChildren(), 0)
		end)

		it("should yield all children", function()
			local parent = BaseInstance:new()

			local child1 = BaseInstance:new()
			child1.Parent = parent

			local child2 = BaseInstance:new()
			child2.Parent = parent

			assert.equal(#parent:GetChildren(), 2)

			local child1Seen = false
			local child2Seen = false
			for _, child in ipairs(parent:GetChildren()) do
				if child == child1 then
					child1Seen = true
				elseif child == child2 then
					child2Seen = true
				else
					error("Invalid child found")
				end
			end

			assert.equal(child1Seen, true)
			assert.equal(child2Seen, true)
		end)
	end)

	describe("GetDescendants", function()
		it("should return no descendants for empty instances", function()
			local instance = BaseInstance:new()

			assert.equal(#instance:GetDescendants(), 0)
		end)

		it("should return all first level children", function()
			local parent = BaseInstance:new()

			local child1 = BaseInstance:new()
			child1.Parent = parent

			local child2 = BaseInstance:new()
			child2.Parent = parent

			assert.equal(#parent:GetDescendants(), 2)

			local child1Seen = false
			local child2Seen = false
			for _, child in ipairs(parent:GetDescendants()) do
				if child == child1 then
					child1Seen = true
				elseif child == child2 then
					child2Seen = true
				else
					error("Invalid child found")
				end
			end

			assert.equal(child1Seen, true)
			assert.equal(child2Seen, true)
		end)

		it("should return all descendants", function()
			local parent = BaseInstance:new()

			local child1 = BaseInstance:new()
			child1.Parent = parent

			local child2 = BaseInstance:new()
			child2.Parent = parent

			local child3 = BaseInstance:new()
			child3.Parent = child2

			assert.equal(#parent:GetDescendants(), 3)

			local child1Seen = false
			local child2Seen = false
			local child3Seen = false
			for _, child in ipairs(parent:GetDescendants()) do
				if child == child1 then
					child1Seen = true
				elseif child == child2 then
					child2Seen = true
				elseif child == child3 then
					child3Seen = true
				else
					error("Invalid child found")
				end
			end

			assert.equal(child1Seen, true)
			assert.equal(child2Seen, true)
			assert.equal(child3Seen, true)
		end)
	end)

	describe("WaitForChild", function()
		it("should work just like FindFirstChild", function()
			local parent = BaseInstance:new()

			local child = BaseInstance:new()
			child.Parent = parent
			child.Name = "foo"

			local result = parent:WaitForChild("foo")
			assert.equal(result, child)

			child.Parent = nil
			result = parent:WaitForChild("foo")
			assert.equal(result, nil)
		end)
	end)

	describe("Destroy", function()
		it("should set the instance's Parent to nil", function()
			local parent = BaseInstance:new()
			local child = BaseInstance:new()
			child.Parent = parent

			assert.equal(child.Parent, parent)

			child:Destroy()

			assert.equal(child.Parent, nil)
		end)

		it("should set the children's parents to nil", function()
			local parent = BaseInstance:new()
			local child = BaseInstance:new()
			child.Parent = parent

			parent:Destroy()
			assert.equal(child.Parent, nil)
		end)

		it("should lock the parent property", function()
			local instance = BaseInstance:new()
			local badParent = BaseInstance:new()

			instance:Destroy()

			assert.has.errors(function()
				instance.Parent = badParent
			end)
		end)

		it("should only lock its own instance, and not all of the same type", function()
			local destroyFolder = BaseInstance:new()
			destroyFolder:Destroy()
			assert.equal(destroyFolder.Parent, nil)

			local goodParent = BaseInstance:new()
			local goodFolder = BaseInstance:new()

			assert.has_no.errors(function()
				goodFolder.Parent = goodParent
			end)
		end)

		it("should disconnect all Changed listeners", function()
			local instance = BaseInstance:new()

			local calls = 0
			instance.Changed:Connect(function()
				calls = calls + 1
			end)

			instance.Name = "Foo"

			assert.equal(calls, 1)

			instance:Destroy()
			instance.Name = "Bar"

			assert.equal(calls, 1)
		end)

		it("should disconnect all GetPropertyChangedSignal listeners", function()
			local instance = BaseInstance:new()

			local callsA = 0
			local callsB = 0

			instance:GetPropertyChangedSignal("Name"):Connect(function()
				callsA = callsA + 1
			end)

			instance:GetPropertyChangedSignal("Name"):Connect(function()
				callsB = callsB + 1
			end)

			instance.Name = "Foo"

			assert.equal(callsA, 1)
			assert.equal(callsB, 1)

			instance:Destroy()
			instance.Name = "Bar"

			assert.equal(callsA, 1)
			assert.equal(callsB, 1)
		end)
	end)

	describe("IsA", function()
		it("should check the class's hierarchy", function()
			local ClassA = BaseInstance:extend("ClassA")
			local ClassB = ClassA:extend("ClassB")
			local ClassC = ClassB:extend("ClassC")

			local instance = BaseInstance:new()
			local objA = ClassA:new()
			local objB = ClassB:new()
			local objC = ClassC:new()

			assert.False(instance:IsA("ClassC"))
			assert.False(instance:IsA("ClassB"))
			assert.False(instance:IsA("ClassA"))
			assert.True(instance:IsA("Instance"))

			assert.False(objA:IsA("ClassC"))
			assert.False(objA:IsA("ClassB"))
			assert.True(objA:IsA("ClassA"))
			assert.True(objA:IsA("Instance"))

			assert.False(objB:IsA("ClassC"))
			assert.True(objB:IsA("ClassB"))
			assert.True(objB:IsA("ClassA"))
			assert.True(objB:IsA("Instance"))

			assert.True(objC:IsA("ClassC"))
			assert.True(objC:IsA("ClassB"))
			assert.True(objC:IsA("ClassA"))
			assert.True(objC:IsA("Instance"))
		end)
	end)

	describe("IsDescendantOf", function()
		it("should return true when the instance is a descendant of the passed argument", function()
			local parent = BaseInstance:new()

			local child = BaseInstance:new()
			child.Parent = parent
			assert.True(child:IsDescendantOf(parent))

			local descendant = BaseInstance:new()
			descendant.Parent = child
			assert.True(descendant:IsDescendantOf(parent))
		end)

		it("should return false when the instance is not a descendant of the passed argument", function()
			local parent = BaseInstance:new()
			local somethingElse = BaseInstance:new()
			assert.False(parent:IsDescendantOf(somethingElse))

			local child = BaseInstance:new()
			child.Parent = parent
			assert.False(child:IsDescendantOf(somethingElse))

			local descendant = BaseInstance:new()
			descendant.Parent = child
			assert.False(descendant:IsDescendantOf(somethingElse))
		end)

		-- Weird, but documented, behavior (https://www.robloxdev.com/api-reference/function/Instance/IsDescendantOf).
		it("should always return true for nil", function()
			assert.True(BaseInstance:new():IsDescendantOf(nil))
		end)
	end)

	describe("GetFullName", function()
		it("should get the full name", function()
			local instance = BaseInstance:new()
			instance.Name = "Test"
			local other = BaseInstance:new()
			other.Name = "Parent"

			instance.Parent = other

			local fullName = instance:GetFullName()
			assert.equal("Parent.Test", fullName)
		end)

		it("should exclude game", function()
			local instance = BaseInstance:new()
			instance.Name = "Test"
			local other = Game:new()
			other.Name = "Parent"

			instance.Parent = other

			local fullName = instance:GetFullName()
			assert.equal("Test", fullName)
		end)

		it("should return the instance name if there is no parent", function()
			local instance = BaseInstance:new()
			instance.Name = "Test"

			local fullName = instance:GetFullName()
			assert.equal("Test", fullName)
		end)
	end)

	describe("tostring", function()
		it("should match the name of the instance", function()
			local instance = BaseInstance:new()
			instance.Name = "foo"

			assert.equal(tostring(instance), "foo")
		end)
	end)

	describe("Changed", function()
		it("should fire Changed", function()
			local instance = BaseInstance:new()

			local changedSpy = spy.new(function() end)
			instance.Changed:Connect(changedSpy)

			instance.Name = "NameChange"
			assert.spy(changedSpy).was.called_with("Name")
		end)
	end)

	describe("GetPropertyChangedSignal", function()
		it("should fire property signals for the right property", function()
			local instance = BaseInstance:new()
			local spy = spy.new(function() end)
			instance:GetPropertyChangedSignal("Name"):Connect(spy)
			instance.Name = "NameChange"
			assert.spy(spy).was.called()
		end)

		it("should not fire property signals for the incorrect property", function()
			local instance = BaseInstance:new()
			local spy = spy.new(function() end)
			instance:GetPropertyChangedSignal("Parent"):Connect(spy)
			instance.Name = "NameChange2"
			assert.spy(spy).was_not_called()
		end)

		it("should error when given an invalid property name", function()
			local instance = BaseInstance:new()
			assert.has.errors(function()
				instance:GetPropertyChangedSignal("CanDestroyTheWorld"):Connect(function() end)
			end)
		end)
	end)

	describe("ClearAllChildren", function()
		it("should clear children", function()
			local parent = BaseInstance:new()
			local child = BaseInstance:new()
			child.Parent = parent

			parent:ClearAllChildren()
			assert.equal(child.Parent, nil)
		end)
	end)

	describe("FindFirstAncestor", function()
		it("should find ancestors", function()
			local parent = BaseInstance:new()
			parent.Name = "Ancestor"

			local child = BaseInstance:new()
			child.Parent = parent

			assert.equal(child:FindFirstAncestor("Ancestor"), parent)
		end)

		it("should return nil with no matching ancestor", function()
			local parent = BaseInstance:new()
			local child = BaseInstance:new()
			child.Parent = parent

			assert.equal(child:FindFirstAncestor("Ancestor"), nil)
		end)

		it("should return nil with no ancestor", function()
			local child = BaseInstance:new()

			assert.equal(child:FindFirstAncestor("Ancestor"), nil)
		end)
	end)

	describe("FindFirstAncestorOfClass", function()
		it("should find ancestors", function()
			local parent = BaseInstance:new()
			local child = BaseInstance:new()
			child.Parent = parent

			assert.equal(child:FindFirstAncestorOfClass("Instance"), parent)
		end)

		it("should return nil with no matching ancestor", function()
			local parent = BaseInstance:new()
			local child = BaseInstance:new()
			child.Parent = parent

			assert.equal(child:FindFirstAncestorOfClass("Ancestor"), nil)
		end)

		it("should return nil with no ancestor", function()
			local child = BaseInstance:new()

			assert.equal(child:FindFirstAncestorOfClass("Instance"), nil)
		end)
	end)

	describe("FindFirstAncestorWhichIsA", function()
		it("should find ancestors", function()
			local parent = BaseInstance:new()
			local child = BaseInstance:new()
			child.Parent = parent

			assert.equal(child:FindFirstAncestorOfClass("Instance"), parent)
		end)

		it("should return nil with no matching ancestor", function()
			local parent = BaseInstance:new()
			local child = BaseInstance:new()
			child.Parent = parent

			assert.equal(child:FindFirstAncestorOfClass("Ancestor"), nil)
		end)

		it("should return nil with no ancestor", function()
			local child = BaseInstance:new()

			assert.equal(child:FindFirstAncestorOfClass("Instance"), nil)
		end)

		it("should handle narrower ancestor classes", function()
			local child = BaseInstance:new()
			local parent = Folder:new()
			child.Parent = parent

			assert.equal(child:FindFirstAncestorWhichIsA("Instance"), parent)
		end)
	end)

	describe("FindFirstChildOfClass", function()
		it("should find instances", function()
			local parent = BaseInstance:new()
			local childCorrect = BaseInstance:new()
			childCorrect.Parent = parent

			local childIncorrect = Folder:new()
			childIncorrect.Parent = parent

			assert.equal(parent:FindFirstChildOfClass("Instance"), childCorrect)
		end)

		it("should return nil with no matching child", function()
			local parent = BaseInstance:new()

			local childIncorrect = BaseInstance:new()
			childIncorrect.Parent = parent

			assert.equal(parent:FindFirstChildOfClass("Folder"), nil)
		end)

		it("should return nil with no children", function()
			local parent = BaseInstance:new()

			assert.equal(parent:FindFirstChildOfClass("Folder"), nil)
		end)
	end)

	describe("FindFirstChildOfClass", function()
		it("should find instances", function()
			local parent = BaseInstance:new()
			local childCorrect = BaseInstance:new()
			childCorrect.Parent = parent

			local childIncorrect = Folder:new()
			childIncorrect.Parent = parent

			assert.equal(parent:FindFirstChildWhichIsA("Instance"), childCorrect)
		end)

		it("should return nil with no matching child", function()
			local parent = BaseInstance:new()

			local childIncorrect = BaseInstance:new()
			childIncorrect.Parent = parent

			assert.equal(parent:FindFirstChildWhichIsA("Folder"), nil)
		end)

		it("should return nil with no children", function()
			local parent = BaseInstance:new()

			assert.equal(parent:FindFirstChildWhichIsA("Folder"), nil)
		end)
	end)

	describe("super", function()
		it("should reference the parent class", function()
			local ClassA = BaseInstance:extend("ClassA")
			local ClassB = ClassA:extend("ClassB")
			local ClassC = ClassB:extend("ClassC")

			assert.equals(ClassC.super, ClassB)
			assert.equals(ClassB.super, ClassA)
			assert.equals(ClassA.super, BaseInstance)
			assert.equals(BaseInstance.super, nil)
		end)
	end)

	describe("AncestryChanged", function()
		it("should fire when my parent changes", function()
			local parent = BaseInstance:new()
			local parentSpy = spy.new(function() end)
			parent.AncestryChanged:Connect(parentSpy)

			local child = BaseInstance:new()
			local childSpy = spy.new(function() end)
			child.AncestryChanged:Connect(childSpy)

			child.Parent = parent
			assert.spy(parentSpy).was_not_called()
			assert.spy(childSpy).was_called_with(child, parent)

			child.Parent = nil
			assert.spy(parentSpy).was_not_called()
			assert.spy(childSpy).was_called_with(child, nil)
		end)

		it("should fire when my ancestor changes", function()
			local parent = BaseInstance:new()
			local parentSpy = spy.new(function() end)
			parent.AncestryChanged:Connect(parentSpy)

			local child = BaseInstance:new()
			local childSpy = spy.new(function() end)
			child.AncestryChanged:Connect(childSpy)

			local grandchild = BaseInstance:new()
			local grandchildSpy = spy.new(function() end)
			grandchild.AncestryChanged:Connect(grandchildSpy)

			grandchild.Parent = child
			assert.spy(parentSpy).was_not_called()
			assert.spy(childSpy).was_not_called()
			assert.spy(grandchildSpy).was_called_with(grandchild, child)

			parentSpy:clear()
			childSpy:clear()
			grandchildSpy:clear()

			child.Parent = parent
			assert.spy(parentSpy).was_not_called()
			assert.spy(childSpy).was_called_with(child, parent)
			assert.spy(grandchildSpy).was_called_with(child, parent)

			parentSpy:clear()
			childSpy:clear()
			grandchildSpy:clear()

			child.Parent = nil
			assert.spy(parentSpy).was_not_called()
			assert.spy(childSpy).was_called_with(child, nil)
			assert.spy(grandchildSpy).was_called_with(child, nil)

			parentSpy:clear()
			childSpy:clear()
			grandchildSpy:clear()

			grandchild.Parent = nil
			assert.spy(parentSpy).was_not_called()
			assert.spy(childSpy).was_not_called()
			assert.spy(grandchildSpy).was_called_with(grandchild, nil)
		end)
	end)

	describe("ChildAdded", function()
		it("should fire when a child is added", function()
			local parent = BaseInstance:new()
			local child = BaseInstance:new()

			local spy = spy.new(function() end)
			parent.ChildAdded:Connect(spy)

			child.Parent = parent
			assert.spy(spy).was_called_with(child)
		end)
	end)

	describe("ChildRemoved", function()
		it("should fire when a child is removed", function()
			local parent = BaseInstance:new()
			local child = BaseInstance:new()
			child.Parent = parent

			local spy = spy.new(function() end)
			parent.ChildRemoved:Connect(spy)

			child.Parent = nil

			assert.spy(spy).was_called_with(child)
		end)
	end)
end)