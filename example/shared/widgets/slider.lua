local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Plasma = require(ReplicatedStorage.Packages.plasma)
local create = Plasma.create

-- Plasma.create("TextLabel", {
-- 	BackgroundTransparency = 1,
-- 	Font = Enum.Font.SourceSans,
-- 	AutomaticSize = Enum.AutomaticSize.XY,
-- 	TextColor3 = style.textColor,
-- 	TextSize = 20,
-- })

return Plasma.widget(function(max)
	local value, setValue = Plasma.useState(0)

	local frame = Plasma.useInstance(function()
		local style = Plasma.useStyle()

		local frame = create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 200, 0, 30),

			create("Frame", {
				Name = "line",
				Size = UDim2.new(1, 0, 0, 2),
				BackgroundColor3 = style.mutedTextColor,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0.5, 0),
			}),

			create("TextButton", {
				Name = "dot",
				Size = UDim2.new(0, 15, 0, 15),
				BackgroundColor3 = style.textColor,
				Position = UDim2.new(0, 0, 0.5, -7),
				Text = "",

				create("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),
			}),
		})

		local inputs = {}

		frame.dot.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end

			inputs[input] = UserInputService.InputChanged:Connect(function(moveInput)
				if moveInput.UserInputType ~= Enum.UserInputType.MouseMovement then
					return
				end

				local x = UserInputService:GetMouseLocation().X

				x -= frame.AbsolutePosition.X
				x = math.clamp(x, 0, frame.AbsoluteSize.X)

				local percent = x / frame.AbsoluteSize.X

				frame.dot.Position = UDim2.new(0, x, 0.5, -7)

				setValue(percent * max)
			end)
		end)

		frame.dot.InputEnded:Connect(function(input)
			if inputs[input] then
				inputs[input]:Disconnect()
			end
		end)

		return frame
	end)

	return value
end)
