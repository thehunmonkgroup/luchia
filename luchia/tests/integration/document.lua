local database = require "luchia.database"
local document = require "luchia.document"

local tests = {}
local db
local database_name
local doc

local response_code_ok = 200
local response_code_created = 201
local status_ok = "HTTP/1.1 200 OK"
local status_created = "HTTP/1.1 201 Created"
local data_key = "foo"
local data_value = "bar"

function tests.setup()
 database_name = "test_" .. tostring(math.random(1000000))
 db = database:new()
 local resp = db:create(database_name)
 assert_true(db:response_ok(resp), "Unable to create database")
 doc = document:new(database_name)
 assert_table(doc, "Unable to create valid document handler")
end

function tests.teardown()
  local resp = db:delete(database_name)
  assert_true(db:response_ok(resp), "Unable to delete database")
end

function tests.test_new_document_returns_nil()
  local bad_doc = document:new()
  assert_equal(nil, bad_doc, "Document should not have been created without database name")
end

function tests.test_create_retrieve()
  local data = {
    [data_key] = data_value,
  }
  local response_data, response_code, headers, status = doc:create(data)
  assert_true(doc:response_ok(response_data), "Unable to create document")
  assert_equal(response_code_created, response_code, "Document creation response_code is incorrect")
  assert_table(headers, "headers are incorrect")
  assert_equal(status_created, status, "status is incorrect")
  local params = {
    rev = response_data.rev,
    revs = "true",
  }
  local data, code = doc:retrieve(response_data.id, params)
  assert_equal(response_data.id, data._id, "Document id mismatch")
  assert_equal(response_data.rev, data._rev, "Document rev mismatch")
  assert_equal(data_value, data[data_key], "Document data mismatch")
  assert_table(data._revisions, "revisions are missing")
  assert_equal(response_code_ok, code, "Document retrieval response_code is incorrect")
end

local function create_document()
  local resp = doc:create({[data_key] = data_value})
  assert_true(doc:response_ok(resp), "Unable to create document")
  return resp
end

function tests.test_list()
  create_document()
  local params = {
    include_docs = "true",
  }
  local data = doc:list(params)
  assert_table(data, "bad data returned from list method")
  assert_equal(1, data.total_rows, "total_rows value is incorrect")
  assert_table(data.rows[1].doc, "include_docs query_parameter failed")
end

function tests.test_update()
  local initial_doc = create_document()
  local updated_data_value = data_value .. "2"
  local data = {
    [data_key] = updated_data_value,
  }
  local updated_doc = doc:update(data, initial_doc.id, initial_doc.rev)
  assert_equal(initial_doc.id, updated_doc.id, "Document id mismatch")
  assert_not_equal(initial_doc.rev, updated_doc.rev, "Document rev was not updated")
  assert_equal(updated_data_value, data[data_key], "Document data not updated")
end

return tests

