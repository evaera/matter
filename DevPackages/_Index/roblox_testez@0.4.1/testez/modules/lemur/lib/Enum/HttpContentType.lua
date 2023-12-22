local createEnum = import("../createEnum")

return createEnum(
	"HttpContentType",
	{
		ApplicationJson = 0,
		ApplicationXml = 1,
		ApplicationUrlEncoded = 2,
		TextPlain = 3,
		TextXml = 4,
	}
)
