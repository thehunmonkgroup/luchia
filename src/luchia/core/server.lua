--- Core server handler class.
--
-- Note that for most cases, the methods in the higher-level @{luchia.database},
-- @{luchia.document}, and @{luchia.utilities} modules should be used; this module
-- provides the core server functionality that those higher-level modules use,
-- but can be used directly for more complex server requests.
--
-- See the @{core.server.lua} example for more detail.
--
-- @classmod luchia.core.server
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips

local json = require "cjson"
local http = require "socket.http"
local url = require "socket.url"
local ltn12 = require "ltn12"
local table = require "table"
local string = require "string"
local conf = require "luchia.conf"
local logger = require "luchia.core.log"
local log = logger.logger

local pairs = pairs
local pcall = pcall
local setmetatable = setmetatable
local tonumber = tonumber
local type = type


local _M = {}

--- Checks for a valid server protocol.
--
-- @return true on a valid protocol, nil otherwise.
-- @usage valid_protocol(server)
local function valid_protocol(server)
  if server.connection.protocol == "http" then
    return true
  else
    log:error([[protocol must be one of: http]])
  end
end

--- Checks for a valid server host.
--
-- NOTE: This regex is a best effort to follow the hostname specification in
--       RFC 1123, but it's not perfect: some labels beginning and ending with
--       a dash are allowed through, but are not permitted by the RFC.
-- @return true on a valid host, nil otherwise.
-- @usage valid_host(server)
local function valid_host(server)
  if string.match(server.connection.host, "^%w[%w%.-]+%w$") then
    return true
  else
    log:error([[Invalid host]])
  end
end

--- Checks for a valid server port.
--
-- @todo Research valid port numbers.
-- @return true on a valid port, nil otherwise.
-- @usage valid_port(server)
local function valid_port(server)
  local port = tonumber(server.connection.port)
  if port and port >= 1 and port <= 65536 then
    return true
  else
    log:error([[Invalid port]])
  end
end

--- Creates a new core server handler.
--
-- In order to talk to CouchDB, a server object must be created with the
-- proper connection parameters.
--
-- @param params
--   Optional. A table with the metadata necessary to create a new server
--   object. If a needed connection parameter is not passed
--   here, the default server setting configuration will be used instead to
--   build the server object.
-- @param params.protocol
--   The protocol to use, currently only "http" is allowed.
-- @param params.host
--   The host name, eg. "localhost" or "www.example.com".
-- @param params.port
--   The port to use, eg. "5984".
-- @param params.user
--   For authentication scenarios, the user to authenticate as.
-- @param params.password
--   For authentication scenarios, the user's password.
-- @param params.custom_request_function
--   A custom request function can be substituted for the default http.request
--   function available from luasocket. The testing framework uses this to
--   mock for unit tests.
-- @param params.custom_configuration
--   A custom configuration table can be substituted for the default one
--   available from @{luchia.conf}. The testing framework uses this to mock for
--   unit tests.
--
-- @return A new server object.
-- @usage srv = luchia.core.server:new(params)
function _M.new(self, params)
  local params = params or {}
  local settings = params.custom_configuration or conf
  local server = {}
  -- Build the connection parameters, fall back to the default server value if
  -- none is provided.
  local connection = {}
  connection.protocol = params.protocol or settings.default.server.protocol
  connection.user = params.user or settings.default.server.user
  connection.password = params.password or settings.default.server.password
  connection.host = params.host or settings.default.server.host
  connection.port = params.port or settings.default.server.port
  server.connection = connection
  if type(params.custom_request_function) == "function" then
    server.request_function = params.custom_request_function
  else
    server.request_function = http.request
  end
  local is_valid_protocol = valid_protocol(server)
  local is_valid_host = valid_host(server)
  local is_valid_port = valid_port(server)
  if is_valid_protocol and is_valid_host and is_valid_port then
    setmetatable(server, self)
    self.__index = self
    log:debug(string.format([[New core server, protocol: %s, user: %s, password: %s, host: %s, port: %s]], connection.protocol, connection.user or "", connection.password or "", connection.host, connection.port or ""))
    return server
  end
