local exists, dkjson = pcall(require, "dkjson")

local json = {}

function json.encode(input)
	error("Please install `dkjson` to use JSON features.", 2)
end

function json.decode(input)
	error("Please install `dkjson` to use JSON features.", 2)
end

if exists then
	json.encode = dkjson.encode
	json.decode = dkjson.decode
end

return json