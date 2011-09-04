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
local custom_request_function = function() end

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

function tests.setup()
  common.conf_valid_default_server_table()
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
    custom_request_function = custom_request_function,
  }
  local srv = server:new(params)
  valid_server_table(srv)
  assert_equal(good_protocol, srv.connection.protocol, "srv.connection.protocol")
  assert_equal(good_host, srv.connection.host, "srv.connection.host")
  assert_equal(good_port, srv.connection.port, "srv.connection.port")
  assert_equal(user, srv.connection.user, "srv.connection.user")
  assert_equal(password, srv.connection.password, "srv.connection.password")
  assert_equal(5, common.table_length(srv.connection), "srv.connection length")
  assert_equal(custom_request_function, srv.request_function, "custom srv.request_function")
end

return tests

