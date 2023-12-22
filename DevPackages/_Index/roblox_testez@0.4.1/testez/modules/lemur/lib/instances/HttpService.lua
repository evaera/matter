local BaseInstance = import("./BaseInstance")
local typeof = import("../functions/typeof")
local json = import("../json")

local HttpService = BaseInstance:extend("HttpService")

function HttpService.prototype:JSONEncode(input)
	return json.encode(input)
end

function HttpService.prototype:JSONDecode(input)
	return json.decode(input)
end

function HttpService.prototype:UrlEncode(input)
	local url = input:gsub("\n", "\r\n")

	return url:gsub("([^%w])", function(c)
		return string.format("%%%02X", string.byte(c))
	end)
end

function HttpService.prototype:GenerateGUID(wrapInCurlyBraces)
	local argType = typeof(wrapInCurlyBraces)
	if wrapInCurlyBraces ~= nil and argType ~= "boolean" then
		error(("Unable to cast %s to bool"):format(argType), 2)
	end

	--[[
		`GenerateGUID` allows any value type for `wrapInCurlyBraces`, but it
		only omits the curly braces when `wrapInCurlyBraces` is set to `false`
	]]
	if wrapInCurlyBraces == false then
		return "04AEBFEA-87FC-480F-A98B-E5E221007A90"
	else
		return "{04AEBFEA-87FC-480F-A98B-E5E221007A90}"
	end
end

return HttpService