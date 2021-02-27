--- High-level database class.
--
-- Contains all of the high-level methods to manage databases. This module
-- should be used instead of the core modules when possible.
--
-- See the @{database.lua} example for more detail.
--
-- @classmod luchia.database
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips

require "luchia.conf"
local logger = require "luchia.core.log"
local log = logger.logger
local server = require "luchia.core.server"
local string = require "string"

local setmetatable = setmetatable

local _M = {}

--- Create a new database handler object.
--
-- @param self
-- @param server_params
--   Optional. A table of server connection parameters (identical to
--   <code>default.server</code> in @{luchia.conf}. If not provided, a server
--   object will be generated from the default server configuration.
-- @return A database handler object.
-- @usage db = luchia.database:new(server_params)
function _M.new(self, server_params)
  local database = {}
  database.server = server:new(server_params)
  setmetatable(database, self)
  self.__index = self
  log:debug(string.format([[New database handler]]))
  return database
end

--- Make a database-related request to the server.
--
-- @param self
-- @param method
--   Required. The HTTP method.
-- @param database_name
--   Required. The database name.
-- @return The following four values, in this order: response_data,
--   response_code, headers, status_code.
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
--
-- @return Same values as @{database_call}, response_data is a list of databases.
-- @usage db:list()
-- @see database_call
function _M:list()
  return self:info("_all_dbs")
end

--- Get information on a database.
--
-- @param database_name
--   Required. The database to get info from.
-- @return Same values as @{database_call}, response_data is a table of database
--   information.
-- @usage db:info("example_database")
-- @see database_call
function _M:info(database_name)
  return database_call(self, "GET", database_name)
end

--- Create a database.
--
-- @param database_name
--   Required. The database to create.
-- @return Same values as @{database_call}, response_data is a table of the
--   request result.
-- @usage db:create("example_database")
-- @see database_call
function _M:create(database_name)
  return database_call(self, "PUT", database_name)
end

--- Delete a database.
--
-- @param database_name
--   Required. The database to delete.
-- @return Same values as @{database_call}, response_data is a table of the
--   request result.
-- @usage db:delete("example_database")
-- @see database_call
function _M:delete(database_name)
  return database_call(self, "DELETE", database_name)
end

--- Check the response for success.
--
-- A convenience method to ensure a successful request.
--
-- @param response
--   Required. The response object returned from the server request.
-- @return true if the server responsed with an ok:true, false otherwise.
-- @usage operation_succeeded = db:response_ok(response)
function _M:response_ok(response)
  return self.server:response_ok(response)
end

return _M
