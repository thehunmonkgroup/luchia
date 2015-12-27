local lunatest = require "lunatest"
local assert_equal = lunatest.assert_equal
local assert_function = lunatest.assert_function
local assert_table = lunatest.assert_table

local common = require "common_test_functions"
local database = require "luchia.database"

local good_protocol = common.server_good_protocol
local good_host = common.server_good_host
local good_port = common.server_good_port
local user = common.server_user
local password = common.server_password
local request_function = common.server_request
local example_database = common.server_example_database
local conf = {
  default = {
    server = {
      protocol = good_protocol,
      host = good_host,
      port = good_port,
    },
  },
}

local tests = {}

local function new_with_default_server_params()
  local params = {
    custom_configuration = conf,
    custom_request_function = request_function,
  }
  local db = database:new(params)
  assert_table(db, "db")
  return db
end

function tests.test_new_with_default_server_params_returns_valid_server()
  local db = new_with_default_server_params()
  assert_table(db.server, "db.server")
  assert_function(db.server.request, "db.server:request")
end

function tests.test_new_with_default_server_params_returns_only_server()
  local db = new_with_default_server_params()
  assert_equal(1, common.table_length(db), "db length")
end

local function new_with_custom_server_params()
  local db = database:new(conf.default.server)
  assert_table(db, "db")
  return db
end

function tests.test_new_with_custom_server_params_returns_valid_server()
  local db = new_with_custom_server_params()
  assert_table(db.server, "db.server")
  assert_function(db.server.request, "db.server:request")
end

function tests.test_new_with_custom_server_params_returns_only_server()
  local db = new_with_custom_server_params()
  assert_equal(1, common.table_length(db), "db length")
end

function tests.test_list_databases_returns_valid_list()
  local db = new_with_default_server_params()
  local response, response_code, headers, status = db:list()
  assert_table(response)
end

function tests.test_info_with_database_name_returns_valid_database_info()
  local db = new_with_default_server_params()
  local response, response_code, headers, status = db:info(example_database)
  assert_table(response)
  assert_equal(response.db_name, example_database)
end

function tests.test_info_with_no_database_name_returns_nil()
  local db = new_with_default_server_params()
  local response, response_code, headers, status = db:info()
  assert_equal(response, nil)
end

function tests.test_create_with_database_name_returns_valid_response()
  local db = new_with_default_server_params()
  local response, response_code, headers, status = db:create(example_database)
  assert_table(response)
  assert_equal(response.ok, true)
end

function tests.test_create_with_no_database_name_returns_nil()
  local db = new_with_default_server_params()
  local response, response_code, headers, status = db:create()
  assert_equal(response, nil)
end

function tests.test_delete_with_database_name_returns_valid_response()
  local db = new_with_default_server_params()
  local response, response_code, headers, status = db:delete(example_database)
  assert_table(response)
  assert_equal(response.ok, true)
end

function tests.test_delete_with_no_database_name_returns_nil()
  local db = new_with_default_server_params()
  local response, response_code, headers, status = db:delete()
  assert_equal(response, nil)
end

function tests.test_response_ok_with_ok_response_returns_true()
  local db = new_with_default_server_params()
  local response = {ok = true}
  local bool = db:response_ok(response)
  assert_equal(bool, true)
end

function tests.test_response_ok_with_not_ok_response_returns_false()
  local db = new_with_default_server_params()
  local response = {ok = false}
  local bool = db:response_ok(response)
  assert_equal(bool, false)
end

return tests

