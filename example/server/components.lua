local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Matter)

local COMPONENTS = {
	"Transform",
	"BoundInstance",
	"Spinner",
	"ColorTween",
}

local components = {}

for _, name in ipairs(COMPONENTS) do
	components[name] = Matter.component(name)
end

return components
