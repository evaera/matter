local createEnum = import("../createEnum")

return createEnum("ConnectionState", {
	CONNECTED = 0,
	DISCONNECTED = 1,
})