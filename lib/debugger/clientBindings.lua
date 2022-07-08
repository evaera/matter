local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local function clientBindings(debugger)
	local connections = {}

	table.insert(
		connections,
		CollectionService:GetInstanceAddedSignal("MatterDebuggerSwitchToClientView"):Connect(function(instance)
			instance.Activated:Connect(function()
				debugger:switchToClientView()
			end)
		end)
	)

	table.insert(
		connections,
		UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseMovement then
				return
			end

			local mousePosition = UserInputService:GetMouseLocation()

			for _, gui in CollectionService:GetTagged("MatterDebuggerTooltip") do
				gui.Position = UDim2.new(0, mousePosition.X + 20, 0, mousePosition.Y)
			end
		end)
	)

	table.insert(
		connections,
		CollectionService:GetInstanceAddedSignal("MatterDebuggerTooltip"):Connect(function(gui)
			local mousePosition = UserInputService:GetMouseLocation()

			gui.Position = UDim2.new(0, mousePosition.X + 20, 0, mousePosition.Y)
		end)
	)

	return connections
end

return clientBindings
