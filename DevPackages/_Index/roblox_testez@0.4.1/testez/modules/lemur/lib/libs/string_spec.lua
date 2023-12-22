local string = import("./string")

describe("libs.string", function()
	describe("split", function()
		it("should be a function", function()
			assert.is_function(string.split)
		end)

		it("should return an array of comma separated strings if sep is nil", function()
			assert.are.same({"Hello", "world", "and", "lemur"}, string.split("Hello,world,and,lemur"))
		end)

		it("should return an array of all characters in a string if sep is the empty string", function()
			assert.are.same({
				"H",
				"e",
				"l",
				"l",
				"o",
				",",
				"w",
				"o",
				"r",
				"l",
				"d",
				",",
				"a",
				"n",
				"d",
				",",
				"l",
				"e",
				"m",
				"u",
				"r",
			}, string.split("Hello,world,and,lemur", ""))
		end)

		it("should return an empty table if the string and sep is the empty string", function()
			assert.are.same({}, string.split("", ""))
		end)

		it("should return the original string in a table if no sep is matched", function()
			assert.are.same({"Hello, world"}, string.split("Hello, world", "K"))
			assert.are.same({""}, string.split("", " "))
		end)

		it("should return empty strings at the front and back when seps are present there", function()
			assert.are.same({"", "Validark", "Osyris", "Vorlias", ""}, string.split("/Validark/Osyris/Vorlias/", "/"))
			assert.are.same({"", "Validark", "Osyris", "Vorlias"}, string.split("/Validark/Osyris/Vorlias", "/"))
			assert.are.same({"Validark", "Osyris", "Vorlias", ""}, string.split("Validark/Osyris/Vorlias/", "/"))
			assert.are.same({"Validark", "Osyris", "Vorlias"}, string.split("Validark/Osyris/Vorlias", "/"))
		end)

		it("should allow multi-character separators", function()
			assert.are.same({"Hello", "world"}, string.split("Hello, world", ", "))
		end)

		it("should literally interpret Lua character classes", function()
			assert.are.same({"Hello, world"}, string.split("Hello, world", "%l"))
			assert.are.same({"Hel", "o, world"}, string.split("Hel%lo, world", "%l"))
		end)

		it("should match Roblox's internal tests", function()
			-- Provided by tiffany352 at https://github.com/LPGhatguy/lemur/pull/190
			local char = string.char
			local ZWJ = char(0xe2, 0x80, 0x8d)
			assert.are.same({ "" }, string.split("", ","))
			assert.are.same({ "foo", "", "bar" }, string.split("foo,,bar", ","))
			assert.are.same({ "", "foo" }, string.split(",foo", ","))
			assert.are.same({ "foo", "" }, string.split("foo,", ","))
			assert.are.same({ "", "" }, string.split(",", ","))
			assert.are.same({ "", "", "" }, string.split(",,", ","))
			assert.are.same({ "" }, string.split("", "~~~"))
			assert.are.same({ "~~" }, string.split("~~", "~~~"))
			assert.are.same({ "~~ ~~" }, string.split("~~ ~~", "~~~"))
			assert.are.same({ "foo", "bar" }, string.split("foo~~~bar", "~~~"))
			assert.are.same({ "foo", "", "bar" }, string.split("foo~~~~~~bar", "~~~"))
			assert.are.same({ "", "foo" }, string.split("~~~foo", "~~~"))
			assert.are.same({ "foo", "" }, string.split("foo~~~", "~~~"))
			assert.are.same({ "", "" }, string.split("~~~", "~~~"))
			assert.are.same({ "", "", "" }, string.split("~~~~~~", "~~~"))
			assert.are.same({ "", "", "O" }, string.split("OOOOO", "OO"))
			assert.are.same({ "   ws   " }, string.split("   ws   ", ","))
			assert.are.same({ "foo ", " bar" }, string.split("foo , bar", ","))
			assert.are.same({ "我很高兴", "你呢？" }, string.split("我很高兴，你呢？", "，"))
			assert.are.same({ "👩", "👩", "👧", "👧" }, string.split("👩‍👩‍👧‍👧", ZWJ))
			assert.are.same({ "foo", "bar" }, string.split("foo\0bar", "\0"))
			assert.are.same({ "foo", "bar", "" }, string.split("foo\0bar\0", "\0"))
			assert.are.same({ "foo", "bar" }, string.split("foo\0\0bar", "\0\0"))
			assert.are.same({ "foo\0" }, string.split("foo\0", "\0\0"))
			assert.are.same({ "foo", "\0" }, string.split("foo\0\0\0", "\0\0"))
			assert.are.same({ }, string.split("", ""))
			assert.are.same({ "a", "b", "c" }, string.split("abc", ""))
			assert.are.same({ char(0xef), char(0xbc), char(0x9f) }, string.split("？", ""))
		end)
	end)
end)
