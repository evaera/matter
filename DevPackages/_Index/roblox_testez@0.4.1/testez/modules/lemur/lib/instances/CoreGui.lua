local BaseInstance = import("./BaseInstance")
local CoreGui = BaseInstance:extend("CoreGui")
local ScreenGui = import("./ScreenGui")

function CoreGui:init(instance)
	local RobloxGui = ScreenGui:new()
	RobloxGui.Name = "RobloxGui"
	RobloxGui.Parent = instance
end

return CoreGui