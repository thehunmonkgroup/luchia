local lunatest = require "lunatest"
local assert_equal = lunatest.assert_equal
local assert_function = lunatest.assert_function
local assert_table = lunatest.assert_table

local common = require "common_test_functions"
local document = require "luchia.document"

local good_protocol = common.server_good_protocol
local good_host = common.server_good_host
local good_port = common.server_good_port
local user = common.server_user
local password = common.server_password
local request_function = common.server_request
local database_name = common.server_example_database
local document_id = common.server_example_document_id
local document_rev = common.server_example_document_rev
local uuid1 = common.server_uuid1
local uuid2 = common.server_uuid2
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

function tests.test_new_no_database_returns_nil()
  local doc = document:new()
  assert_equal(nil, doc)
end

local function new_with_default_server_params()
  local params = {
    custom_configuration = conf,
    custom_request_function = request_function,
  }
  local doc = document:new(database_name, params)
  assert_table(doc, "doc")
  return doc
end

function tests.test_new_with_default_server_params_returns_valid_database_name()
  local doc = new_with_default_server_params()
  assert_equal(database_name, doc.database)
end

function tests.test_new_with_default_server_params_returns_valid_server()
  local doc = new_with_default_server_params()
  assert_table(doc.server, "doc.server")
  assert_function(doc.server.request, "doc.server:request")
end

function tests.test_new_with_default_server_params_returns_only_database_and_server()
  local doc = new_with_default_server_params()
  assert_equal(2, common.table_length(doc), "doc length")
end

local function new_with_custom_server_params()
  local doc = document:new(database_name, conf.default.server)
  assert_table(doc, "doc")
  return doc
end

function tests.test_new_with_custom_server_params_returns_valid_database_name()
  local doc = new_with_custom_server_params()
  assert_equal(database_name, doc.database)
end

function tests.test_new_with_custom_server_params_returns_valid_server()
  local doc = new_with_custom_server_params()
  assert_table(doc.server, "doc.server")
  assert_function(doc.server.request, "doc.server:request")
end

function tests.test_new_with_custom_server_params_returns_only_database_and_server()
  local doc = new_with_custom_server_params()
  assert_equal(2, common.table_length(doc), "doc length")
end

function tests.test_list_documents_returns_valid_list()
  local doc = new_with_default_server_params()
  local response, response_code, headers, status = doc:list()
  assert_table(response)
  assert_equal(response.total_rows, 0)
end

function tests.test_list_documents_with_limit_returns_valid_list()
  local doc = new_with_default_server_params()
  local query_parameters = {
    limit = "3",
  }
  local response, response_code, headers, status = doc:list(query_parameters)
  assert_table(response)
  assert_equal(response.total_rows, 0)
end

function tests.test_retrieve_document_returns_valid_data()
  local doc = new_with_default_server_params()
  local response, response_code, headers, status = doc:retrieve(document_id)
  assert_table(response)
  assert_equal(response._id, document_id)
end

function tests.test_retrieve_document_with_limit_returns_valid_list()
  local doc = new_with_default_server_params()
  local query_parameters = {
    limit = "3",
  }
  local response, response_code, headers, status = doc:retrieve(document_id, query_parameters)
  assert_table(response)
  assert_equal(response._id, document_id)
end

function tests.test_retrieve_document_no_id_returns_nil()
  local doc = new_with_default_server_params()
  local response, response_code, headers, status = doc:retrieve()
  assert_equal(response, nil)
end

function tests.test_create_document_no_id_returns_success()
  local doc = new_with_default_server_params()
  local data = {}
  local response, response_code, headers, status = doc:create(data)
  assert_table(response)
  assert_equal(response.ok, true)
end

function tests.test_create_document_with_id_returns_success()
  local doc = new_with_default_server_params()
  local data = {}
  local response, response_code, headers, status = doc:create(data, uuid2)
  assert_table(response)
  assert_equal(response.ok, true)
end

function tests.test_create_document_no_document_returns_nil()
  local doc = new_with_default_server_params()
  local response, response_code, headers, status = doc:create()
  assert_equal(response, nil)
end

function tests.test_update_document_returns_success()
  local doc = new_with_default_server_params()
  local data = {}
  local rev = document_rev
  local response, response_code, headers, status = doc:update(data, document_id, rev)
  assert_table(response)
  assert_equal(response.ok, true)
end

function tests.test_update_document_no_document_returns_nil()
  local doc = new_with_default_server_params()
  local rev = document_rev
  local response, response_code, headers, status = doc:update(nil, document_id, rev)
  assert_equal(response, nil)
end

function tests.test_update_document_no_id_returns_nil()
  local doc = new_with_default_server_params()
  local data = {}
  local rev = document_rev
  local response, response_code, headers, status = doc:update(data, nil, rev)
  assert_equal(response, nil)
end

function tests.test_update_document_no_rev_returns_nil()
  local doc = new_with_default_server_params()
  local data = {}
  local response, response_code, headers, status = doc:update(data, document_id, nil)
  assert_equal(response, nil)
end

function tests.test_copy_document_returns_success()
  local doc = new_with_default_server_params()
  local destination = document_id .. "2"
  local response, response_code, headers, status = doc:copy(document_id, destination)
  assert_table(response)
  assert_equal(response.ok, true)
end

function tests.test_copy_document_no_id_returns_nil()
  local doc = new_with_default_server_params()
  local destination = document_id .. "2"
  local response, response_code, headers, status = doc:copy(nil, destination)
  assert_equal(response, nil)
end

function tests.test_copy_document_no_destination_returns_nil()
  local doc = new_with_default_server_params()
  local response, response_code, headers, status = doc:copy(document_id, nil)
  assert_equal(response, nil)
end

function tests.test_delete_document_returns_success()
  local doc = new_with_default_server_params()
  local response, response_code, headers, status = doc:delete(document_id, document_rev)
  assert_table(response)
  assert_equal(response.ok, true)
end

function tests.test_delete_document_no_id_returns_nil()
  local doc = new_with_default_server_params()
  local response, response_code, headers, status = doc:delete(nil, document_rev)
  assert_equal(response, nil)
end

function tests.test_delete_document_no_rev_returns_nil()
  local doc = new_with_default_server_params()
  local response, response_code, headers, status = doc:delete(document_id, nil)
  assert_equal(response, nil)
end

function tests.test_info_document_returns_success()
  local doc = new_with_default_server_params()
  local headers = doc:info(document_id)
  assert_equal(headers.etag, document_id)
end

function tests.test_info_document_no_id_returns_nil()
  local doc = new_with_default_server_params()
  local headers = doc:info()
  assert_equal(headers, nil)
end

return tests

