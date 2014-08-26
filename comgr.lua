local processList = {}
local exit = false
function forceExit()
	exit = true
end
function run(logFunc)
	while #processList > 0 or noAutoExit do
		if exit then
			return
		end
		if #processList > 0 then
			local event = {os.pullEventRaw()}
			for i, co in pairs(processList) do
				if coroutine.status(co) == "dead" then
					table.remove(processList, i)
					if logFunc then
						logFunc("Process #"..i.." died.")
					end
				else
					coroutine.resume(co, unpack(event))
				end
			end
		end
	end
end
function addProcess(func)
	table.insert(processList, coroutine.create(func))
	return #processList
end
function removeProcess(id)
	table.remove(processList, id)
end
