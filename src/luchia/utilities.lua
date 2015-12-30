--- High-level utilities class.
--
-- Contains all high-level utility methods. This module should be used instead
-- of the core modules when possible.
--
-- See the @{utilities.lua} example for more detail.
--
-- @classmod luchia.utilities
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips

require "luchia.conf"
local logger = require "luchia.core.log"
local log = logger.logger
local server = require "luchia.core.server"
local string = require "string"

local setmetatable = setmetatable

local _M = {}

--- Create a new utilities handler object.
--
-- @param server_params
--   Optional. A table of server connection parameters (identical to
--   <code>default.server</code> in @{luchia.conf}. If not provided,
--   a server object will be generated from the default server
--   configuration.
-- @return A utilities handler object.
-- @usage util = luchia.utilities:new(server_params)
function _M.new(self, server_params)
  local utilities = {}
  utilities.server = server:new(server_params)
  setmetatable(utilities, self)
  self.__index = self
  log:debug(string.format([[New utilities handler]]))
  return utilities
end

--- Make a utilities-related request to the server.
--
-- @param self
-- @param path
--   Optional. The server path.
-- @return The following four values, in this order: response_data,
--   response_code, headers, status_code.
local function utilities_get_call(self, path)
  local params = {
    path = path,
  }
  local response, response_code, headers, status = self.server:request(params)
  return response, response_code, headers, status
end

--- Get the database server version.
--
-- @return The database server version string.
-- @usage util:version()
function _M:version()
  local response = utilities_get_call(self, "")
  if response and response.version then
    return response.version
  end
end

--- Get the database server configuration.
--
-- @return Same values as @{utilities_get_call}, response_data is a table of
--   database server configuration information.
-- @usage util:config()
-- @see utilities_get_call
function _M:config()
  return utilities_get_call(self, "_config")
end

--- Get the database server statistics.
--
-- @return Same values as @{utilities_get_call}, response_data is a table of
--   database server statistics information.
-- @usage util:stats()
-- @see utilities_get_call
function _M:stats()
  return utilities_get_call(self, "_stats")
end

--- Get the database server active tasks.
--
-- @return Same values as @{utilities_get_call}, response_data is a list of
--   database server active tasks.
-- @usage util:active_tasks()
-- @see utilities_get_call
function _M:active_tasks()
  return utilities_get_call(self, "_active_tasks")
end

return _M
