local BaseInstance = import("./BaseInstance")

local TestService = BaseInstance:extend("TestService")

function TestService.prototype:Error(message)
	io.stderr:write(message)
	io.stderr:write("\n")
end

return TestService