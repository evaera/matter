local createEnum = import("../createEnum")

return createEnum("ScaleType", {
	Stretch = 0,
	Slice = 1,
	Tile = 2,
	Fit = 3,
	Crop = 4,
})