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

--- Create a new database handler object.
-- @param server Optional. The server object to use for the server connection.
-- If not provided, a server object will be generated from the default server
-- configuration.
-- @return A database handler object.
-- @usage db = luchia.database:new(server)
function new(self, server)
  local database = {}
  database.server = server or server:new()
  setmetatable(database, self)
  self.__index = self
  log:debug(string.format([[New database handler]]))
  return database
end

--- Make a database-related request to the server.
-- This is an internal method only.
-- @param method The HTTP method.
-- @param database_name The database name.
-- @return The following four values, in this order: response_data,
-- response_code, headers, status_code.
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

--- List all databases.
-- @return Same values as database_call, response_data is a list of databases.
-- @usage db:list()
-- @see database_call
function list(self)
  return self:info("_all_dbs")
end

--- Get information on a database.
-- @return Same values as database_call, response_data is a table of database
-- information.
-- @usage db:info("example_database")
-- @see database_call
function info(self, database_name)
  return database_call(self, "GET", database_name)
end

--- Create a database.
-- @return Same values as database_call, response_data is a table of the
-- request result.
-- @usage db:create("example_database")
-- @see database_call
function create(self, database_name)
  return database_call(self, "PUT", database_name)
end

--- Delete a database.
-- @return Same values as database_call, response_data is a table of the
-- request result.
-- @usage db:delete("example_database")
-- @see database_call
function delete(self, database_name)
  return database_call(self, "DELETE", database_name)
end

--- Check the response for success.
-- A convenience method to ensure a successful request.
-- @param response The response object returned from the server request.
-- @return true if the server responsed with an ok:true, false otherwise.
-- @usage operation_succeeded = db:response_ok(response)
function response_ok(self, response)
  return self.server:response_ok(response)
end
