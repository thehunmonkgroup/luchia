--- Common testing functions.

local io = require "io"
local os = require "os"
local string = require "string"

local pairs = pairs
local require = require
local tonumber = tonumber
local type = type

local lunatest = require "lunatest"
local assert_table = lunatest.assert_table
local assert_equal = lunatest.assert_equal
local assert_match = lunatest.assert_match
local assert_gte = lunatest.assert_gte
local assert_lte = lunatest.assert_lte

local file1_path

local _M = {}

function _M.create_file1()
  local file1_data = "foo"
  file1_path = os.tmpname()
  local file = io.open(file1_path, "w")
  file:write(file1_data)
  file:close()
  file = io.open(file1_path)
  local file_data = file:read("*a")
  file:close()
  return file1_path, file_data
end

function _M.remove_file1()
  if file1_path then
    os.remove(file1_path)
  end
end

function _M.table_length(t)
  if type(t) == "table" then
    local count = 0
    for _, _ in pairs(t)
      do count = count + 1
    end
    return count
  end
end

function _M.conf_valid_default_server_table()
  local conf = require "luchia.conf"
  assert_table(conf, "conf")
  assert_table(conf.default, "conf.default")
  assert_table(conf.default.server, "conf.default.server")
end

function _M.valid_server_protocol(protocol, field)
  assert_equal("http", protocol, field)
end

function _M.valid_server_host(host, field)
  -- TODO: Research RFC on valid hostnames.
  assert_match("^[%a%.-_]+$", host, field)
end

function _M.valid_server_port(port, field)
  port = tonumber(port)
  -- TODO: Research valid port numbers.
  assert_gte(1, port, field)
  assert_lte(65536, port, field)
end

function _M.conf_valid_log_table()
  local conf = require "luchia.conf"
  assert_table(conf, "conf")
  assert_table(conf.log, "conf.log")
end

return _M
