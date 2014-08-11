tArgs = {...}

if not ui then
	--getUI
end

for _, v in pairs(rs.getSides()) do
	if peripheral.getType(v) == "modem" then
		rednet.open(v)
	end
end

running = true
rdnt = {}
local obj = {}

reDirect = rdnt.goto
redirect = rdnt.goto
showBar = function() end
hideBar = function() end
themeColor = function() end
leftPrint = function(text)
	print(text)
end
lPrint = leftPrint
leftWrite = function(text)
	write(text)
end
lWrite = leftWrite
centerPrint = function(text)
	local w, h = term.getSize()
	local x, y = term.getCursorPos()
	term.setCursorPos(math.floor(w/2-text:len()/2)+1, y)
	print(text)
end
cPrint = centerPrint
centerWrite = function(text)
	local w, h = term.getSize()
	local x, y = term.getCursorPos()
	term.setCursorPos(math.floor(w/2-text:len()/2)+1, y)
	write(text)
end
cWrite = centerWrite
rightPrint = function(text)
	local w, h = term.getSize()
	local x, y = term.getCursorPos()
	term.setCursorPos(w-text:len(), y)
	print(text)
end
rPrint = rightPrint
rightWrite = function(text)
	local w, h = term.getSize()
	local x, y = term.getCursorPos()
	term.setCursorPos(w-text:len(), y)
	write(text)
end
rWrite = rightWrite

function clear()
	term.clear()
	term.setCursorPos(1, 1)
end

function iif(cond, trueval, falseval)
	if cond then
		return trueval
	else
		return falseval
	end
end

function rdnt.bgColor(color)
	if term.isColor() or color == colors.white or color == colors.black then
		term.setBackgroundColor(color)
	end
end

function rdnt.fgColor(color)
	if term.isColor() or color == colors.white or color == colors.black then
		term.setTextColor(color)
	end
end

function rdnt.clear()
	term.clear()
	term.setCursorPos(1, 1)
	rdnt.bgColor(colors.gray)
	term.clearLine()
	if rdnt.siteTitle then
		print("Site: "..rdnt.siteTitle)
	else
		print("URL: "..rdnt.currentURL)
	end
	rdnt.bgColor(colors.black)
	term.setCursorPos(1, 2)
end

function historyIns(pURL)
	for i=1,29 do
		history[i+1] = history[i]
	end
	history[31] = nil
	history[1] = pURL
	saveData()
end
local function loadData()
	if fs.exists("/.lmnet/rdnt") then
		local file = fs.open("/.lmnet/rdnt")
		local exp = textutils.unserialize(file.readAll())
		file.close()
		history = exp["history"]
		bookmarks = exp["bookmarks"]
		rdnt.homeURL = exp["Home"]
	else
		rdnt.homeURL = "rdnt.home"
		bookmarks = {}
		history = {}
	end
end
local function saveData()
	if not fs.exists("/.lmnet") then
		shell.makeDir("/.lmnet")
	end
	local file = fs.open("/.lmnet/rdnt")
	local exp = {["history"] = history,["bookmarks"] = bookmarks,["Home"] = rdnt.homeURL}
	file.write(textutils.serialize(exp))
	file.close()
end

function rdnt.requestImpl(url)
	-- Not intended for regular use!
	-- Use rdnt.goto(url) to go to a URL.
	local urlOGet = url:sub(1,str:find("!")-1)
	rednet.broadcast(urlOGet)
	local e = {rednet.receive(3)}
	if e[2] ~= nil then
		local file = fs.open("/.sitetmp", "w")
		file.write(e[2])
		file.close()
		return true
	else
		return false
	end
end
function rdnt.link(pText,pLink)
	local x,y = term.getCursorPos()
	if term.isColor() then
		term.setTextColor(colors.blue)
		term.setBackgroundColor(colors.white)
	else
		term.setTextColor(colors.black)
		term.setBackgroundColor(colors.white)
	end
	write(' '..pText..' ')
	while x <= pText:len()+2 do
		obj[y][x] = "rdnt.goto("..pLink..")"
		x = x+1
	end
end
function rdnt.textbox(pFkt)
	local x,y = term.getCursorPos()
	if term.isColor() then
		term.setTextColor(colors.green)
		term.setBackgroundColor(colors.grey)
	else
		term.setTextColor(colors.black)
		term.setBackgroundColor(colors.white)
	end
	write(' ... ')
	while x <= pText:len()+2 do
		obj[y][x] = pFkt
		x = x+1
	end
end
function rdnt.goto(url)
	rdnt.siteTitle = nil
	rdnt.tryURL = url
	if url:sub(1, 5) == "rdnt." then
		if internalPages[url:sub(6)] ~= nil then
			rdnt.currentURL = url
			rdnt.clear()
			internalPage = url:sub(6)
		else
			rdnt.clear()
			print("No internal page '"..url:sub(6).."'.")
		end
	else
		historyIns(url)
		rdnt.clear()
		print("Connecting to '"..url.."'...")
		local ok = rdnt.requestImpl(url)
		if ok then
			rdnt.currentURL = url
			rdnt.clear()
			siteLoaded = true
		else
			rdnt.clear()
			print("Failed to connect to '"..url.."'.")
			print("Ask the server administrator to fix this problem.")
		end
	end
