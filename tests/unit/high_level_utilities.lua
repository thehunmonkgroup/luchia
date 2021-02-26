local lunatest = require "lunatest"
local assert_equal = lunatest.assert_equal
local assert_function = lunatest.assert_function
local assert_table = lunatest.assert_table

local common = require "common_test_functions"
local utilities = require "luchia.utilities"

-- Server.
local good_protocol = common.server_good_protocol
local good_host = common.server_good_host
local good_port = common.server_good_port
local request_function = common.server_request
local conf = {
  default = {
    server = {
      protocol = good_protocol,
      host = good_host,
      port = good_port,
    },
  },
}

local version = common.utility.version

local tests = {}

local function new_with_default_server_params()
  local params = {
    custom_configuration = conf,
    custom_request_function = request_function,
  }
  local util = utilities:new(params)
  assert_table(util, "util")
  return util
end

function tests.test_new_with_default_server_params_returns_valid_server()
  local util = new_with_default_server_params()
  assert_table(util.server, "util.server")
  assert_function(util.server.request, "util.server:request")
end

function tests.test_new_with_default_server_params_returns_only_server()
  local util = new_with_default_server_params()
  assert_equal(1, common.table_length(util), "util length")
end

local function new_with_custom_server_params()
  local util = utilities:new(conf.default.server)
  assert_table(util, "util")
  return util
end

function tests.test_new_with_custom_server_params_returns_valid_server()
  local util = new_with_custom_server_params()
  assert_table(util.server, "util.server")
  assert_function(util.server.request, "util.server:request")
end

function tests.test_new_with_custom_server_params_returns_only_server()
  local util = new_with_custom_server_params()
  assert_equal(1, common.table_length(util), "util length")
end

function tests.test_version_returns_version()
  local util = new_with_default_server_params()
  local response, response_code, headers, status = util:version()
  assert_equal(response, version)
end

function tests.test_config_default_node_returns_config()
  local util = new_with_default_server_params()
  local response, response_code, headers, status = util:config()
  assert_equal(response.httpd.port, good_port)
end

function tests.test_config_passed_node_returns_config()
  local util = new_with_default_server_params()
  local response, response_code, headers, status = util:config(common.server_node)
  assert_equal(response.httpd.port, good_port)
end

function tests.test_stats_default_node_returns_stats()
  local util = new_with_default_server_params()
  local response, response_code, headers, status = util:stats()
  assert_equal(response.httpd_status_codes["404"].description, "number of HTTP 404 Not Found responses")
end

function tests.test_stats_passed_node_returns_stats()
  local util = new_with_default_server_params()
  local response, response_code, headers, status = util:stats(common.server_node)
  assert_equal(response.httpd_status_codes["404"].description, "number of HTTP 404 Not Found responses")
end

function tests.test_active_tasks_returns_active_tasks()
  local util = new_with_default_server_params()
  local response, response_code, headers, status = util:active_tasks()
  assert_equal(#response, 0)
end

return tests

