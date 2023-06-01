local formatTableModule = require(script.Parent.Parent.formatTable)
local formatTable = formatTableModule.formatTable

return function(plasma)
	return plasma.widget(function(objectStack, custom)
		local closed = plasma.window({
			title = "Inspect",
			closable = true,
		}, function()
			plasma.row({ padding = 5 }, function()
				for i, object in objectStack do
					if custom.link(object.key, {
						icon = object.icon or "{}",
					}):clicked() then
						local difference = #objectStack - i

						for _ = 1, difference do
							table.remove(objectStack, #objectStack)
						end
					end

					if i < #objectStack then
						custom.link("▶", {
							disabled = true,
						})
					end
				end
			end)

			local items = {}

			for key, value in pairs(objectStack[#objectStack].value) do
				local valueItem

				if type(value) == "table" then
					valueItem = function()
						if custom.link(formatTable(value), {
							font = Enum.Font.Code,
						}):clicked() then
							table.insert(objectStack, {
								key = if type(key) == "table" then formatTable(key) else tostring(key),
								value = value,
							})
						end
					end
				else
					valueItem = tostring(value)
				end

				table.insert(items, {
					tostring(key),
					valueItem,
				})
			end

			plasma.useKey(tostring(objectStack[#objectStack].key) .. ":" .. #objectStack)

			if #items == 0 then
				return plasma.label("(empty table)")
			end

			plasma.table(items)
			return nil
		end):closed()

		if closed then
			table.clear(objectStack)
		end
	end)
end
