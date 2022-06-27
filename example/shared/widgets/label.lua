local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Plasma = require(ReplicatedStorage.Packages.plasma)

return Plasma.widget(function(text)
	local instance = Plasma.useInstance(function()
		local style = Plasma.useStyle()

		return Plasma.create("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.SourceSans,
			AutomaticSize = Enum.AutomaticSize.XY,
			TextColor3 = style.textColor,
			TextSize = 20,
		})
	end)

	instance.Text = text
end)
