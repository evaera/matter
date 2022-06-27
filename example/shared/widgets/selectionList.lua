local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Plasma = require(ReplicatedStorage.Packages.plasma)
local create = Plasma.create

local Item = Plasma.widget(function(text, selected)
	local clicked, setClicked = Plasma.useState(false)
	local style = Plasma.useStyle()

	local button = Plasma.useInstance(function()
		local button = create("TextButton", {
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
			}),

			create("TextLabel", {
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.X,
				Size = UDim2.new(0, 0, 1, 0),
				Text = text,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 19,
				TextColor3 = style.textColor,
				Font = Enum.Font.SourceSans,
			}),

			Activated = function()
				setClicked(true)
			end,
		})

		return button
	end)

	Plasma.useEffect(function()
		button.TextLabel.Text = text
	end, text)

	Plasma.useEffect(function()
		button.BackgroundColor3 = if selected then Color3.fromHex("bd515c") else style.bg2
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

return Plasma.widget(function(items)
	Plasma.useInstance(function()
		local frame = create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),

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
		if Item(item.text, item.selected):clicked() then
			selected = item
		end
	end

	return {
		selected = function()
			return selected
		end,
	}
end)
