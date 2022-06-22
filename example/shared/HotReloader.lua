--!strict
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local HotReloader = {}
HotReloader.__index = HotReloader

function HotReloader.new()
	local self = setmetatable({
		_listeners = {},
		_clonedModules = {},
	}, HotReloader)
	return self
end

function HotReloader:destroy()
	for _, listener: RBXScriptConnection in pairs(self._listeners) do
		listener:Disconnect()
	end
	self._listeners = {}
	for _, cloned in pairs(self._clonedModules) do
		cloned:Destroy()
	end
	self._clonedModules = {}
end

function HotReloader:listen(module: ModuleScript, callback: (ModuleScript) -> nil, cleanup: (ModuleScript) -> nil)
	if RunService:IsStudio() then
		local moduleChanged = module.Changed:Connect(function()
			if self._clonedModules[module] then
				cleanup(self._clonedModules[module])
				self._clonedModules[module]:Destroy()
			else
				cleanup(module)
			end

			if not game:IsAncestorOf(module) then
				return
			end

			local cloned = module:Clone()

			CollectionService:AddTag(cloned, "RewireClonedModule")

			cloned.Parent = module.Parent
			self._clonedModules[module] = cloned

			callback(cloned)
			warn(("HotReloaded %s!"):format(module:GetFullName()))
		end)
		table.insert(self._listeners, moduleChanged)
	end
	callback(module)
end

return HotReloader
