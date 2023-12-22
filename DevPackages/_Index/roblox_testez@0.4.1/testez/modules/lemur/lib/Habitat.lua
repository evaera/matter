--[[
	A Lemur Habitat is an instance of an emulated Roblox environment.

	It is the root instance of the emulated hierarchy.
]]

local Instance = import("./Instance")
local TaskScheduler = import("./TaskScheduler")
local createEnvironment = import("./createEnvironment")
local fs = import("./fs")
local Game = import("./instances/Game")
local validateType = import("./validateType")
local assign = import("./assign")

local defaultLoadFromFsOptions = {
	loadInitModules = true,
}

local Habitat = {}
Habitat.__index = Habitat

function Habitat.new(settings)
	local habitat = {
		game = Game:new(),
		taskScheduler = TaskScheduler.new(),
		settings = settings or {},
		environment = nil,
	}

	setmetatable(habitat, Habitat)

	habitat.environment = createEnvironment(habitat)

	return habitat
end

function Habitat:loadFromFs(path, passedOptions)
	validateType("path", path, "string")

	if passedOptions ~= nil then
		validateType("passedOptions", passedOptions, "table")
	end

	local options = assign({}, defaultLoadFromFsOptions, passedOptions)

	if fs.isFile(path) then
		if path:find("%.lua$") then
			local instance = Instance.new("ModuleScript")
			local contents = assert(fs.read(path))

			instance.Name = path:match("([^/]-)%.lua$")
			instance.Source = contents

			getmetatable(instance).instance.modulePath = path

			return instance
		end
		-- Ignore non-lua files
		return
	elseif fs.isDirectory(path) then
		local instance = Instance.new("Folder")
		instance.Name = path:match("([^/]-)$")

		for name in fs.dir(path) do
			-- Why are these even in the iterator?
			if name ~= "." and name ~= ".." then
				local childPath = path .. "/" .. name

				local childInstance = Habitat:loadFromFs(childPath, passedOptions)
				if childInstance ~= nil then
					childInstance.Parent = instance
				end
			end
		end

		if options.loadInitModules then
			local init = instance:FindFirstChild("init")

			if init ~= nil then
				for _, child in ipairs(instance:GetChildren()) do
					if child ~= init then
						child.Parent = init
					end
				end

				init.Name = instance.Name
				init.Parent = nil

				instance:Destroy()

				instance = init
			end
		end

		return instance
	end

	error(("loadFromFs failed: Path %s did not exist."):format(path), 2)
end

--[[
	Equivalent to Roblox's 'require', called on an emulated Roblox instance.
]]
function Habitat:require(instance)
	validateType("instance", instance, "Instance")

	if not instance:IsA("ModuleScript") then
		local message = ("Attempted to require non-ModuleScript object %q (%s)"):format(
			instance.Name,
			instance.ClassName
		)
		error(message, 2)
	end

	local internalInstance = getmetatable(instance).instance
	if internalInstance.moduleLoaded then
		return internalInstance.moduleResult
	end

	local chunk = assert(loadstring(instance.Source, "@" .. internalInstance.modulePath))

	local environment = assign({}, self.environment, { script = instance })
	setfenv(chunk, environment)

	local result = chunk()

	internalInstance.moduleLoaded = true
	internalInstance.moduleResult = result

	return result
end

return Habitat