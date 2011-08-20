local json = require "cjson"
local http = require "socket.http"
local url = require "socket.url"
local ltn12 = require "ltn12"
local table = require "table"
local string = require "string"
local log = luchia.log

local pairs = pairs
local setmetatable = setmetatable

module(...)

function new(self, server, params)
  params = params or {}
  request = {}
  request.server = server
  request.method = params.method or "GET"
  request.path = params.path
  request.query_parameters = params.query_parameters or {}
  request.data = params.data
  setmetatable(request, self)
  self.__index = self
  log:debug(string.format([[New request, method: %s, path: %s, data: %s]], request.method, request.path or "", request.data or ""))
  return request
end

function execute(self)
  local response_body, response_code, headers, status = self:http_request()
  local json_response
  if response_body then
    log:debug([[Request executed]])
    if string.match(response_code, "20[0-6]") then
      log:debug(string.format([[Request successful, response_code: %s]], response_code))
      json_response = json.decode(response_body)
    else
      log:warn(string.format([[Request failed, response_code: %s, message: %s]], response_code, status))
    end
  else
    log:error(string.format([[Unable to access server, error message: %s]], response_code))
  end
  return json_response, response_code, headers
end

function http_request(self)
  local source = nil
  local headers = nil

  if self.data then
    source = ltn12.source.string(self.data)
    headers = {
      ["content-type"] = "application/json",
      ["content-length"] = self.data:len(),
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
    scheme = self.server.protocol,
    user = self.server.user,
    password = self.server.password,
    host = self.server.host,
    port = self.server.port,
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

