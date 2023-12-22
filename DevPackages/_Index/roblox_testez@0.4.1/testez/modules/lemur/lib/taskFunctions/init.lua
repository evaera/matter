local names = {
	"delay",
	"spawn",
	"wait",
}

local taskFunctions = {}

for _, name in ipairs(names) do
	taskFunctions[name] = import("./" .. name)
end

return taskFunctions