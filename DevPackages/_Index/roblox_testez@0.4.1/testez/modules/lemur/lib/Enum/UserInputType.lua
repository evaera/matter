local createEnum = import("../createEnum")

return createEnum("UserInputType", {
	MouseButton1 = 0,
	MouseButton2 = 1,
	MouseButton3 = 2,
	MouseWheel = 3,
	MouseMovement = 4,
	Touch = 7,
	Keyboard = 8,
	Focus = 9,
	Accelerometer = 10,
	Gyro = 11,
	Gamepad1 = 12,
	Gamepad2 = 13,
	Gamepad3 = 14,
	Gamepad4 = 15,
	Gamepad5 = 16,
	Gamepad6 = 17,
	Gamepad7 = 18,
	Gamepad8 = 19,
	TextInput = 20,
	None = 21,
})