end


--- Send a request to the CouchDB server.
--
-- In order to talk to CouchDB, a server object must be created with the
-- proper connection parameters.
--
-- @param params
--   Optional. A table with the request metadata.
-- @param params.method
--   Optional. The server method, must be one of "GET", "POST", "PUT",
--   "DELETE", "HEAD", "COPY". Default is "GET".
-- @param params.path
--   Optional. The path on the server to access.
-- @param params.query_parameters
--   Optional. A table of query parameters to pass to the server, key is
--   parameter name, value is parameter value, eg.
--   '{ include_docs = "true", limit = "3" }'.
-- @param params.headers
--   Optional. A table of headers to pass to the server, eg.
--   '{ destination = "doc_id" }'.
-- @param params.parse_json_response
--   Optional. Boolean. Set to false to disable automatic parsing of the JSON
--   response from the server into a Lua table. Default is true.
-- @param params.data
--   Optional. A data object containing data to pass to the server.
-- @return The following four values, in this order: response_data,
--   response_code, headers, status_code.
-- @usage response_data, response_code, headers, status_code =
--   srv:request(params)
-- @see prepare_request
-- @see prepare_request_data
-- @see execute_request
function _M:request(params)
  self:prepare_request(params)
  self:prepare_request_data()

  log:debug(string.format([[New request, method: %s, path: %s, request_data: %s]], self.method, self.path, self.request_data or ""))

  local response_data, response_code, headers, status = self:execute_request()
  return response_data, response_code, headers, status
end


--- Prepare a request to the CouchDB server.
--
-- This method is invoked by the request method to set up the necessary
-- parameters before making a request to the CouchDB server. It should not
-- generally need to be called separately.
--
-- @param params
--   Optional. A table with the request metadata.
-- @usage srv:prepare_request(params)
-- @see request
function _M:prepare_request(params)
  params = params or {}
  self.method = params.method or "GET"
  self.path = params.path or ""
  self.query_parameters = params.query_parameters or {}
  self.headers = params.headers or {}
  self.parse_json_response = params.parse_json_response == nil and true or params.parse_json_response
  self.data = params.data
end

--- Prepare request data before sending it to the server.
--
-- The server object calls this method prior to sending a request to the
-- server. If a data object has been passed to the server, and it implements
-- the 'prepare_request_data' method, it will be called and passed the entire
-- server object, so that it may make any necessary adjustments prior to the
-- request.  In particular it should properly set the 'request_data' and
-- 'content_type' attributes on the server object to appropriate values for
-- the data being sent.
--
-- Note that the core document and attachment classes already implement this
-- method, so it should generally not need to be implemented.
--
-- @see request
function _M:prepare_request_data()
  -- Start with fresh content_type and request_data.
  self.content_type = nil
  self.request_data = nil
  if self.data and self.data.prepare_request_data then
    self.data:prepare_request_data(self)
  end
end

--- Execute a request to the CouchDB server.
--
-- This method is invoked by the request method to send a request to the
-- CouchDB server, then collect and parse the response. It should not
-- generally need to be called separately.
--
-- @return The following four values, in this order: response_data,
--   response_code, headers, status_code.
-- @usage response_data, response_code, headers, status_code =
--   srv:execute_request()
-- @see request
-- @see http_request
-- @see parse_response_data
function _M:execute_request()
  local response_body, response_code, headers, status = self:http_request()
  local response_data
  if response_body then
    log:debug([[Request executed]])
    if string.match(response_code, "20[0-6]") then
      log:debug(string.format([[Request successful, response_code: %s]], response_code))
      response_data = self:parse_response_data(response_body)
    else
      log:warn(string.format([[Request failed, response_code: %s, message: %s]], response_code, status or ""))
    end
  else
    log:error(string.format([[Unable to access server, error message: %s]], response_code))
  end
  return response_data, response_code, headers, status
