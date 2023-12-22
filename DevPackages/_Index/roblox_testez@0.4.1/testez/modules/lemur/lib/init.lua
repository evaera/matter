local baste = require((...) .. ".baste")

local Habitat = baste.import("./Habitat")
local Instance = baste.import("./Instance")

return {
	Habitat = Habitat,
	Instance = Instance,
}