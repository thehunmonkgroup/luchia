local common = require "luchia.tests.common"
local attachment = require "luchia.core.attachment"

local tests = {}
local text_content_type, good_text_file, good_text_default_file_name
local good_text_custom_file_name, good_text_file_data, badfile

local function get_good_file(file_name)
  local att
  local params = {
    file_path = good_text_file,
    content_type = text_content_type,
  }
  if file_name then
    params.file_name = file_name
  end
  att = attachment:new(params)
  return att
end

local function compare_parameter(compare_to, key, file_name)
  local att = get_good_file(file_name)
  assert_equal(compare_to, att[key])
end

function tests.setup()
  good_text_file, good_text_default_file_name, good_text_file_data = common.create_file1()
  text_content_type = "text/plain"
  good_text_custom_file_name = "custom_textfile1.txt"
  badfile = "badfile.txt"
end

function tests.teardown()
  common.remove_file1()
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

function tests.test_core_attachment_new_good_file_file_path()
  compare_parameter(good_text_file, "file_path")
end

function tests.test_core_attachment_new_good_file_content_type()
  compare_parameter(text_content_type, "content_type")
end

function tests.test_core_attachment_new_good_file_default_file_name()
  compare_parameter(good_text_default_file_name, "file_name")
end

function tests.test_core_attachment_new_good_file_custom_file_name()
  compare_parameter(good_text_custom_file_name, "file_name", good_text_custom_file_name)
end

function tests.test_core_attachment_new_good_file_file_data()
  compare_parameter(good_text_file_data, "file_data")
end

function tests.test_core_attachment_load_file()
  local att = get_good_file()
  local file_data = att:load_file()
  assert_equal(good_text_file_data, file_data)
end

function tests.test_core_attachment_base64_encode_file()
  require "mime"
  local att = get_good_file()
  local base64_data = att:base64_encode_file()
  assert_equal(mime.b64(good_text_file_data), base64_data)
end

function tests.test_core_attachment_prepare_request()
  local server = {}
  local att = get_good_file()
  att:prepare_request(server)
  assert_equal(att.content_type, server.content_type)
  assert_equal(att.file_data, server.request_data)
end

return tests

