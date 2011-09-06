local common = require "luchia.tests.common"
local server = require "luchia.core.server"

local tests = {}

local good_protocol = "http"
local good_host = "www.example.com"
local good_port = "5984"
local bad_protocol = "ftp"
local bad_host = "www;example;com"
local bad_port_high = "70000"
local bad_port_low = "0"
local bad_port_nan = "foo"
local user = "user"
local password = "password"
local path = "example/foo"
local query_parameters = {
  include_docs = "true",
  limit = "3",
}
local query_string = "include_docs=true&limit=3"

local content_type = "application/json"
local json_good = '{"foo":"bar"}'
local json_good_key = "foo"
local json_good_value = "bar"
local json_bad = 'foo'

local uuid1 = "1c10da9e7736fc84bbb380fd1f002554"
local uuid2 = "1c10da9e7736fc84bbb380fd1f0026b8"

local function valid_server_table(srv)
  assert_table(srv, "srv")
  assert_table(srv.connection, "srv.connection")
  assert_equal(2, common.table_length(srv), "srv length")
end

local function bad_server_param(protocol, host, port)
  local params = {
    protocol = protocol,
    host = host,
    port = port,
  }
  local srv = server:new(params)
  assert_equal(nil, srv, "srv")
end

local function request_function(request)
  local url_string = string.format([[%s://%s:%s]], good_protocol, good_host, good_port)
  local response_data = ""
  local response_code = "200"
  local headers = {}
  local status = "HTTP/1.1 200 OK"

  local uuids = url_string .. "/_uuids?"
  local uuids_with_count = url_string .. "/_uuids?count=2"
  local uuids_bad = url_string .. "/_uuids?count=bad"

  if request.url == uuids then
    response_data = '{"uuids":["' .. uuid1 .. '"]}'
  elseif request.url == uuids_with_count then
    response_data = '{"uuids":["' .. uuid1 .. '","' .. uuid2 .. '"]}'
  elseif request.url == uuids_bad then
    response_data = '{}'
  end

  local source = ltn12.source.string(response_data)
  ltn12.pump.all(source, request.sink)

  return 1, response_code, headers, status
end

local function custom_request_server(params)
  params = params or {
    protocol = good_protocol,
    host = good_host,
    port = good_port,
  }
  params.custom_request_function = request_function
  local srv = server:new(params)
  valid_server_table(srv)
  return srv
end

local function prepare_request(self, server)
  server.content_type = content_type
  server.request_data = json_good
end

function tests.test_core_server_new_bad_protocol()
  bad_server_param(bad_protocol, good_host, good_port)
end

function tests.test_core_server_new_bad_host()
  bad_server_param(good_protocol, bad_host, good_port)
end

function tests.test_core_server_new_bad_port_low()
  bad_server_param(good_protocol, good_host, bad_port_low)
end

function tests.test_core_server_new_bad_port_high()
  bad_server_param(good_protocol, good_host, bad_port_high)
end

function tests.test_core_server_new_bad_port_nan()
  bad_server_param(good_protocol, good_host, bad_port_nan)
end

function tests.test_core_server_new_no_params()
  common.conf_valid_default_server_table()
  local conf = require "luchia.conf"
  local http = require "socket.http"
  local srv = server:new()
  valid_server_table(srv)
  assert_equal(conf.default.server.protocol, srv.connection.protocol, "srv.connection.protocol")
  assert_equal(conf.default.server.host, srv.connection.host, "srv.connection.host")
  assert_equal(conf.default.server.port, srv.connection.port, "srv.connection.port")
  assert_equal(conf.default.server.user, srv.connection.user, "srv.connection.user")
  assert_equal(conf.default.server.password, srv.connection.password, "srv.connection.password")
  assert_gte(3, common.table_length(srv.connection), "srv.connection length")
  assert_lte(5, common.table_length(srv.connection), "srv.connection length")
  assert_equal(http.request, srv.request_function, "default srv.request_function")
end

function tests.test_core_server_new_all_params()
  local params = {
    protocol = good_protocol,
    host = good_host,
    port = good_port,
    user = user,
    password = password,
    custom_request_function = request_function,
  }
  local srv = server:new(params)
  valid_server_table(srv)
  assert_equal(good_protocol, srv.connection.protocol, "srv.connection.protocol")
  assert_equal(good_host, srv.connection.host, "srv.connection.host")
  assert_equal(good_port, srv.connection.port, "srv.connection.port")
  assert_equal(user, srv.connection.user, "srv.connection.user")
  assert_equal(password, srv.connection.password, "srv.connection.password")
  assert_equal(5, common.table_length(srv.connection), "srv.connection length")
  assert_equal(request_function, srv.request_function, "custom srv.request_function")
end

function tests.test_core_server_prepare_request_reset_content_type()
  local srv = custom_request_server()
  srv.content_type = content_type
  srv:prepare_request()
  assert_equal(nil, srv.content_type, "srv.content_type")
end

function tests.test_core_server_prepare_request_reset_request_data()
  local srv = custom_request_server()
  srv.request_data = request_data
  srv:prepare_request()
  assert_equal(nil, srv.request_data, "srv.request_data")
end

function tests.test_core_server_prepare_request_set_content_type()
  local srv = custom_request_server()
  srv.data = {
    prepare_request = prepare_request,
  }
  srv:prepare_request()
  assert_equal(content_type, srv.content_type, "srv.content_type")
end

function tests.test_core_server_prepare_request_set_request_data()
  local srv = custom_request_server()
  srv.data = {
    prepare_request = prepare_request,
  }
  srv:prepare_request()
  assert_equal(json_good, srv.request_data, "srv.request_data")
end

function tests.test_core_server_parse_json_nil()
  local srv = custom_request_server()
  local result = srv:parse_json()
  assert_equal(nil, result, "result")
end

function tests.test_core_server_parse_json_empty()
  local srv = custom_request_server()
  local result = srv:parse_json("")
  assert_equal(nil, result, "result")
end

function tests.test_core_server_parse_json_bad()
  local srv = custom_request_server()
  local result = srv:parse_json(json_bad)
  assert_false(result, "result")
end

function tests.test_core_server_parse_json_good()
  local srv = custom_request_server()
  local result = srv:parse_json(json_good)
  assert_table(result, "result")
  assert_equal(result[json_good_key], json_good_value, "result")
  assert_equal(1, common.table_length(result), "result")
end

function tests.test_core_server_build_url()
  local params = {
    protocol = good_protocol,
    host = good_host,
    port = good_port,
    user = user,
    password = password,
  }
  local srv = custom_request_server(params)
  srv.path = path
  srv.query_parameters = query_parameters
  local result = srv:build_url()
  local full_url = string.format([[%s://%s:%s@%s:%s/%s?%s]], good_protocol, user, password, good_host, good_port, path, query_string)
  assert_equal(full_url, result, "result")
end

function tests.test_core_server_stringify_parameters_empty()
  local srv = custom_request_server()
  local result = srv:stringify_parameters()
  assert_equal("", result, "result")
end

function tests.test_core_server_stringify_parameters_server_attribute()
  local srv = custom_request_server()
  srv.query_parameters = query_parameters
  local result = srv:stringify_parameters()
  assert_equal(query_string, result, "result")
end

function tests.test_core_server_stringify_parameters_server_argument()
  local srv = custom_request_server()
  local result = srv:stringify_parameters(query_parameters)
  assert_equal(query_string, result, "result")
end

function tests.test_core_server_uuids_no_param()
  local srv = custom_request_server()
  local result = srv:uuids()
  assert_table(result, "result")
  assert_equal(1, #result, "result")
  assert_equal(uuid1, result[1], "result")
end

function tests.test_core_server_uuids_count_2()
  local srv = custom_request_server()
  local result = srv:uuids(2)
  assert_table(result, "result")
  assert_equal(2, #result, "result")
  assert_equal(uuid1, result[1], "result")
  assert_equal(uuid2, result[2], "result")
end

function tests.test_core_server_uuids_count_bad()
  local srv = custom_request_server()
  local result = srv:uuids("bad")
  assert_equal(nil, result, "result")
end

function tests.test_core_server_response_ok()
  local srv = custom_request_server()
  local response = {ok = true}
  local result = srv:response_ok(response)
  assert_true(result, "result")
end

function tests.test_core_server_response_ok_false()
  local srv = custom_request_server()
  local response = {ok = false}
  local result = srv:response_ok(response)
  assert_false(result, "result")
end

function tests.test_core_server_response_ok_empty()
  local srv = custom_request_server()
  local response = {}
  local result = srv:response_ok(response)
  assert_equal(nil, result, "result")
end

function tests.test_core_server_response_ok_nil()
  local srv = custom_request_server()
  local response = nil
  local result = srv:response_ok(response)
  assert_equal(nil, result, "result")
end

return tests

