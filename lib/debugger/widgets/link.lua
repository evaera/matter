return function(Plasma)
	local create = Plasma.create

	return Plasma.widget(function(text, options)
		options = options or {}

		local clicked, setClicked = Plasma.useState(false)
		local style = Plasma.useStyle()

		local refs = Plasma.useInstance(function(ref)
			local colorHover = style.textColor

			local darker = colorHover.R * 255 * 0.8 -- 20% darker
			local color = Color3.fromRGB(darker, darker, darker)

			local button = create("TextButton", {
				[ref] = "button",
				BackgroundTransparency = 1,
				Text = "",
				Size = UDim2.new(0, 0, 0, 40),

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
					[ref] = "mainText",
					Name = "MainText",
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 1, 0),
					Text = text,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = color,
					TextSize = 19,
				}),

				Activated = function()
					if options.disabled then
						return
					end

					setClicked(true)
				end,

				MouseEnter = function()
					if options.disabled then
						return
					end

					ref.button.MainText.TextColor3 = colorHover
				end,

				MouseLeave = function()
					ref.button.MainText.TextColor3 = color
				end,
			})

			Plasma.automaticSize(button)
			Plasma.automaticSize(ref.mainText, {
				axis = Enum.AutomaticSize.X,
			})

			return button
		end)

		refs.button.MainText.Text = text

		refs.button.Icon.Text = options.icon or ""
		refs.button.Icon.Visible = not not options.icon

		refs.mainText.Font = options.font or Enum.Font.SourceSans

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
