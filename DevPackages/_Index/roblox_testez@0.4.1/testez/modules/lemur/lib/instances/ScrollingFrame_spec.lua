local Instance = import("../Instance")
local ScrollingDirection = import("../Enum/ScrollingDirection")
local ScrollBarInset = import("../Enum/ScrollBarInset")
local typeof = import("../functions/typeof")
local UDim2 = import("../types/UDim2")
local VerticalScrollBarPosition = import("../Enum/VerticalScrollBarPosition")

local function extractVector2(vector2)
	return { vector2.X, vector2.Y }
end

describe("instances.ScrollingFrame", function()
	it("should instantiate", function()
		local instance = Instance.new("ScrollingFrame")
		assert.not_nil(instance)
	end)

	it("should have properties defined", function()
		local instance = Instance.new("ScrollingFrame")

		assert.equal(typeof(instance.CanvasPosition), "Vector2")
		assert.equal(typeof(instance.CanvasSize), "UDim2")
		assert.equal(typeof(instance.ScrollBarThickness), "number")
		assert.equal(typeof(instance.ScrollingDirection), "EnumItem")
		assert.equal(instance.ScrollingDirection.EnumType, ScrollingDirection)
		assert.equal(typeof(instance.ScrollingEnabled), "boolean")
		assert.equal(typeof(instance.VerticalScrollBarInset), "EnumItem")
		assert.equal(instance.VerticalScrollBarInset.EnumType, ScrollBarInset)
		assert.equal(typeof(instance.VerticalScrollBarPosition), "EnumItem")
		assert.equal(instance.VerticalScrollBarPosition.EnumType, VerticalScrollBarPosition)
	end)

	describe("AbsoluteWindowSize", function()
		it("it should be affected by scrolling", function()
			local screenGui = Instance.new("ScreenGui")
			local screenGuiSize = screenGui.AbsoluteSize

			local instance = Instance.new("ScrollingFrame", screenGui)
			instance.Size = UDim2.new(1, 0, 1, 0)

			instance.ScrollingEnabled = false
			assert.same(extractVector2(screenGuiSize), extractVector2(instance.AbsoluteWindowSize))

			instance.ScrollingEnabled = true
			instance.ScrollingDirection = ScrollingDirection.XY
			assert.same(
				{
					screenGuiSize.X - instance.ScrollBarThickness,
					screenGuiSize.Y - instance.ScrollBarThickness,
				},
				extractVector2(instance.AbsoluteWindowSize)
			)

			instance.ScrollingDirection = ScrollingDirection.X
			instance.ScrollingEnabled = true
			assert.same(
				{
					screenGuiSize.X - instance.ScrollBarThickness,
					screenGuiSize.Y,
				},
				extractVector2(instance.AbsoluteWindowSize)
			)

			instance.ScrollingDirection = ScrollingDirection.Y
			instance.ScrollingEnabled = true
			assert.same(
				{
					screenGuiSize.X,
					screenGuiSize.Y - instance.ScrollBarThickness,
				},
				extractVector2(instance.AbsoluteWindowSize)
			)
		end)
	end)
end)
