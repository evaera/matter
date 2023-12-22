<h1 align="center">Lemur</h1>
<div align="center">
	<a href="https://travis-ci.org/LPGhatguy/lemur">
		<img src="https://api.travis-ci.org/LPGhatguy/lemur.svg?branch=master" />
	</a>
	<a href="https://coveralls.io/github/LPGhatguy/lemur?branch=master">
		<img src="https://coveralls.io/repos/github/LPGhatguy/lemur/badge.svg?branch=master" />
	</a>
</div>

<div align="center">
	<strong>L</strong>ua <strong>Emu</strong>lation of <strong>R</strong>oblox APIs
</div>

<div>&nbsp;</div>

Lemur reimplements a large portion of Roblox's API in Lua in order to enable Roblox projects to have continuous integration using services like Travis CI or Jenkins.

Lemur aims to be a fairly complete and up-to-date implementation of Roblox's API, however:

* Lemur will always be incomplete by nature
* Lemur will not implement deprecated APIs for the sake of simplicity
* Lemur is naturally restricted by the environment it runs in

Current feature coverage is detailed in [FEATURES.md](FEATURES.md)

## Installation
Lemur requires:

* Lua 5.1 or LuaJIT
	* `./?/init.lua` should be in your `LUA_PATH`. This is the default in some, but not all, installations.
* LuaFileSystem (`luarocks install luafilesystem`)

Lemur needs certain extra dependencies for some optional features:

* dkjson (Roblox JSON API) (`luarocks install dkjson`)
* LuaSocket (high performance timer) (`luarocks install luasocket`)
* bit32 (Lua 5.1 bit32 implementation) (`luarocks install bit32`)

Clone the Git repository wherever, then call `require` on it.

## Usage
To use Lemur, create a _Habitat_ and load pieces of the filesystem into the tree:

```lua
local lemur = require("lemur")

-- Create a Habitat
local habitat = lemur.Habitat.new()
local ReplicatedStorage = habitat.game:GetService("ReplicatedStorage")

-- Load `src/roblox` as a Folder containing some ModuleScripts:
local root = habitat:loadFromFs("src/roblox")
root.Parent = ReplicatedStorage

-- Locate src/roblox/CoolModule.lua from inside the habitat and load it!
local CoolModule = habitat:require(root.CoolModule)

-- Invoke a method on our Roblox module!
CoolModule.doSomething()
```

## Contributing
If there are any APIs you'd like that are missing, feel free to open an [issue on GitHub](https://github.com/LPGhatguy/lemur/issues)!

## License
Lemur is available under the MIT license. See [LICENSE.md](LICENSE.md) for details.