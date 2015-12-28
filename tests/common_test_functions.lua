--- Common testing functions.

local io = require "io"
local os = require "os"
local string = require "string"
local url = require "socket.url"

local pairs = pairs
local require = require
local tonumber = tonumber
local type = type

local lunatest = require "lunatest"
local assert_table = lunatest.assert_table
local assert_equal = lunatest.assert_equal
local assert_match = lunatest.assert_match
local assert_gte = lunatest.assert_gte
local assert_lte = lunatest.assert_lte

local file1_path
local server = require "luchia.core.server"
local attachment = require "luchia.core.attachment"

local _M = {}

-- Mock server values.
_M.server_good_protocol = "http"
_M.server_good_host = "www.example.com"
_M.server_good_port = "5984"
_M.server_user = "user"
_M.server_password = "password"

_M.server_response_code_ok = "200"
_M.server_response_code_not_found = "404"
_M.server_response_code_service_error = "error"
_M.server_status_ok = "HTTP/1.1 200 OK"
_M.server_status_not_found = "HTTP/1.1 404 Object Not Found"

_M.server_content_type = "application/json"
_M.server_json_good = '{"foo":"bar"}'
_M.server_json_good_key = "foo"
_M.server_json_good_value = "bar"
_M.server_json_bad = 'foo'

_M.server_uuid1 = "1c10da9e7736fc84bbb380fd1f002554"
_M.server_uuid2 = "1c10da9e7736fc84bbb380fd1f0026b8"

_M.server_example_database = "example"
_M.server_example_document_id = "example"
_M.server_example_document_rev = "1-b14c811bf485b30b70aab77810769d00"

_M.server_valid_server_table = function (srv)
  assert_table(srv, "srv")
  assert_table(srv.connection, "srv.connection")
  assert_equal(2, _M.table_length(srv), "srv length")
end

_M.server_custom_request_server = function (params)
  params = params or {
    protocol = _M.server_good_protocol,
    host = _M.server_good_host,
    port = _M.server_good_port,
  }
  params.custom_request_function = _M.server_request
  local srv = server:new(params)
  _M.server_valid_server_table(srv)
  return srv
end

