local function cloneTable(input)
	local output = {}
	for k, v in pairs(input) do
		if type(v) == "table" then
			output[k] = cloneTable(v)
		else
			output[k] = v
		end
	end
	return output
end

local oldfs = cloneTable(fs)

if not oldfs.exists(".lmnet/.fsdata") then
	local file = fs.open(".lmnet/.fsdata", "w")
	file.write("{}")
	file.close()
end

function fs.getFullPath(file)
	local parts = {}
	for match in string.gmatch(file, "[^/]+") do
		table.insert(parts, match)
	end
	return table.concat(parts, "/")
end

function fs.getPermissions(file)
	file = fs.getFullPath(file)
	
	local f = oldfs.open(".lmnet/.fsdata", "r")
	if not f then
		return {r = true, w = true}
	end
	local permissions = textutils.unserialize(f.readAll())
	f.close()
	
	if not fs.exists(file) then
		fs.setPermissions(file, nil)
		error("File not found", 1)
	end
	
	return currentUser ~= "root" and permissions[file] or {r = true, w = true}
end

function fs.setPermissions(file, newPermissions)
	file = fs.getFullPath(file)
	
	local f = oldfs.open(".lmnet/.fsdata", "r")
	local permissions = textutils.unserialize(f.readAll())
	f.close()
	
	if oldfs.exists(file) and oldfs.isDir(file) and oldfs.list(file) then
		for i, v in ipairs(table.sort(oldfs.list(file))) do
			fs.setPermissions(v, newPermissions)
		end
		return true
	end
	
	permissions[file] = newPermissions
	
	if permissions[file] and type(permissions[file]) == "table" then
		permissions[file] = {r = permissions[file].r, w = permissions[file].w}
	end
	
	local f = oldfs.open(".lmnet/.fsdata", "w") -- local4ever; TODO remove crappy comments
	f.write(textutils.serialize(permissions))
	f.close()
	
	return true
end

function fs.open(file, mode)
	if not fs.getPermissions(file)[(mode == "w" or mode == "a") and "w" or "r"] then
		error("Access denied", 1)
	end
	return oldfs.open(file, mode)
end

function fs.move(source, destination)
	if not fs.getPermissions(source).r then
		error("Access denied", 1)
	end
	return oldfs.move(source, destination)
end

function fs.copy(source, destination)
	if not fs.getPermissions(source).r then
		error("Access denied", 1)
	end
	return oldfs.copy(source, destination)
end

function fs.getFreeSpace(file)
	if not fs.getPermissions(file).r then
		error("Access denied", 1)
	end
	return oldfs.getFreeSpace(file)
end

function fs.delete(file)
	if not fs.getPermissions(file).r then
		error("Access denied", 1)
	end
	return oldfs.delete(file)
end
function fs.isReadOnly(file)
	if oldfs.isReadOnly(file) then
		return true
	end
	if not fs.getPermissions(file).w then
		return true
	end
	return false
end
function fs.makeDir(file)
	if fs.getDir and not fs.getPermissions(fs.getDir(file)).w then
		error("Access denied", 1)
	end
	oldfs.makeDir(file)
end
