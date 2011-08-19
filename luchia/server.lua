local json = require "cjson"
local http = require "socket.http"
local url = require "socket.url"
local ltn12 = require "ltn12"
local table = require "table"
local string = require "string"
local conf = luchia.conf
local log = luchia.log

local pairs = pairs
local setmetatable = setmetatable
local print = print

module(...)

Server = {}

function Server:new(params)
  params = params or {}
  server = {}
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

Request = {}

function Request:new(server, params)
  params = params or {}
  request = {}
  request.server = server
  request.method = params.method or "GET"
  request.path = params.path
  request.query_parameters = params.query_parameters or {}
  request.data = params.data
  setmetatable(request, self)
  self.__index = self
  request.stringified_parameters = self:stringify_parameters(request.query_parameters)
  log:debug(string.format([[New request, method: %s, path: %s, query parameters: %s, data: %s]], request.method, request.path or "", request.stringified_parameters, request.data or ""))
  return request
end

function Request:execute()
  local response_body, response_code, headers = self:http_request()
  local json_response = ""
  if response_code and response_body ~= "" then
    log:debug(string.format([[Request executed, response_code: %s, response body: %s]], response_code, response_body))
    json_response = json.decode(response_body)
  end
  return json_response, response_code, headers
end

function Request:http_request()
  local source = nil
  local headers = nil

  if self.data then
    source = ltn12.source.string(self.data)
    headers = { ["content-length"] = self.data:len() }
  end

  local result = {}
  local _, response_code, headers = http.request {
    method = self.method,
    url = self:build_url(),
    sink = ltn12.sink.table(result),
    source = source,
    headers = headers
  }

  return table.concat(result), response_code, headers
end

function Request:build_url()

  local url_parts = {
    scheme = self.server.protocol,
    user = self.server.user,
    password = self.server.password,
    host = self.server.host,
    port = self.server.port,
    path = "/" .. self.path,
    query = request.stringified_parameters,
  }

  local full_url = url.build(url_parts)
  log:debug(string.format([[Built URL: %s]], full_url));
  return full_url
end

function Request:stringify_parameters(params)
  params = params or self.query_parameters
  local parameter_string = ""
  if #params > 0 then
    for name, value in pairs(params) do
      parameter_string = string.format("%s&%s=%s", parameter_string, url.escape(name), url.escape(value))
    end
  end

  log:debug(string.format([[Built query parameters: %s]], parameter_string));
  return parameter_string
end

