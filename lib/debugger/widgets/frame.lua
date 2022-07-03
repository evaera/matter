return function(Plasma)
	return Plasma.widget(function()
		local refs = Plasma.useInstance(function(ref)
			local style = Plasma.useStyle()

			local Frame = Instance.new("Frame")
			Frame.BackgroundColor3 = style.bg2
			Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
			Frame.AnchorPoint = Vector2.new(0.5, 0.5)
			Frame.Size = UDim2.new(0, 50, 0, 40)
			Frame.Visible = false

			local UICorner = Instance.new("UICorner")
			UICorner.Parent = Frame

			local UIPadding = Instance.new("UIPadding")
			UIPadding.PaddingBottom = UDim.new(0, 20)
			UIPadding.PaddingLeft = UDim.new(0, 20)
			UIPadding.PaddingRight = UDim.new(0, 20)
			UIPadding.PaddingTop = UDim.new(0, 20)
			UIPadding.Parent = Frame

			local UIStroke = Instance.new("UIStroke")
			UIStroke.Parent = Frame

			local UIListLayout = Instance.new("UIListLayout")
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout.Padding = UDim.new(0, 10)
			UIListLayout.Parent = Frame

			local numChildren = #Frame:GetChildren()

			Plasma.automaticSize(Frame)

			local function updateVisibility()
				Frame.Visible = #Frame:GetChildren() > numChildren
			end

			Frame.ChildAdded:Connect(updateVisibility)
			Frame.ChildRemoved:Connect(updateVisibility)

			ref.frame = Frame

			return Frame
		end)

		return refs.frame
	end)
end
