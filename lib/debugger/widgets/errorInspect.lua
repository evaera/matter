return function(plasma)
	return plasma.widget(function(debugger, custom)
		local loop = debugger.loop

		plasma.window("\xf0\x9f\x92\xa5 Errors", function()
			local text, setText = plasma.useState("")

			custom.codeText(text)

			local items = {}
			for index, errorData in loop._systemErrors[debugger.debugSystem] do
				local preview = errorData.error
					:gsub("^(.-):", "")
					:gsub("^%s?[%w%.]+%.(%w+:)", "%1")
					:gsub("\n", " ")
					:sub(1, 60)

				items[index] = {
					DateTime.fromUnixTimestamp(errorData.when):ToIsoDate(),
					preview,

					errorData = errorData,
					selected = errorData.error == text,
				}
			end

			plasma.row(function()
				local selected = plasma.table(items, {
					selectable = true,
				}):selected()

				if selected then
					setText(selected.errorData.error)
				end

				if plasma.button("Clear"):clicked() then
					loop._systemErrors[debugger.debugSystem] = nil
				end
			end)
		end)
	end)
end
