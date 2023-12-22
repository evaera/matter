local Signal = import("../Signal")
local BaseInstance = import("./BaseInstance")
local InstanceProperty = import("../InstanceProperty")

local BindableEvent = BaseInstance:extend("BindableEvent", {
	creatable = true,
})

BindableEvent.properties.Event = InstanceProperty.readOnly({
	getDefault = Signal.new,
})

function BindableEvent.prototype:Fire(...)
	self.Event:Fire(...)
end

return BindableEvent