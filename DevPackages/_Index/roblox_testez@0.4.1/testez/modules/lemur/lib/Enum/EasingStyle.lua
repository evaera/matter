local createEnum = import("../createEnum")

return createEnum("EasingStyle", {
	Linear = 0,
	Sine = 1,
	Back = 2,
	Quad = 3,
	Quart = 4,
	Quint = 5,
	Bounce = 6,
	Elastic = 7,
})