#!/usr/bin/env lua

--- Shell script to make simple GET requests to the default server.
-- @author Chad Phillips
-- @copyright 2011 Chad Phillips

--- Shell script to make simple GET requests to the default server.
-- Requires either the lualogging or stdlib packages be installed. With stdlib
-- the output is much prettier.
-- @usage Run request.lua without any arguments for help/usage.
-- @class function
-- @name request.lua

require "luchia"

local log = luchia.core.log
local server = luchia.core.server

local function usage()
  print [[

Usage: ./request.lua <path> [arg1=value] [arg2=value]...

Easy way to run GET requests against the default configured CouchDB database in
luchia.
  path: the server path, eg. /_all_dbs.
  argN=value: Query parameter and value.

Requires either the 'lualogging' or 'stdlib' lua packages be installed, stdlib
gives nicer output.
]]
end

--- Loader function for the base module.
local function stdlib_base_exists()
  require("base")
end

--- Loader function for the logging module.
local function logging_exists()
  require("logging")
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

local srv = server:new()

local params = {
  path = path,
  query_parameters = query_parameters,
}
local res = srv:request(params)
if res then
  -- Conditionally try to load the base module, then the logging module.
  if pcall(stdlib_base_exists) then
    print(prettytostring(res))
  elseif pcall(logging_exists) then
    log:setLevel(logging.INFO)
    log:info(res)
  else
    usage()
  end
end

-- vim: set filetype=lua
