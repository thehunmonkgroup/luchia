local json = require "cjson"
local http = require "socket.http"
local url = require "socket.url"
local ltn12 = require "ltn12"
local table = require "table"
local string = require "string"
local conf = luchia.conf
local log = luchia.core.log

local pairs = pairs
local pcall = pcall
local setmetatable = setmetatable

module(...)

function new(self, params)
  local params = params or {}
  local server = {}
  local connection = params.connection or {}
  connection.protocol = connection.protocol or conf.default.server.protocol
  connection.user = connection.user or conf.default.server.user
  connection.password = connection.password or conf.default.server.password
  connection.host = connection.host or conf.default.server.host
  connection.port = connection.port or conf.default.server.port
  server.connection = connection
  setmetatable(server, self)
  self.__index = self
  log:debug(string.format([[New core server, protocol: %s, user: %s, password: %s, host: %s, port: %s]], connection.protocol, connection.user or "", connection.password or "", connection.host, connection.port or ""))
  return server
end

function request(self, params)
  params = params or {}
  self.method = params.method or "GET"
  self.path = params.path
  self.query_parameters = params.query_parameters or {}
  self.data = params.data

  self:prepare_request()

  log:debug(string.format([[New request, method: %s, path: %s, request_data: %s]], self.method, self.path or "", self.request_data or ""))
  local response_body, response_code, headers, status = self:http_request()
  local response
  if response_body then
    log:debug([[Request executed]])
    if string.match(response_code, "20[0-6]") then
      log:debug(string.format([[Request successful, response_code: %s]], response_code))
      response = self:parse_json(response_body)
    else
      log:warn(string.format([[Request failed, response_code: %s, message: %s]], response_code, status or ""))
    end
  else
    log:error(string.format([[Unable to access server, error message: %s]], response_code))
  end
  return response, response_code, headers, status
end

function prepare_request(self)
  if self.data then
    if self.data._type == "document" then
      log:debug([[Preparing document request data]])
      self.content_type = "application/json"
      self.request_data = json.encode(self.data.document)
    elseif self.data._type == "attachment" then
      log:debug([[Preparing attachment request data]])
      self.content_type = self.data.content_type
      self.request_data = self.data.file_data
    end
  end
end

function parse_json(self, json_string)
  log:debug(string.format([[JSON to parse: %s]], json_string))
  local result, data = pcall(
    function ()
      return json.decode(json_string)
    end
  )
  if result then
    log:debug([[JSON parsed successfully]])
    return data
  else
    log:error([[JSON parsing failed]])
    return result, data
  end
end

function http_request(self)
  local source = nil
  local headers = nil

  if self.request_data then
    source = ltn12.source.string(self.request_data)
    headers = {
      ["content-type"] = self.content_type,
      ["content-length"] = self.request_data:len(),
    }
  end

  local result = {}
  local _, response_code, headers, status = http.request {
    method = self.method,
    url = self:build_url(),
    sink = ltn12.sink.table(result),
    source = source,
    headers = headers
  }

  return table.concat(result), response_code, headers, status
end

function build_url(self)

  local url_parts = {
    scheme = self.connection.protocol,
    user = self.connection.user,
    password = self.connection.password,
    host = self.connection.host,
    port = self.connection.port,
    path = "/" .. self.path,
    query = self:stringify_parameters(),
  }

  local full_url = url.build(url_parts)
  log:debug(string.format([[Built URL: %s]], full_url));
  return full_url
end

function stringify_parameters(self, params)
  params = params or self.query_parameters
  local parameter_string = ""
  for name, value in pairs(params) do
    parameter_string = string.format("%s&%s=%s", parameter_string, url.escape(name), url.escape(value))
  end

  parameter_string = parameter_string:sub(2)
  log:debug(string.format([[Built query parameters: %s]], parameter_string));
  return parameter_string
end

function response_ok(self, response)
  return response and response.ok and response.ok == true
end

