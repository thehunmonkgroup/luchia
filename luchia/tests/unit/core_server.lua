local common = require "luchia.tests.common"
local server = require "luchia.core.server"

local tests = {}

local good_protocol = "http"
local good_host = "www.example.com"
local good_port = "5984"
local user = "user"
local password = "password"
local conf = {
  default = {
    server = {
      protocol = good_protocol,
      host = good_host,
      port = good_port,
      user = user,
      password = password,
    },
  },
}

local bad_protocol = "ftp"
local bad_host = "www;example;com"
local bad_port_high = "70000"
local bad_port_low = "0"
local bad_port_nan = "foo"

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

local function prepare_request_data(self, server)
  server.content_type = content_type
  server.request_data = json_good
end

function tests.test_new_bad_protocol_returns_nil()
  bad_server_param(bad_protocol, good_host, good_port)
end

function tests.test_new_bad_host_returns_nil()
  bad_server_param(good_protocol, bad_host, good_port)
end

function tests.test_new_bad_port_low_returns_nil()
  bad_server_param(good_protocol, good_host, bad_port_low)
end

function tests.test_new_bad_port_high_returns_nil()
  bad_server_param(good_protocol, good_host, bad_port_high)
end

function tests.test_new_bad_port_nan_returns_nil()
  bad_server_param(good_protocol, good_host, bad_port_nan)
end

local function new_server_default_params()
  local params = {
    custom_default_server = conf,
  }
  local srv = server:new(params)
  valid_server_table(srv)
  return srv
end

function tests.test_new_default_params_returns_valid_connection_protocol()
  local srv = new_server_default_params()
  assert_equal(conf.default.server.protocol, srv.connection.protocol)
end

function tests.test_new_default_params_returns_valid_connection_host()
  local srv = new_server_default_params()
  assert_equal(conf.default.server.host, srv.connection.host)
end

function tests.test_new_default_params_returns_valid_connection_port()
  local srv = new_server_default_params()
  assert_equal(conf.default.server.port, srv.connection.port)
end

function tests.test_new_default_params_returns_valid_connection_user()
  local srv = new_server_default_params()
  assert_equal(conf.default.server.user, srv.connection.user)
end

function tests.test_new_default_params_returns_valid_connection_password()
  local srv = new_server_default_params()
  assert_equal(conf.default.server.password, srv.connection.password)
end

function tests.test_new_default_params_returns_valid_connection_table_length()
  local srv = new_server_default_params()
  assert_equal(5, common.table_length(srv.connection), "srv.connection length")
end

function tests.test_new_default_request_function_returns_default_request_function()
  local http = require "socket.http"
  local params = {
    custom_default_server = conf,
  }
  local srv = server:new(params)
  valid_server_table(srv)
  assert_equal(http.request, srv.request_function)
end

function tests.test_new_custom_request_function_returns_custom_request_function()
  local params = {
    custom_default_server = conf,
    custom_request_function = request_function,
  }
  local srv = server:new(params)
  valid_server_table(srv)
  assert_equal(request_function, srv.request_function)
end

local function new_server_all_params()
  local params = {
    protocol = good_protocol,
    host = good_host,
    port = good_port,
    user = user,
    password = password,
  }
  local srv = server:new(params)
  valid_server_table(srv)
  return srv
end

function tests.test_new_all_params_returns_valid_connection_protocol()
  local srv = new_server_all_params()
  assert_equal(good_protocol, srv.connection.protocol)
end

function tests.test_new_all_params_returns_valid_connection_host()
  local srv = new_server_all_params()
  assert_equal(good_host, srv.connection.host)
end

function tests.test_new_all_params_returns_valid_connection_port()
  local srv = new_server_all_params()
  assert_equal(good_port, srv.connection.port)
end

function tests.test_new_all_params_returns_valid_connection_user()
  local srv = new_server_all_params()
  assert_equal(user, srv.connection.user)
end

function tests.test_new_all_params_returns_valid_connection_password()
  local srv = new_server_all_params()
  assert_equal(password, srv.connection.password)
end

function tests.test_new_all_params_returns_valid_connection_table_length()
  local srv = new_server_all_params()
  assert_equal(5, common.table_length(srv.connection), "srv.connection length")
end

function tests.test_prepare_request_data_no_content_type_resets_content_type()
  local srv = custom_request_server()
  srv.content_type = content_type
  srv:prepare_request_data()
  assert_equal(nil, srv.content_type)
end

function tests.test_prepare_request_data_no_data_resets_request_data()
  local srv = custom_request_server()
  srv.request_data = request_data
  srv:prepare_request_data()
  assert_equal(nil, srv.request_data)
