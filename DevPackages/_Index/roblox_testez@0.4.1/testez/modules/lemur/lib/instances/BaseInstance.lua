--[[
	Provides a base implementation for all Instances in Lemur.

	When adding a new instance, you can define:
	* properties, using helpers in InstanceProperty
	* prototype, used for defining methods and static values
	* init, called by the class's constructor
]]

local assign = import("../assign")
local InstanceProperty = import("../InstanceProperty")
local Signal = import("../Signal")
local typeKey = import("../typeKey")

local function isInstance(value)
	local metatable = getmetatable(value)

	return metatable and metatable.instance ~= nil
end

local BaseInstance = {}

BaseInstance.options = {
	creatable = false,
}

BaseInstance.name = "Instance"

BaseInstance.properties = {}

BaseInstance.properties.Name = InstanceProperty.normal({
	getDefault = function(self)
		return getmetatable(self).class.name
	end,
})

BaseInstance.properties.ClassName = InstanceProperty.readOnly({
	getDefault = function(self)
		return getmetatable(self).class.name
	end,
})

BaseInstance.properties.AncestryChanged = InstanceProperty.readOnly({
	getDefault = function()
		return Signal.new()
	end,
})

BaseInstance.properties.Changed = InstanceProperty.readOnly({
	getDefault = function()
		return Signal.new()
	end,
})

BaseInstance.properties.ChildAdded = InstanceProperty.readOnly({
	getDefault = Signal.new
})

BaseInstance.properties.ChildRemoved = InstanceProperty.readOnly({
	getDefault = Signal.new
})

BaseInstance.properties.Parent = InstanceProperty.normal({
	set = function(self, key, value)
		local instance = getmetatable(self).instance

		if instance.destroyed then
			error("Attempt to set parent after being destroyed!")
		end

		if instance.properties.Parent == value then
			return
		end

		if value ~= nil and not isInstance(value) then
			error(string.format("Can't set Parent to %q; Parent must be an Instance!"), tostring(value))
		end

		if instance.properties.Parent ~= nil then
			getmetatable(instance.properties.Parent).instance.children[self] = nil
			instance.properties.Parent.ChildRemoved:Fire(self)
		end

		instance.properties.Parent = value

		if value ~= nil then
			getmetatable(value).instance.children[self] = true
			value.ChildAdded:Fire(self)
		end

		self:_PropagateAncestryChanged(self, value)
	end,
})

BaseInstance.prototype = {}

function BaseInstance.prototype:ClearAllChildren()
	local children = getmetatable(self).instance.children

	for child in pairs(children) do
		child:Destroy()
	end
end

function BaseInstance.prototype:FindFirstAncestor(name)
	local level = self.Parent

	while level do
		if level.Name == name then
			return level
		end

		level = level.Parent
	end
end

function BaseInstance.prototype:FindFirstAncestorOfClass(name)
	local level = self.Parent

	while level do
		if level.ClassName == name then
			return level
		end

		level = level.Parent
	end
end

function BaseInstance.prototype:FindFirstAncestorWhichIsA(className)
	local level = self.Parent

	while level do
		if level:IsA(className) then
			return level
		end

		level = level.Parent
	end
end

function BaseInstance.prototype:FindFirstChild(name)
	local children = getmetatable(self).instance.children

	-- Search for existing children
	-- This is a set stored by child instead of by name, since names are not unique.
	for child in pairs(children) do
		if child.Name == name then
			return child
		end
	end

	return nil
end

function BaseInstance.prototype:FindFirstChildOfClass(className)
	local children = getmetatable(self).instance.children

	-- Search for existing children
	-- This is a set stored by child instead of by name, since names are not unique.
	for child in pairs(children) do
		if child.ClassName == className then
			return child
		end
	end

	return nil
end

function BaseInstance.prototype:FindFirstChildWhichIsA(className)
	local children = getmetatable(self).instance.children

	-- Search for existing children
	-- This is a set stored by child instead of by name, since names are not unique.
	for child in pairs(children) do
		if child:IsA(className) then
			return child
		end
	end

	return nil
end

function BaseInstance.prototype:GetChildren()
	local children = getmetatable(self).instance.children
	local result = {}

	for child in pairs(children) do
		table.insert(result, child)
	end

	return result
end

