local BaseInstance = import("./BaseInstance")
local InstanceProperty = import("../InstanceProperty")
local Signal = import("../Signal")
local validateType = import("../validateType")

local GuiService = BaseInstance:extend("GuiService")

function GuiService.prototype:BroadcastNotification(data, notification)
	validateType("data", data, "string")
	validateType("noficiation", notification, "number")
end

function GuiService.prototype:GetNotificationTypeList()
	return {
		ACTION_LOG_OUT = "ACTION_LOG_OUT",
	}
end

function GuiService.prototype:SetGlobalGuiInset(x1, y1, x2, y2)
	validateType("x1", x1, "number")
	validateType("y1", y1, "number")
	validateType("x2", x2, "number")
	validateType("y2", y2, "number")
end

function GuiService.prototype:SafeZoneOffsetsChanged()
end

function GuiService.prototype:IsTenFootInterface()
	return false
end

GuiService.properties.BrowserWindowClosed = InstanceProperty.readOnly({
	getDefault = function()
		return Signal.new()
	end,
})

return GuiService
