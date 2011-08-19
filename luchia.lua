--[[
  Bootstrap file for the entire package.
]]

require "luchia.conf"
require "luchia.log"
require "luchia.server"
require "luchia.database"
require "luchia.document"
require "luchia.attachment"

luchia.log:debug("hello world")
local server = luchia.server.Server:new()
local request = luchia.server.Request:new(server, {path = "/_all_dbs"})
local response = request:execute()
