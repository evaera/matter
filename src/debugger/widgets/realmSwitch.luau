local CollectionService = game:GetService("CollectionService")

return function(Plasma)
	local create = Plasma.create

	return Plasma.widget(function(options)
		local style = Plasma.useStyle()

		options = options or {}
		local left = options.left
		local right = options.right
		local isRight = options.isRight

		local clicked, setClicked = Plasma.useState(false)
		local refs = Plasma.useInstance(function(ref)
			ref.corner = create("UICorner")

			local style = Plasma.useStyle()

			create("TextButton", {
				[ref] = "button",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 30),
				Text = "",

				create("UICorner"),

				create("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
				}),

				create("TextLabel", {
					[ref] = "left",
					Text = left,
					Size = UDim2.new(0.5, 0, 1, 0),
					BackgroundColor3 = style.primaryColor,
					TextColor3 = style.textColor,
					Font = Enum.Font.GothamMedium,
					TextSize = 15,
				}),

				create("TextLabel", {
					[ref] = "right",
					Text = right,
					Size = UDim2.new(0.5, 0, 1, 0),
					BackgroundColor3 = style.bg1,
					TextColor3 = style.textColor,
					Font = Enum.Font.GothamMedium,
					TextSize = 15,
				}),

				MouseEnter = function()
					local other = isRight and ref.left or ref.right
					other.BackgroundTransparency = 0.5
				end,

				MouseLeave = function()
					local other = isRight and ref.left or ref.right
					other.BackgroundTransparency = 0
				end,

				Activated = function()
					setClicked(true)
				end,
			})

			if options.tag then
				CollectionService:AddTag(ref.button, options.tag)
			end

			return ref.button
		end)

		refs.left.BackgroundColor3 = isRight and style.bg1 or style.primaryColor
		refs.right.BackgroundColor3 = isRight and style.primaryColor or style.bg1

		refs.corner.Parent = isRight and refs.right or refs.left

		local handle = {
			clicked = function()
				if clicked then
					setClicked(false)
					return true
				end

				return false
			end,
		}

		return handle
	end)
end
