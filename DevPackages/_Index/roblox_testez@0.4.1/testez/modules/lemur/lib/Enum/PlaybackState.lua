local createEnum = import("../createEnum")

return createEnum("PlaybackState", {
	Begin = 0,
	Delayed = 1,
	Playing = 2,
	Paused = 3,
	Completed = 4,
	Cancelled = 5,
})