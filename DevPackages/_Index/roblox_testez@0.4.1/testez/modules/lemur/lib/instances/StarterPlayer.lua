local BaseInstance = import("./BaseInstance")
local StarterCharacterScripts = import("./StarterCharacterScripts")
local StarterPlayerScripts = import("./StarterPlayerScripts")

local StarterPlayer = BaseInstance:extend("StarterPlayer")

function StarterPlayer:init(instance)
	StarterCharacterScripts:new().Parent = instance
	StarterPlayerScripts:new().Parent = instance
end

return StarterPlayer
