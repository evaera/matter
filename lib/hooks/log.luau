local topoRuntime = require(script.Parent.Parent.topoRuntime)
local format = require(script.Parent.Parent.debugger.formatTable)

--[=[
	@within Matter

	:::info Topologically-aware function
	This function is only usable if called within the context of [`Loop:begin`](/api/Loop#begin).
	:::

	@param ... any

	Logs some text. Readable in the Matter debugger.
]=]
local function log(...)
	local state = topoRuntime.useFrameState()

	if state.logs == nil then
		return
	end

	local segments = {}

	for i = 1, select("#", ...) do
		local value = select(i, ...)

		if type(value) == "table" then
			segments[i] = format.formatTable(value)
		else
			segments[i] = tostring(value)
		end
	end

	table.insert(state.logs, table.concat(segments, " "))

	if #state.logs > 100 then
		table.remove(state.logs, 1)
	end
end

return log
