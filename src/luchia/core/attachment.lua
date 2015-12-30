--- core attachment handler class.
--
-- implements the methods necessary to handle attachments. note that for most
-- cases, the attachment handling methods in @{luchia.document} should be used;
-- this module provides the core functionality that those higher-level methods
-- use.
--
-- see the @{core.attachment.lua} example for more detail.
--
-- @module luchia.core.attachment
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips

require "luchia.conf"

local mime = require "mime"
local string = require "string"
local io = require "io"
local logger = require "luchia.core.log"
local log = logger.logger

local setmetatable = setmetatable


local _M = {}

--- Creates a new core attachment handler.
--
-- In order to add an attachment to a document, an attachment object must be
-- created, then attached to the document, as seen in
-- @{luchia.core.document:add_attachment},
-- @{luchia.document:add_standalone_attachment},
-- and @{luchia.document:add_inline_attachment}.
--
-- In order to send a standalone attachment via the core server methods, an
-- attachment object must be created, and passed to the 'data' parameter of
-- @{luchia.core.server:request}.
--
-- @param params
--   Required. A table with the metadata necessary to create a new attachment
--   object.
-- @param params.file_path
--   Required. The path to the file to add as an attachment. Relative paths
--   can be used, but must have a path component, eg. "./myfile" or
--   "/tmp/attachment.txt".
-- @param params.content_type
--   Required. The mime content type of the attachment, eg. "text/plain".
-- @param params.file_name
--   Optional. The name of the attachment as stored in couchdb. If not
--   provided, then the base name of file_path will be used.
-- @param params.custom_loader_function
--   Optional. By default, files are loaded via the @{load_file} method in this
--   class. Use this to specify an alternate loader function.
-- @return A new attachment object.
-- @usage attachment = luchia.core.attachment:new(params)
function _M.new(self, params)
  local params = params or {}
  if not params.file_path then
    log:error([[file_path is required]])
  elseif not params.content_type then
    log:error([[content_type is required]])
  else
    local attachment = {}
    attachment.file_path = params.file_path
    attachment.content_type = params.content_type
    if params.file_name then
      attachment.file_name = params.file_name
    else
      -- Grab filename from the full path.
      attachment.file_name = string.match(attachment.file_path, ".+/([^/%s]+)$")
    end
    if attachment.file_name then
      attachment.loader = params.custom_loader_function or _M.load_file
      local file_data = attachment.loader(attachment)
      if file_data then
        attachment.file_data = file_data
        setmetatable(attachment, self)
        self.__index = self
        log:debug(string.format([[New core attachment handler, file_path: %s, content_type: %s, file_name: %s]], attachment.file_path, attachment.content_type, attachment.file_name))
        return attachment
      end
    else
      log:error([[Illegal file path]])
    end
  end
end

--- Base64 encode the attachment file data.
--
-- @return The encoded data.
-- @usage encoded_data = attachment:base64_encode_file()
function _M:base64_encode_file()
  if self.file_data then
    local base64_data = mime.b64(self.file_data)
    log:debug(string.format([[Base64 encoded file ' %s']], self.file_path))
    return base64_data
  end
end

--- Load the attachment file data.
--
-- @return The file data.
-- @usage data = attachment:load_file()
function _M:load_file()
  local file = io.open(self.file_path)
  if file then
    log:debug(string.format([[Loaded file '%s']], self.file_path))
    local data = file:read("*a")
    io.close(file)
    return data
  else
    log:error(string.format([[Unable to open file '%s']], self.file_path))
  end
end

--- Prepare attachment for a server request.
--
-- This method is called by @{luchia.core.server:prepare_request_data} to allow
-- the attachment object to properly prepare the data for a server request.
--
-- @param server
--   Required. The server object to prepare the request for.
-- @usage attachment:prepare_request_data(server)
function _M:prepare_request_data(server)
  log:debug([[Preparing attachment request data]])
  server.content_type = self.content_type
  server.request_data = self.file_data
end

return _M