_M.server_request = function(request)
  local url_string = string.format([[%s://%s:%s]], _M.server_good_protocol, _M.server_good_host, _M.server_good_port)
  local response = 1
  local response_data = ""
  local response_code = _M.server_response_code_ok
  local headers = request.headers
  local status = _M.server_status_ok

  local uuids = url_string .. "/_uuids?"
  local uuids_with_count = url_string .. "/_uuids?count=2"
  local uuids_bad = url_string .. "/_uuids?count=bad"
  local service_error = url_string .. "/service-error?"
  local not_found = url_string .. "/not-found?"
  local valid_document_response = url_string .. "/valid-document?"
  local database_list = url_string .. "/_all_dbs?"
  local database_name = url_string .. "/" .. _M.server_example_database .. "?"
  local document_list = url_string .. "/" .. _M.server_example_database .. "/_all_docs?"
  local document_list_limit = url_string .. "/" .. _M.server_example_database .. "/_all_docs?limit=3"
  local document_retrieve = url_string .. "/" .. _M.server_example_database .. "/" .. _M.server_example_document_id .. "?"
  local document_retrieve_limit = url_string .. "/" .. _M.server_example_database .. "/" .. _M.server_example_document_id .. "?limit=3"
  local document_create_new = url_string .. "/" .. _M.server_example_database .. "/" .. _M.server_uuid1 .. "?"
  local document_create_with_id = url_string .. "/" .. _M.server_example_database .. "/" .. _M.server_uuid2 .. "?"
  local document_copy = url_string .. "/" .. _M.server_example_database .. "/" .. _M.server_example_document_id .. "?"
  local document_delete = url_string .. "/" .. _M.server_example_database .. "/" .. _M.server_example_document_id .. "?rev=" .. url.escape(_M.server_example_document_rev)
  local add_standalone_attachment = url_string .. "/" .. _M.server_example_database .. "/" .. _M.server_example_document_id .. "/" .. _M.attachment.custom_loader_default_file_name .. "?rev=" .. url.escape(_M.server_example_document_rev)
  local add_standalone_attachment_no_id_no_rev = url_string .. "/" .. _M.server_example_database .. "/" .. _M.attachment.custom_loader_default_file_name .. "/" .. _M.attachment.custom_loader_default_file_name .. "?"
  local add_standalone_attachment_custom_file_name = url_string .. "/" .. _M.server_example_database .. "/" .. _M.server_example_document_id .. "/" .. _M.attachment.custom_file_name .. "?rev=" .. url.escape(_M.server_example_document_rev)

  if request.method == "GET" then
    if request.url == uuids then
      response_data = '{"uuids":["' .. _M.server_uuid1 .. '"]}'
    elseif request.url == uuids_with_count then
      response_data = '{"uuids":["' .. _M.server_uuid1 .. '","' .. _M.server_uuid2 .. '"]}'
    elseif request.url == uuids_bad then
      response_data = '{}'
    elseif request.url == service_error then
      response = nil
      response_code = _M.server_response_code_service_error
      headers = nil
      status = nil
      response_data = nil
    elseif request.url == not_found then
      response_code = _M.server_response_code_not_found
      status = _M.server_status_not_found
    elseif request.url == valid_document_response then
      response_data = _M.server_json_good
    elseif request.url == database_list then
      response_data = '["_users"]'
    elseif request.url == database_name then
      response_data = '{"db_name":"' .. _M.server_example_database .. '"}'
    elseif request.url == document_list or request.url == document_list_limit then
      response_data = '{"total_rows":0,"offset":0,"rows":[]}'
    elseif request.url == document_retrieve or request.url == document_retrieve_limit then
      response_data = '{"_id":"' .. _M.server_example_document .. '"}'
    end
  elseif request.method == "PUT" then
    if request.url == database_name then
      response_data = '{"ok":true}'
    end
    if request.url == document_create_new or request.url == document_create_with_id then
      response_data = '{"ok":true}'
    end
    if request.url == add_standalone_attachment or request.url == add_standalone_attachment_no_id_no_rev or request.url == add_standalone_attachment_custom_file_name then
      response_data = '{"ok":true}'
    end
  elseif request.method == "COPY" then
    if request.url == document_copy then
      response_data = '{"ok":true}'
    end
  elseif request.method == "DELETE" then
    if request.url == database_name then
      response_data = '{"ok":true}'
    end
    if request.url == document_delete then
      response_data = '{"ok":true}'
    end
  elseif request.method == "HEAD" then
    if request.url == document_retrieve then
      request.headers.etag = _M.server_example_document_rev
    end
  end

  if response_data then
    local source = ltn12.source.string(response_data)
    ltn12.pump.all(source, request.sink)
  end
  return response, response_code, headers, status
end

-- Attachment helpers.
_M.attachment = {}
_M.attachment.text_content_type = "text/plain"
_M.attachment.custom_file_name = "custom_textfile1.txt"
_M.attachment.bad_file = "badfile.txt"

_M.attachment.custom_loader_file_path = "/tmp/textfile1.txt"
_M.attachment.custom_loader_default_file_name = "textfile1.txt"
_M.attachment.custom_loader_file_data = "foo."

_M.attachment.custom_loader = function()
  return _M.attachment.custom_loader_file_data
end

_M.attachment.build_new_attachment = function(file_name)
  local params = {
    file_path = _M.attachment.custom_loader_file_path,
    content_type = _M.attachment.text_content_type,
    custom_loader_function = _M.attachment.custom_loader,
  }
  if file_name then
    params.file_name = file_name
  end
  local att = attachment:new(params)
  return att
end



function _M.create_file1()
  local file1_data = "foo"
  file1_path = os.tmpname()
  local file = io.open(file1_path, "w")
  file:write(file1_data)
  file:close()
  file = io.open(file1_path)
  local file_data = file:read("*a")
  file:close()
  return file1_path, file_data
end

function _M.remove_file1()
  if file1_path then
    os.remove(file1_path)
  end
end

function _M.table_length(t)
  if type(t) == "table" then
    local count = 0
    for _, _ in pairs(t)
      do count = count + 1
    end
    return count
  end
end

function _M.conf_valid_default_server_table()
  local conf = require "luchia.conf"
  assert_table(conf, "conf")
  assert_table(conf.default, "conf.default")
  assert_table(conf.default.server, "conf.default.server")
end

function _M.valid_server_protocol(protocol, field)
  assert_equal("http", protocol, field)
end

function _M.valid_server_host(host, field)
  -- TODO: Research RFC on valid hostnames.
  assert_match("^[%a%.-_]+$", host, field)
end

function _M.valid_server_port(port, field)
  port = tonumber(port)
  -- TODO: Research valid port numbers.
  assert_gte(1, port, field)
  assert_lte(65536, port, field)
end

function _M.conf_valid_log_table()
  local conf = require "luchia.conf"
  assert_table(conf, "conf")
  assert_table(conf.log, "conf.log")
end

return _M
