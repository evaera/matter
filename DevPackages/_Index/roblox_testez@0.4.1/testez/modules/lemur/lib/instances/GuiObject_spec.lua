local ScreenGui = import("./ScreenGui")
local UDim2 = import("../types/UDim2")
local typeof = import("../functions/typeof")
local SizeConstraint = import("../Enum/SizeConstraint")

local GuiObject = import("./GuiObject")

local function extractVector2(v)
	return { v.X, v.Y }
end

describe("instances.GuiObject", function()
	it("should instantiate", function()
		local instance = GuiObject:new()

		assert.not_nil(instance)
	end)

	it("should have properties defined", function()
		local instance = GuiObject:new()

		assert.equal(typeof(instance.Active), "boolean")
		assert.equal(typeof(instance.AnchorPoint), "Vector2")
		assert.equal(typeof(instance.BackgroundColor3), "Color3")
		assert.equal(typeof(instance.BackgroundTransparency), "number")
		assert.equal(typeof(instance.BorderColor3), "Color3")
		assert.equal(typeof(instance.BorderSizePixel), "number")
		assert.equal(typeof(instance.ClipsDescendants), "boolean")
		assert.equal(typeof(instance.InputBegan), "RBXScriptSignal")
		assert.equal(typeof(instance.InputEnded), "RBXScriptSignal")
		assert.equal(typeof(instance.LayoutOrder), "number")
		assert.equal(typeof(instance.MouseEnter), "RBXScriptSignal")
		assert.equal(typeof(instance.MouseLeave), "RBXScriptSignal")
		assert.equal(typeof(instance.Position), "UDim2")
		assert.equal(typeof(instance.Selectable), "boolean")
		assert.equal(typeof(instance.Size), "UDim2")
		assert.equal(typeof(instance.SizeConstraint), "EnumItem")
		assert.equal(instance.SizeConstraint.EnumType, SizeConstraint)
		assert.equal(typeof(instance.Visible), "boolean")
		assert.equal(typeof(instance.ZIndex), "number")
	end)

	describe("AbsolutePosition", function()
		it("should return (0, 0) when it is not a child of ScreenGui", function()
			local parent = GuiObject:new()
			parent.Size = UDim2.new(0, 320, 0, 240)

			local child = GuiObject:new()
			child.Size = UDim2.new(0.5, 20, 0.5, 20)
			child.Parent = parent

			assert.are.same(extractVector2(parent.AbsolutePosition), {0, 0})
			assert.are.same(extractVector2(child.AbsolutePosition), {0, 0})
		end)

		it("should propagate position from a ScreenGui", function()
			local screenGui = ScreenGui:new()
			local screenGuiSize = screenGui.AbsoluteSize

			local parent = GuiObject:new()
			parent.Parent = screenGui
			parent.Position = UDim2.new(0.1, 50, 0.2, 100)
			parent.Size = UDim2.new(0.5, 100, 0.1, 200)

			local parentAbsolutePosition = parent.AbsolutePosition
			local parentAbsoluteSize = parent.AbsoluteSize
			assert.are.same(
				extractVector2(parentAbsolutePosition),
				{
					0.1 * screenGuiSize.X + 50,
					0.2 * screenGuiSize.Y + 100,
				}
			)

			local child = GuiObject:new()
			child.Parent = parent
			child.Position = UDim2.new(0.5, 0, 0.2, 10)
			child.Size = UDim2.new(2, 50, 4, 10)

			local childAbsolutePosition = child.AbsolutePosition
			assert.are.same(
				extractVector2(childAbsolutePosition),
				{
					parentAbsolutePosition.X + 0.5 * parentAbsoluteSize.X,
					parentAbsolutePosition.Y + 0.2 * parentAbsoluteSize.Y + 10,
				}
			)
		end)
	end)

	describe("AbsoluteSize", function()
		it("should return (0, 0) when it is not a child of ScreenGui", function()
			local parent = GuiObject:new()
			parent.Size = UDim2.new(0, 320, 0, 240)

			local child = GuiObject:new()
			child.Size = UDim2.new(0.5, 20, 0.5, 20)
			child.Parent = parent

			assert.are.same(extractVector2(parent.AbsoluteSize), {0, 0})
			assert.are.same(extractVector2(child.AbsoluteSize), {0, 0})
		end)

		it("should propagate size from a ScreenGui", function()
			local screenGui = ScreenGui:new()
			local screenGuiSize = screenGui.AbsoluteSize

			local parent = GuiObject:new()
			parent.Parent = screenGui
			parent.Size = UDim2.new(0.5, 100, 0.1, 200)

			local parentAbsoluteSize = parent.AbsoluteSize
			assert.are.same(
				extractVector2(parentAbsoluteSize),
				{
					0.5 * screenGuiSize.X + 100,
					0.1 * screenGuiSize.Y + 200,
				}
			)

			local child = GuiObject:new()
			child.Parent = parent
			child.Size = UDim2.new(2, 50, 4, 10)

			local childAbsoluteSize = child.AbsoluteSize
			assert.are.same(
				extractVector2(childAbsoluteSize),
				{
					2 * parentAbsoluteSize.X + 50,
					4 * parentAbsoluteSize.Y + 10,
				}
			)
		end)
	end)
end)
