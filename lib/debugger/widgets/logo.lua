return function(Plasma)
	local create = Plasma.create

	return Plasma.widget(function(text, options)
		options = options or {}

		local refs = Plasma.useInstance(function(ref)
			local frame = create("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),

				create("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
				}),

				create("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 150, 0, 32),
					Image = "rbxassetid://10111158431",
				}),

				-- create("TextLabel", {
				-- 	BackgroundTransparency = 1,
				-- 	Text = "DEBUGGER",
				-- 	Font = Enum.Font.Gotham,
				-- 	TextSize = 20,
				-- 	Size = UDim2.new(1, 0, 0, 0),
				-- 	AutomaticSize = Enum.AutomaticSize.Y,
				-- 	TextColor3 = Color3.fromHex("bd515c"),
				-- 	TextTransparency = 0.2,
				-- }),

				create("UIPadding", {
					PaddingBottom = UDim.new(0, 20),
					PaddingTop = UDim.new(0, 20),
				}),
			})

			Plasma.automaticSize(frame, {
				axis = Enum.AutomaticSize.Y,
			})

			return frame
		end)
	end)
end
