local success, socket = pcall(require, "socket")

local tick
if success then
	tick = socket.gettime
else
	tick = os.clock
end

return tick