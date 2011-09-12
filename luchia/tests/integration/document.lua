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

function tests.test_create_retrieve()
  local response_data, response_code, headers, status = doc:create({[data_key] = data_value})
  assert_true(response_data.ok, "Unable to create document")
  assert_equal(response_code_created, response_code, "Document creation response_code is incorrect")
  assert_table(headers, "headers are incorrect")
  assert_equal(status_created, status, "status is incorrect")
  local data, code = doc:retrieve(response_data.id)
  assert_equal(response_data.id, data._id, "Document id mismatch")
  assert_equal(response_data.rev, data._rev, "Document rev mismatch")
  assert_equal(data_value, data[data_key], "Document data mismatch")
  assert_equal(response_code_ok, code, "Document retrieval response_code is incorrect")
end

return tests

