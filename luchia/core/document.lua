--- Core document handler class.
-- @author Chad Phillips
-- @copyright 2011 Chad Phillips

require "luchia.conf"

local json = require "cjson"
local string = require "string"
local log = require "luchia.core.log"

local setmetatable = setmetatable
local type = type

--- Core document handler class.
-- <p>Implements the methods necessary to handle documents. Note that for most
-- cases, the document handling methods in luchia.document should be used;
-- this module provides the core functionality that those higher-level methods
-- use.
-- See the method documentation for more detail, here is a quick primer:</p>
-- <p><code>
-- -- Require the class.<br />
-- local document = require "luchia.core.document"<br />
-- -- Build a new document object.<br />
-- local doc = document:new({<br />
-- &nbsp;&nbsp;id = "document-id",<br />
-- &nbsp;&nbsp;document = {<br />
-- &nbsp;&nbsp;&nbsp;&nbsp;hello = "world",<br />
-- &nbsp;&nbsp;},<br />
-- })<br />
-- -- Add an attachment.<br />
-- local response = doc:add_attachment(previously_created_attachment_object)
-- <br />
-- </p></code>
-- @see luchia.document
module("luchia.core.document")

--- Parameters table for creating new document objects.
-- This is the optional table to pass when calling the 'new' method to create
-- new document objects.
-- @field id Optional. The document ID. If provided, this is copied into the
--   document itself.
-- @field rev Optional. The document revision. If provided, this is copied
--   into the document itself.
-- @field document Optional. A table representing the document to be stored in
--   CouchDB. This table is converted to proper JSON format before being sent to
--   the database.
-- @class table
-- @name new_params
-- @see new

--- Creates a new core document handler.
-- In order to send a document via the core server methods, a document object
-- must be created, and passed to the 'data' parameter of
-- luchia.core.server:request().
-- @param params Optional. A table with the metadata necessary to create a new
--   document object.
-- @return A new document object.
-- @usage document = luchia.core.document:new(params)
-- @see new_params
function new(self, params)
  local params = params or {}
  local document = {}
  document.id = params.id
  document.rev = params.rev
  document.document = params.document or {}
  if document.rev and not document.id then
    log:error([[id required with rev]])
  else
    -- Copy id and rev into the document object.
    document.document._id = document.id
    document.document._rev = document.rev
    setmetatable(document, self)
    self.__index = self
    log:debug([[New core document handler]])
    return document
  end
end

--- Add an inline attachment to a document.
-- This method should not usually be called directly, instead use the
-- higher-level luchia.document:add_inline_attachment().
-- @param attachment The attachment object to add to the document, as generated
--   by luchia.core.attachment:new().
-- @return The document table with the attachment added. Note that this does
--   not return the full document object.
-- @usage document_table = document:add_attachment(attachment)
function add_attachment(self, attachment)
  if attachment and type(attachment.base64_encode_file) == "function" then
    local file_data = attachment:base64_encode_file()
    if file_data then
      -- Attachments are located under the special _attachments key of the
      -- document.
      self.document._attachments = self.document._attachments or {}
      self.document._attachments[attachment.file_name] = {
        ["content_type"] = attachment.content_type,
        data = file_data,
      }
      log:debug(string.format([[Added inline attachment: %s, content_type: %s]], attachment.file_name, attachment.content_type))
      return self.document
    else
      log:error(string.format([[Unable to encode file data for file: %s]], attachment.file_path or ""))
    end
  else
    log:error([[Invalid attachment object]])
  end
end

--- Prepare document for a server request.
-- This method is called by luchia.core.server:prepare_request_data() to allow
-- the document object to properly prepare the data for a server request.
-- @param server The server object to prepare the request for.
function prepare_request_data(self, server)
  log:debug([[Preparing document request data]])
  server.content_type = "application/json"
  server.request_data = json.encode(self.document)
end