end

function tests.test_prepare_request_data_set_content_type_sets_content_type()
  local srv = custom_request_server()
  srv.data = {
    prepare_request_data = prepare_request_data,
  }
  srv:prepare_request_data()
  assert_equal(content_type, srv.content_type)
end

function tests.test_prepare_request_data_set_request_data_sets_server_request_data()
  local srv = custom_request_server()
  srv.data = {
    prepare_request_data = prepare_request_data,
  }
  srv:prepare_request_data()
  assert_equal(json_good, srv.request_data)
end

local function get_parsed_json(json_string)
  local srv = custom_request_server()
  local result = srv:parse_json(json_string)
  return result
end

function tests.test_parse_json_nil_returns_nil()
  local result = get_parsed_json(nil)
  assert_equal(nil, result)
end

function tests.test_parse_json_empty_string_returns_nil()
  local result = get_parsed_json("")
  assert_equal(nil, result)
end

function tests.test_parse_json_bad_json_returns_false()
  local result = get_parsed_json(json_bad)
  assert_false(result)
end

function tests.test_parse_json_good_json_returns_result()
  local result = get_parsed_json(json_good)
  assert_table(result)
end

function tests.test_parse_json_good_json_returns_correct_key_value()
  local result = get_parsed_json(json_good)
  assert_equal(result[json_good_key], json_good_value)
end

function tests.test_parse_json_good_json_returns_one_key_value()
  local result = get_parsed_json(json_good)
  assert_equal(1, common.table_length(result))
end

function tests.test_build_url_all_valid_params_returns_full_url()
  local params = {
    protocol = good_protocol,
    host = good_host,
    port = good_port,
    user = user,
    password = password,
  }
  local srv = custom_request_server(params)
  local params = {
    path = path,
    query_parameters = query_parameters,
  }
  srv:prepare_request(params)
  local result = srv:build_url()
  local full_url = string.format([[%s://%s:%s@%s:%s/%s?%s]], good_protocol, user, password, good_host, good_port, path, query_string)
  assert_equal(full_url, result)
end

function tests.test_stringify_parameters_no_parameters_returns_empty_string()
  local srv = custom_request_server()
  local result = srv:stringify_parameters()
  assert_equal("", result)
end

function tests.test_stringify_parameters_with_server_attribute_returns_stringified_server_attribute()
  local srv = custom_request_server()
  local params = {
    query_parameters = query_parameters,
  }
  srv:prepare_request(params)
  local result = srv:stringify_parameters()
  assert_equal(query_string, result)
end

function tests.test_stringify_parameters_with_argument_returns_stringified_argument()
  local srv = custom_request_server()
  local result = srv:stringify_parameters(query_parameters)
  assert_equal(query_string, result)
end

local function get_uuids(count)
  local srv = custom_request_server()
  local result = srv:uuids(count)
  return result
end

function tests.test_uuids_no_param_returns_result()
  local result = get_uuids()
  assert_table(result)
end

function tests.test_uuids_no_param_returns_one_uuid()
  local result = get_uuids()
  assert_equal(1, #result)
end

function tests.test_uuids_no_param_returns_valid_uuid()
  local result = get_uuids()
  assert_equal(uuid1, result[1])
end

function tests.test_uuids_count_2_returns_result()
  local result = get_uuids(2)
  assert_table(result)
end

function tests.test_uuids_count_2_returns_2_uuids()
  local result = get_uuids(2)
  assert_equal(2, #result)
end

function tests.test_uuids_count_2_returns_valid_uuid1()
  local result = get_uuids(2)
  assert_equal(uuid1, result[1])
end

function tests.test_uuids_count_2_returns_valid_uuid2()
  local result = get_uuids(2)
  assert_equal(uuid2, result[2])
end

function tests.test_uuids_count_non_numeric_returns_nil()
  local result = get_uuids("string")
  assert_equal(nil, result)
end

local function get_response_ok(response)
  local srv = custom_request_server()
  local result = srv:response_ok(response)
  return result
end

function tests.test_response_ok_true_returns_true()
  local result = get_response_ok({ok = true})
  assert_true(result)
end

function tests.test_response_ok_false_returns_false()
  local result = get_response_ok({ok = false})
  assert_false(result)
end

function tests.test_response_ok_empty_returns_nil()
  local result = get_response_ok({})
  assert_equal(nil, result)
end

function tests.test_response_ok_nil_returns_nil()
  local result = get_response_ok(nil)
  assert_equal(nil, result)
end

return tests

