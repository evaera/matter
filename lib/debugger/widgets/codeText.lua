return function(Plasma)
	local create = Plasma.create

	return Plasma.widget(function(text, options)
		options = options or {}

		local refs = Plasma.useInstance(function(ref)
			return create("TextButton", {
				[ref] = "label",
				BackgroundTransparency = 1,
				Text = "",
				AutomaticSize = Enum.AutomaticSize.Y,
				Font = Enum.Font.Code,
				TextSize = 18,
				TextStrokeTransparency = 0.5,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextWrapped = true,
				TextColor3 = Color3.new(1, 1, 1),
				Size = UDim2.new(0, 800, 0, 0),

				create("UIPadding", {
					PaddingBottom = UDim.new(0, 8),
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
					PaddingTop = UDim.new(0, 8),
				}),
			})
		end)

		refs.label.Text = text
	end)
end
