local BaseInstance = import("./BaseInstance")

local AnalyticsService = import("./AnalyticsService")
local ContentProvider = import("./ContentProvider")
local CoreGui = import("./CoreGui")
local ContextActionService = import("./ContextActionService")
local CorePackages = import("./CorePackages")
local CreatorType = import("../Enum/CreatorType")
local GuiService = import("./GuiService")
local HttpRbxApiService = import("./HttpRbxApiService")
local HttpService = import("./HttpService")
local InsertService = import("./InsertService")
local InstanceProperty = import("../InstanceProperty")
local LocalizationService = import("./LocalizationService")
local MarketplaceService = import("./MarketplaceService")
local NotificationService = import("./NotificationService")
local Players = import("./Players")
local ReplicatedFirst = import("./ReplicatedFirst")
local ReplicatedStorage = import("./ReplicatedStorage")
local RunService = import("./RunService")
local ServerScriptService = import("./ServerScriptService")
local ServerStorage = import("./ServerStorage")
local StarterPlayer = import("./StarterPlayer")
local Stats = import("./Stats")
local TestService = import("./TestService")
local TextService = import("./TextService")
local TweenService = import("./TweenService")
local UserInputService = import("./UserInputService")
local VirtualInputManager = import("./VirtualInputManager")
local Workspace = import("./Workspace")

local Game = BaseInstance:extend("DataModel")

function Game:init(instance)
	AnalyticsService:new().Parent = instance
	ContentProvider:new().Parent = instance
	CoreGui:new().Parent = instance
	CorePackages:new().Parent = instance
	ContextActionService:new().Parent = instance
	GuiService:new().Parent = instance
	HttpRbxApiService:new().Parent = instance
	HttpService:new().Parent = instance
	InsertService:new().Parent = instance
	LocalizationService:new().Parent = instance
	MarketplaceService:new().Parent = instance
	NotificationService:new().Parent = instance
	Players:new().Parent = instance
	ReplicatedFirst:new().Parent = instance
	ReplicatedStorage:new().Parent = instance
	RunService:new().Parent = instance
	ServerScriptService:new().Parent = instance
	ServerStorage:new().Parent = instance
	StarterPlayer:new().Parent = instance
	Stats:new().Parent = instance
	TestService:new().Parent = instance
	TextService:new().Parent = instance
	TweenService:new().Parent = instance
	UserInputService:new().Parent = instance
	VirtualInputManager:new().Parent = instance
	Workspace:new().Parent = instance
end

function Game.prototype:GetService(serviceName)
	local service = self:FindFirstChildOfClass(serviceName)

	if service then
		return service
	end

	-- TODO: Load the service if possible?

	error(string.format("Cannot get service %q", tostring(serviceName)), 2)
end

Game.properties.CreatorId = InstanceProperty.readOnly({
	getDefault = function()
		return 0
	end,
})

Game.properties.CreatorType = InstanceProperty.readOnly({
	getDefault = function()
		return CreatorType.User
	end,
})

Game.properties.GameId = InstanceProperty.readOnly({
	getDefault = function()
		return 0
	end,
})

Game.properties.JobId = InstanceProperty.readOnly({
	getDefault = function()
		return ""
	end,
})

Game.properties.PlaceId = InstanceProperty.readOnly({
	getDefault = function()
		return 0
	end,
})

Game.properties.PlaceVersion = InstanceProperty.readOnly({
	getDefault = function()
		return 0
	end,
})

Game.properties.VIPServerId = InstanceProperty.readOnly({
	getDefault = function()
		return ""
	end,
})

Game.properties.VIPServerOwnerId = InstanceProperty.readOnly({
	getDefault = function()
		return 0
	end,
})

return Game