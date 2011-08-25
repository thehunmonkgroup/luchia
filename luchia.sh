#!/bin/env lua

local luchia = require "luchia"
local logging = require "logging"
local log = luchia.core.log
log:setLevel(logging.INFO)

local function usage()
  print [[

Usage: ./luchia.sh <path> [arg1=value] [arg2=value]...

Easy way to run GET requests against the default configured CouchDB database in
luchia.
  path: the server path, eg. /_all_dbs.
  argN=value: Query parameter and value. 
]]
end

if #arg == 0 then
  usage()
  do return end
end

local path = table.remove(arg, 1)
local query_parameters
if #arg > 0 then
  query_parameters = {}
  for _, argument in ipairs(arg) do
    local key, value = string.match(argument, "(.+)=(.+)")
    query_parameters[key] = value
  end
end

local server = luchia.core.server
srv = server:new()

local params = {
  path = path,
  query_parameters = query_parameters,
}
res = srv:request(params)
if res then
  log:info(res)
end

-- vim: set filetype=lua
