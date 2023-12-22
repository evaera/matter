stds.baste = {
	read_globals = {
		"import",
	},
}

ignore = {
	"212", -- unused arguments
}

std = "lua51+baste"

files["lib/**/*_spec.lua"] = {
	std = "+busted",
}

files["spec/**/*_spec.lua"] = {
	std = "+busted",
}