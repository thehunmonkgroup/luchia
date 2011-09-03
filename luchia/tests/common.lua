--- Common testing functions.

luchia = luchia or {}
luchia.temp = luchia.temp or {}
luchia.test = luchia.test or {}

local file1_data = "foo"

function luchia.test.create_files()
  luchia.temp.file1 = {}
  luchia.temp.file1.file_path = os.tmpname()
  -- Grab filename from the full path.
  luchia.temp.file1.file_name = string.match(luchia.temp.file1.file_path, ".+/([^/%s]+)$")
  local file = io.open(luchia.temp.file1.file_path, "w")
  file:write(file1_data)
  file:close()
  file = io.open(luchia.temp.file1.file_path)
  luchia.temp.file1.file_data = file:read("*a")
  file:close()
end

function luchia.test.remove_files()
  if luchia.temp.file1.file_path then
    os.remove(luchia.temp.file1.file_path)
  end
end

function luchia.test.table_length(t)
  local count = 0
  for _, _ in pairs(t)
    do count = count + 1
  end
  return count
end
