local function warn(...)
	local count = select("#", ...)
	for i = 1, count do
		local piece = select(i, ...)
		io.stderr:write(tostring(piece))

		if i < count then
			io.stderr:write("\t")
		end
	end

	io.stderr:write("\n")
end

return warn