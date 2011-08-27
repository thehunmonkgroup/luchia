require "luchia.conf"

local mime = require "mime"
local string = require "string"
local io = require "io"
local log = require "luchia.core.log"

local setmetatable = setmetatable

module(...)

function new(self, params)
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
      attachment.file_name = string.match(attachment.file_path, ".+/([^/]+)$")
    end
    if attachment.file_name then
      local file_data = load_file(attachment, attachment.file_path)
      if file_data then
        attachment.file_data = file_data
      end
      setmetatable(attachment, self)
      self.__index = self
      log:debug(string.format([[New core attachment handler, file_path: %s, content_type: %s, file_name: %s]], attachment.file_path, attachment.content_type, attachment.file_name))
      return attachment
    else
      log:error([[Illegal file path]])
    end
  end
end

function base64_encode_file(self, file_path)
  if self.file_data then
    local base64_data = mime.b64(self.file_data)
    log:debug(string.format([[Base64 encoded file ' %s']], file_path))
    return base64_data
  end
end

function load_file(self, file_path)
  local file = io.open(file_path)
  if file then
    local data = file:read("*a")
    if data then
      log:debug(string.format([[Loaded file '%s']], file_path))
      return data
    else
      log:error(string.format([[Unable to read file '%s']], file_path))
    end
    io.close(file)
  else
    log:error(string.format([[Unable to open file '%s']], file_path))
  end
end

function prepare_request(self, server)
  log:debug([[Preparing attachment request data]])
  server.content_type = self.content_type
  server.request_data = self.file_data
end
