local lunatest = require "lunatest"
local assert_equal = lunatest.assert_equal

local common = require "common_test_functions"
local attachment = require "luchia.core.attachment"

local tests = {}

local text_content_type = common.attachment.text_content_type
local custom_file_name = common.attachment.custom_file_name
local bad_file = common.attachment.bad_file

local custom_loader_file_path = common.attachment.custom_loader_file_path
local custom_loader_default_file_name = common.attachment.custom_loader_default_file_name
local custom_loader_file_data = common.attachment.custom_loader_file_data

local custom_loader_function = common.attachment.custom_loader
local build_new_attachment = common.attachment.build_new_attachment

function tests.test_new_no_params_returns_nil()
  local att = attachment:new()
  assert_equal(nil, att)
end

function tests.test_new_missing_file_path_returns_nil()
  local att = attachment:new({content_type = text_content_type})
  assert_equal(nil, att)
end

function tests.test_new_missing_content_type_returns_nil()
  local att = attachment:new({file_path = custom_loader_file_path})
  assert_equal(nil, att)
end

function tests.test_new_bad_file_path_returns_nil()
  local att = attachment:new({file_path = bad_file, content_type = text_content_type})
  assert_equal(nil, att)
end

function tests.test_new_non_existent_file_returns_nil()
  local bad_file_path = common.create_file1()
  -- Remove the file before trying to load.
  common.remove_file1()
  local att = attachment:new({file_path = bad_file_path, content_type = text_content_type})
  assert_equal(nil, att)
end

function tests.test_new_good_params_default_file_name_returns_valid_file_path()
  local att = build_new_attachment()
  assert_equal(custom_loader_file_path, att.file_path)
end

function tests.test_new_good_params_default_file_name_returns_valid_content_type()
  local att = build_new_attachment()
  assert_equal(text_content_type, att.content_type)
end

function tests.test_new_good_params_default_file_name_returns_valid_default_file_name()
  local att = build_new_attachment()
  assert_equal(custom_loader_default_file_name, att.file_name)
end

function tests.test_new_good_params_default_file_name_returns_valid_file_data()
  local att = build_new_attachment()
  assert_equal(custom_loader_file_data, att.file_data)
end

function tests.test_new_good_params_custom_file_name_returns_valid_file_path()
  local att = build_new_attachment(custom_file_name)
  assert_equal(custom_loader_file_path, att.file_path)
end

function tests.test_new_good_params_custom_file_name_returns_valid_content_type()
  local att = build_new_attachment(custom_file_name)
  assert_equal(text_content_type, att.content_type)
end

function tests.test_new_good_params_custom_file_name_returns_valid_custom_file_name()
  local att = build_new_attachment(custom_file_name)
  assert_equal(custom_file_name, att.file_name)
end

function tests.test_new_good_params_custom_file_name_returns_valid_file_data()
  local att = build_new_attachment(custom_file_name)
  assert_equal(custom_loader_file_data, att.file_data)
end

function tests.test_new_good_params_custom_loader_function_returns_custom_loader_function()
  local att = build_new_attachment()
  assert_equal(custom_loader_function, att.loader)
end

function tests.test_new_good_params_default_loader_function_returns_default_loader_function()
  local file_path = common.create_file1()
  local params = {
    file_path = file_path,
    content_type = text_content_type,
  }
  local att = attachment:new(params)
  common.remove_file1()
  assert_equal(att.load_file, att.loader)
end

function tests.test_load_file_valid_file_returns_valid_file_data()
  local file_path, file_data = common.create_file1()
  local params = {
    file_path = file_path,
    content_type = text_content_type,
  }
  local att = attachment:new(params)
  local loaded_file_data = att:load_file()
  common.remove_file1()
  assert_equal(file_data, loaded_file_data)
end

function tests.test_load_file_missing_file_returns_nil()
  local file_path = common.create_file1()
  local params = {
    file_path = file_path,
    content_type = text_content_type,
  }
  local att = attachment:new(params)
  -- Remove the file before trying to load.
  common.remove_file1()
  local loaded_file_data = att:load_file()
  assert_equal(nil, loaded_file_data)
end

function tests.test_core_attachment_base64_encode_file()
  local mime = require "mime"
  local att = build_new_attachment()
  local base64_data = att:base64_encode_file()
  assert_equal(mime.b64(custom_loader_file_data), base64_data)
end

function tests.test_core_attachment_prepare_request_data_content_type()
  local server = {}
  local att = build_new_attachment()
  att:prepare_request_data(server)
  assert_equal(att.content_type, server.content_type)
end

function tests.test_core_attachment_prepare_request_data_request_data()
  local server = {}
  local att = build_new_attachment()
  att:prepare_request_data(server)
  assert_equal(att.file_data, server.request_data)
end

return tests

