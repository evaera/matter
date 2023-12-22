local warn = import("./warn")

local function setupWarnDetour()
	local oldErr = io.stderr

	local writeSpy = spy.new(function() end)

	io.stderr = { -- luacheck: ignore
		write = writeSpy
	}

	return oldErr, writeSpy
end

describe("functions.warn", function()
	it("should be a function", function()
		assert.is_function(warn)
	end)

	it("should warn", function()
		local oldErr, writeSpy = setupWarnDetour()
		warn("Doge has taken over the world!")
		assert.spy(writeSpy).was_called_with(io.stderr, "Doge has taken over the world!")
		io.stderr = oldErr -- luacheck: ignore
	end)

	it("should warn with multiple arguments", function()
		local oldErr, writeSpy = setupWarnDetour()
		warn("IT'S DOGE!", "AAH!")
		assert.spy(writeSpy).was.called(4) -- IT'S DOGE, \t, AAH!, \n
		io.stderr = oldErr -- luacheck: ignore
	end)

	it("should warn with a non-string argument", function()
		local oldErr, writeSpy = setupWarnDetour()
		warn(1)
		assert.spy(writeSpy).was_called_with(io.stderr, "1")
		io.stderr = oldErr -- luacheck: ignore
	end)

	it("should warn with non-string arguments", function()
		local oldErr, writeSpy = setupWarnDetour()
		warn(2, 3)
		assert.spy(writeSpy).was.called(4) -- 2, \t, 3, \n
		io.stderr = oldErr -- luacheck: ignore
	end)
end)