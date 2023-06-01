local CollectionService = game:GetService("CollectionService")
return function(plasma)
	local create = plasma.create

	return plasma.widget(function(text)
		local refs = plasma.useInstance(function(ref)
			local style = plasma.useStyle()

			create("TextLabel", {
				[ref] = "label",
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextSize = 20,
				BorderSizePixel = 0,
				Font = Enum.Font.Code,
				TextStrokeTransparency = 0.5,
				TextColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 0.5,
				BackgroundColor3 = style.bg1,
				AutomaticSize = Enum.AutomaticSize.XY,

				create("UIPadding", {
					PaddingBottom = UDim.new(0, 8),
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
					PaddingTop = UDim.new(0, 8),
				}),

				create("UICorner"),

				create("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				}),
			})

			CollectionService:AddTag(ref.label, "MatterDebuggerTooltip")

			return ref.label
		end)

		refs.label.Text = text
	end)
end
