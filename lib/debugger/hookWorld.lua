local useCurrentSystem = require(script.Parent.Parent.topoRuntime).useCurrentSystem
local World = require(script.Parent.Parent.World)

local originalQuery = World.query
local originalQueryChanged = World.queryChanged

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

	World.queryChanged = function(world, componentToTrack)
		if useCurrentSystem() == debugger.debugSystem then
			table.insert(debugger._queries, {
				changedComponent = componentToTrack,
			})
		end

		return originalQueryChanged(world, componentToTrack)
	end
end

local function unhookWorld()
	World.query = originalQuery
	World.queryChanged = originalQueryChanged
end

return {
	hookWorld = hookWorld,
	unhookWorld = unhookWorld,
}
