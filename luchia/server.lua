local string = require "string"
local conf = luchia.conf
local log = luchia.log

local setmetatable = setmetatable

module(...)

function new(self, params)
  local params = params or {}
  local server = {}
  server.protocol = params.protocol or conf.default.server.protocol
  server.user = params.user or conf.default.server.user
  server.password = params.password or conf.default.server.password
  server.host = params.host or conf.default.server.host
  server.port = params.port or conf.default.server.port
  setmetatable(server, self)
  self.__index = self
  log:debug(string.format([[New server, protocol: %s, user: %s, password: %s, host: %s, port: %s]], server.protocol, server.user or "", server.password or "", server.host, server.port or ""))
  return server
end

