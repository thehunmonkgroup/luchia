local lunatest = require "lunatest"
local assert_equal = lunatest.assert_equal
local assert_function = lunatest.assert_function
local assert_table = lunatest.assert_table

local common = require "common_test_functions"
local document = require "luchia.document"

-- Server.
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

-- Attachment.
local text_content_type = common.attachment.text_content_type
local custom_file_name = common.attachment.custom_file_name
local custom_loader_default_file_name = common.attachment.custom_loader_default_file_name
local custom_loader_file_path = common.attachment.custom_loader_file_path
local custom_loader_file_data = common.attachment.custom_loader_file_data
local custom_loader_function = common.attachment.custom_loader

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
  local response, response_code, headers, status = doc:update(data, document_id, document_rev)
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

function tests.test_document_info_returns_success()
  local doc = new_with_default_server_params()
  local headers = doc:info(document_id)
  assert_equal(headers.etag, document_rev)
end

function tests.test_document_info_no_id_returns_nil()
  local doc = new_with_default_server_params()
  local headers = doc:info()
  assert_equal(headers, nil)
end

function tests.test_document_current_revision_returns_success()
  local doc = new_with_default_server_params()
  local rev = doc:current_revision(document_id)
  assert_equal(rev, document_rev)
end

function tests.test_document_current_revision_no_id_returns_nil()
  local doc = new_with_default_server_params()
  local rev = doc:current_revision()
  assert_equal(rev, nil)
end

function tests.test_document_add_standalone_attachment_no_file_name_returns_success()
  local doc = new_with_default_server_params()
  local response, response_code, headers, status = doc:add_standalone_attachment(custom_loader_file_path, text_content_type, nil, document_id, document_rev, custom_loader_function)
  assert_table(response)
  assert_equal(response.ok, true)
end

function tests.test_document_add_standalone_attachment_with_file_name_returns_success()
  local doc = new_with_default_server_params()
  local response, response_code, headers, status = doc:add_standalone_attachment(custom_loader_file_path, text_content_type, custom_file_name, document_id, document_rev, custom_loader_function)
  assert_table(response)
  assert_equal(response.ok, true)
end

function tests.test_document_add_standalone_attachment_no_id_no_rev_returns_success()
  local doc = new_with_default_server_params()
  local response, response_code, headers, status = doc:add_standalone_attachment(custom_loader_file_path, text_content_type, nil, nil, nil, custom_loader_function)
  assert_table(response)
  assert_equal(response.ok, true)
end

function tests.test_document_add_standalone_attachment_no_file_path_returns_nil()
  local doc = new_with_default_server_params()
  local response, response_code, headers, status = doc:add_standalone_attachment(nil, text_content_type, nil, document_id, document_rev)
  assert_equal(response, nil)
end

function tests.test_document_add_standalone_attachment_no_content_type_returns_nil()
  local doc = new_with_default_server_params()
  local response, response_code, headers, status = doc:add_standalone_attachment(custom_loader_file_path, nil, nil, document_id, document_rev)
  assert_equal(response, nil)
end

function tests.test_document_add_inline_attachment_no_file_name_returns_success()
  local doc = new_with_default_server_params()
  local data = {}
  local response, response_code, headers, status = doc:add_inline_attachment(custom_loader_file_path, text_content_type, nil, data, document_id, document_rev, custom_loader_function)
  assert_table(response)
  assert_equal(response.ok, true)
end

function tests.test_document_add_inline_attachment_with_file_name_returns_success()
  local doc = new_with_default_server_params()
  local data = {}
  local response, response_code, headers, status = doc:add_inline_attachment(custom_loader_file_path, text_content_type, custom_file_name, data, document_id, document_rev, custom_loader_function)
  assert_table(response)
  assert_equal(response.ok, true)
end

function tests.test_document_add_inline_attachment_no_id_no_rev_returns_success()
  local doc = new_with_default_server_params()
  local data = {}
  local response, response_code, headers, status = doc:add_inline_attachment(custom_loader_file_path, text_content_type, nil, data, nil, nil, custom_loader_function)
  assert_table(response)
  assert_equal(response.ok, true)
end

function tests.test_document_add_inline_attachment_no_id_with_rev_returns_nil()
  local doc = new_with_default_server_params()
  local data = {}
  local response, response_code, headers, status = doc:add_inline_attachment(custom_loader_file_path, text_content_type, nil, data, nil, document_rev)
  assert_equal(response, nil)
end

function tests.test_document_add_inline_attachment_no_file_path_returns_nil()
  local doc = new_with_default_server_params()
  local data = {}
  local response, response_code, headers, status = doc:add_inline_attachment(nil, text_content_type, nil, data, document_id, document_rev)
  assert_equal(response, nil)
end

function tests.test_document_add_inline_attachment_no_content_type_returns_nil()
  local doc = new_with_default_server_params()
  local data = {}
  local response, response_code, headers, status = doc:add_inline_attachment(custom_loader_file_path, nil, nil, data, document_id, document_rev)
  assert_equal(response, nil)
end

function tests.test_document_retrieve_attachment_returns_success()
  local doc = new_with_default_server_params()
  local response, response_code, headers, status = doc:retrieve_attachment(custom_loader_default_file_name, document_id)
  assert_equal(response, custom_loader_file_data)
end

function tests.test_document_retrieve_attachment_no_attachment_name_returns_nil()
  local doc = new_with_default_server_params()
  local response, response_code, headers, status = doc:retrieve_attachment(nil, document_id)
  assert_equal(response, nil)
end

function tests.test_document_retrieve_attachment_no_id_returns_nil()
  local doc = new_with_default_server_params()
  local response, response_code, headers, status = doc:retrieve_attachment(custom_loader_default_file_name, nil)
  assert_equal(response, nil)
end

function tests.test_document_delete_attachment_returns_success()
  local doc = new_with_default_server_params()
  local response, response_code, headers, status = doc:delete_attachment(custom_loader_default_file_name, document_id, document_rev)
  assert_table(response)
  assert_equal(response.ok, true)
end

function tests.test_document_delete_attachment_no_attachment_name_returns_nil()
  local doc = new_with_default_server_params()
  local response, response_code, headers, status = doc:delete_attachment(nil, document_id, document_rev)
  assert_equal(response, nil)
end

function tests.test_document_delete_attachment_no_id_returns_nil()
  local doc = new_with_default_server_params()
  local response, response_code, headers, status = doc:delete_attachment(custom_loader_default_file_name, nil, document_rev)
  assert_equal(response, nil)
end

function tests.test_document_delete_attachment_no_rev_returns_nil()
  local doc = new_with_default_server_params()
  local response, response_code, headers, status = doc:delete_attachment(custom_loader_default_file_name, document_id, nil)
  assert_equal(response, nil)
end

function tests.test_response_ok_with_ok_response_returns_true()
  local doc = new_with_default_server_params()
  local response = {ok = true}
  local bool = doc:response_ok(response)
  assert_equal(bool, true)
end

function tests.test_response_ok_with_not_ok_response_returns_false()
  local doc = new_with_default_server_params()
  local response = {ok = false}
  local bool = doc:response_ok(response)
  assert_equal(bool, false)
end

return tests

