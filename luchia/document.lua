local string = require "string"
local log = luchia.log

local setmetatable = setmetatable

module(...)

function new(self, params)
  local params = params or {}
  local document = {}
  document.data = params.data or {}
  setmetatable(document, self)
  self.__index = self
  log:debug([[New document handler]])
  return document
end

function add_attachment(self, attachment)
  local file_data = attachment:base64_encode_file(attachment.file_path)
  if file_data then
    self.data._attachments = self.data._attachments or {}
    self.data._attachments[attachment.file_name] = {
      ["content-type"] = attachment.content_type,
      data = file_data,
    }
    log:debug(string.format([[Added attachment: %s, content_type: %s]], attachment.file_name, attachment.content_type))
    return self.data
  end
end

