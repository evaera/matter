local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Plasma = require(ReplicatedStorage.Packages.plasma)
local create = Plasma.create

return Plasma.widget(function(fn, options)
	options = options or {}

	local padding = options.padding or 10

	local frame = Plasma.useInstance(function()
		return create("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, options.marginTop or 0),
			Size = UDim2.new(1, 0, 1, -(options.marginTop or 0)),

			create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = options.direction or Enum.FillDirection.Vertical,
				Padding = UDim.new(0, padding),
			}),
		})
	end)

	Plasma.scope(fn)

	return frame
end)
