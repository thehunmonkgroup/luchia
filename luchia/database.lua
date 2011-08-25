--[[
  Methods for working with databases.
]]

require "luchia.conf"
require "luchia.core.log"
require "luchia.core.server"

local string = require "string"
local setmetatable = setmetatable

local log = luchia.core.log
local server = luchia.core.server

module(...)

function new(self, params)
  local params = params or {}
  local database = {}
  database.server = params.server or server:new()
  setmetatable(database, self)
  self.__index = self
  log:debug(string.format([[New database handler]]))
  return database
end

function list(self)
  local params = {
    path = "_all_dbs",
  }
  local response = self.server:request(params)
  return response
end

local function database_call(self, method, database_name)
  if database_name then
    local params = {
      method = method,
      path = database_name,
    }
    local response = self.server:request(params)
    return response
  else
    log:error([[Database name is required]])
  end
end

function info(self, database_name)
  return database_call(self, "GET", database_name)
end

function create(self, database_name)
  return database_call(self, "PUT", database_name)
end

function delete(self, database_name)
  return database_call(self, "DELETE", database_name)
end