end

--- Parse the response data from the CouchDB server if necessary.
--
-- @param data
--   Required. The data to parse.
-- @return The parsed data.
-- @usage parsed_data = srv:parse_response_data(data)
-- @see execute_request
-- @see parse_json
function _M:parse_response_data(data)
  local parsed_data
  if self.parse_json_response then
    parsed_data = self:parse_json(data)
  else
    parsed_data = data
  end
  return parsed_data
end

--- Parse a JSON string.
--
-- @param json_string
--   Required. The JSON string to parse.
-- @return The parsed JSON string, converted to a Lua table.
-- @usage srv:parse_json('{"key": "value"}')
-- @see parse_response_data
function _M:parse_json(json_string)
  if json_string and json_string ~= "" then
    log:debug(string.format([[JSON to parse: %s]], json_string))
    -- Invalid JSON causes an error, so wrap the parsing in a protected call.
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
  else
    log:debug([[No JSON to parse]])
  end
end

--- Make an HTTP request to the server.
--
-- This is the low level method to make a server request, and should generally
-- not be used.
--
-- @return The following four values, in this order: response_data,
--   response_code, headers, status_code.
-- @usage response_data, response_code, headers, status_code =
--   srv:http_request()
-- @see execute_request
-- @see build_url
function _M:http_request()
  local source = nil
  local headers = self.headers

  if self.request_data then
    source = ltn12.source.string(self.request_data)
    headers["content-type"] = self.content_type
    headers["content-length"] = self.request_data:len()
  end

  local result = {}
  local response, response_code, headers, status = self.request_function {
    method = self.method,
    url = self:build_url(),
    sink = ltn12.sink.table(result),
    source = source,
    headers = headers
  }

  local response_data
  if response then
    response_data = table.concat(result)
  end

  return response_data, response_code, headers, status
end

--- Builds a URL based on the server connection object, the request path,
-- and the request parameters.
--
-- @return A URL string.
-- @see http_request
-- @see stringify_parameters
function _M:build_url()

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

--- Builds a query string from a Lua table of query parameters.
--
-- @param params
--   Optional. A table of query parameters, key is parameter name, value is
--   parameter value. If not provided, the query_parameters attribute on the
--   server object is used.
-- @return The query string.
-- @usage srv:stringify_parameters({ include_docs = "true", limit = "3" })
-- @see build_url
function _M:stringify_parameters(params)
  params = params or self.query_parameters or {}
  local parameter_string = ""
  -- It's not strictly necessary to sort query parameters, but doing so is
  -- fast and allows for more simple and consistent tests.
  local sorted = {}
  for k in pairs(params) do
    table.insert(sorted, k)
  end
  table.sort(sorted)
  for i, name in ipairs(sorted) do
    parameter_string = string.format("%s&%s=%s", parameter_string, url.escape(name), url.escape(params[name]))
  end

  -- Remove leading ampersand.
  parameter_string = parameter_string:sub(2)
  log:debug(string.format([[Built query parameters: %s]], parameter_string));
  return parameter_string
end

--- Retrieve uuids from the CouchDB server.
--
-- This provides a convenient way to get random unique identifiers from the
-- server itself if no other facility is available to generate them.
--
-- @param count
--   Optional. The number of uuids to generate, default is 1.
-- @return A list of uuids.
-- @usage srv:uuids(10)
function _M:uuids(count)
  local params = {
    path = "_uuids",
  }
  if count then
    params.query_parameters = {}
    params.query_parameters.count = count
  end
  local response = self:request(params)
  if response and response.uuids then
    return response.uuids
  end
end

--- Check the response for success.
--
-- A convenience method to ensure a successful request.
--
-- @param response
--   Required. The response object returned from the server request.
-- @return true if the server responsed with an ok:true, false otherwise.
-- @usage operation_succeeded = srv:response_ok(response)
function _M:response_ok(response)
  return response and response.ok and response.ok == true
end

return _M
