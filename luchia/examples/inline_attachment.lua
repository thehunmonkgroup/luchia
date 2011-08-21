--[[
  Quick example of retrieving inline attachments.
]]

local luchia = require "luchia"

local log = luchia.log
local server = luchia.server
local request = luchia.request
local attachment = luchia.attachment

log:debug("Attaching file to new document...")

-- Grab a server object using the default connection configuration.
local srv = server:new()

local params = {
  file_name = "attachment.wav",
  file_path = "/tmp/attachment.wav",
  content_type = "audio/x-wav",
}
local att = attachment:new(params)

local document = {
  title = "Test attachment",
}
local document_with_attachment = att:add(document)

if document_with_attachment then
  -- Build up the request parameters.
  params = {
    method = "POST",
    path = "example/",
    data = document_with_attachment,
  }
  -- Grab a request object using the server object for communication.
  local req = request:new(srv, params)
  -- Execute the request.
  local response = req:execute()
end

