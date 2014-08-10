-- rdnt-srv 1.1
-- Server software for rdnt

function loadData()
	if fs.exists("/.lmnet") then
		fs.makeDir("/.lmnet")
	end
	if fs.exists("/.lmnet/rdntPro") then
		local file = fs.open("/.lmnet/rdnt")
		data = textutils.unserialize(file.readAll())
		file.close()
	else
		data = {}
	end
end
function saveData()

end
function loadSite(pSite)
	if not fs.exists("/www/"..pSite) then
		return nil	
	end
	if data["mode"] == 'pre' then
		return loadfile('/www/'..pSite)()
	elseif data["mode"] = "post" then
		local file = fs.open("/www/"..pSide)
		local site = file.readAll()
		file.close()
		return site
	end
end
function genData()
	
end

local oldPullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

for _, v in pairs(rs.getSides()) do
	if peripheral.getType(v) == "modem" then
		rednet.open(v)
	end
end

genData()
local url = data["url"]


function clear()
	term.clear()
	term.setCursorPos(1, 1)
end

clear()

function printLog(text)
	local time = textutils.formatTime(os.time(), true)
	print("["..string.rep(" ", 5-time:len())..time.."] "..text)
end

printLog("rdnt-srvPro 1.0: ")

while true do
	local e = {os.pullEvent()}
	local event = e[1]
	if event == "rednet_message" and type(e[3]) == "string" then
		local sender = e[2]
		local msg = e[3]
		local header = "local _DATA = {}\n"
		local tmp = {string.gsub(msg, "[^?]+", "")}
		if tmp[2] > 1 then
			local matches = {}
			for match in string.gmatch(msg, "[^?]+") do
				table.insert(matches, match)
			end
			local rawData = matches[2]
			local parts = {}
			for match in string.gmatch(rawData, "[^&]+") do
				table.insert(parts, match)
			end
			local data = {}
			for _, v in pairs(parts) do
				local subparts = {}
				for match in string.gmatch(v, "[^=]+") do
					table.insert(subparts, match)
				end
				local key = subparts[1]
				local value = subparts[2]
				data[key] = value
			end
			header = "local _DATA = "..textutils.serialize(data).."\n"
		end
		if msg:sub(1, url:len()) == url and (msg:sub(url:len()+1, url:len()+1) == "" or msg:sub(url:len()+1, url:len()+1) == "/") then
			local f = {string.gsub(msg, "[^/]+", "")}
			if f[2] > 1 then
				local str = ""
				local matches = {}
				for match in string.gmatch(msg, "[^?]+") do
					table.insert(matches, match)
				end
				for match in string.gmatch(matches[1], "[^/]+") do
					if match ~= url then
						str = str.."/"..match
					end
				end
				printLog("ID "..sender.." wants "..str)
				if fs.exists("/subsite"..str) then
					local file = fs.open("/subsite"..str, "r")
					rednet.send(sender, header..file.readAll())
					file.close()
				else
					if fs.exists("/404") then
						--need
					else
						rednet.send(sender, "print(\"404 Not Found\")\nprint(\"This file does not exist on this site.\")")
					end
					printLog("Reply to ID "..sender..": 404")
				end
			else
				rednet.send(sender, header..site)
				printLog("ID "..sender.." wants main site")
			end
			printLog("Request by ID "..sender..": success.")
		end
	elseif event == "terminate" then
		printLog("Exiting.")
		sleep(0.1)
		os.pullEvent = oldPullEvent
		return
	end
end