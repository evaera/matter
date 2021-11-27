local stack = {}

local TopoStack = {}

function TopoStack.push(info)
	table.insert(stack, info)
end

function TopoStack.pop()
	table.remove(stack, #stack)
end

function TopoStack.peek()
	if #stack == 0 then
		error("Attempt to peek from topo stack when it is empty", 2)
	end

	return stack[#stack]
end

return TopoStack
