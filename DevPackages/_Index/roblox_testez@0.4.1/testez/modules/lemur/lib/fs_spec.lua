describe("fs", function()
	local fs = import("./fs")

	it("should return errors when failing to open a file", function()
		local contents, err = fs.read("nuclear launch codes.txt")

		assert.is_nil(contents)
		assert.is_not_nil(err)
	end)

	it("should return contents of files read", function()
		local contents, err = fs.read("init.lua")

		assert.is_not_nil(contents)
		assert.is_nil(err)
		assert.is_true(#contents > 0)
	end)
end)
