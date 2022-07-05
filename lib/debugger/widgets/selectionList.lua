return function(Plasma)
	local create = Plasma.create

	local Item = Plasma.widget(function(text, selected, icon, sideText, width)
		local clicked, setClicked = Plasma.useState(false)
		local style = Plasma.useStyle()

		local refs = Plasma.useInstance(function(ref)
			local button = create("TextButton", {
				[ref] = "button",
				Size = UDim2.new(1, 0, 0, 40),
				Text = "",

				create("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),

				create("UIPadding", {
					PaddingBottom = UDim.new(0, 0),
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
					PaddingTop = UDim.new(0, 0),
				}),

				create("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 10),
				}),

				create("TextLabel", {
					Name = "Icon",
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 22, 1, 0),
					Text = icon,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextSize = 23,
					TextColor3 = style.textColor,
					Font = Enum.Font.GothamBold,
				}),

				create("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Text = text,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextSize = 19,
					TextColor3 = style.textColor,
					Font = Enum.Font.SourceSans,
					TextTruncate = Enum.TextTruncate.AtEnd,
				}),

				create("TextLabel", {
					[ref] = "sideText",
					BackgroundTransparency = 1,
					AutomaticSize = Enum.AutomaticSize.X,
					Size = UDim2.new(0, 0, 1, 0),
					Text = "",
					TextXAlignment = Enum.TextXAlignment.Left,
					TextSize = 15,
					TextColor3 = style.mutedTextColor,
					Font = Enum.Font.SourceSans,
				}),

				Activated = function()
					setClicked(true)
				end,
			})

			ref.button.TextLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
				ref.button.TextLabel.Size = UDim2.new(
					0,
					math.min(ref.button.TextLabel.TextBounds.X, width or 180),
					1,
					0
				)
			end)

			return button
		end)

		Plasma.useEffect(function()
			refs.button.TextLabel.Text = text
			refs.button.Icon.Text = icon or ""
			refs.button.Icon.Visible = not not icon
		end, text, icon)

		refs.sideText.Visible = not not sideText
		refs.sideText.Text = sideText or ""
		refs.sideText.TextColor3 = if selected then style.textColor else style.mutedTextColor
		refs.button.TextLabel.TextTruncate = sideText and Enum.TextTruncate.AtEnd or Enum.TextTruncate.None

		Plasma.useEffect(function()
			refs.button.BackgroundColor3 = if selected then Color3.fromHex("bd515c") else style.bg2
		end, selected)

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

	return Plasma.widget(function(items, options)
		options = options or {}

		Plasma.useInstance(function()
			local frame = create("Frame", {
				BackgroundTransparency = 1,
				Size = options.width and UDim2.new(0, options.width, 0, 0) or UDim2.new(1, 0, 0, 0),

				create("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
			})

			Plasma.automaticSize(frame, {
				axis = Enum.AutomaticSize.Y,
			})

			return frame
		end)

		local selected

		for _, item in items do
			if Item(item.text, item.selected, item.icon, item.sideText, options.width):clicked() then
				selected = item
			end
		end

		return {
			selected = function()
				return selected
			end,
		}
	end)
end
