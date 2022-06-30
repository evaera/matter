local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Plasma = require(ReplicatedStorage.Packages.plasma)
local create = Plasma.create

return Plasma.widget(function(children, options)
	options = options or {}

	options.fullHeight = if options.fullHeight then options.fullHeight else true

	Plasma.useInstance(function()
		local style = Plasma.useStyle()

		local frame = create("Frame", {
			BackgroundColor3 = style.bg2,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(0, 250, if options.fullHeight then 1 else 0, 0),

			create("UIPadding", {
				PaddingBottom = UDim.new(0, 20),
				PaddingLeft = UDim.new(0, 20),
				PaddingRight = UDim.new(0, 20),
				PaddingTop = UDim.new(0, 20),
			}),
			create("UIStroke", {}),

			create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			create("ScrollingFrame", {
				BackgroundTransparency = 1,
				Name = "Container",
				VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
				HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
				BorderSizePixel = 0,
				ScrollBarThickness = 6,
				ClipsDescendants = false,
				Size = UDim2.new(1, 0, 1, 0),

				create("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
			}),
		})

		Plasma.automaticSize(frame.Container, {
			axis = Enum.AutomaticSize.Y,
		})

		return frame, frame.Container
	end)

	Plasma.scope(children)
end)
