return function(Plasma)
	local create = Plasma.create

	return Plasma.widget(function(text, options)
		options = options or {}

		local clicked, setClicked = Plasma.useState(false)
		local style = Plasma.useStyle()

		local button
		button = Plasma.useInstance(function()
			local colorHover = style.textColor

			local darker = colorHover.R * 255 * 0.8 -- 20% darker
			local color = Color3.fromRGB(darker, darker, darker)

			local button = create("TextButton", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 40),
				Text = "",

				create("UIPadding", {
					PaddingBottom = UDim.new(0, 0),
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
					PaddingTop = UDim.new(0, 0),
				}),

				create("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
				}),

				create("TextLabel", {
					Name = "Icon",
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 30, 1, 0),
					Text = options.icon,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextSize = 23,
					TextColor3 = style.textColor,
					Font = Enum.Font.GothamBold,
				}),

				create("TextLabel", {
					Name = "MainText",
					BackgroundTransparency = 1,
					AutomaticSize = Enum.AutomaticSize.X,
					Size = UDim2.new(0, 0, 1, 0),
					Text = text,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextSize = 19,
					TextColor3 = color,
					Font = Enum.Font.SourceSans,
				}),

				Activated = function()
					setClicked(true)
				end,

				MouseEnter = function()
					button.MainText.TextColor3 = colorHover
				end,

				MouseLeave = function()
					button.MainText.TextColor3 = color
				end,
			})

			return button
		end)

		Plasma.useEffect(function()
			button.MainText.Text = text

			button.Icon.Text = options.icon or ""
		end, text, options.icon)

		return {
			clicked = function()
				if clicked then
					setClicked(false)
					return true
				end

				return false
			end,
		}
	end)
end
