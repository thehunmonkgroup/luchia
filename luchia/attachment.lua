local mime = require "mime"
local string = require "string"
local log = luchia.log

local io = require "io"

local setmetatable = setmetatable

module(...)

function new(self, params)
  params = params or {}
  if params.file_path then
    self.file_path = params.file_path
    self.file_name = params.file_name or "attachment.txt"
    self.content_type = params.content_type or "text/plain"
    attachment = {}
    setmetatable(attachment, self)
    self.__index = self
    log:debug([[New attachment handler]])
    return attachment
  else
    log:error([[Required file path not provided for attachment]])
  end
end

function base64_encode_file(self, file_path)
  local file_data = self:load_file(file_path)
  if file_data then
    local base64_data = mime.b64(file_data)
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

