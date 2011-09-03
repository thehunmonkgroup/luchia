local document = require "luchia.core.document"

tests = {}

local id = "id"
local rev = "rev"
local doc_key = "key"
local doc_value = "value"
local content_type = "application/json"

local text_file_content_type, text_file_path, text_file_name, text_file_data

function tests.setup()
  luchia.test.create_files()
  text_file_content_type = "text/plain"
  text_file_path = luchia.temp.file1.file_path
  text_file_name = luchia.temp.file1.file_name
  text_file_data = luchia.temp.file1.file_data
end

function tests.teardown()
  luchia.test.remove_files()
end


function tests.test_core_document_new_no_params()
  local doc = document:new()
  assert_table(doc, "doc")
  assert_table(doc.document, "doc.document")
  assert_equal(1, luchia.test.table_length(doc), "doc length")
  assert_equal(0, luchia.test.table_length(doc.document), "doc.document length")
end

function tests.test_core_document_new_only_id_param()
  local params = {
    id = id,
  }
  local doc = document:new(params)
  assert_table(doc, "doc")
  assert_equal(id, doc.id, "doc.id")
  assert_table(doc.document, "doc.document")
  assert_equal(2, luchia.test.table_length(doc), "doc length")
  assert_equal(id, doc.document._id, "doc.document._id")
  assert_equal(1, luchia.test.table_length(doc.document), "doc.document length")
end

function tests.test_core_document_new_no_id_with_rev_param()
  local params = {
    rev = rev,
  }
  local doc = document:new(params)
  assert_equal(nil, doc, "rev when id nil")
end

function tests.test_core_document_new_only_document_param()
  local params = {
    document = {
      [doc_key] = doc_value,
    },
  }
  local doc = document:new(params)
  assert_table(doc, "doc")
  assert_table(doc.document, "doc.document")
  assert_equal(1, luchia.test.table_length(doc), "doc length")
  assert_equal(doc_value, doc.document[doc_key], "doc.document key/value")
  assert_equal(1, luchia.test.table_length(doc.document), "doc.document length")
end

function tests.test_core_document_new_all_params()
  local params = {
    id = id,
    rev = rev,
    document = {
      [doc_key] = doc_value,
    },
  }
  local doc = document:new(params)
  assert_table(doc, "doc")
  assert_equal(id, doc.id, "doc.id")
  assert_equal(rev, doc.rev, "doc.rev")
  assert_table(doc.document, "doc.document")
  assert_equal(3, luchia.test.table_length(doc), "doc length")
  assert_equal(id, doc.document._id, "doc.document._id")
  assert_equal(rev, doc.document._rev, "doc.document._rev")
  assert_equal(doc_value, doc.document[doc_key], "doc.document key/value")
  assert_equal(3, luchia.test.table_length(doc.document), "doc.document length")
end

function tests.test_core_document_add_attachment_valid_att()
  local mime = require "mime"
  local attachment = require "luchia.core.attachment"
  local doc = document:new()
  local params = {
    file_path = text_file_path,
    content_type = text_file_content_type,
    file_name = text_file_name,
  }
  local att = attachment:new(params)
  local return_document = doc:add_attachment(att)
  assert_table(doc, "doc")
  assert_table(doc.document, "doc.document")
  assert_equal(1, luchia.test.table_length(doc), "doc length")
  assert_table(doc.document._attachments, "doc.document._attachments")
  assert_equal(1, luchia.test.table_length(doc.document), "doc.document length")
  assert_table(doc.document._attachments[text_file_name], "doc.document._attachments[text_file_name]")
  assert_equal(1, luchia.test.table_length(doc.document._attachments), "doc.document._attachments length")
  assert_equal(text_file_content_type, doc.document._attachments[text_file_name].content_type, "doc.document._attachments[text_file_name].content_type")
  assert_equal(mime.b64(text_file_data), doc.document._attachments[text_file_name].data, "doc.document._attachments[text_file_name].data")
  assert_equal(2, luchia.test.table_length(doc.document._attachments[text_file_name]), "doc.document._attachments[text_file_name] length")
  assert_equal(doc.document, return_document, "return doc.document")
end

function tests.test_core_document_add_attachment_invalid_att()
  local doc = document:new()
  local return_document = doc:add_attachment({})
  assert_table(doc, "doc")
  assert_table(doc.document, "doc.document")
  assert_equal(1, luchia.test.table_length(doc), "doc length")
  assert_equal(0, luchia.test.table_length(doc.document), "doc.document length")
  assert_equal(nil, return_document, "return doc.document")
end

function tests.test_core_document_prepare_request()
  local json = require "cjson"
  local server = {}
  local params = {
    id = id,
    rev = rev,
    document = {
      [doc_key] = doc_value,
    },
  }
  local doc = document:new(params)
  doc:prepare_request(server)
  assert_equal(content_type, server.content_type, "server.content_type")
  assert_equal(json.encode(doc.document), server.request_data, "server.request_data")
end


return tests

