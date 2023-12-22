local BaseInstance = import("./BaseInstance")
local validateType = import("../validateType")
local ContextActionService = BaseInstance:extend("ContextActionService")

--[[
	These action binding and unbinding functions mimic Roblox's validation
	of arguments, but are a little stricter about type expectations:
	* Roblox only throws errors on the 'actionName' parameter if it can't cast it to a string

	Additionally, Roblox does not throw error in either of these cases:
	* Binding a different action to the same name (overwrites existing action)
	* Unbinding actions that were never bound does not error
]]
function ContextActionService.prototype:BindCoreAction(actionName, functionToBind, createTouchButton, ...)
	validateType("actionName", actionName, "string")
	validateType("functionToBind", functionToBind, "function")
	validateType("createTouchButton", createTouchButton, "boolean")
end

function ContextActionService.prototype:UnbindCoreAction(actionName)
	validateType("actionName", actionName, "string")
end

return ContextActionService