local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.Matter)

local COMPONENTS = {
	"Roomba",
	"Model",
	"Charge",
	"Health",
	"Target",
	"Transform",
	"Mothership",
	"Lasering",
	"DebugLabel",
	"Spinner",
}

local components = {}

for _, name in ipairs(COMPONENTS) do
	components[name] = Matter.component(name)
end

return components
