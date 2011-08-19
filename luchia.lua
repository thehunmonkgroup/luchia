--[[
  Bootstrap file for the entire package.
]]

require "luchia.conf"
require "luchia.log"
require "luchia.server"

luchia.log:debug("hello world")
local server = luchia.server.Server:new()
local params = {
  --method = "POST",
  path = "example/_all_docs",
  --data = '{"hello":"world"}',
  query_parameters = {
    include_docs = "true",
  },
}
local request = luchia.server.Request:new(server, params)
local response = request:execute()
