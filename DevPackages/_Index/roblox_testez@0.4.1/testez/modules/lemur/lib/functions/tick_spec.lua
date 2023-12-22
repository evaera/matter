local tick = import("./tick")

describe("functions.tick", function()
	it("returns a number", function()
		assert.is.number(tick())
	end)
end)