local useCurrentSystem = require(script.Parent.Parent.topoRuntime).useCurrentSystem
local World = require(script.Parent.Parent.World)

local originalQuery = World.query

local function hookWorld(debugger)
	World.query = function(world, ...)
		if useCurrentSystem() == debugger.debugSystem then
			table.insert(debugger._queries, {
				components = { ... },
				result = originalQuery(world, ...),
			})
		end

		return originalQuery(world, ...)
	end
end

local function unhookWorld()
	World.query = originalQuery
end

return {
	hookWorld = hookWorld,
	unhookWorld = unhookWorld,
}
