--[[
  Quick example of retrieving inline attachments.
]]

local luchia = require "luchia"

local log = luchia.log
local server = luchia.server
local document = luchia.document
local attachment = luchia.attachment

log:debug("Attaching file to new document...")

-- Grab a server object using the default connection configuration.
local srv = server:new()

-- Build the attachment.
local params = {
  file_name = "attachment.wav",
  file_path = "/tmp/attachment.wav",
  content_type = "audio/x-wav",
}
local att = attachment:new(params)

-- Create the document.
params = {
  document = {
    title = "Test attachment",
  },
}
local doc = document:new(params)

-- Attach the attachment.
if doc:add_attachment(att) then
  -- Build up the request parameters.
  params = {
    method = "POST",
    path = "example",
    data = doc.data,
  }
  -- Execute the request.
  local response = srv:request(params)
end

