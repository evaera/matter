local GuiService = import("./GuiService")
local typeof = import("../functions/typeof")

describe("instances.GuiService", function()
	it("should instantiate", function()
		local instance = GuiService:new()

		assert.not_nil(instance)
	end)

	describe("BroadcastNotification", function()
		it("should exist", function()
			GuiService:new():BroadcastNotification("test", 123)
		end)
	end)

	describe("GetNotificationTypeList", function()
		it("should return a table", function()
			assert.equal(type(GuiService:new():GetNotificationTypeList()), "table")
		end)
	end)

	describe("SetGlobalGuiInset", function()
		it("should exist", function()
			GuiService:new():SetGlobalGuiInset(1, 2, 3, 4)
		end)
	end)

	describe("SafeZoneOffsetsChanged", function()
		it("should exist", function()
			GuiService:new():SafeZoneOffsetsChanged()
		end)
	end)

	describe("IsTenFootInterface", function()
		it("should return a boolean", function()
			assert.equal(type(GuiService:new():IsTenFootInterface()), "boolean")
		end)
	end)

	describe("BrowserWindowClosed", function()
		it("should return a signal", function()
			local instance = GuiService:new()

			assert.equal(typeof(instance.BrowserWindowClosed), "RBXScriptSignal")
		end)
	end)
end)