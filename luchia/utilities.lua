--[[
  Various utility methods.
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
  local utilities = {}
  utilities.server = params.server or server:new()
  setmetatable(utilities, self)
  self.__index = self
  log:debug(string.format([[New utilities handler]]))
  return utilities
end

local function utilities_get_call(self, path)
  local params = {
    path = path,
  }
  local response = self.server:request(params)
  return response
end

function version(self)
  local response = utilities_get_call(self, "")
  if response and response.version then
    return response.version
  end
end

function config(self)
  return utilities_get_call(self, "_config")
end

function stats(self)
  return utilities_get_call(self, "_stats")
end

function active_tasks(self)
  return utilities_get_call(self, "_active_tasks")
end

function uuids(self, count)
  local params = {
    path = "_uuids",
  }
  if count then
    params.query_parameters = {}
    params.query_parameters.count = count
  end
  local response = self.server:request(params)
  if response and response.uuids then
    return response.uuids
  end
end

