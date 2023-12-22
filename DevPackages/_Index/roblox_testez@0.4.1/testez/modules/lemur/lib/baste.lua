-- luacheck: ignore

--[[
	Baste, a module system for Lua
	Version 1.2.0-dev

	MIT License

	Copyright (c) 2017 Lucien Greathouse

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
]]

local baste = {}

local function componentsFromPathString(input)
	local components = {}
	local sliceStart = 1
	local sliceEnd = 0

	for i = 1, #input do
		local char = input:sub(i, i)

		if char == "/" or char == "\\" then
			if sliceEnd ~= 0 then
				local slice = input:sub(sliceStart, sliceEnd)

				if slice == ".." then
					local lastComponent = components[#components]

					if lastComponent ~= nil and lastComponent ~= ".." then
						table.remove(components)
					else
						table.insert(components, slice)
					end
				elseif slice ~= "." then
					table.insert(components, slice)
				end
			end

			sliceStart = i + 1
			sliceEnd = 0
		else
			sliceEnd = i
		end
	end

	if sliceEnd ~= 0 then
		local slice = input:sub(sliceStart, sliceEnd)
		table.insert(components, slice)
	end

	return components
end

local Path = {}
Path.prototype = {}
Path.__index = Path.prototype

function Path.fromString(input)
	if type(input) ~= "string" then
		error("Path.fromString expects a string, but got " .. type(input), 2)
	end

	local isAbsolute = input:sub(1, 1) == "/"

	local path = {
		isAbsolute = isAbsolute,
		components = componentsFromPathString(input),
	}

	setmetatable(path, Path)

	return path
end

function Path:__tostring()
	if self.__stringRepresentation ~= nil then
		return self.__stringRepresentation
	end

	local output = table.concat(self.components, "/")

	if self.isAbsolute then
		output = "/" .. output
	end

	self.__stringRepresentation = output

	return output
end

function Path.prototype:getExtension()
	local lastComponent = self.components[#self.components]

	if lastComponent == nil then
		return nil
	end

	-- TODO: Handle files that start with a dot?

	return lastComponent:match("%.[^.]+")
end

function Path.prototype:clone()
	local components = {}

	for _, component in ipairs(self.components) do
		table.insert(components, component)
	end

	local newPath = {
		isAbsolute = self.isAbsolute,
		components = components,
	}

	setmetatable(newPath, getmetatable(self))

	return newPath
end

function Path.prototype:push(input)
	self = self:clone()

	local newComponents = componentsFromPathString(input)

	for _, component in ipairs(newComponents) do
		if component == ".." then
			if #self.components > 0 then
				table.remove(self.components)
			else
				table.insert(self.components, component)
			end
		elseif component ~= "." then
			table.insert(self.components, component)
		end
	end

	return self
end

function Path.prototype:pop()
	self = self:clone()
	table.remove(self.components)

	return self
end

function Path.prototype:addExtension(extension)
	self = self:clone()
	self.components[#self.components] = self.components[#self.components] .. extension

	return self
end

baste._Path = Path

-- Abstraction over loadstring and load
local loadWithEnv
if setfenv then
	-- 5.1, LuaJIT
	loadWithEnv = function(source, name, env)
		local chunk, err = loadstring(source, name)

		if not chunk then
			return nil, err
		end

		if env then
			setfenv(chunk, env)
		end

		return chunk
	end
else
	-- 5.2+
	loadWithEnv = function(source, name, env)
		return load(source, name, "bt", env)
	end
end

-- Abstraction over filesystem APIs
local function readFile(path)
	local handle, err = io.open(path, "r")

	if not handle then
		return nil, err
	end

	local contents = handle:read("*all")
	handle:close()

	return contents
end

if love then
	local oldReadFile = readFile

	readFile = function(path)
		local contents = love.filesystem.read(path)

		-- It could still exist outside the sandbox!
		if not contents then
			return oldReadFile(path)
		end

		return contents
	end
end

local loadedModules = {}
local moduleResults = {}

--[[
	Because of tail-call optimization, trying to get the file location of a
	chunk whose contents are just a return statement fails.

	Using an 'import function factory' solves thie problem by injecting the
	file's path into the generated function. This also reduces the number of
	debug library calls.
]]
local function makeImport(rootPath)
	return function(modulePath)
		local currentPath = rootPath

		if currentPath == nil then
			currentPath = Path.fromString(debug.getinfo(2, "S").source:gsub("^@", ""))
		end

		if type(modulePath) ~= "string" then
			local message = "Bad argument #1 to import, expected string but got %s"
			error(string.format(message, type(modulePath)), 2)
		end

		-- Relative import!
		if modulePath:sub(1, 1) == "." then
			local currentDirectory = currentPath:pop()
			local relativeModulePath = currentDirectory:push(modulePath)

			local pathsToTry = {relativeModulePath}

			if Path.fromString(modulePath):getExtension() == nil then
				table.insert(pathsToTry, relativeModulePath:addExtension(".lua"))
				table.insert(pathsToTry, relativeModulePath:push("init.lua"))
			end

			-- TODO: Plug-in point for adding additional paths to try

			-- Have we loaded this module before?
			for _, path in ipairs(pathsToTry) do
				if loadedModules[tostring(path)] then
					return moduleResults[tostring(path)]
				end
			end

			-- Let's try to load from these paths!
			for _, path in ipairs(pathsToTry) do
				-- Hand-craft an environment for the module we're loading
				-- The module won't be able to iterate over globals!
				local env = setmetatable({
					import = makeImport(path),
				}, {
					__index = _G,
					__newindex = _G,
				})

				-- TODO: Plug-in point for adding extra loaders

				local source = readFile(tostring(path))

				if source then
					local chunk, err = loadWithEnv(source, "@" .. tostring(path), env)

					if chunk then
						local result = chunk()
						loadedModules[tostring(path)] = true
						moduleResults[tostring(path)] = result

						return result
					else
						-- Syntax error!
						error(err, 2)
					end
				end
			end

			local pathsToTryAsStrings = {}

			for _, path in ipairs(pathsToTry) do
				table.insert(pathsToTryAsStrings, tostring(path))
			end

			-- We didn't find any modules.
			local message = string.format("Couldn't import %q from file %s, tried:\n\t%s",
				modulePath,
				tostring(currentPath),
				table.concat(pathsToTryAsStrings, "\n\t")
			)

			error(message, 2)
		else
			-- TODO: check `baste_modules` folder (or similar)
			return require(modulePath)
		end
	end
end

baste.import = makeImport()

function baste.global()
	_G.import = baste.import

	return baste
end

return baste