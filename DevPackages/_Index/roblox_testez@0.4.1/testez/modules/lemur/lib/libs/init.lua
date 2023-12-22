local names = {
	"bit32",
	"math",
	"string",
}

local libs = {}

for _, name in ipairs(names) do
	libs[name] = import("./" .. name)
end

return libs
