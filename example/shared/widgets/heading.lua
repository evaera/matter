local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Plasma = require(ReplicatedStorage.Packages.plasma)

local levels = {
	30,
	25,
	20,
}

return Plasma.widget(function(text, level)
	local instance = Plasma.useInstance(function()
		local style = Plasma.useStyle()

		return Plasma.create("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			AutomaticSize = Enum.AutomaticSize.XY,
			TextColor3 = style.mutedTextColor,
			TextSize = if level then levels[level] or 20 else 20,
		})
	end)

	instance.Text = text
end)
