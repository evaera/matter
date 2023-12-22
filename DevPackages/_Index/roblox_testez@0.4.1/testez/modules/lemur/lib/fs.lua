local ok, lfs = pcall(require, "lfs")

if not ok then
	error("Lemur requires LuaFileSystem, which couldn't be found: " .. lfs)
end

local fs = {}

function fs.isFile(path)
	return lfs.attributes(path, "mode") == "file"
end

function fs.isDirectory(path)
	return lfs.attributes(path, "mode") == "directory"
end

function fs.read(path)
	local handle, err = io.open(path, "r")

	if not handle then
		return nil, err
	end

	local contents = handle:read("*all")

	handle:close()

	return contents
end

fs.dir = lfs.dir

return fs