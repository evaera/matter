local GuiService = game:GetService("GuiService")

return function(Plasma)
	local create = Plasma.create
	return Plasma.widget(function(children, options)
		options = options or {}

		Plasma.useInstance(function()
			local style = Plasma.useStyle()

			local frame = create("Frame", {
				Name = "Panel",
				BackgroundColor3 = style.bg2,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(0, 250, 1, 0),

				create("Frame", {
					-- Account for GUI inset
					-- GuiService:GetGuiInset returns wrong info on the server :(
					Size = UDim2.new(1, 0, 0, 46),
					BackgroundColor3 = Color3.new(0, 0, 0),
					BackgroundTransparency = 0.5,

					create("ImageLabel", {
						Position = UDim2.new(1, -20, 0.5, 0),
						AnchorPoint = Vector2.new(1, 0.5),
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 120, 0, 26),
						Image = "rbxassetid://10111567777",
					}),
				}),

				create("UIStroke", {}),

				create("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
				}),

				create("ScrollingFrame", {
					BackgroundTransparency = 1,
					Name = "Container",
					VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
					HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
					BorderSizePixel = 0,
					ScrollBarThickness = 6,
					Size = UDim2.new(1, -40, 0, 0),

					create("UIPadding", {
						PaddingTop = UDim.new(0, 20),
					}),

					create("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
				}),
			})

			Plasma.automaticSize(frame.Container, {
				axis = Enum.AutomaticSize.Y,
				maxSize = UDim2.new(1, 0, 1, 0),
			})

			return frame, frame.Container
		end)

		Plasma.scope(children)
	end)
end
