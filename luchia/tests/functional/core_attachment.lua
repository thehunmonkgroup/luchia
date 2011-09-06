local common = require "luchia.tests.common"
local attachment = require "luchia.core.attachment"

local tests = {}

local text_content_type = "text/plain"
local custom_file_name = "custom_textfile1.txt"
local badfile = "badfile.txt"

local function build_new_attachment(file_name)
  local file_path, default_file_name, file_data = common.create_file1()
  local params = {
    file_path = file_path,
    content_type = text_content_type,
  }
  if file_name then
    params.file_name = file_name
  end
  local att = attachment:new(params)
  common.remove_file1()
  return att, file_path, default_file_name, file_data
end

function tests.test_core_attachment_new_no_params()
  local att = attachment:new()
  assert_equal(nil, att, "No file_path, content_type params passed.")
end

function tests.test_core_attachment_new_missing_file_path()
  local att = attachment:new({content_type = text_content_type})
  assert_equal(nil, att, "No file_path param passed.")
end

function tests.test_core_attachment_new_missing_content_type()
  local att = attachment:new({file_path = good_text_file})
  assert_equal(nil, att, "No content_type param passed.")
end

function tests.test_core_attachment_new_bad_file_path()
  local att = attachment:new({file_path = badfile, content_type = text_content_type})
  assert_equal(nil, att, "Bad file_path param passed.")
end

function tests.test_core_attachment_new_bad_file_path()
  local att = attachment:new({file_path = "./" .. badfile, content_type = text_content_type})
  assert_equal(nil, att, "Non-existent file passed.")
end

function tests.test_core_attachment_new_good_params()
  local att, file_path, default_file_name, file_data = build_new_attachment()
  assert_equal(file_path, att.file_path, "file_path")
  assert_equal(text_content_type, att.content_type, "content_type")
  assert_equal(default_file_name, att.file_name, "default file_name")
  assert_equal(file_data, att.file_data, "file_data")
end

function tests.test_core_attachment_new_good_params_custom_file_name()
  local att, file_path, default_file_name, file_data = build_new_attachment(custom_file_name)
  assert_equal(file_path, att.file_path, "file_path")
  assert_equal(text_content_type, att.content_type, "content_type")
  assert_equal(custom_file_name, att.file_name, "custom file_name")
  assert_equal(file_data, att.file_data, "file_data")
end

function tests.test_core_attachment_load_file()
  local file_path, default_file_name, file_data = common.create_file1()
  local params = {
    file_path = file_path,
    content_type = text_content_type,
  }
  local att = attachment:new(params)
  local loaded_file_data = att:load_file()
  common.remove_file1()
  assert_equal(file_data, loaded_file_data, "loaded file_data")
end

function tests.test_core_attachment_base64_encode_file()
  require "mime"
  local att, file_path, default_file_name, file_data = build_new_attachment()
  local base64_data = att:base64_encode_file()
  assert_equal(mime.b64(file_data), base64_data)
end

function tests.test_core_attachment_prepare_request_content_type()
  local server = {}
  local att = build_new_attachment()
  att:prepare_request(server)
  assert_equal(att.content_type, server.content_type)
end

function tests.test_core_attachment_prepare_request_request_data()
  local server = {}
  local att = build_new_attachment()
  att:prepare_request(server)
  assert_equal(att.file_data, server.request_data)
end

return tests

