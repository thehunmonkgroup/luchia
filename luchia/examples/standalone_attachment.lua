--[[
  Quick example of adding a new standalone attachment.
]]

local luchia = require "luchia"

local log = luchia.log
local server = luchia.server
local attachment = luchia.attachment

log:debug("Adding a standalone attachment...")

-- Grab a server object using the default connection configuration.
local srv = server:new()

-- Build the attachment.
local params = {
  file_name = "attachment.wav",
  file_path = "/tmp/attachment.wav",
  content_type = "audio/x-wav",
}
local att = attachment:new(params)

-- Build up the request parameters.
params = {
  method = "PUT",
  path = "example/standalone_attachment/attachment.wav",
  data = att,
}
-- Execute the request.
local response = srv:request(params)

