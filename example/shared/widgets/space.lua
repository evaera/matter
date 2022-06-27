local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Plasma = require(ReplicatedStorage.Packages.plasma)

return Plasma.widget(function(size)
	local frame = Plasma.useInstance(function()
		return Plasma.create("Frame", {
			BackgroundTransparency = 1,
		})
	end)

	Plasma.useEffect(function()
		frame.Size = UDim2.new(0, size, 0, size)
	end, size)
end)
