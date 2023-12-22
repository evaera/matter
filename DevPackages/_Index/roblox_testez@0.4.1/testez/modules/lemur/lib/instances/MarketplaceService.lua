local BaseInstance = import("./BaseInstance")
local InstanceProperty = import("../InstanceProperty")
local Signal = import("../Signal")
local MarketplaceService = BaseInstance:extend("MarketplaceService")

MarketplaceService.properties.PromptPurchaseRequested = InstanceProperty.readOnly({
	getDefault = function()
		return Signal.new()
	end,
})

MarketplaceService.properties.PromptProductPurchaseRequested = InstanceProperty.readOnly({
	getDefault = function()
		return Signal.new()
	end,
})

MarketplaceService.properties.PromptGamePassPurchaseRequested = InstanceProperty.readOnly({
	getDefault = function()
		return Signal.new()
	end,
})

MarketplaceService.properties.ServerPurchaseVerification = InstanceProperty.readOnly({
	getDefault = function()
		return Signal.new()
	end,
})

return MarketplaceService