function BaseInstance.prototype:GetDescendants()
	local stack = {}
	local descendants = {}
	local current = self

	while current do
		local children = current:GetChildren()

		for _, child in pairs(children) do
			descendants[#descendants + 1] = child
			stack[#stack + 1] = child
		end

		current = stack[#stack]
		stack[#stack] = nil
	end

	return descendants
end

function BaseInstance.prototype:IsA(className)
	local currentClass = getmetatable(self).class

	while currentClass ~= nil do
		if currentClass.name == className then
			return true
		end

		currentClass = currentClass.super
	end

	return false
end

function BaseInstance.prototype:IsDescendantOf(object)
	local parent = self

	repeat
		parent = parent.Parent
	until parent == nil or parent == object

	return parent == object
end

function BaseInstance.prototype:Destroy()
	self:ClearAllChildren()

	if self.Parent ~= nil then
		self.Parent = nil
	end

	self:_DisconnectAllChangedListeners()

	getmetatable(self).instance.destroyed = true
end

function BaseInstance.prototype:GetPropertyChangedSignal(key)
	local properties = getmetatable(self).class.properties
	local propertySignals = getmetatable(self).instance.propertySignals

	local listener = propertySignals[key]

	if not listener then
		assert(properties[key], key .. " is not a valid property name.")

		listener = Signal.new()
		propertySignals[key] = listener
	end

	return listener
end

function BaseInstance.prototype:GetFullName()
	local name = self.Name
	local level = self.Parent

	while level and getmetatable(level).class.name ~= "DataModel" do
		name = level.Name .. "." .. name
		level = level.Parent
	end

	return name
end

function BaseInstance.prototype:WaitForChild(name, delay)
	return self:FindFirstChild(name)
end

function BaseInstance.prototype:_DisconnectAllChangedListeners()
	local propertySignals = getmetatable(self).instance.propertySignals

	for _, signal in pairs(propertySignals) do
		signal:_DisconnectAllListeners()
	end

	self.Changed:_DisconnectAllListeners()
end

function BaseInstance.prototype:_PropagateAncestryChanged(instance, parent)
	self.AncestryChanged:Fire(instance, parent)

	local children = getmetatable(self).instance.children

	for child in pairs(children) do
		child:_PropagateAncestryChanged(instance, parent)
	end
end

BaseInstance.metatable = {}
BaseInstance.metatable[typeKey] = "Instance"

function BaseInstance.metatable.__index(self, key)
	local class = getmetatable(self).class

	if class.properties[key] then
		return class.properties[key].get(self, key)
	end

	if class.prototype[key] then
		return class.prototype[key]
	end

	local object = self:FindFirstChild(key)
	if object then
		return object
	end

	error(string.format("%q is not a valid member of %s", tostring(key), self.ClassName), 2)
end

function BaseInstance.metatable.__newindex(self, key, value)
	local class = getmetatable(self).class

	if class.properties[key] then
		class.properties[key].set(self, key, value)

		self.Changed:Fire(key)

		local propertyChangedSignal = getmetatable(self).instance.propertySignals[key]

		if propertyChangedSignal then
			propertyChangedSignal:Fire()
		end

		return
	end

	error(string.format("%q is not a valid member of %s", tostring(key), self.ClassName), 2)
end

function BaseInstance.metatable:__tostring()
	return self.Name
end

function BaseInstance:new(...)
	local internalInstance = {
		destroyed = false,
		properties = {},
		propertySignals = {},
		children = {},
	}

	local instance = newproxy(true)

	-- Because userdata have a fixed metatable, merge values onto it.
	assign(getmetatable(instance), self.metatable)
	getmetatable(instance).instance = internalInstance
	getmetatable(instance).class = self

	for key, property in pairs(self.properties) do
		internalInstance.properties[key] = property.getDefault(instance)
	end

	self:init(instance, ...)

	return instance
end

function BaseInstance:init(instance, ...)
end

--[[
	Create a new instance class with the given name.
]]
function BaseInstance:extend(name, options)
	assert(type(name) == "string", "Expected string 'name' as argument #1.")
	assert(type(options) == "table" or options == nil, "Expected optional table 'options' as argument #2.")

	local newClass = assign({}, self)

	newClass.name = name
	newClass.super = self

	newClass.properties = assign({}, self.properties)
	newClass.prototype = assign({}, self.prototype)
	newClass.metatable = assign({}, self.metatable)
	newClass.options = assign({}, self.options, options or {})

	return newClass
end

return BaseInstance