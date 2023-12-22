local FillDirection = import("../Enum/FillDirection")
local HorizontalAlignment = import("../Enum/HorizontalAlignment")
local SortOrder = import("../Enum/SortOrder")
local typeof = import("../functions/typeof")
local VerticalAlignment = import("../Enum/VerticalAlignment")

local UIGridStyleLayout = import("./UIGridStyleLayout")

describe("instances.UIGridStyleLayout", function()
	it("should instantiate", function()
		local instance = UIGridStyleLayout:new()

		assert.not_nil(instance)
	end)

	it("should have properties defined", function()
		local instance = UIGridStyleLayout:new()

		assert.equals(typeof(instance.FillDirection), "EnumItem")
		assert.equals(instance.FillDirection.EnumType, FillDirection)
		assert.equals(typeof(instance.HorizontalAlignment), "EnumItem")
		assert.equals(instance.HorizontalAlignment.EnumType, HorizontalAlignment)
		assert.equals(typeof(instance.SortOrder), "EnumItem")
		assert.equals(instance.SortOrder.EnumType, SortOrder)
		assert.equals(typeof(instance.VerticalAlignment), "EnumItem")
		assert.equal(instance.VerticalAlignment.EnumType, VerticalAlignment)
		assert.equals(typeof(instance.AbsoluteContentSize), "Vector2")
	end)
end)