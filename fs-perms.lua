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

local oldfs = {}
function fs.getPermissions(file)
  local f = oldfs.open(".lmnet/.fsdata", "r")
  if not f then return {r=true,w=true} end
  local permissions = textutils.unserialize(f.readAll())
  f.close()
  return permissions[file] or {r=true,w=true}
end
