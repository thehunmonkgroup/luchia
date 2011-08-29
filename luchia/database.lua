--- High-level database class.
-- @author Chad Phillips
-- @copyright 2011 Chad Phillips

require "luchia.conf"
local log = require "luchia.core.log"
local server = require "luchia.core.server"
local string = require "string"

local setmetatable = setmetatable

--- High-level database class.
-- Contains all of the high-level methods to manage databases. This module
-- should be used instead of the core modules when possible.
module("luchia.database")

function new(self, params)
  local params = params or {}
  local database = {}
  database.server = params.server or server:new()
  setmetatable(database, self)
  self.__index = self
  log:debug(string.format([[New database handler]]))
  return database
end

local function database_call(self, method, database_name)
  if database_name then
    local params = {
      method = method,
      path = database_name,
    }
    local response, response_code, headers, status = self.server:request(params)
    return response, response_code, headers, status
  else
    log:error([[Database name is required]])
  end
end

function list(self)
  return self:info("_all_dbs")
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

function response_ok(self, response)
  return self.server:response_ok(response)
end
