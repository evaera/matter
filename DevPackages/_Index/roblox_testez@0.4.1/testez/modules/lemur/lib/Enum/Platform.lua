local createEnum = import("../createEnum")

return createEnum("Platform", {
	Windows = 0,
	OSX = 1,
	IOS = 2,
	Android = 3,
	XBoxOne = 4,
	PS4 = 5,
	PS3 = 6,
	XBox360 = 7,
	WiiU = 8,
	NX = 9,
	Ouya = 10,
	AndroidTV = 11,
	Chromecast = 12,
	Linux = 13,
	SteamOS = 14,
	WebOS = 15,
	DOS = 16,
	BeOS = 17,
	UWP = 18,
	None = 19,
})