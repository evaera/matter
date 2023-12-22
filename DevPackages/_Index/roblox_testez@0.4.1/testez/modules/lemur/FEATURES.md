# Lemur Features
Lemur does not aim to provide full coverage of all Roblox APIs. Coverage progresses as is necessary, though some APIs may prove difficult or impossible to recreate effectively.

This document should remain up-to-date with current API coverage and status.

## Implemented Enums
- ConnectionState
- DataStoreRequestType
- EasingDirection
- EasingStyle
- Font
- HorizontalAlignment
- Platform
- PlaybackState
- ScaleType
- ScrollingDirection
- SizeConstraint
- SortOrder
- TextXAlignment
- TextYAlignment
- ThumbnailSize
- ThumbnailType
- VerticalAlignment
- VirtualInputMode

## Implemented Globals
* require
* script
* settings
	* Rendering
		* QualityLevel
* delay
* spawn
* tick
* typeof
* wait (stub)
* warn
* bit32 (requires bit32 installed)

## Implemented Types
* Color3
	* Color3.new()
	* Color3.new(r, g, b)
	* Color3.fromRGB(r, g, b)
	* Color3.fromHSV(h, s, v)
	* Color3.toHSV(color)
	* Color3:lerp()
	* Operators: `==`
* Rect
	* Rect.new(x, y, width, height)
	* Rect.new(min, max)
	* Operators: `==`
* UDim
	* UDim.new()
	* UDim.new(scale, offset)
	* Operators: `==`, `+`
* UDim2
	* UDim2.new()
	* UDim2.new(xDim, yDim)
	* UDim2.new(xScale, xOffset, yScale, yOffset)
	* UDim2:lerp()
	* Operators: `==`, `+`
* Vector2
	* Vector2.new()
	* Vector2.new(x, y)
	* Operators: `==`, `+`, `*`, `/`

## Implemented Instance Members
* AnalyticsService
* BindableEvent
	* Fire(...)
* BoolValue, StringValue, IntValue, NumberValue, ObjectValue
	* Value
* Folder
* Frame
* GuiObject
	* AbsoluteSize
	* Active
	* AnchorPoint
	* AutoButtonColor
	* BackgroundColor3
	* BackgroundTransparency
	* BorderSizePixel
	* ClipsDescendants
	* Frame
	* InputBegan
	* InputEnded
	* LayoutOrder
	* MouseEnter
	* MouseLeave
	* Position
	* Selectable
	* Size
	* SizeConstraint
	* Visible
* Humanoid
	* Died
	* Health
	* MaxHealth
* ImageButton
	* Image
	* ImageColor3
	* ImageRectOffset
	* ImageRectSize
	* ScaleType
	* SliceCenter
* ImageLabel
	* Image
	* ImageColor3
	* ImageRectOffset
	* ImageRectSize
	* ScaleType
	* SliceCenter
* Instance
	* AncestryChanged
	* ChildAdded
	* ClassName
	* Name
	* Parent
	* ClearAllChildren()
	* Destroy()
	* FindFirstAncestor(name)
	* FindFirstAncestorOfClass(className)
	* FindFirstAncestorWhichIsA(className)
	* FindFirstChild(name)
	* FindFirstChildOfClass(className)
	* FindFirstChildWhichIsA(className)
	* GetChildren()
	* GetDescendants()
	* GetFullName()
	* GetPropertyChangedSignal(key)
	* IsA(className)
	* IsDescendantOf(object)
	* WaitForChild(name)
* LocalScript (stub)
	* Source
* Model (stub)
* ModuleScript
	* Source
* ParticleEffect
	* Enabled
* Script (stub)
	* Source
* ScreenGui
	* AbsoluteSize
	* DisplayOrder
* ScrollingFrame
	* AbsoluteWindowSize
	* CanvasSize
	* ScrollBarThickness
	* ScrollingDirection
	* ScrollingEnabled
* TextButton
	* Font
	* Text
	* TextColor3
	* TextSize
	* TextWrapped
	* TextXAlignment
	* TextYAlignment
* TextLabel
	* Font
	* Text
	* TextColor3
	* TextSize
	* TextWrapped
	* TextXAlignment
	* TextYAlignment
* UIGridStyleLayout
	* HorizontalAlignment
	* SortOrder
	* VerticalAlignment
* UIListLayout
	* Padding
* Workspace
	* AllowThirdPartySales
	* DistributedGameTime
	* Gravity

## Implemented Services
* ContentProvider
	* BaseUrl
* CoreGui
* NotificationService
* GuiService
* HttpService (requires dkjson installed)
	* JSONDecode(input)
	* JSONEncode(input)
* LocalizationService
	* SystemLocaleId
* LocalizationTable
* Players
	* GetPlayerFromCharacter (stub)
	* LocalPlayer
		* UserId
* ReplicatedFirst
* ReplicatedStorage
* RunService
	* Heartbeat
	* RenderStepped
	* IsServer()
	* IsStudio()
* ServerScriptService
* ServerStorage
* StarterPlayer
	* StarterCharacterScripts
	* StarterPlayerScripts
* Stats
* TestService
	* Error(message)
* TextService
	* GetTextSize(text, fontSize, font, frameSize)
* TweenService
* UserInputService
* VirtualInputManager
* Workspace
	* CurrentCamera
		* ViewportSize
