return function(Plasma)
	local create = Plasma.create

	return Plasma.widget(function(fn, options)
		options = options or {}

		local padding = options.padding or 10

		local refs = Plasma.useInstance(function(ref)
			return create("Frame", {
				[ref] = "frame",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 1, 0),

				create("UIPadding", {
					PaddingTop = UDim.new(0, options.marginTop or 0),
					PaddingLeft = UDim.new(0, options.marginLeft or 0),
				}),

				create("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = options.direction or Enum.FillDirection.Vertical,
					Padding = UDim.new(0, padding),
				}),
			})
		end)

		Plasma.scope(fn)

		return refs.frame
	end)
end
