--!strict
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local HotReloader = {}
HotReloader.__index = HotReloader

--[=[
	@class HotReloader
]=]

type Context = {
	originalModule: ModuleScript,
	isReloading: boolean,
}

--[=[
	@interface Context
	@within HotReloader

	.originalModule ModuleScript
	.isReloading boolean
]=]

--[=[
	Creates a new HotReloader.

	@return HotReloader
]=]
function HotReloader.new()
	local self = setmetatable({
		_listeners = {},
		_clonedModules = {},
	}, HotReloader)
	return self
end

--[=[
	Cleans up this HotReloader, forgetting about any previously modules that were being listened to.
]=]
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

--[=[
	Listen to changes from a single module.

	Runs the given `callback` once to start, and then again whenever the module changes.

	Runs the given `cleanup` callback after a module is changed, but before `callback` is run.

	Both are passed a [Context] object, which contains information about the original module
	and whether or not the script is reloading.

	- For `callback`, `Context.isReloading` is true if this is not the first time the callback is being run.
	- For `cleanup`, `Context.isReloading` is true if the module has been removed (this is the last cleanup).

	@param module -- The original module to attach listeners to
	@param callback -- A callback that runs when the ModuleScript is added or changed
	@param cleanup -- A callback that runs when the ModuleScript is changed or removed
]=]
function HotReloader:listen(
	module: ModuleScript,
	callback: (ModuleScript, Context) -> (),
	cleanup: (ModuleScript, Context) -> ()
)
	if RunService:IsStudio() then
		local moduleChanged = module.Changed:Connect(function()
			local originalStillExists = game:IsAncestorOf(module)

			local cleanupContext = {
				isReloading = originalStillExists,
				originalModule = module,
			}

			if self._clonedModules[module] then
				cleanup(self._clonedModules[module], cleanupContext)
				self._clonedModules[module]:Destroy()
			else
				cleanup(module, cleanupContext)
			end

			if not originalStillExists then
				return
			end

			local cloned = module:Clone()

			CollectionService:AddTag(cloned, "RewireClonedModule")

			cloned.Parent = module.Parent
			self._clonedModules[module] = cloned

			callback(cloned, {
				originalModule = module,
				isReloading = true,
			})
			warn(("HotReloaded %s!"):format(module:GetFullName()))
		end)
		table.insert(self._listeners, moduleChanged)
	end

	callback(module, {
		originalModule = module,
		isReloading = false,
	})
end

--[=[
	Scans current and new descendants of an object for ModuleScripts, and runs `callback` for each of them.

	This function has the same semantics as [HotReloader:listen].

	@param container -- The root instance
	@param callback -- A callback that runs when the ModuleScript is added or changed
	@param cleanup -- A callback that runs when the ModuleScript is changed or removed
]=]
function HotReloader:scan(
	container: Instance,
	callback: (ModuleScript, Context) -> (),
	cleanup: (ModuleScript, Context) -> ()
)
	local function add(module)
		self:listen(module, callback, cleanup)
	end

	for _, instance in container:GetDescendants() do
		if instance:IsA("ModuleScript") then
			add(instance)
		end
	end

	local descendantAdded = container.DescendantAdded:Connect(function(instance)
		if instance:IsA("ModuleScript") and not CollectionService:HasTag(instance, "RewireClonedModule") then
			add(instance)
		end
	end)

	table.insert(self._listeners, descendantAdded)
end

return HotReloader
