local format = require(script.Parent.Parent.formatTable)

return function(plasma)
	return plasma.widget(function(debugger)
		return plasma.window({
			title = "Queries",
			closable = true,
		}, function()
			if #debugger._queries == 0 then
				return plasma.label("No queries.")
			end

			for i, query in debugger._queries do
				if query.changedComponent then
					plasma.heading(string.format("Query Changed %d", i))

					plasma.label(tostring(query.changedComponent))

					continue
				end

				plasma.heading(string.format("Query %d", i))

				local componentNames = {}

				for _, component in query.components do
					table.insert(componentNames, tostring(component))
				end

				plasma.label(table.concat(componentNames, ", "))

				local items = { { "ID", unpack(componentNames) } }

				while #items <= 10 do
					local data = { query.result:next() }

					if #data == 0 then
						break
					end

					for index, value in data do
						if type(value) == "table" then
							data[index] = format.formatTable(value)
						else
							data[index] = tostring(value)
						end
					end

					table.insert(items, data)
				end

				plasma.table(items, {
					headings = true,
				})

				if #items > 10 and query.result:next() then
					plasma.label("(further results truncated)")
				end
			end
			return nil
		end):closed()
	end)
end
