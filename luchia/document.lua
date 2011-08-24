local string = require "string"
local log = luchia.log

local type = type
local setmetatable = setmetatable

module(...)

function new(self, params)
  local params = params or {}
  local document = {}
  document._type = "document"
  document.id = params.id
  document.rev = params.rev
  document.document = params.document or {}
  document.document._id = document.id
  document.document._rev = document.rev
  setmetatable(document, self)
  self.__index = self
  log:debug([[New document handler]])
  return document
end

function add_attachment(self, attachment)
  local file_data = attachment:base64_encode_file(attachment.file_path)
  if file_data then
    self.document._attachments = self.document._attachments or {}
    self.document._attachments[attachment.file_name] = {
      ["content-type"] = attachment.content_type,
      data = file_data,
    }
    log:debug(string.format([[Added inline attachment: %s, content_type: %s]], attachment.file_name, attachment.content_type))
    return self.document
  end
end

