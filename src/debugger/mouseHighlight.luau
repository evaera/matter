local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function mouseHighlight(debugger, remoteEvent)
	if not RunService:IsClient() then
		error("Hovering can only be checked on the client")
	end

	local lastSent, setLastSent = debugger.plasma.useState()

	if UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
		local mouse = Players.LocalPlayer:GetMouse()
		local instance = mouse.Target

		if mouse.Target then
			local id
			while instance.Parent do
				id = instance:GetAttribute(debugger:_isServerView() and "serverEntityId" or "clientEntityId")

				if id then
					break
				end

				instance = instance.Parent
			end

			if id then
				if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
					if debugger:_isServerView() then
						remoteEvent:FireServer("inspect", id)
					else
						debugger.debugEntity = id
					end
				else
					debugger.plasma.highlight(instance, {
						fillColor = Color3.fromRGB(218, 62, 62),
					})

					if debugger:_isServerView() then
						if lastSent ~= id then
							setLastSent(id)
							remoteEvent:FireServer("hover", id)
						end
					else
						debugger.hoverEntity = id
					end
				end

				return
			end
		end
	end

	if debugger:_isServerView() then
		if lastSent ~= nil then
			remoteEvent:FireServer("hover", nil)
			setLastSent(nil)
		end
	else
		debugger.hoverEntity = nil
	end
end

return mouseHighlight
