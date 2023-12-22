local lemur = require("lib")

describe("init", function()
	it("should load", function()
		assert.not_nil(lemur)
	end)
end)