end
function rdnt.home()
	rdnt.goto(rdnt.homeURL)
end
function rdnt.title(pTitle)
	rdnt.siteTitle = pTitle
	rdnt.clear()
end
function rdnt.get()
	local inp = rdnt.currentURL
	local function split(str,pat)
		local t = {}
		local fpat = "(.-)"..pat
		local last_end = 1
		local s,e,cap = str:find(fpat,1)
		while s do
			if s ~= 1 or cap ~= "" then
				table.insert(t,cap)
			end
			last_end = e+1
			s,e,cap = str:find(fpat,last_end)
		end
		if last_end <= #str then
			cap = str:sub(last_end)
			table.insert(t,cap)
		end
		return t
	end
	local allGet = split(str:sub(str:find("!")+1,str:len()),"&")
	local get = {}
	for i=1,#allGet do
		local x = split(allGet[i],"=")
		get[x[1]] = x[2]
	end
	return get
end


internalPages = {
	["home"] = function()
		rdnt.title("rdnt v1.2")
		rdnt.clear()
		print("Welcome to rdnt!")
		print("Press left Ctrl to enter a URL.")
		print("Enter rdnt.intpages to view internal pages.")
		print("Enter rdnt.history for visited Pages")--need
		print("Enter rdnt.bookmarks for bookmarks")--also
		print("Enter rdnt.exit or press f4 to exit.")
		print("Press F6 for menu")
		print("Press F5 to refresh.")
	end,
	["exit"] = function()
		running = false
	end,
	["about"] = function()
		rdnt.title("About LMNet OS")
		rdnt.clear()
		cPrint(os.version())
		print("by MultMine")
		print("few help by timia2109")
	end,
	["history"] = function()
		local cho = ui.menu(history,'History')
		if cho then
			rdnt.goto(cho)
		end
	end,
	["bookmarks"] = function()
		local inGet = rdnt.get()
		if inGet["mode"] == 'add' then
			
		else
			local show = {}
			for i,v in pairs(bookmarks) do
				table.insert(show,i..' ['..v..']')
			end
			local cho = ui.menu(show,'Bookmarks')
			if cho then
				rdnt.goto(cho:sub(cho:find("[")+1,cho:len()-1))
			end
		end
	end,
	["settings"] = function()
	
	end,
	["intpages"] = function()
		rdnt.title("intpages")
		rdnt.clear()
		print("Internal pages in rdnt:")
		for v in pairs(internalPages) do
			textutils.pagedPrint("- "..v)
		end
	end
}

function main()
	while running do
		if siteLoaded then
			siteLoaded = false
			shell.run("/.sitetmp")
		end
		if internalPage then
			internalPages[internalPage]()
			internalPage = nil
		end
		sleep(0)
	end
end
function rdntCmd()
	while true do
		e = {os.pullEvent()}
		if e[1] == "key" then
			if e[2] == keys.leftCtrl then
				term.setCursorPos(1, 1)
				rdnt.bgColor(colors.red)
				term.clearLine()
				write("URL: ")
				local input = read()
				rdnt.bgColor(colors.black)
				term.clearLine()
				rdnt.goto(input)
			elseif e[2] == keys.f5 then
				rdnt.goto(rdnt.tryURL)
			elseif e[2] == keys.f6 then
				local open = ui.menu({'Home','Bookmarks','Add to bookmarks','History','Settings','Back'},'Menu',1,false)
				if open == 'Home' then
					rdnt.home()
				elseif open == 'Bookmarks' then
					rdnt.goto('rdnt.bookmarks')
				elseif open == 'Add to bookmarks' then
					rdnt.goto('rdnt.bookmarks?mode=add&url='..currentURL)
				elseif open == 'History' then
					rdnt.goto('rdnt.history')
				elseif open == 'Settings' then
					rdnt.goto('rdnt.settings')
				end
			elseif e[2] == keys.f4 then
				rdnt.goto('rdnt.exit')
			end
		elseif e[1] == "mouse_click" then
			if e[4] == 1 then
				term.setCursorPos(1, 1)
				rdnt.bgColor(colors.red)
				term.clearLine()
				write("URL: ")
				local input = read()
				rdnt.bgColor(colors.black)
				term.clearLine()
				rdnt.goto(input)
			elseif obj[e[4]][e[3]] then
				loadstring(obj[e[4]][e[3]])()
			end 
		end
		sleep(0)
	end
end

loadData()
local siteLoaded = false
local internalPage
rdnt.tryURL = ""
rdnt.currentURL = ""
if tArgs[1] then
	rdnt.goto(tArgs[1])
else
	rdnt.home()
end
parallel.waitForAny(main, rdntCmd)

clear()
